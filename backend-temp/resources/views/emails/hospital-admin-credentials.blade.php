<!DOCTYPE html>
<html lang="ar" dir="rtl">
<head>
    <meta charset="UTF-8">
    <title>دعوة إدارة مستشفى</title>
</head>
<body style="font-family: Arial, sans-serif; line-height: 1.8; color: #0f172a;">
    <h2>مرحبًا {{ $user->name }}</h2>

    <p>
        تمت إضافتك مديرًا للمستشفى:
        <strong>{{ $hospital->name }}</strong>
        في منصة بطاقة الصحة.
    </p>

    <p>يمكنك تسجيل الدخول إلى المنصة باستخدام البيانات التالية:</p>

    <ul>
        <li>البريد الإلكتروني: <strong>{{ $user->email }}</strong></li>
        <li>كلمة المرور المؤقتة: <strong>{{ $temporaryPassword }}</strong></li>
    </ul>

    <p>
        رابط الدخول:
        <a href="{{ config('app.frontend_url') }}/login">
            {{ config('app.frontend_url') }}/login
        </a>
    </p>

    <p style="color: #b91c1c;">
        يرجى تغيير كلمة المرور فور تسجيل الدخول.
    </p>

    <p>فريق بطاقة الصحة</p>
</body>
</html>