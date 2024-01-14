import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:perpustakaan/src/resources/buku/buku_model.dart';
import 'package:perpustakaan/src/utils/dio.dart';

class BukuRepository {
  static Future<List<Buku>> getAll(String? search) async {
    try {
      final response = await dio.get(
          '/buku${search?.trim().isEmpty ?? true ? '' : '?search=$search'}');
      return (response.data['data'] as List)
          .map((e) => Buku.fromJson(e))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  static Future<Buku> getByNoIsbn(String noIsbn) async {
    try {
      final response = await dio.get('/buku/$noIsbn');
      return Buku.fromJson(response.data['data']);
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> createBuku(Buku buku) async {
    try {
      final formBuku = FormData.fromMap({
        'no_isbn': buku.noIsbn,
        'nama_pengarang': buku.namaPengarang,
        'tgl_cetak': DateFormat('yyyy-MM-dd').format(buku.tglCetak),
        'kondisi': buku.kondisi,
        'harga': buku.harga,
        'jenis': buku.jenis,
        'harga_produksi': buku.hargaProduksi,
      });
      await dio.post(
        '/buku',
        data: formBuku,
      );
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> updateBuku(Buku buku) async {
    try {
      final formBuku = FormData.fromMap({
        'nama_pengarang': buku.namaPengarang,
        'tgl_cetak': DateFormat('yyyy-MM-dd').format(buku.tglCetak),
        'kondisi': buku.kondisi,
        'harga': buku.harga,
        'jenis': buku.jenis,
        'harga_produksi': buku.hargaProduksi,
      });
      await dio.put(
        '/buku/${buku.noIsbn}',
        data: formBuku,
      );
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> deleteBuku(String noIsbn) async {
    try {
      await dio.delete(
        '/buku/$noIsbn',
      );
    } catch (e) {
      rethrow;
    }
  }
}
