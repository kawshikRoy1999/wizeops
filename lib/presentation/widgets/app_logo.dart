import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';

class AppLogo extends StatelessWidget {
  final double size;
  const AppLogo({super.key, this.size = 72});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.25),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF39C12), Color(0xFFE67E22)],
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.actionAccent.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Center(
        child: Text(
          'W',
          style: GoogleFonts.inter(
            fontSize: size * 0.5,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            height: 1,
          ),
        ),
      ),
    );
  }
}
