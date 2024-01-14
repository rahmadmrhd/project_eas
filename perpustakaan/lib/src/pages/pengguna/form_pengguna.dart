import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:perpustakaan/src/components/loading_dialog.dart';
import 'package:perpustakaan/src/formatter/phone_formater.dart';
import 'package:perpustakaan/src/resources/pengguna/pengguna_model.dart';
import 'package:perpustakaan/src/resources/pengguna/pengguna_repository.dart';
import 'package:perpustakaan/src/utils/validator.dart';
import 'package:skeletons/skeletons.dart';

class FormPengguna extends StatefulWidget {
  const FormPengguna({super.key, this.idPengguna});
  final String? idPengguna;
  static const routeName = '/form_pengguna';

  @override
  State<FormPengguna> createState() => _FormPenggunaState();
}

class _FormPenggunaState extends State<FormPengguna> {
  Future<void>? dataPengguna;
  @override
  void initState() {
    super.initState();
  }

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _idPengguna = TextEditingController();
  final TextEditingController _nama = TextEditingController();
  final TextEditingController _tglDaftar = TextEditingController();
  final TextEditingController _alamat = TextEditingController();
  final TextEditingController _noTelp = TextEditingController();
  DateTime? _dateTime;
  String _foto = '';
  String _urlFoto = '';
  String? _imageUpload;

  final ImagePicker picker = ImagePicker();
  Future<void> pilihFoto() async {
    if (picker.supportsImageSource(ImageSource.camera)) {
      bool? isCamera = await showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(
            height: 140,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20), topRight: Radius.circular(20)),
              color: Colors.white,
            ),
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.only(top: 18, bottom: 18),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                // alignment: MainAxisAlignment.center,
                children: [
                  // const Text('Modal BottomSheet'),
                  TextButton(
                    style: ButtonStyle(
                      shape: MaterialStatePropertyAll(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(0),
                        ),
                      ),
                      textStyle: const MaterialStatePropertyAll<TextStyle>(
                        TextStyle(
                          color: Colors.black87,
                          fontSize: 18,
                        ),
                      ),
                      foregroundColor:
                          const MaterialStatePropertyAll(Colors.black87),
                    ),
                    onPressed: () => Navigator.pop(context, true),
                    child: Container(
                      height: 36,
                      alignment: Alignment.center,
                      width: double.infinity,
                      child: const Text("Kamera"),
                    ),
                  ),
                  TextButton(
                    style: ButtonStyle(
                      shape: MaterialStatePropertyAll(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(0),
                        ),
                      ),
                      textStyle: const MaterialStatePropertyAll<TextStyle>(
                        TextStyle(
                          color: Colors.black87,
                          fontSize: 18,
                        ),
                      ),
                      foregroundColor:
                          const MaterialStatePropertyAll(Colors.black87),
                    ),
                    onPressed: () => Navigator.pop(context, false),
                    child: Container(
                      height: 36,
                      alignment: Alignment.center,
                      width: double.infinity,
                      child: const Text("Galeri"),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
      if (isCamera == null) return;

      if (isCamera) {
        var image = await picker.pickImage(source: ImageSource.camera);
        if (image == null) return;
        setState(() {
          _imageUpload = image.path;
        });
        return;
      }
    }

    FilePickerResult? photo = await FilePicker.platform.pickFiles(
      dialogTitle: 'Pilih Foto',
      type: FileType.image,
      allowMultiple: false,
    );

    if (photo != null) {
      setState(() {
        _imageUpload = photo.files.single.path;
      });
    }
  }

  Future<void> getData(String idPengguna) async {
    final response = await PenggunaRepository.getByIdPengguna(idPengguna);
    setState(() {
      _idPengguna.text = response.idPengguna;
      _nama.text = response.nama;
      _dateTime = response.tglDaftar;
      _tglDaftar.text = DateFormat('dd MMMM yyyy').format(response.tglDaftar);
      _alamat.text = response.alamat;
      _noTelp.text = PhoneTextInputFormatter()
          .formatEditUpdate(
            TextEditingValue.empty,
            TextEditingValue(text: response.noTelp),
          )
          .text;
      _foto = response.foto;
      _urlFoto = response.imgUrl ?? '';
    });
  }

  void saveData(String? idPengguna) async {
    if (!_formKey.currentState!.validate()) return;
    if (_imageUpload == null && _foto.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Tidak ada gambar yang diupload'),
      ));
      return;
    }
    loadingDialog(context);
    final pengguna = Pengguna(
      idPengguna: _idPengguna.text,
      nama: _nama.text,
      alamat: _alamat.text,
      noTelp:
          _noTelp.text.replaceAll(RegExp(r'-'), '').replaceFirst('(+62) ', ''),
      tglDaftar: _dateTime!,
      foto: _foto,
      imgPath: _imageUpload,
    );
    try {
      if (idPengguna == null) {
        await PenggunaRepository.createPengguna(pengguna);
        if (!mounted) return;
        Navigator.of(context).pop(); //dismis loading dialog

        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Data buku berhasil ditambahkan'),
        ));
        _idPengguna.clear();
        _nama.clear();
        _tglDaftar.clear();
        _alamat.clear();
        _noTelp.clear();
        setState(() {
          _dateTime = null;
          _imageUpload = null;
        });
      } else {
        await PenggunaRepository.updatePengguna(pengguna);
        if (!mounted) return;
        Navigator.of(context).pop(); //dismis loading dialog
        Navigator.of(context).pop();
      }
    } catch (e) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.toString()),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final idPengguna = ModalRoute.of(context)!.settings.arguments as String?;
    if (idPengguna != null && dataPengguna == null) {
      dataPengguna = getData(idPengguna);
    }
    return Scaffold(
      appBar: idPengguna == null
          ? null
          : AppBar(
              title: const Text('Form Pengguna'),
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
            ),
      bottomSheet: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: const RoundedRectangleBorder(),
                fixedSize: const Size.fromHeight(56),
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
              ),
              onPressed: () => saveData(idPengguna),
              child: const Text(
                'SIMPAN',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 5,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: FutureBuilder(
          future: dataPengguna,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 24),
                    SkeletonAvatar(
                      style: SkeletonAvatarStyle(
                        width: 150,
                        height: 150,
                        borderRadius: BorderRadius.circular(75),
                      ),
                    ),
                    const SizedBox(height: 48),
                    Expanded(
                      child: ListView.separated(
                        itemCount: 5,
                        separatorBuilder: (BuildContext context, int index) =>
                            const SizedBox(height: 12),
                        itemBuilder: (BuildContext context, int index) {
                          return const SkeletonLine(
                            style: SkeletonLineStyle(height: 56),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            } else {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        const SizedBox(height: 24),
                        Stack(
                          children: [
                            Container(
                              width: 150,
                              height: 150,
                              clipBehavior: Clip.antiAlias,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                image: DecorationImage(
                                  image: _imageUpload != null
                                      ? FileImage(File(_imageUpload!))
                                      : _urlFoto.isNotEmpty
                                          ? NetworkImage(_urlFoto)
                                          : const AssetImage(
                                                  'assets/images/empty.jpg')
                                              as ImageProvider,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      Theme.of(context).colorScheme.background,
                                  padding: const EdgeInsets.all(0),
                                  shape: const CircleBorder(
                                    side: BorderSide.none,
                                  ),
                                  shadowColor: Colors.grey,
                                  elevation: 3,
                                ),
                                onPressed: pilihFoto,
                                child: const Icon(Icons.edit),
                              ),
                            )
                          ],
                        ),
                        const SizedBox(height: 48),
                        TextFormField(
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          controller: _idPengguna,
                          enabled: idPengguna == null,
                          decoration: const InputDecoration(
                            labelText: 'ID Pengguna',
                          ),
                          validator: (value) {
                            final result = validatorNotEmpty(value);
                            if (result == null) return null;
                            return 'ID Pengguna $result';
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          controller: _nama,
                          decoration: const InputDecoration(
                            labelText: 'Nama Pengguna',
                          ),
                          validator: (value) {
                            final result = validatorNotEmpty(value);
                            if (result == null) return null;
                            return 'Nama Pengguna $result';
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          controller: _alamat,
                          decoration: const InputDecoration(
                            labelText: 'Alamat Pengguna',
                          ),
                          validator: (value) {
                            final result = validatorNotEmpty(value);
                            if (result == null) return null;
                            return 'Alamat Pengguna $result';
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          controller: _tglDaftar,
                          readOnly: true,
                          decoration: const InputDecoration(
                            labelText: 'Tanggal Daftar',
                          ),
                          validator: (value) {
                            final result = validatorNotEmpty(value);
                            if (result == null) return null;
                            return 'Tanggal Pengguna $result';
                          },
                          onTap: () async {
                            DateTime? pickedDate = await showDatePicker(
                                context: context,
                                initialEntryMode:
                                    DatePickerEntryMode.calendarOnly,
                                initialDate: _dateTime,
                                firstDate: DateTime(1970),
                                lastDate: DateTime.now());
                            _tglDaftar.text = pickedDate != null
                                ? DateFormat('dd MMMM yyyy').format(pickedDate)
                                : _tglDaftar.text;
                            setState(() {
                              _dateTime = pickedDate ?? _dateTime;
                            });
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          controller: _noTelp,
                          keyboardType: TextInputType.phone,
                          textInputAction: TextInputAction.next,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            PhoneTextInputFormatter()
                          ],
                          decoration: const InputDecoration(
                            labelText: 'No Telepon',
                          ),
                          validator: (value) {
                            final result = validatorNotEmpty(value);
                            if (result == null) return null;
                            return 'No Telepon $result';
                          },
                        ),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
