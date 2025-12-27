class Validators {
  // Private constructor to prevent object creation
  Validators._();

  /// -------------------------------
  /// Email Validation
  /// -------------------------------
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }

    final emailRegex = RegExp(
      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
    );

    if (!emailRegex.hasMatch(value.trim())) {
      return 'Enter a valid email address';
    }

    return null; // valid
  }

  /// -------------------------------
  /// Password Validation
  /// -------------------------------
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }

    return null; // valid
  }

  /// -------------------------------
  /// Confirm Password Validation
  /// -------------------------------
  static String? confirmPassword(
      String? value,
      String originalPassword,
      ) {
    if (value == null || value.isEmpty) {
      return 'Confirm password is required';
    }

    if (value != originalPassword) {
      return 'Passwords do not match';
    }

    return null; // valid
  }

  /// -------------------------------
  /// Name Validation (Profile / Register)
  /// -------------------------------
  static String? name(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Name is required';
    }

    if (value.trim().length < 3) {
      return 'Name must be at least 3 characters';
    }

    return null; // valid
  }

  /// -------------------------------
  /// Phone Number Validation
  /// -------------------------------
  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }

    if (value.length != 10) {
      return 'Enter a valid 10-digit phone number';
    }

    return null; // valid
  }

  /// -------------------------------
  /// Waste Level Validation (Optional)
  /// -------------------------------
  static String? wasteLevel(String? value) {
    if (value == null || value.isEmpty) {
      return 'Waste level is required';
    }

    final int? level = int.tryParse(value);

    if (level == null || level < 0 || level > 100) {
      return 'Waste level must be between 0 and 100';
    }

    return null; // valid
  }
}
