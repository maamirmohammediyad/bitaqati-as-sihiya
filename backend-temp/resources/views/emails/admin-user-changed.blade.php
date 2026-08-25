<!doctype html>
<html lang="ar" dir="rtl">
<head>
    <meta charset="utf-8">
    <title>بطاقتي الصحية</title>
</head>

<body style="margin:0; padding:24px; background:#f1f5f9; color:#0f172a; font-family:Arial, Tahoma, sans-serif;">
    <table role="presentation" width="100%" cellspacing="0" cellpadding="0" border="0">
        <tr>
            <td align="center">
                <table role="presentation" width="640" cellspacing="0" cellpadding="0" border="0" style="max-width:640px; width:100%; background:#ffffff; border-radius:16px; overflow:hidden;">
                    <tr>
                        <td style="padding:28px; background:#0f172a; color:#ffffff;">
                            <h1 style="margin:0; font-size:22px;">بطاقتي الصحية</h1>
                            <p style="margin:8px 0 0; color:#a5f3fc; font-size:14px;">
                                إشعار إدارة المنصة
                            </p>
                        </td>
                    </tr>

                    <tr>
                        <td style="padding:28px;">
                            <p style="margin:0 0 16px; font-size:16px;">
                                مرحبًا {{ $user->name ?? 'مستخدمنا العزيز' }}،
                            </p>

                            @if ($action === 'created')
                                <h2 style="margin:0 0 14px; font-size:20px;">
                                    تم إنشاء حسابك بنجاح
                                </h2>

                                <p style="line-height:1.8;">
                                    أنشأت إدارة منصة بطاقتي الصحية حسابًا جديدًا لك.
                                    استخدم المعلومات التالية لتسجيل الدخول.
                                </p>

                                <table role="presentation" width="100%" cellspacing="0" cellpadding="0" border="0" style="margin:20px 0; border:1px solid #cbd5e1; border-radius:12px; overflow:hidden;">
                                    <tr>
                                        <td style="padding:12px; background:#f8fafc; width:40%; border-bottom:1px solid #e2e8f0;">
                                            <strong>الاسم</strong>
                                        </td>
                                        <td style="padding:12px; border-bottom:1px solid #e2e8f0;">
                                            {{ $user->name }}
                                        </td>
                                    </tr>

                                    <tr>
                                        <td style="padding:12px; background:#f8fafc; width:40%; border-bottom:1px solid #e2e8f0;">
                                            <strong>البريد الإلكتروني</strong>
                                        </td>
                                        <td dir="ltr" style="padding:12px; border-bottom:1px solid #e2e8f0;">
                                            {{ $user->email }}
                                        </td>
                                    </tr>

                                    <tr>
                                        <td style="padding:12px; background:#f8fafc; width:40%; border-bottom:1px solid #e2e8f0;">
                                            <strong>كلمة المرور المؤقتة</strong>
                                        </td>
                                        <td dir="ltr" style="padding:12px; border-bottom:1px solid #e2e8f0; font-family:monospace; font-weight:bold;">
                                            {{ $plainPassword ?? 'يرجى التواصل مع الإدارة' }}
                                        </td>
                                    </tr>

                                    <tr>
                                        <td style="padding:12px; background:#f8fafc; width:40%;">
                                            <strong>نوع الحساب</strong>
                                        </td>
                                        <td style="padding:12px;">
                                            @switch($user->role)
                                                @case('patient')
                                                    مريض
                                                    @break
                                                @case('guardian')
                                                    ولي أمر
                                                    @break
                                                @case('health_worker')
                                                    موظف صحي
                                                    @break
                                                @case('super_admin')
                                                    مدير منصة
                                                    @break
                                                @default
                                                    {{ $user->role }}
                                            @endswitch
                                        </td>
                                    </tr>
                                </table>

                                @if (in_array($user->role, ['patient', 'guardian']) && $user->national_id)
                                    <p style="line-height:1.8;">
                                        <strong>الرقم الوطني:</strong>
                                        <span dir="ltr">{{ $user->national_id }}</span>
                                    </p>
                                @endif

                                @if ($user->role === 'patient' && $user->patient_code)
                                    <p style="line-height:1.8;">
                                        <strong>رمز المريض:</strong>
                                        <span dir="ltr" style="font-family:monospace; font-weight:bold;">
                                            {{ $user->patient_code }}
                                        </span>
                                    </p>
                                @endif

                                @if ($user->role === 'health_worker' && $user->employee_code)
                                    <p style="line-height:1.8;">
                                        <strong>رمز الموظف:</strong>
                                        <span dir="ltr" style="font-family:monospace; font-weight:bold;">
                                            {{ $user->employee_code }}
                                        </span>
                                    </p>
                                @endif

                                <p style="margin-top:24px; padding:14px; background:#fff7ed; border:1px solid #fed7aa; border-radius:10px; line-height:1.8; color:#9a3412;">
                                    لأمان حسابك، غيّر كلمة المرور فور تسجيل الدخول ولا تشاركها مع أي شخص.
                                </p>
                            @elseif ($action === 'updated')
                                <h2 style="margin:0 0 14px; font-size:20px;">
                                    تم تحديث بيانات حسابك
                                </h2>

                                <p style="line-height:1.8;">
                                    قامت إدارة المنصة بتحديث بيانات حسابك. إذا لم تكن تتوقع هذا الإجراء،
                                    تواصل مع إدارة المنصة فورًا.
                                </p>
                            @elseif ($action === 'deleted')
                                <h2 style="margin:0 0 14px; font-size:20px;">
                                    تم حذف أو تعطيل حسابك
                                </h2>

                                <p style="line-height:1.8;">
                                    قامت إدارة المنصة بحذف حسابك أو تعطيله. إذا كنت تعتقد أن هذا الإجراء تم بالخطأ،
                                    تواصل مع الإدارة.
                                </p>
                            @endif
                        </td>
                    </tr>

                    <tr>
                        <td style="padding:18px 28px; background:#f8fafc; color:#64748b; font-size:12px;">
                            هذه رسالة آلية من منصة بطاقتي الصحية، يرجى عدم الرد عليها مباشرة.
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
    </table>
</body>
</html>