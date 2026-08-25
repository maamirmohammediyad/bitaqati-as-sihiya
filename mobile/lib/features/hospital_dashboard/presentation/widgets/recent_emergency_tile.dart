import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/hospital_dashboard.dart';

class RecentEmergencyTile extends StatelessWidget {
  const RecentEmergencyTile({
    super.key,
    required this.emergency,
    required this.onTap,
  });

  final RecentEmergency emergency;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isResolved = emergency.isResolved;
    final statusColor = isResolved
        ? const Color(0xFF16A34A)
        : const Color(0xFFDC2626);

    final createdAt = emergency.createdAt == null
        ? 'وقت غير معروف'
        : DateFormat('dd MMM، HH:mm', 'ar').format(
            emergency.createdAt!.toLocal(),
          );

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE7ECF3)),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: statusColor.withOpacity(0.12),
              child: Icon(
                isResolved
                    ? Icons.check_circle_outline_rounded
                    : Icons.emergency_rounded,
                color: statusColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    emergency.patient.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF172033),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    emergency.locationName ?? 'لم يتم تحديد الموقع',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF667085),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    createdAt,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF98A2B3),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.10),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Text(
                emergency.statusLabel,
                style: TextStyle(
                  color: statusColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}