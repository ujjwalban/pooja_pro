import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool centerTitle;
  final List<Widget>? actions;
  final VoidCallback? onBackPressed;
  final Color backgroundColor;
  final Color iconColor;
  final Color titleColor;
  final bool automaticallyImplyLeading;

  const CustomAppBar({
    Key? key,
    required this.title,
    this.centerTitle = false,
    this.actions,
    this.onBackPressed,
    this.backgroundColor = Colors.white,
    this.iconColor = const Color(0xFF5A2E02),
    this.titleColor = const Color(0xFF5A2E02),
    this.automaticallyImplyLeading = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: backgroundColor,
      elevation: 0,
      centerTitle: centerTitle,
      automaticallyImplyLeading: automaticallyImplyLeading,
      leading: automaticallyImplyLeading
          ? IconButton(
              icon: Icon(Icons.arrow_back, color: iconColor),
              onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.only(left: 16.0),
            )
          : null,
      title: Text(
        title,
        style: GoogleFonts.poppins(
          color: titleColor,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
