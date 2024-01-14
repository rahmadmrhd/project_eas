import 'package:flutter/services.dart';

class PhoneTextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    // if (newValue.text.length > 12) {
    //   newValue = TextEditingValue(text: newValue.text.substring(0, 12));
    // }

    // Jika teks baru tidak memiliki kode negara, tambahkan kode negara Indonesia (+62)
    String value = newValue.text;
    String newText = newValue.text.trim();
    if (newValue.text.isNotEmpty) {
      if ("62".indexOf(newText) != 0 && !newText.contains('62')) {
        newText = "62$newText";
        value = newText;
      }
    }

    if (newText.length > 2) {
      final result =
          newText.length > 5 ? newText.substring(2, 5) : newText.substring(2);
      newText = "(+62) $result";
    }
    if (value.length > 5) {
      final result =
          value.length > 9 ? value.substring(5, 9) : value.substring(5);
      newText += "-$result";
    }
    if (value.length > 9) {
      final result = value.substring(9);
      newText += "-$result";
    }
    // newText =
    //     "+62 ${newText.substring(2)}-${newText.substring(5, 8)}-${newText.substring(9)}";

    return newValue.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}
