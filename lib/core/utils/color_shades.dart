import 'package:flutter/material.dart';

/// Schiarisce [color] di [amount] (0.0 - 1.0) sulla luminosità HSL.
Color lightenColor(Color color, double amount) {
  final hsl = HSLColor.fromColor(color);
  final lightness = (hsl.lightness + amount).clamp(0.0, 1.0);
  return hsl.withLightness(lightness).toColor();
}

/// Scurisce [color] di [amount] (0.0 - 1.0) sulla luminosità HSL.
Color darkenColor(Color color, double amount) => lightenColor(color, -amount);

/// Data una tonalità base, restituisce 3 varianti: chiara, base, scura.
/// Volutamente poche sfumature per tonalità: meglio avere più colori
/// diversi tra cui scegliere piuttosto che tante varianti dello stesso.
List<Color> colorShades(Color base) => [
      lightenColor(base, 0.22),
      base,
      darkenColor(base, 0.20),
    ];
