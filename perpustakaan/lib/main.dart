import 'package:flutter/material.dart';
import 'package:perpustakaan/src/pages/buku/buku_detail_page.dart';
import 'package:perpustakaan/src/pages/buku/form_buku.dart';
import 'package:perpustakaan/src/pages/main_page.dart';
import 'package:perpustakaan/src/pages/pengguna/form_pengguna.dart';
import 'package:perpustakaan/src/pages/pengguna/pengguna_detail_page.dart';
import 'package:perpustakaan/src/pages/signin_page.dart';
import 'package:perpustakaan/src/pages/spalsh_screen.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF00B4D8),
    );
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: colorScheme,
        inputDecorationTheme: InputDecorationTheme(
          prefixIconColor: MaterialStateColor.resolveWith(
            (Set<MaterialState> states) {
              if (states.contains(MaterialState.error)) {
                return colorScheme.error;
              }
              if (states.contains(MaterialState.focused)) {
                return colorScheme.primary;
              }
              return Colors.grey;
            },
          ),
          suffixIconColor: MaterialStateColor.resolveWith(
            (Set<MaterialState> states) {
              if (states.contains(MaterialState.error)) {
                return colorScheme.error;
              }
              if (states.contains(MaterialState.focused)) {
                return colorScheme.primary;
              }
              return Colors.grey;
            },
          ),
          floatingLabelStyle: const TextStyle(
            fontSize: 20,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 18,
          ),
          border: OutlineInputBorder(
            borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.5)),
            borderRadius: BorderRadius.circular(8),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.primary,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      initialRoute: SplashScreen.routeName,
      routes: {
        SplashScreen.routeName: (context) => const SplashScreen(),
        MainPage.routeName: (context) => const MainPage(),
        SigninPage.routeName: (context) => const SigninPage(),
        DetailPenggunaPage.routeName: (context) => const DetailPenggunaPage(),
        FormPengguna.routeName: (context) => const FormPengguna(),
        DetailBukuPage.routeName: (context) => const DetailBukuPage(),
        FormBuku.routeName: (context) => const FormBuku(),
      },
    );
  }
}
