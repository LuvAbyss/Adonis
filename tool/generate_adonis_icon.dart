import 'dart:io';
import 'dart:math' as math;

import 'package:image/image.dart' as img;

/// Renders Adonis's simple geometric A mark, independent of upstream branding.
void main() {
  const size = 1024;
  double distance(
      double x, double y, double ax, double ay, double bx, double by) {
    final dx = bx - ax;
    final dy = by - ay;
    final t = ((x - ax) * dx + (y - ay) * dy) / (dx * dx + dy * dy);
    final clamped = t.clamp(0.0, 1.0);
    return math.sqrt(math.pow(x - ax - clamped * dx, 2) +
        math.pow(y - ay - clamped * dy, 2));
  }

  final logo = img.Image(width: size, height: size, numChannels: 4);
  final foreground = img.Image(width: size, height: size, numChannels: 4);
  final background = img.Image(width: size, height: size, numChannels: 4);
  for (var y = 0; y < size; y++) {
    for (var x = 0; x < size; x++) {
      final u = x / size;
      final v = y / size;
      final gradient = (u + v) / 2;
      final r = (65 + 36 * gradient).round();
      final g = (36 + 15 * gradient).round();
      final b = (124 + 55 * gradient).round();
      background.setPixelRgba(x, y, r, g, b, 255);
      final cx = (u - 0.5).abs() - 0.30;
      final cy = (v - 0.5).abs() - 0.30;
      final rounded = math.sqrt(
              math.pow(math.max(cx, 0), 2) + math.pow(math.max(cy, 0), 2)) <=
          0.18;
      final letter = distance(u, v, 0.32, 0.72, 0.50, 0.29) < 0.037 ||
          distance(u, v, 0.50, 0.29, 0.68, 0.72) < 0.037 ||
          distance(u, v, 0.39, 0.57, 0.61, 0.57) < 0.032;
      if (rounded) logo.setPixelRgba(x, y, r, g, b, 255);
      if (letter) {
        logo.setPixelRgba(x, y, 244, 239, 255, 255);
        foreground.setPixelRgba(x, y, 244, 239, 255, 255);
      }
    }
  }
  for (final asset in {
    'adonis-logo': logo,
    'adonis-foreground': foreground,
    'adonis-background': background,
  }.entries) {
    File('assets/${asset.key}.png')
        .writeAsBytesSync(img.encodePng(asset.value));
  }
}
