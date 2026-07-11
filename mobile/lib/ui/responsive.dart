import 'package:flutter/material.dart';

/// Layout helpers for phones / emulators (esp. short landscape).
class Responsive {
  Responsive._(this.size);

  factory Responsive.of(BuildContext context) =>
      Responsive._(MediaQuery.sizeOf(context));

  final Size size;

  /// Shortest side — typical phone logical height in landscape.
  double get shortest => size.shortestSide;

  double get longest => size.longestSide;

  bool get isLandscape => size.width > size.height;

  /// Emulators and small phones often sit around 360–400 logical px tall.
  bool get isCompact => shortest < 420;

  bool get isNarrow => longest < 700;

  /// Scale factor vs a ~400px-tall landscape reference.
  double get scale => (shortest / 400).clamp(0.62, 1.25);

  double sp(double value) => value * scale;

  EdgeInsets pad({
    double h = 16,
    double v = 12,
  }) =>
      EdgeInsets.symmetric(horizontal: sp(h), vertical: sp(v));
}
