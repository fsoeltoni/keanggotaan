import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:keanggotaan/app/data/models/koperasi_model.dart';
import '../../services/logger_service.dart';

class KoperasiRepository {
  final CollectionReference _koperasiCollection = FirebaseFirestore.instance
      .collection('koperasi');

  // Menggunakan LoggerService
  final LoggerService _logger = LoggerService.to;

  // Mendapatkan semua koperasi
  Future<List<KoperasiModel>> getAllKoperasi() async {
    try {
      _logger.d('Fetching all koperasi');
      final snapshot = await _koperasiCollection.get();

      final result =
          snapshot.docs.map((doc) {
            Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
            data['id'] = doc.id;
            return KoperasiModel.fromJson(data);
          }).toList();

      _logger.d('Retrieved ${result.length} koperasi records');
      return result;
    } catch (e, stackTrace) {
      _logger.e('Error fetching koperasi', e, stackTrace);
      return [];
    }
  }

  // Mendapatkan koperasi berdasarkan ID
  Future<KoperasiModel?> getKoperasiById(String id) async {
    try {
      _logger.d('Fetching koperasi with id: $id');
      final doc = await _koperasiCollection.doc(id).get();

      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        _logger.d('Retrieved koperasi: ${data['nama']}');
        return KoperasiModel.fromJson(data);
      }

      _logger.w('Koperasi with id $id not found');
      return null;
    } catch (e, stackTrace) {
      _logger.e('Error fetching koperasi by id: $id', e, stackTrace);
      return null;
    }
  }

  // Menambah koperasi baru
  Future<String?> addKoperasi(KoperasiModel koperasi) async {
    try {
      _logger.d('Adding new koperasi: ${koperasi.nama}');
      final docRef = await _koperasiCollection.add(koperasi.toJson());
      _logger.i('Successfully added koperasi with id: ${docRef.id}');
      return docRef.id;
    } catch (e, stackTrace) {
      _logger.e('Error adding koperasi', e, stackTrace);
      return null;
    }
  }

  // Memperbarui koperasi
  Future<bool> updateKoperasi(KoperasiModel koperasi) async {
    try {
      _logger.d('Updating koperasi with id: ${koperasi.id}');
      await _koperasiCollection.doc(koperasi.id).update(koperasi.toJson());
      _logger.i('Successfully updated koperasi: ${koperasi.nama}');
      return true;
    } catch (e, stackTrace) {
      _logger.e('Error updating koperasi: ${koperasi.id}', e, stackTrace);
      return false;
    }
  }

  // Menghapus koperasi
  Future<bool> deleteKoperasi(String id) async {
    try {
      _logger.d('Deleting koperasi with id: $id');
      await _koperasiCollection.doc(id).delete();
      _logger.i('Successfully deleted koperasi: $id');
      return true;
    } catch (e, stackTrace) {
      _logger.e('Error deleting koperasi: $id', e, stackTrace);
      return false;
    }
  }

  // Inisialisasi data koperasi jika belum ada
  Future<void> initKoperasi() async {
    try {
      _logger.d('Initializing koperasi data');
      final snapshot = await _koperasiCollection.get();

      if (snapshot.docs.isEmpty) {
        _logger.i('Koperasi collection is empty, adding default values');
        await _koperasiCollection.add({
          'nama': 'Koperasi Kesejahteraan Petani',
        });
        await _koperasiCollection.add({
          'nama': 'Koperasi Kesejahteraan Nelayan',
        });
        await _koperasiCollection.add({'nama': 'Koperasi Kesejahteraan Buruh'});
        _logger.i('Default koperasi data successfully added');
      } else {
        _logger.d(
          'Koperasi data already exists (${snapshot.docs.length} records)',
        );
      }
    } catch (e, stackTrace) {
      _logger.e('Error initializing koperasi data', e, stackTrace);
    }
  }
}
