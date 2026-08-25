import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/hospital_dashboard_repository.dart';
import '../../models/hospital_dashboard.dart';
import '../widgets/dashboard_stat_card.dart';
import '../widgets/recent_emergency_tile.dart';

class HospitalDashboardScreen extends ConsumerWidget {
  const HospitalDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(hospitalDashboardProvider);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F8FC),
        body: SafeArea(
          child: dashboardAsync.when(
            loading: () => const Center(
              child: CircularProgressIndicator(),
            ),
            error: (error, _) => _DashboardError(
              message: _errorMessage(error),
              onRetry: () {
                ref.invalidate(hospitalDashboardProvider);
              },
            ),
            data: (dashboard) => RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(hospitalDashboardProvider);
                await ref.read(hospitalDashboardProvider.future);
              },
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: _DashboardHeader(dashboard: dashboard),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 22, 20, 0),
                    sliver: SliverToBoxAdapter(
                      child: _StatsGrid(statistics: dashboard.statistics),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 28, 20, 14),
                    sliver: SliverToBoxAdapter(
                      child: Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'أحدث حالات الطوارئ',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF172033),
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              // لاحقًا: الانتقال إلى صفحة كل الطوارئ.
                            },
                            child: const Text('عرض الكل'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (dashboard.recentEmergencies.isEmpty)
                    const SliverFillRemaining(
                      hasScrollBody: false,
                      child: _EmptyEmergencies(),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
                      sliver: SliverList.separated(
                        itemCount: dashboard.recentEmergencies.length,
                        itemBuilder: (context, index) {
                          final emergency =
                              dashboard.recentEmergencies[index];

                          return RecentEmergencyTile(
                            emergency: emergency,
                            onTap: () {
                              // لاحقًا: تفاصيل حالة الطوارئ.
                            },
                          );
                        },
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 2),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _errorMessage(Object error) {
    final message = error.toString();
    return message.isEmpty
        ? 'تعذر تحميل لوحة التحكم. تحقق من الاتصال ثم أعد المحاولة.'
        : message;
  }
}

class _DashboardHeader extends StatelessWidget {
  const _DashboardHeader({required this.dashboard});

  final HospitalDashboard dashboard;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF075985),
            Color(0xFF0E7490),
          ],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.16),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.local_hospital_rounded,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  dashboard.hospital.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.notifications_none_rounded,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              'مرحبًا، ${dashboard.staff.name}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 7),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '${dashboard.staff.roleLabel} · ${dashboard.hospital.city ?? 'موقع غير محدد'}',
              style: TextStyle(
                color: Colors.white.withOpacity(0.82),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({required this.statistics});

  final HospitalStatistics statistics;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.42,
      children: [
        DashboardStatCard(
          title: 'طوارئ نشطة',
          value: statistics.activeEmergencies,
          icon: Icons.emergency_rounded,
          color: const Color(0xFFDC2626),
        ),
        DashboardStatCard(
          title: 'تم الوصول اليوم',
          value: statistics.checkedInToday,
          icon: Icons.location_on_rounded,
          color: const Color(0xFF2563EB),
        ),
        DashboardStatCard(
          title: 'تم إنهاؤها اليوم',
          value: statistics.resolvedToday,
          icon: Icons.check_circle_rounded,
          color: const Color(0xFF16A34A),
        ),
        DashboardStatCard(
          title: 'الموظفون النشطون',
          value: statistics.activeStaffCount,
          icon: Icons.groups_rounded,
          color: const Color(0xFF7C3AED),
        ),
      ],
    );
  }
}

class _DashboardError extends StatelessWidget {
  const _DashboardError({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              size: 58,
              color: Color(0xFF98A2B3),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF475467)),
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyEmergencies extends StatelessWidget {
  const _EmptyEmergencies();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.health_and_safety_outlined,
              size: 58,
              color: Color(0xFF98A2B3),
            ),
            SizedBox(height: 12),
            Text(
              'لا توجد حالات طوارئ حديثة.',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Color(0xFF475467),
              ),
            ),
          ],
        ),
      ),
    );
  }
}