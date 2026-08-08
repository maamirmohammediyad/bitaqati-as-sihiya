import 'package:bitaqati_as_sihiya/features/guardian/domain/entities/guardian_patient_dashboard.dart';
import 'package:bitaqati_as_sihiya/features/guardian/domain/repositories/guardian_repository.dart';
import 'package:bitaqati_as_sihiya/features/guardian/data/datasources/guardian_remote_datasource.dart';

class GuardianRepositoryImpl implements GuardianRepository {
  final GuardianRemoteDataSource remoteDataSource;

  GuardianRepositoryImpl({required this.remoteDataSource});

  @override
  Future<GuardianPatientDashboard> getPatientDashboard(String patientId) {
    return remoteDataSource.getPatientDashboard(patientId);
  }
}