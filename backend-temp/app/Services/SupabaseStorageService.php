<?php

declare(strict_types=1);

namespace App\Services;

use Illuminate\Http\Client\RequestException;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

class SupabaseStorageService
{
    private string $projectUrl;

    private string $serviceKey;

    private string $defaultBucket;

    public function __construct()
    {
        $this->projectUrl = rtrim(config('services.supabase.url'), '/');
        $this->serviceKey = config('services.supabase.service_key');
        $this->defaultBucket = config('health.supabase_buckets.medical_files', 'medical-files');
    }

    public function upload(string $filePath, string $fileName, ?string $bucket = null): ?string
    {
        $bucket = $bucket ?? $this->defaultBucket;

        try {
            $fileContent = file_get_contents($filePath);

            if ($fileContent === false) {
                throw new \RuntimeException("Cannot read file: {$filePath}");
            }

            $response = Http::withHeaders([
                'Authorization' => 'Bearer ' . $this->serviceKey,
                'Content-Type' => 'application/octet-stream',
            ])->post("{$this->projectUrl}/storage/v1/object/{$bucket}/{$fileName}", $fileContent);

            if ($response->successful()) {
                $path = "{$bucket}/{$fileName}";

                Log::info('File uploaded to Supabase Storage', ['path' => $path]);

                return $path;
            }

            Log::error('Supabase upload failed', [
                'status' => $response->status(),
                'body' => $response->body(),
            ]);

            return null;
        } catch (\Throwable $e) {
            Log::error('Supabase upload exception: ' . $e->getMessage());

            return null;
        }
    }

    public function download(string $path): ?string
    {
        try {
            $response = Http::withHeaders([
                'Authorization' => 'Bearer ' . $this->serviceKey,
            ])->get("{$this->projectUrl}/storage/v1/object/{$path}");

            if ($response->successful()) {
                return $response->body();
            }

            Log::error('Supabase download failed', [
                'path' => $path,
                'status' => $response->status(),
            ]);

            return null;
        } catch (\Throwable $e) {
            Log::error('Supabase download exception: ' . $e->getMessage());

            return null;
        }
    }

    public function delete(string $path): bool
    {
        try {
            $response = Http::withHeaders([
                'Authorization' => 'Bearer ' . $this->serviceKey,
            ])->delete("{$this->projectUrl}/storage/v1/object/{$path}");

            if ($response->successful()) {
                Log::info('File deleted from Supabase Storage', ['path' => $path]);

                return true;
            }

            Log::error('Supabase delete failed', [
                'path' => $path,
                'status' => $response->status(),
            ]);

            return false;
        } catch (\Throwable $e) {
            Log::error('Supabase delete exception: ' . $e->getMessage());

            return false;
        }
    }

    public function getPublicUrl(string $path): string
    {
        return "{$this->projectUrl}/storage/v1/object/public/{$path}";
    }
}
