import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class UIStyles {
  // Colors
  static const Color primaryColor = Color(0xFF5A2E02);
  static const Color accentColor = Color(0xFF9E723C);
  static const Color backgroundColor = Color(0xFFFAF5EF);
  static const Color surfaceColor = Colors.white;
  static const Color dividerColor = Color(0xFFE0D2C3);

  // Text Styles
  static TextStyle get titleLarge => GoogleFonts.poppins(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: primaryColor,
        height: 1.3,
      );

  static TextStyle get titleMedium => GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: primaryColor,
      );

  static TextStyle get titleSmall => GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: primaryColor,
      );

  static TextStyle get bodyLarge => GoogleFonts.poppins(
        fontSize: 16,
        color: Colors.black87,
        height: 1.5,
      );

  static TextStyle get bodyMedium => GoogleFonts.poppins(
        fontSize: 14,
        color: Colors.black87,
        height: 1.5,
      );

  static TextStyle get bodySmall => GoogleFonts.poppins(
        fontSize: 12,
        color: Colors.grey.shade700,
      );

  static TextStyle get caption => GoogleFonts.poppins(
        fontSize: 12,
        color: Colors.grey.shade600,
        fontStyle: FontStyle.italic,
      );

  // Decorations
  static BoxDecoration get cardDecoration => BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(
          color: dividerColor.withOpacity(0.5),
          width: 1,
        ),
      );

  static BoxDecoration get accentedCardDecoration => BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(
          color: accentColor.withOpacity(0.3),
          width: 1,
        ),
      );

  // Button Styles
  static ButtonStyle get primaryButtonStyle => ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 0,
      );

  static ButtonStyle get accentButtonStyle => ElevatedButton.styleFrom(
        backgroundColor: accentColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 0,
      );

  static ButtonStyle get outlinedButtonStyle => OutlinedButton.styleFrom(
        foregroundColor: primaryColor,
        side: const BorderSide(color: primaryColor, width: 1.5),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      );

  // Container Paddings
  static const EdgeInsets containerPadding = EdgeInsets.all(16);
  static const EdgeInsets listItemPadding =
      EdgeInsets.symmetric(vertical: 12, horizontal: 16);
  static const EdgeInsets cardPadding = EdgeInsets.all(20);

  // Decorative elements
  static Widget buildDivider() {
    return const Divider(
      color: dividerColor,
      thickness: 1.5,
      height: 32,
    );
  }

  static Widget buildSectionHeader(String title,
      {IconData? icon, Widget? trailing}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, color: accentColor, size: 20),
            const SizedBox(width: 8),
          ],
          Text(
            title,
            style: titleMedium,
          ),
          const Spacer(),
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 350);
  static const Duration longAnimation = Duration(milliseconds: 500);
}
