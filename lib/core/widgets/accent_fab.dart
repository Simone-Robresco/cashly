import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// Tasto + con colore pieno (non piÃ¹ a gradiente) e angoli arrotondati.
class AccentFab extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;

  const AccentFab({
    super.key,
    required this.onPressed,
    this.icon = Icons.add_rounded,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 58,
      height: 58,
      decoration: BoxDecoration(
        color: AppColors.accent,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withValues(alpha: 0.35),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onPressed,
          child: Icon(icon, color: Colors.white, size: 26),
        ),
      ),
    );
  }
}
