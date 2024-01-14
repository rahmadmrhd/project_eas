import 'package:flutter/material.dart';

class ErrorDialog extends StatelessWidget {
  const ErrorDialog(
      {super.key, this.onTry, required this.title, required this.msgError});
  final void Function()? onTry;
  final String title;
  final String msgError;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      icon: const Icon(
        Icons.cancel,
        color: Colors.red,
      ),
      content: Text(
        'Terjadi kesalahan, silahkan coba lagi!\n $msgError',
        textAlign: TextAlign.center,
      ),
      actions: [
        TextButton(
          onPressed: () {
            onTry?.call();
          },
          child: Text(onTry != null ? 'Coba Lagi' : 'OK'),
        ),
      ],
    );
  }
}
