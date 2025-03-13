import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';

class Validators {
  /// Email validation using the email_validator package
  static bool isValidEmail(String email) {
    return EmailValidator.validate(email);
  }

  /// Advanced email validation using Google's Email Validation API (mock function)
  /// In a real implementation, you would use a proper email validation service
  static Future<bool> isValidEmailWithGoogle(String email) async {
    if (!isValidEmail(email)) {
      return false;
    }

    // This is a placeholder - in a real app, you would use a proper email validation service
    // Example: Google's Email Verification API or similar service
    try {
      // Check for common disposable email domains
      final disposableDomains = [
        'mailinator.com',
        'yopmail.com',
        'tempmail.com',
        'guerrillamail.com',
        'temp-mail.org',
        'fakeinbox.com',
        'throwawaymail.com'
      ];

      final domain = email.split('@').last.toLowerCase();
      if (disposableDomains.contains(domain)) {
        return false;
      }

      // Check for valid MX records (simplified mock implementation)
      // In real implementation, you would use DNS lookups
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Simple phone number validation without external library
  static bool isValidPhoneNumber(String phoneNumber, String countryCode) {
    // Simple implementation of phone validation without external library

    // Remove any non-digit characters
    final cleanNumber = phoneNumber.replaceAll(RegExp(r'\D'), '');

    // Basic length validation based on country
    switch (countryCode) {
      case 'US':
      case 'CA':
        return cleanNumber.length == 10; // US/Canada: 10 digits
      case 'IN':
        return cleanNumber.length == 10; // India: 10 digits
      case 'UK':
      case 'GB':
        return cleanNumber.length >= 10 &&
            cleanNumber.length <= 11; // UK: 10-11 digits
      default:
        // Generic validation - most phone numbers worldwide are 7-15 digits
        return cleanNumber.length >= 7 && cleanNumber.length <= 15;
    }
  }

  /// Password strength validator
  static String? validatePassword(String password) {
    if (password.isEmpty) {
      return 'Password cannot be empty';
    }

    if (password.length < 8) {
      return 'Password must be at least 8 characters';
    }

    bool hasUppercase = password.contains(RegExp(r'[A-Z]'));
    bool hasLowercase = password.contains(RegExp(r'[a-z]'));
    bool hasDigit = password.contains(RegExp(r'[0-9]'));
    bool hasSpecialChar = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

    if (!hasUppercase || !hasLowercase || !hasDigit || !hasSpecialChar) {
      return 'Password must contain uppercase, lowercase, digit and special character';
    }

    return null; // Valid password
  }

  /// Display validation error in a SnackBar
  static void showValidationError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade800,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
