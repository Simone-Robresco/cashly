import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// Messaggio di avviso/errore uniforme in tutta l'app: box bianco
/// arrotondato, bordo e testo rossi. Usato sia per gli errori di
/// validazione dei form, sia per i pulsanti che portano a pagine non
/// ancora pronte.
void showAppNotice(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.error, width: 1.4),
        ),
        content: Row(
          children: [
            const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: AppColors.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
}
