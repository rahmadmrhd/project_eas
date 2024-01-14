import 'package:flutter/material.dart';
import 'package:perpustakaan/src/components/loading_dialog.dart';
import 'package:perpustakaan/src/pages/pengguna/form_pengguna.dart';
import 'package:perpustakaan/src/resources/pengguna/pengguna_model.dart';
import 'package:perpustakaan/src/resources/pengguna/pengguna_repository.dart';
import 'package:skeletons/skeletons.dart';

class DetailPenggunaPage extends StatefulWidget {
  const DetailPenggunaPage({super.key});
  static const routeName = '/detail_pengguna';

  @override
  State<DetailPenggunaPage> createState() => _DetailPenggunaPageState();
}

class _DetailPenggunaPageState extends State<DetailPenggunaPage> {
  Future<Pengguna>? dataPengguna;
  String? idPengguna;

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
    await PenggunaRepository.deletePengguna(idPengguna!);
    if (!context.mounted) return;

    Navigator.pop(context); // dismiss loading dialog
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    idPengguna ??= ModalRoute.of(context)!.settings.arguments as String;
    dataPengguna ??= PenggunaRepository.getByIdPengguna(idPengguna!);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        title: const Text("Detail Pengguna"),
        actions: [
          IconButton(
            tooltip: "Ubah",
            icon: const Icon(Icons.edit),
            onPressed: () async {
              await Navigator.pushNamed(
                context,
                FormPengguna.routeName,
                arguments: idPengguna!,
              );
              setState(() {
                dataPengguna = PenggunaRepository.getByIdPengguna(idPengguna!);
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
              dataPengguna = PenggunaRepository.getByIdPengguna(idPengguna!);
            });
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: FutureBuilder(
              future: dataPengguna ??
                  PenggunaRepository.getByIdPengguna(idPengguna!),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Column(
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
                  final pengguna = snapshot.data!;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 24),
                      pengguna.imgUrl?.isEmpty ?? true
                          ? const Icon(
                              Icons.account_circle_rounded,
                              size: 150,
                            )
                          : Container(
                              width: 150,
                              height: 150,
                              clipBehavior: Clip.antiAlias,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                image: DecorationImage(
                                  image: NetworkImage(pengguna.imgUrl!),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                      const SizedBox(height: 48),
                      Expanded(
                        child: ListView.separated(
                          itemCount: pengguna.toMap().entries.length,
                          separatorBuilder: (BuildContext context, int index) =>
                              const Divider(height: 0),
                          itemBuilder: (BuildContext context, int index) {
                            final item =
                                pengguna.toMap().entries.elementAt(index);
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
