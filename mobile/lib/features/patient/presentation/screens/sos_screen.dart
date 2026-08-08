import 'package:flutter/material.dart';
import 'package:bitaqati_as_sihiya/core/theme/app_text_styles.dart';
import 'package:bitaqati_as_sihiya/features/emergency/presentation/widgets/sos_button.dart';

class SosScreen extends StatelessWidget {
  const SosScreen({super.key});

  void _onSosPressed(BuildContext context) {
    // هنا استدعِ نفس الدالة التي كنت تستخدمها لإرسال SOS
    // مثلاً: context.read<SosProvider>().sendSos();
    // أو استدعِ Navigator إلى شاشة التأكيد... إلخ.

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم إرسال نداء الطوارئ'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('نداء طارئ')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 24),
            Text(
              'في حالة الطوارئ، اضغط على الزر لإرسال نداء استغاثة مع موقعك إلى النظام وأوليائك.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium,
            ),
            const SizedBox(height: 32),
            Center(
              child: SosButton(
                onPressed: () => _onSosPressed(context),
              ),
            ),
            const SizedBox(height: 32),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'ملاحظة:',
                style: AppTextStyles.bodySmall
                    .copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'سيتم إشعار أولياء أمرك المرتبطين بحسابك والمسجَّلين في النظام، '
              'مع إرسال موقعك الحالي ليتمكنوا من متابعتك بسرعة.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}