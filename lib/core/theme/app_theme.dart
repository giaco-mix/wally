import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  const AppTheme._();

  static const Color _seed = Color(0xFF1565C0);
  static const Color positive = Color(0xFF2E7D32);
  static const Color negative = Color(0xFFC62828);

  static ThemeData light() => _base(Brightness.light);
  static ThemeData dark() => _base(Brightness.dark);

  /// Attiva le **tabular figures** su tutta la scala tipografica: le cifre hanno
  /// larghezza fissa e restano incolonnate nelle tabelle (portafoglio,
  /// ribilanciamento, numeri chiave del piano). Riusato anche quando si
  /// applicano i font brand.
  static TextTheme withTabularFigures(TextTheme base) {
    const features = [FontFeature.tabularFigures()];
    TextStyle? tf(TextStyle? s) => s?.copyWith(fontFeatures: features);
    return base.copyWith(
      displayLarge: tf(base.displayLarge),
      displayMedium: tf(base.displayMedium),
      displaySmall: tf(base.displaySmall),
      headlineLarge: tf(base.headlineLarge),
      headlineMedium: tf(base.headlineMedium),
      headlineSmall: tf(base.headlineSmall),
      titleLarge: tf(base.titleLarge),
      titleMedium: tf(base.titleMedium),
      titleSmall: tf(base.titleSmall),
      bodyLarge: tf(base.bodyLarge),
      bodyMedium: tf(base.bodyMedium),
      bodySmall: tf(base.bodySmall),
      labelLarge: tf(base.labelLarge),
      labelMedium: tf(base.labelMedium),
      labelSmall: tf(base.labelSmall),
    );
  }

  /// Tipografia di brand: **Sora** per display/headline/title (geometrico,
  /// fintech) e **Inter** per body/label. Le tabular figures vengono applicate
  /// in coda così le cifre restano incolonnate.
  ///
  /// NB: google_fonts scarica i font a runtime al primo avvio; senza rete cade
  /// sul font di sistema. Se serve l'offline puro nella PWA, bundlare i .ttf
  /// come asset.
  static TextTheme _brandTextTheme(Brightness brightness) {
    final base = ThemeData(brightness: brightness).textTheme;
    final inter = GoogleFonts.interTextTheme(base);
    final sora = GoogleFonts.soraTextTheme(base);
    final merged = inter.copyWith(
      displayLarge: sora.displayLarge,
      displayMedium: sora.displayMedium,
      displaySmall: sora.displaySmall,
      headlineLarge: sora.headlineLarge,
      headlineMedium: sora.headlineMedium,
      headlineSmall: sora.headlineSmall,
      titleLarge: sora.titleLarge,
      titleMedium: sora.titleMedium,
      titleSmall: sora.titleSmall,
    );
    return withTabularFigures(merged);
  }

  static ThemeData _base(Brightness brightness) {
    final scheme = ColorScheme.fromSeed(
      seedColor: _seed,
      brightness: brightness,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      textTheme: _brandTextTheme(brightness),
      scaffoldBackgroundColor: scheme.surface,
      cardTheme: CardThemeData(
        elevation: 0,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: scheme.outlineVariant),
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
        isDense: true,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
