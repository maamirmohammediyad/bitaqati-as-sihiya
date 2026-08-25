<?php

declare(strict_types=1);

namespace App\Mail;

use App\Domain\Models\Hospital;
use App\Domain\Models\User;
use Illuminate\Bus\Queueable;
use Illuminate\Mail\Mailable;
use Illuminate\Queue\SerializesModels;

class HospitalAdminCredentialsMail extends Mailable
{
    use Queueable;
    use SerializesModels;

    public function __construct(
        public User $user,
        public Hospital $hospital,
        public string $temporaryPassword,
    ) {
    }

    public function build(): self
    {
        return $this
            ->subject('تمت إضافتك مديرًا لمستشفى في بطاقة الصحة')
            ->view('emails.hospital-admin-credentials');
    }
}