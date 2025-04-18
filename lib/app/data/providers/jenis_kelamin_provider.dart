import '../repositories/jenis_kelamin_repository.dart';

class JenisKelaminProvider {
  final JenisKelaminRepository _jenisKelaminRepository =
      JenisKelaminRepository();

  Future initJenisKelamin() => _jenisKelaminRepository.initJenisKelamin();
  Future getAllJenisKelamin() => _jenisKelaminRepository.getAllJenisKelamin();
  Future getJenisKelaminById(String id) =>
      _jenisKelaminRepository.getJenisKelaminById(id);
  Future addJenisKelamin(dynamic jenisKelamin) =>
      _jenisKelaminRepository.addJenisKelamin(jenisKelamin);
  Future updateJenisKelamin(dynamic jenisKelamin) =>
      _jenisKelaminRepository.updateJenisKelamin(jenisKelamin);
  Future deleteJenisKelamin(String id) =>
      _jenisKelaminRepository.deleteJenisKelamin(id);
}
