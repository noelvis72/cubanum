import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // ---- Tema claro ----
  static const Color claroFondo       = Color(0xFFF8F4EC);
  static const Color claroSuperficie  = Color(0xFFF1EADF);
  static const Color claroSuperficie2 = Color(0xFFEADFCB);
  static const Color claroTexto       = Color(0xFF3B2F2F);
  static const Color claroTextoSuave  = Color(0xFF6B5A55);
  static const Color claroAcento      = Color(0xFFB08D57);
  static const Color claroAcentoOsc   = Color(0xFF8E6F3E);
  static const Color claroBorde       = Color(0xFFD9CDB8);
  static const Color claroError       = Color(0xFF9C3B2E);

  // ---- Tema oscuro ----
  static const Color oscuroFondo       = Color(0xFF12151C);
  static const Color oscuroSuperficie  = Color(0xFF1E222B);
  static const Color oscuroSuperficie2 = Color(0xFF262B36);
  static const Color oscuroTexto       = Color(0xFFEAEAEA);
  static const Color oscuroTextoSuave  = Color(0xFFA9AEB8);
  static const Color oscuroAcento      = Color(0xFFC9A227);
  static const Color oscuroAcentoOsc   = Color(0xFF9A7B15);
  static const Color oscuroBorde       = Color(0xFF333A46);
  static const Color oscuroError       = Color(0xFFE07A6B);
}

class AppTheme {
  static TextTheme _textos(Color color, Color suave) {
    final serif = GoogleFonts.ebGaramondTextTheme();
    final sans  = GoogleFonts.interTextTheme();

    return TextTheme(
      displayLarge:   serif.displayLarge?.copyWith(color: color, fontWeight: FontWeight.w600),
      displayMedium:  serif.displayMedium?.copyWith(color: color, fontWeight: FontWeight.w600),
      displaySmall:   serif.displaySmall?.copyWith(color: color, fontWeight: FontWeight.w600),
      headlineLarge:  serif.headlineLarge?.copyWith(color: color, fontWeight: FontWeight.w600),
      headlineMedium: serif.headlineMedium?.copyWith(color: color, fontWeight: FontWeight.w600),
      headlineSmall:  serif.headlineSmall?.copyWith(color: color, fontWeight: FontWeight.w600),
      titleLarge:     serif.titleLarge?.copyWith(color: color, fontWeight: FontWeight.w600),
      titleMedium:    serif.titleMedium?.copyWith(color: color, fontWeight: FontWeight.w600),
      titleSmall:     serif.titleSmall?.copyWith(color: color, fontWeight: FontWeight.w600),
      bodyLarge:      sans.bodyLarge?.copyWith(color: color),
      bodyMedium:     sans.bodyMedium?.copyWith(color: color),
      bodySmall:      sans.bodySmall?.copyWith(color: suave),
      labelLarge:     sans.labelLarge?.copyWith(color: color, fontWeight: FontWeight.w600),
      labelMedium:    sans.labelMedium?.copyWith(color: suave),
      labelSmall:     sans.labelSmall?.copyWith(color: suave),
    );
  }

  static ThemeData get claro {
    const fondo      = AppColors.claroFondo;
    const superficie = AppColors.claroSuperficie;
    const texto      = AppColors.claroTexto;
    const suave      = AppColors.claroTextoSuave;
    const acento     = AppColors.claroAcento;
    const borde      = AppColors.claroBorde;

    final scheme = ColorScheme(
      brightness: Brightness.light,
      primary: acento,
      onPrimary: const Color(0xFFFFFBF2),
      secondary: AppColors.claroAcentoOsc,
      onSecondary: const Color(0xFFFFFBF2),
      error: AppColors.claroError,
      onError: const Color(0xFFFFFBF2),
      surface: superficie,
      onSurface: texto,
      surfaceContainerHighest: AppColors.claroSuperficie2,
      outline: borde,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: scheme,
      scaffoldBackgroundColor: fondo,
      canvasColor: fondo,
      textTheme: _textos(texto, suave),
      appBarTheme: AppBarTheme(
        backgroundColor: fondo,
        foregroundColor: texto,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.ebGaramond(
          color: texto, fontSize: 22, fontWeight: FontWeight.w600, letterSpacing: 1.2,
        ),
        iconTheme: const IconThemeData(color: texto),
      ),
      cardTheme: CardThemeData(
        color: superficie,
        elevation: 2,
        shadowColor: const Color(0x33000000),
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: borde, width: 0.6),
        ),
      ),
      dividerTheme: const DividerThemeData(color: borde, thickness: 0.6),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.claroSuperficie2,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: borde),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: borde),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: acento, width: 1.4),
        ),
        labelStyle: GoogleFonts.inter(color: suave),
        hintStyle: GoogleFonts.inter(color: suave),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: acento,
          foregroundColor: const Color(0xFFFFFBF2),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: AppColors.claroAcentoOsc),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: acento,
        foregroundColor: Color(0xFFFFFBF2),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.claroSuperficie2,
        selectedColor: acento.withOpacity(0.25),
        side: const BorderSide(color: borde),
        labelStyle: GoogleFonts.inter(color: texto),
      ),
      listTileTheme: const ListTileThemeData(iconColor: acento, textColor: texto),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? acento : const Color(0xFFBFB3A0),
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? acento.withOpacity(0.4) : borde,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: superficie,
        indicatorColor: acento.withOpacity(0.2),
        labelTextStyle: WidgetStatePropertyAll(
          GoogleFonts.inter(color: texto, fontSize: 12),
        ),
      ),
    );
  }

  static ThemeData get oscuro {
    const fondo      = AppColors.oscuroFondo;
    const superficie = AppColors.oscuroSuperficie;
    const texto      = AppColors.oscuroTexto;
    const suave      = AppColors.oscuroTextoSuave;
    const acento     = AppColors.oscuroAcento;
    const borde      = AppColors.oscuroBorde;

    final scheme = ColorScheme(
      brightness: Brightness.dark,
      primary: acento,
      onPrimary: const Color(0xFF1A1408),
      secondary: AppColors.oscuroAcentoOsc,
      onSecondary: const Color(0xFF1A1408),
      error: AppColors.oscuroError,
      onError: const Color(0xFF1A1408),
      surface: superficie,
      onSurface: texto,
      surfaceContainerHighest: AppColors.oscuroSuperficie2,
      outline: borde,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
      scaffoldBackgroundColor: fondo,
      canvasColor: fondo,
      textTheme: _textos(texto, suave),
      appBarTheme: AppBarTheme(
        backgroundColor: fondo,
        foregroundColor: texto,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.ebGaramond(
          color: texto, fontSize: 22, fontWeight: FontWeight.w600, letterSpacing: 1.2,
        ),
        iconTheme: const IconThemeData(color: texto),
      ),
      cardTheme: CardThemeData(
        color: superficie,
        elevation: 1,
        shadowColor: const Color(0x66000000),
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: borde, width: 0.7),
        ),
      ),
      dividerTheme: const DividerThemeData(color: borde, thickness: 0.6),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.oscuroSuperficie2,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: borde),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: borde),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: acento, width: 1.4),
        ),
        labelStyle: GoogleFonts.inter(color: suave),
        hintStyle: GoogleFonts.inter(color: suave),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: acento,
          foregroundColor: const Color(0xFF1A1408),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: acento),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: acento,
        foregroundColor: Color(0xFF1A1408),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.oscuroSuperficie2,
        selectedColor: acento.withOpacity(0.3),
        side: const BorderSide(color: borde),
        labelStyle: GoogleFonts.inter(color: texto),
      ),
      listTileTheme: const ListTileThemeData(iconColor: acento, textColor: texto),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? acento : const Color(0xFF4A5160),
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? acento.withOpacity(0.4) : borde,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: superficie,
        indicatorColor: acento.withOpacity(0.25),
        labelTextStyle: WidgetStatePropertyAll(
          GoogleFonts.inter(color: texto, fontSize: 12),
        ),
      ),
    );
  }
}
