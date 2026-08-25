<!DOCTYPE html>
<html lang="ar" dir="rtl">
<head>
    <meta charset="UTF-8">
    <title>بيانات الدخول</title>
</head>
<body style="font-family: Arial, sans-serif; direction: rtl; color: #0f172a;">
    <h2>مرحبًا {{ $name }}</h2>

    <p>تم إنشاء حسابك ضمن طاقم المستشفى في نظام بطاقة الصحة.</p>

    <p><strong>كود الموظف:</strong> {{ $employeeCode }}</p>
    <p><strong>الدور:</strong> {{ $role }}</p>
    <p><strong>كلمة المرور المؤقتة:</strong> {{ $password }}</p>

    <p>
        يرجى تسجيل الدخول وتغيير كلمة المرور فورًا بعد أول دخول.
    </p>

    <p>مع التحية،<br>نظام بطاقة الصحة</p>
</body>
</html>