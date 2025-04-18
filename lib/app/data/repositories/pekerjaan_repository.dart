import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:keanggotaan/app/data/models/pekerjaan_model.dart';
import '../../services/logger_service.dart';

class PekerjaanRepository {
  final CollectionReference _pekerjaanCollection = FirebaseFirestore.instance
      .collection('pekerjaan');

  // Menggunakan LoggerService
  final LoggerService _logger = LoggerService.to;

  // Mendapatkan semua pekerjaan
  Future<List<PekerjaanModel>> getAllPekerjaan() async {
    try {
      _logger.d('Fetching all pekerjaan');
      final snapshot = await _pekerjaanCollection.get();

      final result =
          snapshot.docs.map((doc) {
            Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
            data['id'] = doc.id;
            return PekerjaanModel.fromJson(data);
          }).toList();

      _logger.d('Retrieved ${result.length} pekerjaan records');
      return result;
    } catch (e, stackTrace) {
      _logger.e('Error fetching pekerjaan', e, stackTrace);
      return [];
    }
  }

  // Mendapatkan pekerjaan berdasarkan ID
  Future<PekerjaanModel?> getPekerjaanById(String id) async {
    try {
      _logger.d('Fetching pekerjaan with id: $id');
      final doc = await _pekerjaanCollection.doc(id).get();

      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        _logger.d('Retrieved pekerjaan: ${data['nama']}');
        return PekerjaanModel.fromJson(data);
      }

      _logger.w('Pekerjaan with id $id not found');
      return null;
    } catch (e, stackTrace) {
      _logger.e('Error fetching pekerjaan by id: $id', e, stackTrace);
      return null;
    }
  }

  // Menambah pekerjaan baru
  Future<String?> addPekerjaan(PekerjaanModel pekerjaan) async {
    try {
      _logger.d('Adding new pekerjaan: ${pekerjaan.nama}');
      final docRef = await _pekerjaanCollection.add(pekerjaan.toJson());
      _logger.i('Successfully added pekerjaan with id: ${docRef.id}');
      return docRef.id;
    } catch (e, stackTrace) {
      _logger.e('Error adding pekerjaan', e, stackTrace);
      return null;
    }
  }

  // Memperbarui pekerjaan
  Future<bool> updatePekerjaan(PekerjaanModel pekerjaan) async {
    try {
      _logger.d('Updating pekerjaan with id: ${pekerjaan.id}');
      await _pekerjaanCollection.doc(pekerjaan.id).update(pekerjaan.toJson());
      _logger.i('Successfully updated pekerjaan: ${pekerjaan.nama}');
      return true;
    } catch (e, stackTrace) {
      _logger.e('Error updating pekerjaan: ${pekerjaan.id}', e, stackTrace);
      return false;
    }
  }

  // Menghapus pekerjaan
  Future<bool> deletePekerjaan(String id) async {
    try {
      _logger.d('Deleting pekerjaan with id: $id');
      await _pekerjaanCollection.doc(id).delete();
      _logger.i('Successfully deleted pekerjaan: $id');
      return true;
    } catch (e, stackTrace) {
      _logger.e('Error deleting pekerjaan: $id', e, stackTrace);
      return false;
    }
  }

  // Inisialisasi data pekerjaan jika belum ada
  Future<void> initPekerjaan() async {
    try {
      _logger.d('Initializing pekerjaan data');
      final snapshot = await _pekerjaanCollection.get();

      if (snapshot.docs.isEmpty) {
        _logger.i('Pekerjaan collection is empty, adding default values');
        await _pekerjaanCollection.add({'nama': 'Petani'});
        await _pekerjaanCollection.add({'nama': 'Nelayan'});
        await _pekerjaanCollection.add({'nama': 'Lain-lain'});
        _logger.i('Default pekerjaan data successfully added');
      } else {
        _logger.d(
          'Pekerjaan data already exists (${snapshot.docs.length} records)',
        );
      }
    } catch (e, stackTrace) {
      _logger.e('Error initializing pekerjaan data', e, stackTrace);
    }
  }
}
