import 'package:dio/dio.dart';
import 'package:bitaqati_as_sihiya/core/constants/api_constants.dart';
import 'package:bitaqati_as_sihiya/features/medical_files/domain/entities/medical_file.dart';

abstract class PatientMedicalFilesRemoteDataSource {
  Future<List<MedicalFile>> getMyMedicalFiles();
}

class PatientMedicalFilesRemoteDataSourceImpl
    implements PatientMedicalFilesRemoteDataSource {
  final Dio dio;

  PatientMedicalFilesRemoteDataSourceImpl(this.dio);

 @override
Future<List<MedicalFile>> getMyMedicalFiles() async {
  final response = await dio.get(ApiConstants.patientMedicalFiles);

  if (response.data is! Map) {
    throw const FormatException('استجابة الملفات الطبية غير صالحة');
  }

  final body = Map<String, dynamic>.from(response.data as Map);
  final rawFiles = body['data'];

  if (rawFiles is! List) {
    throw const FormatException('قائمة الملفات الطبية غير صالحة');
  }

  return rawFiles
      .whereType<Map>()
      .map(
        (item) => MedicalFile.fromJson(
          Map<String, dynamic>.from(item),
        ),
      )
      .toList();
}
}