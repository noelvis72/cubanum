import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Identificador de los 6 temas disponibles.
enum AppThemeId {
  claro,
  oscuro,
  verde,
  azul,
  desierto,
  rosado,
}

class AppColors {
  // ---- 1. Catálogo de museo (claro) ----
  static const Color claroFondo       = Color(0xFFF8F4EC);
  static const Color claroSuperficie  = Color(0xFFF1EADF);
  static const Color claroSuperficie2 = Color(0xFFEADFCB);
  static const Color claroTexto       = Color(0xFF3B2F2F);
  static const Color claroTextoSuave  = Color(0xFF6B5A55);
  static const Color claroAcento      = Color(0xFFB08D57);
  static const Color claroAcentoOsc   = Color(0xFF8E6F3E);
  static const Color claroBorde       = Color(0xFFD9CDB8);
  static const Color claroError       = Color(0xFF9C3B2E);

  // ---- 2. Gabinete nocturno (oscuro) ----
  static const Color oscuroFondo       = Color(0xFF12151C);
  static const Color oscuroSuperficie  = Color(0xFF1E222B);
  static const Color oscuroSuperficie2 = Color(0xFF262B36);
  static const Color oscuroTexto       = Color(0xFFEAEAEA);
  static const Color oscuroTextoSuave  = Color(0xFFA9AEB8);
  static const Color oscuroAcento      = Color(0xFFC9A227);
  static const Color oscuroAcentoOsc   = Color(0xFF9A7B15);
  static const Color oscuroBorde       = Color(0xFF333A46);
  static const Color oscuroError       = Color(0xFFE07A6B);

  // ---- 3. Verde pastel (relajante) ----
  static const Color verdeFondo       = Color(0xFFE8F5E9);
  static const Color verdeSuperficie  = Color(0xFFDCEEDE);
  static const Color verdeSuperficie2 = Color(0xFFC9E2CC);
  static const Color verdeTexto       = Color(0xFF2E4A34);
  static const Color verdeTextoSuave  = Color(0xFF54735B);
  static const Color verdeAcento      = Color(0xFF5C8A63);
  static const Color verdeAcentoOsc   = Color(0xFF3F6B47);
  static const Color verdeBorde       = Color(0xFFB8D4BC);
  static const Color verdeError       = Color(0xFF8B3A2E);

  // ---- 4. Azul suave (sereno) ----
  static const Color azulFondo       = Color(0xFFE3F2FD);
  static const Color azulSuperficie  = Color(0xFFD4E8F7);
  static const Color azulSuperficie2 = Color(0xFFC0DCF2);
  static const Color azulTexto       = Color(0xFF1A3A5C);
  static const Color azulTextoSuave  = Color(0xFF486A8C);
  static const Color azulAcento      = Color(0xFF3F6EA3);
  static const Color azulAcentoOsc   = Color(0xFF2A4F7A);
  static const Color azulBorde       = Color(0xFFA9C9E3);
  static const Color azulError       = Color(0xFF8B3A2E);

  // ---- 5. Desierto dorado (cálido) ----
  static const Color desiertoFondo       = Color(0xFFFDF6E3);
  static const Color desiertoSuperficie  = Color(0xFFF8EEC9);
  static const Color desiertoSuperficie2 = Color(0xFFF1E1AC);
  static const Color desiertoTexto       = Color(0xFF6B4F1D);
  static const Color desiertoTextoSuave  = Color(0xFF8E7238);
  static const Color desiertoAcento      = Color(0xFFB8862A);
  static const Color desiertoAcentoOsc   = Color(0xFF8E6415);
  static const Color desiertoBorde       = Color(0xFFE3D08A);
  static const Color desiertoError       = Color(0xFF9C3B2E);

  // ---- 6. Rosado suave ----
static const Color rosadoFondo       = Color(0xFFFDF0F4);
static const Color rosadoSuperficie  = Color(0xFFF8E3EB);
static const Color rosadoSuperficie2 = Color(0xFFF2D2DE);
static const Color rosadoTexto       = Color(0xFF5C2E3D);
static const Color rosadoTextoSuave  = Color(0xFF8A5F6E);
static const Color rosadoAcento      = Color(0xFFB86580);
static const Color rosadoAcentoOsc   = Color(0xFF8E4560);
static const Color rosadoBorde       = Color(0xFFE8C4D0);
static const Color rosadoError       = Color(0xFF9C3B2E);
}

class AppTheme {
  // ---------- Tipografías ----------
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

  /// Constructor genérico de un ThemeData a partir de una paleta.
  static ThemeData _construir({
    required Brightness brightness,
    required Color fondo,
    required Color superficie,
    required Color superficie2,
    required Color texto,
    required Color suave,
    required Color acento,
    required Color acentoOsc,
    required Color borde,
    required Color error,
    required Color onAcento,
  }) {
    final scheme = ColorScheme(
      brightness: brightness,
      primary: acento,
      onPrimary: onAcento,
      secondary: acentoOsc,
      onSecondary: onAcento,
      error: error,
      onError: onAcento,
      surface: superficie,
      onSurface: texto,
      surfaceContainerHighest: superficie2,
      outline: borde,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
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
        iconTheme: IconThemeData(color: texto),
      ),
      cardTheme: CardThemeData(
        color: superficie,
        elevation: brightness == Brightness.light ? 2 : 1,
        shadowColor: brightness == Brightness.light
            ? const Color(0x33000000)
            : const Color(0x66000000),
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: borde, width: 0.6),
        ),
      ),
      dividerTheme: DividerThemeData(color: borde, thickness: 0.6),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: superficie2,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: borde),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: borde),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: acento, width: 1.4),
        ),
        labelStyle: GoogleFonts.inter(color: suave),
        hintStyle: GoogleFonts.inter(color: suave),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: acento,
          foregroundColor: onAcento,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: acentoOsc),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: acento,
        foregroundColor: onAcento,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: superficie2,
        selectedColor: acento.withOpacity(0.25),
        side: BorderSide(color: borde),
        labelStyle: GoogleFonts.inter(color: texto),
      ),
      listTileTheme: ListTileThemeData(iconColor: acento, textColor: texto),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? acento
              : (brightness == Brightness.light
                  ? const Color(0xFFBFB3A0)
                  : const Color(0xFF4A5160)),
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

  // ---------- Tema 1: Catálogo de museo ----------
  static ThemeData get claro => _construir(
        brightness: Brightness.light,
        fondo: AppColors.claroFondo,
        superficie: AppColors.claroSuperficie,
        superficie2: AppColors.claroSuperficie2,
        texto: AppColors.claroTexto,
        suave: AppColors.claroTextoSuave,
        acento: AppColors.claroAcento,
        acentoOsc: AppColors.claroAcentoOsc,
        borde: AppColors.claroBorde,
        error: AppColors.claroError,
        onAcento: const Color(0xFFFFFBF2),
      );

  // ---------- Tema 2: Gabinete nocturno ----------
  static ThemeData get oscuro => _construir(
        brightness: Brightness.dark,
        fondo: AppColors.oscuroFondo,
        superficie: AppColors.oscuroSuperficie,
        superficie2: AppColors.oscuroSuperficie2,
        texto: AppColors.oscuroTexto,
        suave: AppColors.oscuroTextoSuave,
        acento: AppColors.oscuroAcento,
        acentoOsc: AppColors.oscuroAcentoOsc,
        borde: AppColors.oscuroBorde,
        error: AppColors.oscuroError,
        onAcento: const Color(0xFF1A1408),
      );

  // ---------- Tema 3: Verde pastel ----------
  static ThemeData get verde => _construir(
        brightness: Brightness.light,
        fondo: AppColors.verdeFondo,
        superficie: AppColors.verdeSuperficie,
        superficie2: AppColors.verdeSuperficie2,
        texto: AppColors.verdeTexto,
        suave: AppColors.verdeTextoSuave,
        acento: AppColors.verdeAcento,
        acentoOsc: AppColors.verdeAcentoOsc,
        borde: AppColors.verdeBorde,
        error: AppColors.verdeError,
        onAcento: const Color(0xFFFFFFFF),
      );

  // ---------- Tema 4: Azul suave ----------
  static ThemeData get azul => _construir(
        brightness: Brightness.light,
        fondo: AppColors.azulFondo,
        superficie: AppColors.azulSuperficie,
        superficie2: AppColors.azulSuperficie2,
        texto: AppColors.azulTexto,
        suave: AppColors.azulTextoSuave,
        acento: AppColors.azulAcento,
        acentoOsc: AppColors.azulAcentoOsc,
        borde: AppColors.azulBorde,
        error: AppColors.azulError,
        onAcento: const Color(0xFFFFFFFF),
      );

  // ---------- Tema 5: Desierto dorado ----------
  static ThemeData get desierto => _construir(
        brightness: Brightness.light,
        fondo: AppColors.desiertoFondo,
        superficie: AppColors.desiertoSuperficie,
        superficie2: AppColors.desiertoSuperficie2,
        texto: AppColors.desiertoTexto,
        suave: AppColors.desiertoTextoSuave,
        acento: AppColors.desiertoAcento,
        acentoOsc: AppColors.desiertoAcentoOsc,
        borde: AppColors.desiertoBorde,
        error: AppColors.desiertoError,
        onAcento: const Color(0xFFFFFBF2),
      );

  // ---------- Tema 6: Rosado suave ----------
static ThemeData get rosado => _construir(
      brightness: Brightness.light,
      fondo: AppColors.rosadoFondo,
      superficie: AppColors.rosadoSuperficie,
      superficie2: AppColors.rosadoSuperficie2,
      texto: AppColors.rosadoTexto,
      suave: AppColors.rosadoTextoSuave,
      acento: AppColors.rosadoAcento,
      acentoOsc: AppColors.rosadoAcentoOsc,
      borde: AppColors.rosadoBorde,
      error: AppColors.rosadoError,
      onAcento: const Color(0xFFFFFFFF),
    );

  /// Devuelve el ThemeData correspondiente a un AppThemeId.
  static ThemeData porId(AppThemeId id) {
    switch (id) {
      case AppThemeId.claro:    return claro;
      case AppThemeId.oscuro:   return oscuro;
      case AppThemeId.verde:    return verde;
      case AppThemeId.azul:     return azul;
      case AppThemeId.desierto: return desierto;
      case AppThemeId.rosado:   return rosado;
    }
  }

  /// Nombre legible del tema.
  static String nombre(AppThemeId id) {
    switch (id) {
      case AppThemeId.claro:    return 'Catálogo de museo';
      case AppThemeId.oscuro:   return 'Gabinete nocturno';
      case AppThemeId.verde:    return 'Verde pastel';
      case AppThemeId.azul:     return 'Azul suave';
      case AppThemeId.desierto: return 'Desierto dorado';
      case AppThemeId.rosado:   return 'Rosado suave';
    }
  }
}
