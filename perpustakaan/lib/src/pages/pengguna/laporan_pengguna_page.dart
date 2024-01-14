import 'package:flutter/material.dart';
import 'package:perpustakaan/src/components/loading_dialog.dart';
import 'package:perpustakaan/src/formatter/phone_formater.dart';
import 'package:perpustakaan/src/pages/pengguna/pengguna_detail_page.dart';
import 'package:perpustakaan/src/resources/pengguna/pengguna_model.dart';
import 'package:perpustakaan/src/resources/pengguna/pengguna_repository.dart';
import 'package:perpustakaan/src/utils/debouncer.dart';
import 'package:skeletons/skeletons.dart';

class LaporanPenggunaPage extends StatefulWidget {
  const LaporanPenggunaPage({
    super.key,
    required this.onAddBtnClicked,
  });
  final void Function() onAddBtnClicked;

  @override
  State<LaporanPenggunaPage> createState() => _LaporanPenggunaPageState();
}

class _LaporanPenggunaPageState extends State<LaporanPenggunaPage> {
  bool isSelectedMode = false;
  final _debouncerSearch = Debouncer(milliseconds: 500);
  late Future<List<Pengguna>> dataPengguna;
  List<Pengguna> listPengguna = [];
  final TextEditingController _searchController = TextEditingController();
  @override
  void initState() {
    dataPengguna = PenggunaRepository.getAll('');
    super.initState();
  }

  void refresh() {
    setState(() {
      dataPengguna = PenggunaRepository.getAll(_searchController.text);
    });
  }

  int get countSelected {
    return listPengguna.where((element) => element.selected).length;
  }

  void selectPengguna(Pengguna pengguna) {
    setState(() {
      pengguna.selected = !pengguna.selected;
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
    for (var pengguna in listPengguna) {
      await PenggunaRepository.deletePengguna(pengguna.idPengguna);
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
                  if (countSelected < listPengguna.length)
                    IconButton(
                      tooltip: 'Pilih Semua',
                      onPressed: () {
                        setState(() {
                          for (var element in listPengguna) {
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
                        for (var element in listPengguna) {
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
                    countSelected == listPengguna.length
                        ? 'Terpilih semua'
                        : 'Terpilih $countSelected dari ${listPengguna.length}',
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
                hintText: 'Cari Pengguna',
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
                future: dataPengguna,
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
                          child: Row(
                            children: [
                              SkeletonAvatar(
                                style: SkeletonAvatarStyle(
                                  borderRadius: BorderRadius.circular(100),
                                  width: 70,
                                  height: 70,
                                ),
                              ),
                              const SizedBox(
                                width: 16,
                              ),
                              const Column(
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
                              const Spacer(),
                              const Icon(
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
                      listPengguna = snapshot.data!;
                      final pengguna = listPengguna[index];
                      return InkWell(
                        onTap: () async {
                          if (isSelectedMode) {
                            selectPengguna(pengguna);
                          } else {
                            await Navigator.pushNamed(
                              context,
                              DetailPenggunaPage.routeName,
                              arguments: pengguna.idPengguna,
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
                            pengguna.selected = true;
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
                                  value: pengguna.selected,
                                  onChanged: (value) {
                                    selectPengguna(pengguna);
                                  },
                                ),
                              if (pengguna.imgUrl?.isEmpty ?? true)
                                const Icon(
                                  Icons.account_circle_rounded,
                                  size: 48,
                                )
                              else
                                Stack(
                                  children: [
                                    SkeletonAvatar(
                                      style: SkeletonAvatarStyle(
                                        width: 70,
                                        height: 70,
                                        borderRadius: BorderRadius.circular(70),
                                      ),
                                    ),
                                    Container(
                                      width: 70,
                                      height: 70,
                                      clipBehavior: Clip.antiAlias,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        image: DecorationImage(
                                          image: NetworkImage(pengguna.imgUrl!),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              const SizedBox(
                                width: 16,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    pengguna.nama,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                  Text(
                                    PhoneTextInputFormatter()
                                        .formatEditUpdate(
                                          TextEditingValue.empty,
                                          TextEditingValue(
                                              text: pengguna.noTelp),
                                        )
                                        .text,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    pengguna.alamat,
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
