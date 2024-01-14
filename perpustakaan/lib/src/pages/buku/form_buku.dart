import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:perpustakaan/src/components/loading_dialog.dart';
import 'package:perpustakaan/src/formatter/currency_formatter.dart';
import 'package:perpustakaan/src/resources/buku/buku_model.dart';
import 'package:perpustakaan/src/resources/buku/buku_repository.dart';
import 'package:perpustakaan/src/utils/validator.dart';
import 'package:skeletons/skeletons.dart';

class FormBuku extends StatefulWidget {
  const FormBuku({super.key, this.noIsbn});
  final String? noIsbn;
  static const routeName = '/form_buku';

  @override
  State<FormBuku> createState() => _FormBukuState();
}

class _FormBukuState extends State<FormBuku> {
  Future<void>? dataBuku;
  @override
  void initState() {
    super.initState();
  }

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _noIsbn = TextEditingController();
  final TextEditingController _namaPengarang = TextEditingController();
  final TextEditingController _tglCetak = TextEditingController();
  final TextEditingController _harga = TextEditingController();
  final TextEditingController _hargaProduksi = TextEditingController();
  DateTime? _dateTime;
  bool? _kondisi;
  String? _jenis;

  Future<void> getData(String noIsbn) async {
    final response = await BukuRepository.getByNoIsbn(noIsbn);
    setState(() {
      _noIsbn.text = response.noIsbn;
      _namaPengarang.text = response.namaPengarang;
      _tglCetak.text = DateFormat('dd MMMM yyyy').format(response.tglCetak);
      _kondisi = response.kondisi;
      _harga.text =
          'Rp. ${NumberFormat('#,###', 'id-ID').format(response.harga)}';
      _hargaProduksi.text =
          'Rp. ${NumberFormat('#,###', 'id-ID').format(response.hargaProduksi)}';
      _dateTime = response.tglCetak;
      _jenis = response.jenis;
    });
  }

  void saveData(String? noIsbn) async {
    if (!_formKey.currentState!.validate()) return;
    loadingDialog(context);
    final buku = Buku(
      noIsbn: _noIsbn.text,
      namaPengarang: _namaPengarang.text,
      tglCetak: _dateTime!,
      kondisi: _kondisi!,
      harga: int.tryParse(
            _harga.text.replaceAll(RegExp(r'\.'), '').replaceFirst('Rp ', ''),
          ) ??
          0,
      jenis: _jenis!,
      hargaProduksi: int.tryParse(
            _hargaProduksi.text
                .replaceAll(RegExp(r'\.'), '')
                .replaceFirst('Rp ', ''),
          ) ??
          0,
    );
    try {
      if (noIsbn == null) {
        await BukuRepository.createBuku(buku);
        if (!mounted) return;
        Navigator.of(context).pop(); //dismis loading dialog
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Data buku berhasil ditambahkan'),
        ));
        _noIsbn.clear();
        _namaPengarang.clear();
        _tglCetak.clear();
        _harga.clear();
        _hargaProduksi.clear();
        setState(() {
          _dateTime = null;
          _kondisi = null;
          _jenis = null;
        });
        _formKey.currentState!.reset();
      } else {
        await BukuRepository.updateBuku(buku);
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
    final noIsbn = ModalRoute.of(context)!.settings.arguments as String?;
    if (noIsbn != null && dataBuku == null) {
      dataBuku = getData(noIsbn);
    }
    return Scaffold(
      appBar: noIsbn == null
          ? null
          : AppBar(
              title: const Text('Form Buku'),
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
              onPressed: () => saveData(noIsbn),
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
          future: dataBuku,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 12),
                    Expanded(
                      child: ListView.separated(
                        itemCount: 7,
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
                        const SizedBox(height: 12),
                        TextFormField(
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          controller: _noIsbn,
                          enabled: noIsbn == null,
                          decoration: const InputDecoration(
                            labelText: 'No ISBN',
                          ),
                          validator: (value) {
                            final result = validatorNotEmpty(value);
                            if (result == null) return null;
                            return 'No ISBN $result';
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          controller: _namaPengarang,
                          decoration: const InputDecoration(
                            labelText: 'Nama Pengarang',
                          ),
                          validator: (value) {
                            final result = validatorNotEmpty(value);
                            if (result == null) return null;
                            return 'Nama Pengarang $result';
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          controller: _tglCetak,
                          readOnly: true,
                          decoration: const InputDecoration(
                            labelText: 'Tanggal Daftar',
                          ),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Tanggal Daftar harus diisi';
                            }
                            return null;
                          },
                          onTap: () async {
                            DateTime? pickedDate = await showDatePicker(
                                context: context,
                                initialEntryMode:
                                    DatePickerEntryMode.calendarOnly,
                                initialDate: _dateTime,
                                firstDate: DateTime(1970),
                                lastDate: DateTime.now());
                            _tglCetak.text = pickedDate != null
                                ? DateFormat('dd MMMM yyyy').format(pickedDate)
                                : _tglCetak.text;
                            setState(() {
                              _dateTime = pickedDate ?? _dateTime;
                            });
                          },
                        ),
                        const SizedBox(height: 12),
                        RadioMenuButton(
                          value: false,
                          groupValue: _kondisi,
                          onChanged: (val) {
                            setState(() {
                              _kondisi = val;
                            });
                          },
                          child: const Text('Rusak'),
                        ),
                        RadioMenuButton(
                          value: true,
                          groupValue: _kondisi,
                          onChanged: (val) {
                            setState(() {
                              _kondisi = val;
                            });
                          },
                          child: const Text('Baik'),
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField(
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          value: _jenis,
                          decoration: const InputDecoration(
                            labelText: 'Jenis',
                          ),
                          items: ['Teknik', 'Seni', 'Ekonomi', 'Humaniora']
                              .map(
                                (item) => DropdownMenuItem(
                                  value: item,
                                  child: Text(item),
                                ),
                              )
                              .toList(),
                          onChanged: (val) {
                            setState(() {
                              _jenis = val.toString();
                            });
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          controller: _harga,
                          keyboardType: const TextInputType.numberWithOptions(
                            signed: false,
                            decimal: false,
                          ),
                          textInputAction: TextInputAction.next,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            CurrencyFormatter()
                          ],
                          decoration: const InputDecoration(
                            labelText: 'Harga',
                          ),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Harga harus diisi';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          controller: _hargaProduksi,
                          keyboardType: const TextInputType.numberWithOptions(
                            signed: false,
                            decimal: false,
                          ),
                          textInputAction: TextInputAction.next,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            CurrencyFormatter()
                          ],
                          decoration: const InputDecoration(
                            labelText: 'Harga Produksi',
                          ),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Harga Produksi harus diisi';
                            }
                            return null;
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
