import 'package:flutter/material.dart';
import 'package:perpustakaan/src/pages/main_page.dart';
import 'package:perpustakaan/src/pages/signin_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  static const routeName = '/splash';

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    //
    super.initState();
    Future.delayed(const Duration(seconds: 3), () async {
      final isLogin = await checkIsLogin();
      if (isLogin) {
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, MainPage.routeName);
      } else {
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, SigninPage.routeName);
      }
    });
  }

  Future<bool> checkIsLogin() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('user')?.isNotEmpty ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/background.png',
                scale: 2,
              ),
              const SizedBox(height: 48),
              const CircularProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }
}
