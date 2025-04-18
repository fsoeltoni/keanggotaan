import '../repositories/pekerjaan_repository.dart';

class PekerjaanProvider {
  final PekerjaanRepository _pekerjaanRepository = PekerjaanRepository();

  Future initPekerjaan() => _pekerjaanRepository.initPekerjaan();
  Future getAllPekerjaan() => _pekerjaanRepository.getAllPekerjaan();
  Future getPekerjaanById(String id) =>
      _pekerjaanRepository.getPekerjaanById(id);
  Future addPekerjaan(dynamic pekerjaan) =>
      _pekerjaanRepository.addPekerjaan(pekerjaan);
  Future updatePekerjaan(dynamic pekerjaan) =>
      _pekerjaanRepository.updatePekerjaan(pekerjaan);
  Future deletePekerjaan(String id) => _pekerjaanRepository.deletePekerjaan(id);
}
