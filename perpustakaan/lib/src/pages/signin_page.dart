import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:perpustakaan/src/components/error_dialog.dart';
import 'package:perpustakaan/src/pages/main_page.dart';
import 'package:perpustakaan/src/utils/validator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../components/loading_dialog.dart';

class SigninPage extends StatefulWidget {
  const SigninPage({super.key});
  static const routeName = '/signin';

  @override
  State<SigninPage> createState() => _SigninPageState();
}

class _SigninPageState extends State<SigninPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nbiController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool showPassword = false;

  void signin(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      try {
        loadingDialog(context);
        if (_nbiController.text != '1462200017' ||
            _passwordController.text != 'rahmadmaulana') {
          Navigator.pop(context);
          showDialog(
            context: context,
            builder: (context) {
              return const ErrorDialog(
                title: 'Gagal',
                msgError: 'NBI atau Password salah',
              );
            },
          );
          return;
        }
        final prefs = await SharedPreferences.getInstance();
        await prefs.setStringList('user', [
          _nbiController.text,
          _passwordController.text,
        ]);

        if (!mounted) return;
        Navigator.pop(context);
        Navigator.pushReplacementNamed(context, MainPage.routeName);
      } catch (e) {
        if (!mounted) return;
        Navigator.pop(context);
        dialogResult(context, false, e.toString());
      }
    }
  }

  //fungsi menampilkan dialog
  void dialogResult(BuildContext context, bool isSuccess, String msg) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(isSuccess ? 'Berhasil' : 'Gagal'),
          icon: Icon(
            isSuccess ? Icons.check : Icons.cancel,
            color: isSuccess ? Colors.green : Colors.red,
          ),
          content: Text(
            msg,
            textAlign: TextAlign.center,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Image.asset(
                    'assets/images/background.png',
                    scale: 2,
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Welcome Back',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  Text(
                    'Sign to continue',
                    style: TextStyle(fontSize: 18, color: Colors.grey[500]!),
                  ),
                  const SizedBox(height: 56),
                  //form login
                  TextFormField(
                    controller: _nbiController,
                    keyboardType: const TextInputType.numberWithOptions(
                      signed: false,
                      decimal: false,
                    ),
                    textInputAction: TextInputAction.next,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(
                      labelText: 'NBI',
                      prefixIcon: Icon(
                        Icons.person,
                      ),
                    ),
                    validator: validatorNotEmpty,
                  ),
                  const SizedBox(height: 18),
                  TextFormField(
                    controller: _passwordController,
                    keyboardType: TextInputType.name,
                    textInputAction: TextInputAction.done,
                    // inputFormatters: [FilteringTextInputFormatter.allow(filterPattern)],
                    decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(
                          Icons.password_rounded,
                        ),
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              showPassword = !showPassword;
                            });
                          },
                          icon: Icon(showPassword
                              ? Icons.visibility_off
                              : Icons.visibility),
                        )),
                    obscureText: !showPassword,
                    validator: validatorNotEmpty,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        minimumSize: const Size.fromHeight(50)),
                    onPressed: () {
                      signin(context);
                    },
                    child: const Text(
                      'LOGIN',
                      style: TextStyle(
                        fontSize: 24,
                        letterSpacing: 5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
