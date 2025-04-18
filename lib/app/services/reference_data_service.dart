import 'package:get/get.dart';
import 'package:keanggotaan/app/data/models/golongan_darah_model.dart';
import 'package:keanggotaan/app/data/models/jenis_kelamin_model.dart';
import 'package:keanggotaan/app/data/models/koperasi_model.dart';
import 'package:keanggotaan/app/data/models/pekerjaan_model.dart';
import 'package:keanggotaan/app/data/models/status_perkawinan_model.dart';
import 'package:keanggotaan/app/data/repositories/koperasi_repository.dart';
import 'package:keanggotaan/app/data/repositories/pekerjaan_repository.dart';
import 'package:keanggotaan/app/data/repositories/status_perkawinan_repository.dart';
import '../data/repositories/jenis_kelamin_repository.dart';
import '../data/repositories/golongan_darah_repository.dart';
import './logger_service.dart';

class ReferenceDataService extends GetxService {
  static ReferenceDataService get to => Get.find<ReferenceDataService>();

  final JenisKelaminRepository _jenisKelaminRepository =
      JenisKelaminRepository();

  final GolonganDarahRepository _golonganDarahRepository =
      GolonganDarahRepository();

  final PekerjaanRepository _pekerjaanRepository = PekerjaanRepository();

  final StatusPerkawinanRepository _statusPerkawinanRepository =
      StatusPerkawinanRepository();

  final KoperasiRepository _koperasiRepository = KoperasiRepository();

  final LoggerService _logger = LoggerService.to;

  // Menyimpan data referensi untuk jenis kelamin
  final RxList<JenisKelaminModel> jenisKelaminList = <JenisKelaminModel>[].obs;
  final RxBool isLoadingJenisKelamin = false.obs;

  // Menyimpan data referensi untuk golongan darah
  final RxList<GolonganDarahModel> golonganDarahList =
      <GolonganDarahModel>[].obs;
  final RxBool isLoadingGolonganDarah = false.obs;

  // Menyimpan data referensi untuk pekerjaan
  final RxList<PekerjaanModel> pekerjaanList = <PekerjaanModel>[].obs;
  final RxBool isLoadingPekerjaan = false.obs;

  // Menyimpan data referensi untuk status perkawinan
  final RxList<StatusPerkawinanModel> statusPerkawinanList =
      <StatusPerkawinanModel>[].obs;
  final RxBool isLoadingStatusPerkawinan = false.obs;

  // Menyimpan data referensi untuk koperasi
  final RxList<KoperasiModel> koperasiList = <KoperasiModel>[].obs;
  final RxBool isLoadingKoperasi = false.obs;

  // Method untuk inisialisasi data
  Future<ReferenceDataService> init() async {
    _logger.i('Initializing ReferenceDataService');

    try {
      await Future.wait([fetchJenisKelamin(), fetchGolonganDarah()]);
      _logger.i('ReferenceDataService initialized successfully');
    } catch (e, stackTrace) {
      _logger.e('Failed to initialize ReferenceDataService', e, stackTrace);
    }

    return this;
  }

  // Fetch jenis kelamin
  Future<void> fetchJenisKelamin() async {
    _logger.d('Fetching jenis kelamin data');
    isLoadingJenisKelamin.value = true;

    try {
      final data = await _jenisKelaminRepository.getAllJenisKelamin();
      jenisKelaminList.assignAll(data);
      _logger.d('Successfully loaded ${data.length} jenis kelamin records');

      // Contoh output data untuk debugging
      for (var item in jenisKelaminList) {
        _logger.t('Jenis Kelamin: ${item.id} - ${item.nama}');
      }
    } catch (e, stackTrace) {
      _logger.e('Error fetching jenis kelamin data', e, stackTrace);
    } finally {
      isLoadingJenisKelamin.value = false;
    }
  }

  // Fetch golongan darah
  Future<void> fetchGolonganDarah() async {
    _logger.d('Fetching golongan darah data');
    isLoadingGolonganDarah.value = true;

    try {
      await _golonganDarahRepository
          .initGolonganDarah(); // Pastikan data awal ada
      final data = await _golonganDarahRepository.getAllGolonganDarah();
      golonganDarahList.assignAll(data);
      _logger.d('Successfully loaded ${data.length} golongan darah records');

      // Contoh output data untuk debugging
      for (var item in golonganDarahList) {
        _logger.t('Golongan Darah: ${item.id} - ${item.nama}');
      }
    } catch (e, stackTrace) {
      _logger.e('Error fetching golongan darah data', e, stackTrace);
    } finally {
      isLoadingGolonganDarah.value = false;
    }
  }

  // Fetch pekerjaan
  Future<void> fetchPekerjaan() async {
    _logger.d('Fetching pekerjaan data');
    isLoadingPekerjaan.value = true;

    try {
      final data = await _pekerjaanRepository.getAllPekerjaan();
      pekerjaanList.assignAll(data);
      _logger.d('Successfully loaded ${data.length} pekerjaan records');

      // Contoh output data untuk debugging
      for (var item in pekerjaanList) {
        _logger.t('Pekerjaan: ${item.id} - ${item.nama}');
      }
    } catch (e, stackTrace) {
      _logger.e('Error fetching pekerjaan data', e, stackTrace);
    } finally {
      isLoadingPekerjaan.value = false;
    }
  }

  // Fetch status perkawinan
  Future<void> fetchStatusPerkawinan() async {
    _logger.d('Fetching status perkawinan data');
    isLoadingStatusPerkawinan.value = true;

    try {
      final data = await _statusPerkawinanRepository.getAllStatusPerkawinan();
      statusPerkawinanList.assignAll(data);
      _logger.d('Successfully loaded ${data.length} status perkawinan records');

      // Contoh output data untuk debugging
      for (var item in statusPerkawinanList) {
        _logger.t('Status Perkawinan: ${item.id} - ${item.nama}');
      }
    } catch (e, stackTrace) {
      _logger.e('Error fetching status perkawinan data', e, stackTrace);
    } finally {
      isLoadingStatusPerkawinan.value = false;
    }
  }

  // Fetch koperasi
  Future<void> fetchKoperasi() async {
    _logger.d('Fetching koperasi data');
    isLoadingKoperasi.value = true;

    try {
      final data = await _koperasiRepository.getAllKoperasi();
      koperasiList.assignAll(data);
      _logger.d('Successfully loaded ${data.length} koperasi records');

      // Contoh output data untuk debugging
      for (var item in koperasiList) {
        _logger.t('Koperasi: ${item.id} - ${item.nama}');
      }
    } catch (e, stackTrace) {
      _logger.e('Error fetching koperasi data', e, stackTrace);
    } finally {
      isLoadingKoperasi.value = false;
    }
  }

  // Mendapatkan jenis kelamin berdasarkan ID
  JenisKelaminModel? getJenisKelaminById(String id) {
    _logger.d('Getting jenis kelamin by id: $id');
    try {
      final result = jenisKelaminList.firstWhereOrNull(
        (element) => element.id == id,
      );
      if (result != null) {
        _logger.d('Found jenis kelamin: ${result.nama}');
      } else {
        _logger.w('Jenis kelamin with id $id not found in local data');
      }
      return result;
    } catch (e, stackTrace) {
      _logger.e('Error getting jenis kelamin by id', e, stackTrace);
      return null;
    }
  }

  // Mendapatkan golongan darah berdasarkan ID
  GolonganDarahModel? getGolonganDarahById(String id) {
    _logger.d('Getting golongan darah by id: $id');
    try {
      final result = golonganDarahList.firstWhereOrNull(
        (element) => element.id == id,
      );
      if (result != null) {
        _logger.d('Found golongan darah: ${result.nama}');
      } else {
        _logger.w('Golongan darah with id $id not found in local data');
      }
      return result;
    } catch (e, stackTrace) {
      _logger.e('Error getting golongan darah by id', e, stackTrace);
      return null;
    }
  }

  // Mendapatkan pekerjaan berdasarkan ID
  PekerjaanModel? getPekerjaanById(String id) {
    _logger.d('Getting pekerjaan by id: $id');
    try {
      final result = pekerjaanList.firstWhereOrNull(
        (element) => element.id == id,
      );
      if (result != null) {
        _logger.d('Found pekerjaan: ${result.nama}');
      } else {
        _logger.w('Pekerjaan with id $id not found in local data');
      }
      return result;
    } catch (e, stackTrace) {
      _logger.e('Error getting pekerjaan by id', e, stackTrace);
      return null;
    }
  }

  // Mendapatkan status perkawinan berdasarkan ID
  StatusPerkawinanModel? getStatusPerkawinanById(String id) {
    _logger.d('Getting status perkawinan by id: $id');
    try {
      final result = statusPerkawinanList.firstWhereOrNull(
        (element) => element.id == id,
      );
      if (result != null) {
        _logger.d('Found status perkawinan: ${result.nama}');
      } else {
        _logger.w('Status perkawinan with id $id not found in local data');
      }
      return result;
    } catch (e, stackTrace) {
      _logger.e('Error getting status perkawinan by id', e, stackTrace);
      return null;
    }
  }

  // Mendapatkan koperasi berdasarkan ID
  KoperasiModel? getKoperasiById(String id) {
    _logger.d('Getting koperasi by id: $id');
    try {
      final result = koperasiList.firstWhereOrNull(
        (element) => element.id == id,
      );
      if (result != null) {
        _logger.d('Found koperasi: ${result.nama}');
      } else {
        _logger.w('Koperasi with id $id not found in local data');
      }
      return result;
    } catch (e, stackTrace) {
      _logger.e('Error getting koperasi by id', e, stackTrace);
      return null;
    }
  }

  // Reload data jenis kelamin jika diperlukan
  Future<void> reloadJenisKelamin() async {
    _logger.i('Reloading jenis kelamin data');
    await fetchJenisKelamin();
  }

  // Reload data golongan darah jika diperlukan
  Future<void> reloadGolonganDarah() async {
    _logger.i('Reloading golongan darah data');
    await fetchGolonganDarah();
  }

  // Reload data pekerjaan jika diperlukan
  Future<void> reloadPekerjaan() async {
    _logger.i('Reloading pekerjaan data');
    await fetchPekerjaan();
  }

  // Reload data status perkawinan jika diperlukan
  Future<void> reloadStatusPerkawinan() async {
    _logger.i('Reloading status perkawinan data');
    await fetchStatusPerkawinan();
  }

  // Reload data koperasi jika diperlukan
  Future<void> reloadKoperasi() async {
    _logger.i('Reloading koperasi data');
    await fetchKoperasi();
  }

  // Reload semua data referensi
  Future<void> reloadAllReferenceData() async {
    _logger.i('Reloading all reference data');
    await Future.wait([fetchJenisKelamin(), fetchGolonganDarah()]);
    _logger.i('All reference data reloaded successfully');
  }
}
