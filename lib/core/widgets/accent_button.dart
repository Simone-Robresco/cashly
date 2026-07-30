import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// Bottone principale a tutta larghezza, colore pieno (non piÃ¹ a
/// gradiente), forma a pillola.
class AccentButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const AccentButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54,
      decoration: BoxDecoration(
        color: AppColors.accent,
        borderRadius: BorderRadius.circular(27),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(27),
          onTap: onPressed,
          child: Center(
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
