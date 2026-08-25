<!DOCTYPE html>
<html lang="ar" dir="rtl">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>إعادة تعيين كلمة المرور</title>
</head>

<body style="margin:0;padding:0;background:#f3f7fb;font-family:Arial, Tahoma, sans-serif;direction:rtl;">
    <div style="max-width:600px;margin:32px auto;background:#ffffff;border-radius:18px;overflow:hidden;border:1px solid #e5edf5;">
        <div style="padding:28px 24px;background:#087ea4;text-align:center;">
            <img
                src="{{ $message->embed(public_path('images/email/logo.png')) }}"
                alt="بطاقتي الصحية"
                width="72"
                height="72"
                style="width:72px;height:72px;object-fit:contain;display:block;margin:0 auto 12px;"
            >

            <div style="color:#ffffff;font-weight:bold;font-size:22px;">
                بطاقتي الصحية
            </div>
        </div>

        <div style="padding:32px 28px;color:#172033;">
            <h1 style="margin:0 0 18px;font-size:22px;line-height:1.5;">
                إعادة تعيين كلمة المرور
            </h1>

            <p style="margin:0 0 16px;font-size:15px;line-height:1.9;color:#475467;">
                تلقّينا طلبًا لإعادة تعيين كلمة مرور حسابك في منصة بطاقتي الصحية.
            </p>

            <p style="margin:0 0 24px;font-size:15px;line-height:1.9;color:#475467;">
                اضغط الزر التالي لتعيين كلمة مرور جديدة:
            </p>

            <div style="text-align:center;margin:28px 0;">
                <a
                    href="{{ $url }}"
                    style="display:inline-block;background:#087ea4;color:#ffffff;text-decoration:none;padding:13px 24px;border-radius:10px;font-size:15px;font-weight:bold;"
                >
                    إعادة تعيين كلمة المرور
                </a>
            </div>

            <p style="margin:0 0 12px;font-size:14px;line-height:1.8;color:#667085;">
                تنتهي صلاحية هذا الرابط بعد {{ $expireMinutes }} دقيقة.
            </p>

            <p style="margin:0;font-size:14px;line-height:1.8;color:#667085;">
                إذا لم تطلب تغيير كلمة المرور، تجاهل هذه الرسالة ولن يتغير شيء في حسابك.
            </p>
        </div>

        <div style="padding:18px 28px;background:#f8fafc;color:#98a2b3;text-align:center;font-size:12px;">
            © {{ date('Y') }} بطاقتي الصحية — رسالة تلقائية.
        </div>
    </div>
</body>
</html>