<?php

declare(strict_types=1);

namespace App\Services;

use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

class FCMService
{
    private string $serverKey;

    private string $baseUrl;

    public function __construct()
    {
        $this->serverKey = config('services.fcm.server_key');
        $this->baseUrl = 'https://fcm.googleapis.com/fcm/send';
    }

    public function sendToDevice(string $deviceToken, array $data, ?string $title = null, ?string $body = null): bool
    {
        $payload = [
            'to' => $deviceToken,
            'notification' => [
                'title' => $title,
                'body' => $body,
                'sound' => 'default',
            ],
            'data' => $data,
            'priority' => 'high',
        ];

        return $this->send($payload);
    }

    public function sendToTopic(string $topic, array $data, ?string $title = null, ?string $body = null): bool
    {
        $payload = [
            'to' => '/topics/' . $topic,
            'notification' => [
                'title' => $title,
                'body' => $body,
                'sound' => 'default',
            ],
            'data' => $data,
        ];

        return $this->send($payload);
    }

    public function sendToMultipleDevices(array $deviceTokens, array $data, ?string $title = null, ?string $body = null): bool
    {
        $payload = [
            'registration_ids' => $deviceTokens,
            'notification' => [
                'title' => $title,
                'body' => $body,
                'sound' => 'default',
            ],
            'data' => $data,
            'priority' => 'high',
        ];

        return $this->send($payload);
    }

    private function send(array $payload): bool
    {
        if (empty($this->serverKey)) {
            Log::warning('FCM server key not configured');

            return false;
        }

        try {
            $response = Http::withHeaders([
                'Authorization' => 'key=' . $this->serverKey,
                'Content-Type' => 'application/json',
            ])->post($this->baseUrl, $payload);

            if ($response->successful()) {
                return true;
            }

            Log::error('FCM send failed', [
                'status' => $response->status(),
                'body' => $response->body(),
            ]);

            return false;
        } catch (\Throwable $e) {
            Log::error('FCM exception: ' . $e->getMessage());

            return false;
        }
    }
}

