import 'package:flutter/material.dart';

abstract class AppTheme {
  static ThemeData light() {
    final base = ThemeData.light();
    return base.copyWith(
      pageTransitionsTheme: PageTransitionsTheme(
        builders: {
          for (final platform in TargetPlatform.values)
            platform: const ZoomPageTransitionsBuilder(),
        },
      ),
      dividerTheme: base.dividerTheme.copyWith(
        space: 0,
        thickness: 1,
      ),
    );
  }
}
