import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:keanggotaan/app/data/models/status_perkawinan_model.dart';
import '../../services/logger_service.dart';

class StatusPerkawinanRepository {
  final CollectionReference _statusPerkawinanCollection = FirebaseFirestore
      .instance
      .collection('jenis_kelamin');

  // Menggunakan LoggerService
  final LoggerService _logger = LoggerService.to;

  // Mendapatkan semua status perkawinan
  Future<List<StatusPerkawinanModel>> getAllStatusPerkawinan() async {
    try {
      _logger.d('Fetching all status perkawinan');
      final snapshot = await _statusPerkawinanCollection.get();

      final result =
          snapshot.docs.map((doc) {
            Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
            data['id'] = doc.id;
            return StatusPerkawinanModel.fromJson(data);
          }).toList();

      _logger.d('Retrieved ${result.length} status perkawinan records');
      return result;
    } catch (e, stackTrace) {
      _logger.e('Error fetching status perkawinan', e, stackTrace);
      return [];
    }
  }

  // Mendapatkan status perkawinan berdasarkan ID
  Future<StatusPerkawinanModel?> getStatusPerkawinanById(String id) async {
    try {
      _logger.d('Fetching status perkawinan with id: $id');
      final doc = await _statusPerkawinanCollection.doc(id).get();

      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        _logger.d('Retrieved status perkawinan: ${data['nama']}');
        return StatusPerkawinanModel.fromJson(data);
      }

      _logger.w('Status Perkawinan with id $id not found');
      return null;
    } catch (e, stackTrace) {
      _logger.e('Error fetching status perkawinan by id: $id', e, stackTrace);
      return null;
    }
  }

  // Menambah status perkawinan baru
  Future<String?> addStatusPerkawinan(
    StatusPerkawinanModel statusPerkawinan,
  ) async {
    try {
      _logger.d('Adding new status perkawinan: ${statusPerkawinan.nama}');
      final docRef = await _statusPerkawinanCollection.add(
        statusPerkawinan.toJson(),
      );
      _logger.i('Successfully added status perkawinan with id: ${docRef.id}');
      return docRef.id;
    } catch (e, stackTrace) {
      _logger.e('Error adding status perkawinan', e, stackTrace);
      return null;
    }
  }

  // Memperbarui status perkawinan
  Future<bool> updateStatusPerkawinan(
    StatusPerkawinanModel statusPerkawinan,
  ) async {
    try {
      _logger.d('Updating status perkawinan with id: ${statusPerkawinan.id}');
      await _statusPerkawinanCollection
          .doc(statusPerkawinan.id)
          .update(statusPerkawinan.toJson());
      _logger.i(
        'Successfully updated status perkawinan: ${statusPerkawinan.nama}',
      );
      return true;
    } catch (e, stackTrace) {
      _logger.e(
        'Error updating status perkawinan: ${statusPerkawinan.id}',
        e,
        stackTrace,
      );
      return false;
    }
  }

  // Menghapus status perkawinan
  Future<bool> deleteStatusPerkawinan(String id) async {
    try {
      _logger.d('Deleting status perkawinan with id: $id');
      await _statusPerkawinanCollection.doc(id).delete();
      _logger.i('Successfully deleted status perkawinan: $id');
      return true;
    } catch (e, stackTrace) {
      _logger.e('Error deleting status perkawinan: $id', e, stackTrace);
      return false;
    }
  }

  // Inisialisasi data status perkawinan jika belum ada
  Future<void> initStatusPerkawinan() async {
    try {
      _logger.d('Initializing status perkawinan data');
      final snapshot = await _statusPerkawinanCollection.get();

      if (snapshot.docs.isEmpty) {
        _logger.i(
          'Status Perkawinan collection is empty, adding default values',
        );
        await _statusPerkawinanCollection.add({'nama': 'Belum kawin'});
        await _statusPerkawinanCollection.add({'nama': 'Kawin'});
        await _statusPerkawinanCollection.add({'nama': 'Cerai hidup'});
        await _statusPerkawinanCollection.add({'nama': 'Cerai mati'});
        _logger.i('Default status perkawinan data successfully added');
      } else {
        _logger.d(
          'Status Perkawinan data already exists (${snapshot.docs.length} records)',
        );
      }
    } catch (e, stackTrace) {
      _logger.e('Error initializing status perkawinan data', e, stackTrace);
    }
  }
}
