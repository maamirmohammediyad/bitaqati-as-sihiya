<?php

namespace App\Mail;

use Illuminate\Bus\Queueable;
use Illuminate\Mail\Mailable;
use Illuminate\Queue\SerializesModels;

class HospitalStaffCredentialsMail extends Mailable
{
    use Queueable, SerializesModels;

    public function __construct(
        public string $name,
        public string $employeeCode,
        public string $password,
        public string $role,
    ) {
    }

    public function build(): self
    {
        return $this
            ->subject('بيانات دخولك إلى بطاقة الصحة')
            ->view('emails.hospital-staff-credentials');
    }
}