import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:perpustakaan/src/resources/pengguna/pengguna_model.dart';
import 'package:perpustakaan/src/utils/dio.dart';

class PenggunaRepository {
  static Future<List<Pengguna>> getAll(String? search) async {
    try {
      final response = await dio.get(
          '/pengguna${search?.trim().isEmpty ?? true ? '' : '?search=$search'}');
      return (response.data['data'] as List)
          .map((e) => Pengguna.fromJson(e))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  static Future<Pengguna> getByIdPengguna(String noIsbn) async {
    try {
      final response = await dio.get('/pengguna/$noIsbn');
      return Pengguna.fromJson(response.data['data']);
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> createPengguna(Pengguna pengguna) async {
    try {
      final formPengguna = FormData.fromMap({
        'id_pengguna': pengguna.idPengguna,
        'nama': pengguna.nama,
        'alamat': pengguna.alamat,
        'no_telp': pengguna.noTelp,
        'tgl_daftar': DateFormat('yyyy-MM-dd').format(pengguna.tglDaftar),
        'foto': pengguna.imgPath != null
            ? await MultipartFile.fromFile(pengguna.imgPath!)
            : pengguna.foto,
      });
      await dio.post(
        '/pengguna',
        data: formPengguna,
      );
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> updatePengguna(Pengguna pengguna) async {
    try {
      final formPengguna = FormData.fromMap({
        'id_pengguna': pengguna.idPengguna,
        'nama': pengguna.nama,
        'alamat': pengguna.alamat,
        'no_telp': pengguna.noTelp,
        'tgl_daftar': DateFormat('yyyy-MM-dd').format(pengguna.tglDaftar),
        'foto': pengguna.imgPath != null
            ? await MultipartFile.fromFile(pengguna.imgPath!)
            : pengguna.foto,
      });
      await dio.put(
        '/pengguna/${pengguna.idPengguna}',
        data: formPengguna,
      );
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> deletePengguna(String idPengguna) async {
    try {
      await dio.delete(
        '/pengguna/$idPengguna',
      );
    } catch (e) {
      rethrow;
    }
  }
}
