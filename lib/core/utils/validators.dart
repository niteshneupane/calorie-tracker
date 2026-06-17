class Validators {
  static String? requiredText(String? value) {
    if (value == null || value.trim().isEmpty) return 'Required';
    return null;
  }
}
