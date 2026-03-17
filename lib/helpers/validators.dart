/// Reusable form validators for use with TextFormField.validator.
/// Each method returns String? — null means valid, non-null is the error message.
class Validators {
  Validators._();

  /// Field must not be empty
  static String? Function(String?) required(String fieldName) {
    return (value) {
      if (value == null || value.trim().isEmpty) {
        return '$fieldName is required';
      }
      return null;
    };
  }

  /// Field must be a valid email address
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email is required';
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(value.trim())) return 'Enter a valid email address';
    return null;
  }

  /// Field must have at least [length] characters
  static String? Function(String?) minLength(int length) {
    return (value) {
      if (value == null || value.length < length) {
        return 'Must be at least $length characters';
      }
      return null;
    };
  }

  /// Field must have at most [length] characters
  static String? Function(String?) maxLength(int length) {
    return (value) {
      if (value != null && value.length > length) {
        return 'Must be at most $length characters';
      }
      return null;
    };
  }

  /// Field must be a valid number
  static String? numeric(String? value) {
    if (value == null || value.trim().isEmpty) return null; // use required() for presence check
    if (num.tryParse(value.trim()) == null) return 'Must be a number';
    return null;
  }

  /// Compose multiple validators. Returns the first error found.
  static String? Function(String?) compose(List<String? Function(String?)> validators) {
    return (value) {
      for (final validator in validators) {
        final error = validator(value);
        if (error != null) return error;
      }
      return null;
    };
  }
}
