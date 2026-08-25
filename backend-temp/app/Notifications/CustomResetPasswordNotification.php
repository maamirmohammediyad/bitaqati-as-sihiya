<?php

namespace App\Notifications;

use Illuminate\Auth\Notifications\ResetPassword;
use Illuminate\Notifications\Messages\MailMessage;

class CustomResetPasswordNotification extends ResetPassword
{
    public function toMail($notifiable): MailMessage
    {
        $url = $this->resetUrl($notifiable);

        return (new MailMessage)
            ->subject('إعادة تعيين كلمة المرور - بطاقتي الصحية')
            ->view('emails.reset-password', [
                'url' => $url,
                'expireMinutes' => config('auth.passwords.users.expire'),
            ]);
    }
}