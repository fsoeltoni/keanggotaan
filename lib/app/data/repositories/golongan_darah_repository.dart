import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:keanggotaan/app/data/models/golongan_darah_model.dart';
import '../../services/logger_service.dart';

class GolonganDarahRepository {
  final CollectionReference _golonganDarahCollection = FirebaseFirestore
      .instance
      .collection('golongan_darah');

  // Menggunakan LoggerService
  final LoggerService _logger = LoggerService.to;

  // Mendapatkan semua golongan darah
  Future<List<GolonganDarahModel>> getAllGolonganDarah() async {
    try {
      _logger.d('Fetching all golongan darah');
      final snapshot = await _golonganDarahCollection.get();

      final result =
          snapshot.docs.map((doc) {
            Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
            data['id'] = doc.id;
            return GolonganDarahModel.fromJson(data);
          }).toList();

      _logger.d('Retrieved ${result.length} golongan darah records');
      return result;
    } catch (e, stackTrace) {
      _logger.e('Error fetching golongan darah', e, stackTrace);
      return [];
    }
  }

  // Mendapatkan golongan darah berdasarkan ID
  Future<GolonganDarahModel?> getGolonganDarahById(String id) async {
    try {
      _logger.d('Fetching golongan darah with id: $id');
      final doc = await _golonganDarahCollection.doc(id).get();

      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        _logger.d('Retrieved golongan darah: ${data['nama']}');
        return GolonganDarahModel.fromJson(data);
      }

      _logger.w('Golongan darah with id $id not found');
      return null;
    } catch (e, stackTrace) {
      _logger.e('Error fetching golongan darah by id: $id', e, stackTrace);
      return null;
    }
  }

  // Menambah golongan darah baru
  Future<String?> addGolonganDarah(GolonganDarahModel golonganDarah) async {
    try {
      _logger.d('Adding new golongan darah: ${golonganDarah.nama}');
      final docRef = await _golonganDarahCollection.add(golonganDarah.toJson());
      _logger.i('Successfully added golongan darah with id: ${docRef.id}');
      return docRef.id;
    } catch (e, stackTrace) {
      _logger.e('Error adding golongan darah', e, stackTrace);
      return null;
    }
  }

  // Memperbarui golongan darah
  Future<bool> updateGolonganDarah(GolonganDarahModel golonganDarah) async {
    try {
      _logger.d('Updating golongan darah with id: ${golonganDarah.id}');
      await _golonganDarahCollection
          .doc(golonganDarah.id)
          .update(golonganDarah.toJson());
      _logger.i('Successfully updated golongan darah: ${golonganDarah.nama}');
      return true;
    } catch (e, stackTrace) {
      _logger.e(
        'Error updating golongan darah: ${golonganDarah.id}',
        e,
        stackTrace,
      );
      return false;
    }
  }

  // Menghapus golongan darah
  Future<bool> deleteGolonganDarah(String id) async {
    try {
      _logger.d('Deleting golongan darah with id: $id');
      await _golonganDarahCollection.doc(id).delete();
      _logger.i('Successfully deleted golongan darah: $id');
      return true;
    } catch (e, stackTrace) {
      _logger.e('Error deleting golongan darah: $id', e, stackTrace);
      return false;
    }
  }

  // Inisialisasi data golongan darah jika belum ada
  Future<void> initGolonganDarah() async {
    try {
      _logger.d('Initializing golongan darah data');
      final snapshot = await _golonganDarahCollection.get();

      if (snapshot.docs.isEmpty) {
        _logger.i('Golongan darah collection is empty, adding default values');
        await _golonganDarahCollection.add({'nama': 'A'});
        await _golonganDarahCollection.add({'nama': 'B'});
        await _golonganDarahCollection.add({'nama': 'AB'});
        await _golonganDarahCollection.add({'nama': 'O'});
        _logger.i('Default golongan darah data successfully added');
      } else {
        _logger.d(
          'Golongan darah data already exists (${snapshot.docs.length} records)',
        );
      }
    } catch (e, stackTrace) {
      _logger.e('Error initializing golongan darah data', e, stackTrace);
    }
  }
}
