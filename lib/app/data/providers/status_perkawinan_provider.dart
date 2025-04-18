import 'package:keanggotaan/app/data/repositories/status_perkawinan_repository.dart';

class StatusPerkawinanProvider {
  final StatusPerkawinanRepository _statusPerkawinanRepository =
      StatusPerkawinanRepository();

  Future initStatusPerkawinan() =>
      _statusPerkawinanRepository.initStatusPerkawinan();
  Future getAllStatusPerkawinan() =>
      _statusPerkawinanRepository.getAllStatusPerkawinan();
  Future getStatusPerkawinanById(String id) =>
      _statusPerkawinanRepository.getStatusPerkawinanById(id);
  Future addStatusPerkawinan(dynamic statusPerkawinan) =>
      _statusPerkawinanRepository.addStatusPerkawinan(statusPerkawinan);
  Future updateStatusPerkawinan(dynamic statusPerkawinan) =>
      _statusPerkawinanRepository.updateStatusPerkawinan(statusPerkawinan);
  Future deleteStatusPerkawinan(String id) =>
      _statusPerkawinanRepository.deleteStatusPerkawinan(id);
}
