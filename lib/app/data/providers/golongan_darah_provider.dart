import 'package:keanggotaan/app/data/repositories/golongan_darah_repository.dart';

class GolonganDarahProvider {
  final GolonganDarahRepository _golonganDarahRepository =
      GolonganDarahRepository();

  Future initGolonganDarah() => _golonganDarahRepository.initGolonganDarah();
  Future getAllGolonganDarah() =>
      _golonganDarahRepository.getAllGolonganDarah();
  Future getGolonganDarahById(String id) =>
      _golonganDarahRepository.getGolonganDarahById(id);
  Future addGolonganDarah(dynamic golonganDarah) =>
      _golonganDarahRepository.addGolonganDarah(golonganDarah);
  Future updateGolonganDarah(dynamic golonganDarah) =>
      _golonganDarahRepository.updateGolonganDarah(golonganDarah);
  Future deleteGolonganDarah(String id) =>
      _golonganDarahRepository.deleteGolonganDarah(id);
}
