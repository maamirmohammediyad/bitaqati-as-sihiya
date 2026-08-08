import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bitaqati_as_sihiya/core/localization/app_localizations.dart';
import 'package:bitaqati_as_sihiya/core/theme/app_colors.dart';
import 'package:bitaqati_as_sihiya/core/theme/app_text_styles.dart';
import 'package:bitaqati_as_sihiya/features/hospitals/presentation/widgets/hospital_card.dart';

class HospitalsScreen extends ConsumerWidget {
  const HospitalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.nearbyHospitals),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_outlined),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.filter_list_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Map placeholder
          Container(
            height: 200,
            width: double.infinity,
            decoration: const BoxDecoration(
              color: AppColors.grey100,
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.map_outlined,
                    size: 48,
                    color: AppColors.grey300,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Map View',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.grey400,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${localizations.hospitals} (3)',
                  style: AppTextStyles.heading3,
                ),
                Text(
                  'Sort: ${localizations.distance}',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          // Hospital List
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: const [
                HospitalCard(
                  name: 'King Fahd Medical City',
                  address: 'Prince Naif Bin Abdulaziz Road, Riyadh',
                  distance: 2.3,
                  phone: '+966114888888',
                  rating: 4.5,
                  isOpen: true,
                  latitude: 24.7136,
                  longitude: 46.6753,
                ),
                HospitalCard(
                  name: 'King Saud Medical City',
                  address: 'Al Imam AbdulAziz Bin Mohammed, Riyadh',
                  distance: 4.1,
                  phone: '+966114355555',
                  rating: 4.3,
                  isOpen: true,
                  latitude: 24.6389,
                  longitude: 46.7142,
                ),
                HospitalCard(
                  name: 'King Faisal Specialist Hospital',
                  address: 'Al Zahrawi Street, Riyadh',
                  distance: 5.7,
                  phone: '+966114424444',
                  rating: 4.7,
                  isOpen: false,
                  latitude: 24.6725,
                  longitude: 46.6939,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
