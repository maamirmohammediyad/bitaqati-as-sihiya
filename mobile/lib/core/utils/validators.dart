class Validators {
  Validators._();

  static String? required(String? value, [String? fieldName]) {
    if (value == null || value.trim().isEmpty) {
      return fieldName != null ? '$fieldName is required' : 'This field is required';
    }
    return null;
  }

  static String? nationalId(String? value) {
  final v = value?.trim() ?? '';
  if (v.isEmpty) {
    return 'National ID is required';
  }
  if (v.length != 18) {
    return 'National ID must be 18 digits';
  }
  if (!RegExp(r'^[0-9]+$').hasMatch(v)) {
    return 'National ID must contain digits only';
  }
  return null;
}

static String? algerianPhone(String? value) {
  final v = value?.trim() ?? '';
  if (v.isEmpty) {
    return 'Phone number is required';
  }
  if (!RegExp(r'^(05|06|07)[0-9]{8}$').hasMatch(v)) {
    return 'Phone must start with 05/06/07 and be 10 digits';
  }
  return null;
}
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Password must contain at least one uppercase letter';
    }
    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'Password must contain at least one lowercase letter';
    }
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Password must contain at least one number';
    }
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  static String? confirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != password) {
      return 'Passwords do not match';
    }
    return null;
  }

  static String? name(String? value, [String fieldName = 'Name']) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    if (value.trim().length < 2) {
      return '$fieldName must be at least 2 characters';
    }
    if (value.trim().length > 50) {
      return '$fieldName must not exceed 50 characters';
    }
    return null;
  }

  static String? numeric(String? value, [String fieldName = 'Value']) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    if (!RegExp(r'^\d+(\.\d+)?$').hasMatch(value.trim())) {
      return 'Please enter a valid number';
    }
    return null;
  }

  static String? date(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    try {
      DateTime.parse(value.trim());
    } catch (_) {
      return 'Please enter a valid date (YYYY-MM-DD)';
    }
    return null;
  }

  static String? url(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    final uri = Uri.tryParse(value.trim());
    if (uri == null || !uri.hasScheme || !uri.hasAuthority) {
      return 'Please enter a valid URL';
    }
    return null;
  }

  static String? bloodType(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    final validTypes = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];
    if (!validTypes.contains(value.trim().toUpperCase())) {
      return 'Please enter a valid blood type (A+, A-, B+, B-, AB+, AB-, O+, O-)';
    }
    return null;
  }

  static String? latinName(String? value, String fieldName) {
  final name = value?.trim() ?? '';

  if (name.isEmpty) {
    return '$fieldName مطلوب';
  }

  // حروف لاتينية فقط، مع السماح بمسافة أو شرطة أو apostrophe.
  final latinNamePattern = RegExp(r"^[A-Za-zÀ-ÖØ-öø-ÿ' -]+$");

  if (!latinNamePattern.hasMatch(name)) {
    return '$fieldName يجب أن يحتوي على حروف لاتينية فقط';
  }

  if (name.length < 2) {
    return '$fieldName يجب أن يكون حرفين على الأقل';
  }

  return null;
}
}
