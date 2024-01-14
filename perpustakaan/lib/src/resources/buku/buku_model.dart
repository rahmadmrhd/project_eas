import 'package:intl/intl.dart';

class Buku {
  final String noIsbn;
  final String namaPengarang;
  final DateTime tglCetak;
  final bool kondisi;
  final int harga;
  final String jenis;
  final int hargaProduksi;
  bool selected = false;

  Buku({
    required this.noIsbn,
    required this.namaPengarang,
    required this.tglCetak,
    required this.kondisi,
    required this.harga,
    required this.jenis,
    required this.hargaProduksi,
  });

  factory Buku.fromJson(Map<String, dynamic> json) {
    return Buku(
      noIsbn: json['no_isbn'],
      namaPengarang: json['nama_pengarang'],
      tglCetak:
          DateTime.tryParse(json['tgl_cetak'])?.toLocal() ?? DateTime.now(),
      kondisi: json['kondisi'] > 0,
      jenis: json['jenis'],
      harga: json['harga'],
      hargaProduksi: json['harga_produksi'],
    );
  }

  Map<String, String> toMap() {
    return {
      'No ISBN': noIsbn,
      'Pengarang': namaPengarang,
      'Tgl Cetak': DateFormat('dd MMMM yyyy').format(tglCetak),
      'Kondisi': kondisi ? 'Baik' : 'Rusak',
      'Jenis': jenis,
      'Harga': 'Rp. ${NumberFormat('#,###', 'id-ID').format(harga)}',
      'Harga Produksi':
          'Rp. ${NumberFormat('#,###', 'id-ID').format(hargaProduksi)}',
    };
  }
}
