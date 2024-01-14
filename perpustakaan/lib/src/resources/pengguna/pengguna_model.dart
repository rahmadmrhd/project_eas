import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:perpustakaan/src/formatter/phone_formater.dart';

class Pengguna {
  final String idPengguna;
  final String nama;
  final String alamat;
  final DateTime tglDaftar;
  final String noTelp;
  final String foto;
  final String? imgUrl;
  final String? imgPath;
  bool selected = false;

  Pengguna({
    required this.idPengguna,
    required this.nama,
    required this.alamat,
    required this.tglDaftar,
    required this.noTelp,
    required this.foto,
    this.imgUrl,
    this.imgPath,
  });

  factory Pengguna.fromJson(Map<String, dynamic> json) {
    return Pengguna(
      idPengguna: json['id_pengguna'],
      nama: json['nama'],
      alamat: json['alamat'],
      tglDaftar:
          DateTime.tryParse(json['tgl_daftar'])?.toLocal() ?? DateTime.now(),
      noTelp: json['no_telp'],
      foto: json['foto'],
      imgUrl: 'https://7fn1bhg9-3000.asse.devtunnels.ms/images/${json['foto']}',
    );
  }

  Map<String, String> toMap() {
    return {
      'ID Pengguna': idPengguna,
      'Nama': nama,
      'Alamat': alamat,
      'Tanggal Daftar': DateFormat('dd MMMM yyyy').format(tglDaftar),
      'No. Telp': PhoneTextInputFormatter()
          .formatEditUpdate(
            TextEditingValue.empty,
            TextEditingValue(text: noTelp),
          )
          .text,
    };
  }
}
