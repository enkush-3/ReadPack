String normalizePhoneNumber(String value) {
  final trimmed = value.trim();
  final digits = trimmed.replaceAll(RegExp(r'\D'), '');
  if (trimmed.startsWith('+')) return '+$digits';
  if (trimmed.startsWith('00') && digits.length > 2) {
    return '+${digits.substring(2)}';
  }
  if (digits.startsWith('976')) return '+$digits';
  return '+976$digits';
}
