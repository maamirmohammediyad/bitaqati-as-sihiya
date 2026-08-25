<?php

declare(strict_types=1);

namespace App\Mail;

use App\Domain\Models\User;
use Illuminate\Bus\Queueable;
use Illuminate\Mail\Mailable;
use Illuminate\Queue\SerializesModels;

class AdminUserChangedMail extends Mailable
{
    use Queueable;
    use SerializesModels;

    public function __construct(
        public readonly User $user,
        public readonly string $action,
        public readonly ?string $plainPassword = null,
    ) {
    }

    public function build(): self
    {
        $subjects = [
            'created' => 'تم إنشاء حسابك في بطاقتي الصحية',
            'updated' => 'تم تحديث بيانات حسابك في بطاقتي الصحية',
            'deleted' => 'تحديث على حسابك في بطاقتي الصحية',
        ];

        return $this
            ->subject($subjects[$this->action] ?? 'تحديث على حسابك')
            ->view('emails.admin-user-changed');
    }
}