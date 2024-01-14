import 'package:flutter/material.dart';
import 'package:perpustakaan/src/components/loading_dialog.dart';
import 'package:perpustakaan/src/pages/buku/form_buku.dart';
import 'package:perpustakaan/src/resources/buku/buku_model.dart';
import 'package:perpustakaan/src/resources/buku/buku_repository.dart';
import 'package:skeletons/skeletons.dart';

class DetailBukuPage extends StatefulWidget {
  const DetailBukuPage({super.key});
  static const routeName = '/detail_buku';

  @override
  State<DetailBukuPage> createState() => _DetailBukuPageState();
}

class _DetailBukuPageState extends State<DetailBukuPage> {
  Future<Buku>? dataBuku;
  String? noIsbn;

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
    await BukuRepository.deleteBuku(noIsbn!);
    if (!context.mounted) return;

    Navigator.pop(context); // dismiss loading dialog
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    noIsbn ??= ModalRoute.of(context)!.settings.arguments as String;
    dataBuku ??= BukuRepository.getByNoIsbn(noIsbn!);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        title: const Text("Detail Buku"),
        actions: [
          IconButton(
            tooltip: "Ubah",
            icon: const Icon(Icons.edit),
            onPressed: () async {
              await Navigator.pushNamed(
                context,
                FormBuku.routeName,
                arguments: noIsbn!,
              );
              setState(() {
                dataBuku = BukuRepository.getByNoIsbn(noIsbn!);
              });
            },
          ),
          IconButton(
            tooltip: "Hapus",
            icon: const Icon(Icons.delete),
            onPressed: removeData,
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            setState(() {
              dataBuku = BukuRepository.getByNoIsbn(noIsbn!);
            });
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: FutureBuilder(
              future: dataBuku ?? BukuRepository.getByNoIsbn(noIsbn!),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: ListView.separated(
                          itemCount: 7,
                          separatorBuilder: (BuildContext context, int index) =>
                              const Divider(height: 0),
                          itemBuilder: (BuildContext context, int index) {
                            return const ListTile(
                              title: SkeletonLine(
                                style: SkeletonLineStyle(width: 200),
                              ),
                              subtitle: SkeletonLine(
                                style: SkeletonLineStyle(width: 100),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text('Error : ${snapshot.error.toString()}'),
                  );
                } else {
                  final buku = snapshot.data!;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: ListView.separated(
                          itemCount: buku.toMap().entries.length,
                          separatorBuilder: (BuildContext context, int index) =>
                              const Divider(height: 0),
                          itemBuilder: (BuildContext context, int index) {
                            final item = buku.toMap().entries.elementAt(index);
                            return ListTile(
                              title: Text(
                                item.key,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(item.value),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}
