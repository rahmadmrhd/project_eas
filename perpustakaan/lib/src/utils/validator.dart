String? validatorNotEmpty(String? value) {
  if (value == null || value.isEmpty) {
    return 'Tidak Boleh Kosong';
  }
  return null;
}
