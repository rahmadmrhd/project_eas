import 'package:flutter/material.dart';
import 'package:perpustakaan/src/models/menu_item_model.dart';
import 'package:perpustakaan/src/pages/buku/form_buku.dart';
import 'package:perpustakaan/src/pages/buku/laporan_buku_page.dart';
import 'package:perpustakaan/src/pages/pengguna/form_pengguna.dart';
import 'package:perpustakaan/src/pages/pengguna/laporan_pengguna_page.dart';
import 'package:perpustakaan/src/pages/signin_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});
  static const routeName = '/main';

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  List<MenuItem> listMenu = [];
  late MenuItem _currentMenu;
  _MainPageState() {
    listMenu = [
      MenuItem(
        title: 'Laporan Buku',
        icon: Icons.my_library_books_rounded,
        screen: LaporanBukuPage(
          onAddBtnClicked: () {
            setState(() {
              _currentMenu = listMenu[2];
            });
          },
        ),
      ),
      MenuItem(
        title: 'Laporan Pengguna',
        icon: Icons.group,
        screen: LaporanPenggunaPage(
          onAddBtnClicked: () {
            setState(() {
              _currentMenu = listMenu[3];
            });
          },
        ),
      ),
      MenuItem(
        title: 'Buku',
        icon: Icons.book,
        screen: const FormBuku(),
      ),
      MenuItem(
        title: 'Pengguna',
        icon: Icons.person,
        screen: const FormPengguna(),
      ),
    ];
    _currentMenu = listMenu[0];
  }

  void logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user');
    if (mounted) Navigator.pushReplacementNamed(context, SigninPage.routeName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_currentMenu.title),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      drawer: Drawer(
        backgroundColor: Theme.of(context).colorScheme.onBackground,
        child: SafeArea(
          child: Column(
            children: [
              ...listMenu.map((menu) {
                return ListTile(
                  tileColor: menu == _currentMenu
                      ? Theme.of(context).colorScheme.surfaceTint
                      : null,
                  iconColor: Theme.of(context).colorScheme.background,
                  textColor: Theme.of(context).colorScheme.background,
                  leading: Icon(menu.icon),
                  title: Text(menu.title),
                  onTap: () {
                    setState(() {
                      _currentMenu = menu;
                    });
                    Navigator.pop(context);
                  },
                );
              }),
              const Spacer(),
              const Divider(
                height: 0,
              ),
              ListTile(
                // tileColor: Theme.of(context).colorScheme.error,
                iconColor: Theme.of(context).colorScheme.onError,
                textColor: Theme.of(context).colorScheme.onError,
                leading: const Icon(
                  Icons.account_circle,
                  size: 32,
                ),
                trailing: IconButton(
                  style: IconButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.error,
                    foregroundColor: Theme.of(context).colorScheme.onError,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.all(8),
                    fixedSize: const Size(42, 42),
                  ),
                  onPressed: logout,
                  icon: const Icon(Icons.logout),
                ),
                subtitle: const Text(
                  '1462200017',
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
                title: const Text(
                  'Rahmad Maulana',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: _currentMenu.screen,
    );
  }
}
