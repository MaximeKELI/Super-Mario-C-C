import 'package:flutter/material.dart';

/// Layout helpers for phones, tablets, and short landscape emulators.
class Responsive {
  Responsive._(this.size);

  factory Responsive.of(BuildContext context) =>
      Responsive._(MediaQuery.sizeOf(context));

  final Size size;

  /// Shortest side — typical phone logical height in landscape.
  double get shortest => size.shortestSide;

  double get longest => size.longestSide;

  bool get isLandscape => size.width > size.height;

  /// Material-ish breakpoints on shortest side.
  bool get isPhone => shortest < 600;
  bool get isTablet => shortest >= 600;
  bool get isLargeTablet => shortest >= 900;

  /// Emulators and small phones often sit around 360–400 logical px tall.
  bool get isCompact => isPhone && shortest < 420;

  bool get isNarrow => longest < 700;

  /// Scale vs a ~400px-tall landscape phone reference.
  /// Tablets get a gentler boost so HUD/controls stay usable without huge UI.
  double get scale {
    if (isLargeTablet) return (shortest / 700).clamp(1.05, 1.45);
    if (isTablet) return (shortest / 560).clamp(0.95, 1.3);
    return (shortest / 400).clamp(0.62, 1.2);
  }

  /// Touch controls: a bit larger on tablets for thumbs.
  double get controlScale {
    if (isLargeTablet) return scale * 1.15;
    if (isTablet) return scale * 1.08;
    return scale;
  }

  double sp(double value) => value * scale;

  EdgeInsets pad({
    double h = 16,
    double v = 12,
  }) =>
      EdgeInsets.symmetric(horizontal: sp(h), vertical: sp(v));

  /// Max content width for menus on very wide tablets / desktop.
  double get menuMaxWidth {
    if (isLargeTablet) return 980;
    if (isTablet) return 820;
    return double.infinity;
  }
}
