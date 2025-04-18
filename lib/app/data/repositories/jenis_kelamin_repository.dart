import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:keanggotaan/app/data/models/jenis_kelamin_model.dart';
import '../../services/logger_service.dart';

class JenisKelaminRepository {
  final CollectionReference _jenisKelaminCollection = FirebaseFirestore.instance
      .collection('jenis_kelamin');

  // Menggunakan LoggerService
  final LoggerService _logger = LoggerService.to;

  // Mendapatkan semua jenis kelamin
  Future<List<JenisKelaminModel>> getAllJenisKelamin() async {
    try {
      _logger.d('Fetching all jenis kelamin');
      final snapshot = await _jenisKelaminCollection.get();

      final result =
          snapshot.docs.map((doc) {
            Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
            data['id'] = doc.id;
            return JenisKelaminModel.fromJson(data);
          }).toList();

      _logger.d('Retrieved ${result.length} jenis kelamin records');
      return result;
    } catch (e, stackTrace) {
      _logger.e('Error fetching jenis kelamin', e, stackTrace);
      return [];
    }
  }

  // Mendapatkan jenis kelamin berdasarkan ID
  Future<JenisKelaminModel?> getJenisKelaminById(String id) async {
    try {
      _logger.d('Fetching jenis kelamin with id: $id');
      final doc = await _jenisKelaminCollection.doc(id).get();

      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        _logger.d('Retrieved jenis kelamin: ${data['nama']}');
        return JenisKelaminModel.fromJson(data);
      }

      _logger.w('Jenis kelamin with id $id not found');
      return null;
    } catch (e, stackTrace) {
      _logger.e('Error fetching jenis kelamin by id: $id', e, stackTrace);
      return null;
    }
  }

  // Menambah jenis kelamin baru
  Future<String?> addJenisKelamin(JenisKelaminModel jenisKelamin) async {
    try {
      _logger.d('Adding new jenis kelamin: ${jenisKelamin.nama}');
      final docRef = await _jenisKelaminCollection.add(jenisKelamin.toJson());
      _logger.i('Successfully added jenis kelamin with id: ${docRef.id}');
      return docRef.id;
    } catch (e, stackTrace) {
      _logger.e('Error adding jenis kelamin', e, stackTrace);
      return null;
    }
  }

  // Memperbarui jenis kelamin
  Future<bool> updateJenisKelamin(JenisKelaminModel jenisKelamin) async {
    try {
      _logger.d('Updating jenis kelamin with id: ${jenisKelamin.id}');
      await _jenisKelaminCollection
          .doc(jenisKelamin.id)
          .update(jenisKelamin.toJson());
      _logger.i('Successfully updated jenis kelamin: ${jenisKelamin.nama}');
      return true;
    } catch (e, stackTrace) {
      _logger.e(
        'Error updating jenis kelamin: ${jenisKelamin.id}',
        e,
        stackTrace,
      );
      return false;
    }
  }

  // Menghapus jenis kelamin
  Future<bool> deleteJenisKelamin(String id) async {
    try {
      _logger.d('Deleting jenis kelamin with id: $id');
      await _jenisKelaminCollection.doc(id).delete();
      _logger.i('Successfully deleted jenis kelamin: $id');
      return true;
    } catch (e, stackTrace) {
      _logger.e('Error deleting jenis kelamin: $id', e, stackTrace);
      return false;
    }
  }

  // Inisialisasi data jenis kelamin jika belum ada
  Future<void> initJenisKelamin() async {
    try {
      _logger.d('Initializing jenis kelamin data');
      final snapshot = await _jenisKelaminCollection.get();

      if (snapshot.docs.isEmpty) {
        _logger.i('Jenis kelamin collection is empty, adding default values');
        await _jenisKelaminCollection.add({'nama': 'Laki-laki'});
        await _jenisKelaminCollection.add({'nama': 'Perempuan'});
        _logger.i('Default jenis kelamin data successfully added');
      } else {
        _logger.d(
          'Jenis kelamin data already exists (${snapshot.docs.length} records)',
        );
      }
    } catch (e, stackTrace) {
      _logger.e('Error initializing jenis kelamin data', e, stackTrace);
    }
  }
}
