<?php

declare(strict_types=1);

namespace App\Domain\Actions\Emergency;

use App\Domain\Models\EmergencyEvent;
use App\Domain\Models\User;
use App\Services\AuditLogService;
use App\Services\FCMService;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Http;

class TriggerSosAction
{
    public function __construct(
        private readonly FCMService $fcmService,
        private readonly AuditLogService $auditLogService,
    ) {}

    public function execute(string $userId, array $data): EmergencyEvent
    {
        return DB::transaction(function () use ($userId, $data): EmergencyEvent {
$existingEvent = EmergencyEvent::query()
    ->where('user_id', $userId)
    ->whereIn('status', ['active', 'checked_in'])
    ->latest('created_at')
    ->first();

if ($existingEvent !== null) {
    return $existingEvent;
}
            $latitude  = $data['latitude'] ?? null;
            $longitude = $data['longitude'] ?? null;

            $locationName = null;

            // فقط لو الإحداثيات موجودة نحاول نجيب عنوان مقروء
            if ($latitude !== null && $longitude !== null) {
                try {
                    $response = Http::timeout(5)->get('https://eu1.locationiq.com/v1/reverse', [
                        'key'    => env('LOCATIONIQ_API_KEY'),
                        'lat'    => (float) $latitude,
                        'lon'    => (float) $longitude,
                        'format' => 'json',
                        // لغة العنوان: ar أو en
                        'accept-language' => 'ar',
                    ]);

                    if ($response->successful()) {
                        $json = $response->json();

                        if (isset($json['display_name'])) {
                            $locationName = $json['display_name'];
                        } elseif (isset($json['address'])) {
                            $address = $json['address'];

                            $parts = [
                                $address['road']    ?? null,
                                $address['city']    ?? null,
                                $address['state']   ?? null,
                                $address['country'] ?? null,
                            ];

                            $locationName = implode(', ', array_filter($parts));
                        }
                    }
                } catch (\Throwable $e) {
                    // لا نعطّل نداء الاستغاثة لو فشل geocoding
                    report($e);
                    $locationName = null;
                }
            }

            // هنا ننشئ الحدث مع location_name المحسوب
            $event = EmergencyEvent::create([
                'user_id'       => $userId,
                'status'        => 'active',
                'latitude'      => $latitude,
                'longitude'     => $longitude,
                'location_name' => $locationName,
            ]);

            $user = User::with('guardians.deviceTokens')->findOrFail($userId);

            $guardianTokens     = [];
            $notifiedGuardians  = [];

            foreach ($user->guardians as $guardian) {
                if ($guardian->pivot->is_verified && $guardian->pivot->can_access_location) {
                    $notifiedGuardians[] = [
                        'guardian_id'   => $guardian->id,
                        'guardian_name' => $guardian->name,
                        'guardian_phone'=> $guardian->phone,
                        'notified_at'   => now()->toIso8601String(),
                    ];

                    foreach ($guardian->deviceTokens as $deviceToken) {
                        if ($deviceToken->is_active) {
                            $guardianTokens[] = $deviceToken->device_token;
                        }
                    }
                }
            }

            if (! empty($guardianTokens)) {
                $this->fcmService->sendToMultipleDevices(
                    deviceTokens: $guardianTokens,
                    data: [
                        'type'          => 'sos_alert',
                        'event_id'      => $event->id,
                        'user_id'       => $userId,
                        'user_name'     => $user->name,
                        'latitude'      => (string) $event->latitude,
                        'longitude'     => (string) $event->longitude,
                        'location_name' => $event->location_name ?? '',
                        'timestamp'     => $event->created_at->toIso8601String(),
                    ],
                    title: '🚨 SOS Emergency Alert',
                    body: $user->name . ' has triggered an SOS emergency!',
                );
            }

            $event->update([
                'notified_guardians' => $notifiedGuardians,
            ]);

            $this->auditLogService->logSosTrigger($userId, $event->id);

            return $event->fresh();

        });
    }
}