/// Validation helpers for Pakistani CNIC and mobile numbers.
abstract final class PakistanValidators {
  /// CNIC: 13 digits, optionally formatted as XXXXX-XXXXXXX-X.
  static final RegExp _cnicDigits = RegExp(r'^\d{13}$');
  static final RegExp _cnicFormatted = RegExp(r'^\d{5}-\d{7}-\d$');

  /// Pakistani mobile: 03XX XXXXXXX (11 digits, starts with 03).
  static final RegExp _mobileLocal = RegExp(r'^03\d{9}$');

  static String digitsOnly(String input) =>
      input.replaceAll(RegExp(r'\D'), '');

  /// Normalizes to local 11-digit form (03XXXXXXXXX), or null if invalid.
  static String? normalizePhone(String input) {
    final String digits = digitsOnly(input.trim());
    if (digits.length == 11 && digits.startsWith('03')) {
      return digits;
    }
    if (digits.length == 12 && digits.startsWith('92')) {
      final String local = '0${digits.substring(2)}';
      if (_mobileLocal.hasMatch(local)) return local;
    }
    if (digits.length == 10 && digits.startsWith('3')) {
      final String local = '0$digits';
      if (_mobileLocal.hasMatch(local)) return local;
    }
    return null;
  }

  static String? validatePhone(String? value, {bool required = true}) {
    final String raw = value?.trim() ?? '';
    if (raw.isEmpty) {
      return required ? 'Phone number is required' : null;
    }
    if (normalizePhone(raw) == null) {
      return 'Enter a valid Pakistani mobile (03XX XXXXXXX)';
    }
    return null;
  }

  static String? validateCnic(String? value, {bool required = true}) {
    final String raw = value?.trim() ?? '';
    if (raw.isEmpty) {
      return required ? 'CNIC is required' : null;
    }
    final String compact = raw.replaceAll(RegExp(r'[\s-]'), '');
    if (_cnicDigits.hasMatch(compact)) return null;
    if (_cnicFormatted.hasMatch(raw)) return null;
    return 'Enter a valid CNIC (XXXXX-XXXXXXX-X)';
  }

  static String? validateEmailOptional(String? value) {
    final String v = value?.trim() ?? '';
    if (v.isEmpty) return null;
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(v)) {
      return 'Enter a valid email';
    }
    return null;
  }

  /// Formats 13-digit CNIC as XXXXX-XXXXXXX-X for display/storage.
  static String formatCnic(String input) {
    final String digits = digitsOnly(input);
    if (digits.length != 13) return input.trim();
    return '${digits.substring(0, 5)}-'
        '${digits.substring(5, 12)}-'
        '${digits.substring(12)}';
  }

  /// Formats 11-digit mobile as 03XX XXXXXXX.
  static String formatPhone(String input) {
    final String? local = normalizePhone(input);
    if (local == null) return input.trim();
    return '${local.substring(0, 4)} ${local.substring(4)}';
  }
}
