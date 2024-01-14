import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:perpustakaan/src/components/loading_dialog.dart';
import 'package:perpustakaan/src/pages/buku/buku_detail_page.dart';
import 'package:perpustakaan/src/resources/buku/buku_model.dart';
import 'package:perpustakaan/src/resources/buku/buku_repository.dart';
import 'package:perpustakaan/src/utils/debouncer.dart';
import 'package:skeletons/skeletons.dart';

class LaporanBukuPage extends StatefulWidget {
  const LaporanBukuPage({
    super.key,
    required this.onAddBtnClicked,
  });
  final void Function() onAddBtnClicked;

  @override
  State<LaporanBukuPage> createState() => _LaporanBukuPageState();
}

class _LaporanBukuPageState extends State<LaporanBukuPage> {
  bool isSelectedMode = false;
  final _debouncerSearch = Debouncer(milliseconds: 500);
  late Future<List<Buku>> dataBuku;
  List<Buku> listBuku = [];
  final TextEditingController _searchController = TextEditingController();
  @override
  void initState() {
    dataBuku = BukuRepository.getAll('');
    super.initState();
  }

  void refresh() {
    setState(() {
      dataBuku = BukuRepository.getAll(_searchController.text);
    });
  }

  int get countSelected {
    return listBuku.where((element) => element.selected).length;
  }

  void selectBuku(Buku buku) {
    setState(() {
      buku.selected = !buku.selected;
      if (countSelected <= 0) {
        isSelectedMode = false;
      }
    });
  }

  void removeData() async {
    bool result = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: const Text('Yakin untuk menghapus data ini?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('Ok'),
            ),
          ],
        );
      },
    );
    if (!result) return;
    if (!context.mounted) return;

    loadingDialog(context);
    for (var buku in listBuku) {
      await BukuRepository.deleteBuku(buku.noIsbn);
    }
    if (!context.mounted) return;

    Navigator.pop(context); // dismiss loading dialog
    refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: isSelectedMode
          ? null
          : FloatingActionButton(
              child: const Icon(Icons.add),
              onPressed: () async {
                widget.onAddBtnClicked();
              },
            ),
      bottomSheet: !isSelectedMode
          ? null
          : Container(
              height: 64,
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  if (countSelected < listBuku.length)
                    IconButton(
                      tooltip: 'Pilih Semua',
                      onPressed: () {
                        setState(() {
                          for (var element in listBuku) {
                            element.selected = true;
                          }
                        });
                      },
                      icon: const Icon(Icons.select_all),
                    ),
                  IconButton(
                    tooltip: 'Batal',
                    onPressed: () {
                      setState(() {
                        for (var element in listBuku) {
                          element.selected = false;
                        }
                        isSelectedMode = false;
                      });
                    },
                    icon: const Icon(Icons.close),
                  ),
                  const Spacer(),
                  const SizedBox(width: 12),
                  Text(
                    countSelected == listBuku.length
                        ? 'Terpilih semua'
                        : 'Terpilih $countSelected dari ${listBuku.length}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const Spacer(),
                  IconButton(
                    tooltip: 'Hapus Terpilih',
                    onPressed: removeData,
                    icon: Icon(
                      Icons.delete,
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
              ),
            ),
      body: RefreshIndicator(
        onRefresh: () async {
          refresh();
        },
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Cari Buku',
                border: UnderlineInputBorder(),
                focusedBorder: UnderlineInputBorder(),
                suffixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                _debouncerSearch.run(refresh);
              },
            ),
            Expanded(
              child: FutureBuilder(
                future: dataBuku,
                builder: (context, snapshot) {
                  return ListView.builder(
                    itemCount:
                        snapshot.connectionState == ConnectionState.waiting
                            ? 8
                            : snapshot.hasError || !snapshot.hasData
                                ? 1
                                : snapshot.data!.length,
                    itemBuilder: (context, index) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Container(
                          height: 100,
                          padding: const EdgeInsets.all(16),
                          decoration: const BoxDecoration(
                            border: Border.symmetric(
                              horizontal: BorderSide(
                                color: Colors.black12,
                                width: 1,
                              ),
                            ),
                          ),
                          child: const Row(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SkeletonLine(
                                    style: SkeletonLineStyle(
                                      width: 150,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  SkeletonLine(
                                    style: SkeletonLineStyle(
                                      width: 100,
                                      height: 8,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  SkeletonLine(
                                    style: SkeletonLineStyle(
                                      width: 100,
                                      height: 8,
                                    ),
                                  ),
                                ],
                              ),
                              Spacer(),
                              Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 16,
                              ),
                            ],
                          ),
                        );
                      } else if (snapshot.hasError) {
                        return Center(
                            child:
                                Text('Error : ${snapshot.error.toString()}'));
                      } else if (!snapshot.hasData) {
                        return const Center(child: Text('Data Kosong'));
                      }
                      listBuku = snapshot.data!;
                      final buku = listBuku[index];
                      return InkWell(
                        onTap: () async {
                          if (isSelectedMode) {
                            selectBuku(buku);
                          } else {
                            await Navigator.pushNamed(
                              context,
                              DetailBukuPage.routeName,
                              arguments: buku.noIsbn,
                            );
                            setState(() {
                              isSelectedMode = false;
                            });
                            refresh();
                          }
                        },
                        onLongPress: () {
                          setState(() {
                            isSelectedMode = true;
                            buku.selected = true;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: const BoxDecoration(
                            border: Border.symmetric(
                              horizontal: BorderSide(
                                color: Colors.black12,
                                width: 1,
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              if (isSelectedMode)
                                Checkbox(
                                  value: buku.selected,
                                  onChanged: (value) {
                                    selectBuku(buku);
                                  },
                                ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    buku.noIsbn,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                  Text(
                                    buku.namaPengarang,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    DateFormat('dd MMMM yyyy')
                                        .format(buku.tglCetak),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                              const Spacer(),
                              const Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 16,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
