import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bitaqati_as_sihiya/core/network/api_client.dart';
import 'package:bitaqati_as_sihiya/features/auth/data/datasources/account_remote_datasource.dart';
import 'package:bitaqati_as_sihiya/features/auth/presentation/providers/auth_provider.dart';

final accountRemoteDataSourceProvider = Provider<AccountRemoteDataSource>((
  ref,
) {
  final apiClient = ref.watch(apiClientProvider);
  return AccountRemoteDataSource(apiClient.dio);
});

final accountLoadingProvider = StateProvider<bool>((ref) => false);

final accountActionsProvider = Provider<AccountActions>((ref) {
  return AccountActions(
    ref: ref,
    remoteDataSource: ref.watch(accountRemoteDataSourceProvider),
  );
});

class AccountActions {
  final Ref ref;
  final AccountRemoteDataSource remoteDataSource;

  AccountActions({required this.ref, required this.remoteDataSource});

  Future<void> updateEmail({
  required String email,
}) async {
  ref.read(accountLoadingProvider.notifier).state = true;

  try {
    await remoteDataSource.updateEmail(
      email: email,
    );

    await ref.read(authProvider.notifier).checkAuth();
  } finally {
    ref.read(accountLoadingProvider.notifier).state = false;
  }
}

  Future<void> changePassword({
    required String currentPassword,
    required String password,
    required String passwordConfirmation,
  }) async {
    ref.read(accountLoadingProvider.notifier).state = true;

    try {
      await remoteDataSource.changePassword(
        currentPassword: currentPassword,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );
    } finally {
      ref.read(accountLoadingProvider.notifier).state = false;
    }
  }
}
