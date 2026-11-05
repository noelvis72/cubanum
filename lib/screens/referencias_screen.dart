import 'package:flutter/material.dart';
import 'package:misri_hijri/misri_hijri.dart';

class ReferenciasScreen extends StatelessWidget {
  const ReferenciasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Referencias'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.numbers), text: 'Sistemas numéricos'),
              Tab(icon: Icon(Icons.event_note), text: 'Hégira ↔ Gregoriano'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _TablaSistemaNumerico(),
            _TablaHejira(),
          ],
        ),
      ),
    );
  }
}

// =====================================================================
// Pestaña 1: Sistemas numéricos internacionales
// =====================================================================

class _TablaSistemaNumerico extends StatelessWidget {
  const _TablaSistemaNumerico();

  /// Cada entrada: (sistema, ejemplo 0-9 o descripción, países, notas).
  static const List<(String, String, String, String)> _datos = [
    (
      'Árabe occidental (estándar internacional)',
      '0 1 2 3 4 5 6 7 8 9',
      'Mayoría del mundo',
      'El que usamos a diario en Europa, América y África occidental.',
    ),
    (
      'Árabe-índico oriental',
      '٠ ١ ٢ ٣ ٤ ٥ ٦ ٧ ٨ ٩',
      'Egipto, Arabia Saudita, Golfo Pérsico',
      'Frecuente en monedas otomanas y árabes modernas.',
    ),
    (
      'Árabe-índico occidental (persa)',
      '۰ ۱ ۲ ۳ ۴ ۵ ۶ ۷ ۸ ۹',
      'Irán, Afganistán, Pakistán (urdu)',
      'Variante del oriental; cambian los glifos 4, 5 y 6.',
    ),
    (
      'Árabe-turco (abjad)',
      'Sistema alfabético (letras con valor numérico)',
      'Imperio Otomano',
      'Usado para fechas en documentos y monedas otomanas.',
    ),
    (
      'Hyderabad Arabic',
      '٠ ١ ٢ ٣ ٤ ٥ ٦ ٧ ٨ ٩ (variante local)',
      'Estado de Hyderabad (India)',
      'Usado en monedas del Nizam, junto a fecha AH.',
    ),
    (
      'Devanagari',
      '० १ २ ३ ४ ५ ६ ७ ८ ९',
      'India (hindi), Nepal',
      'Base de muchos sistemas índicos.',
    ),
    (
      'Bengalí',
      '০ ১ ২ ৩ ৪ ৫ ৬ ৭ ৮ ৯',
      'Bangladés, India (Bengala)',
      'También usado en Assam.',
    ),
    (
      'Assamés',
      '০ ১ ২ ৩ ৪ ৫ ৬ ৭ ৮ ৯',
      'Assam (India)',
      'Comparte glifos con el bengalí.',
    ),
    (
      'Gujarati',
      '૦ ૧ ૨ ૩ ૪ ૫ ૬ ૭ ૮ ૯',
      'Gujarat (India)',
      'Derivado del devanagari.',
    ),
    (
      'Kutch',
      'Copia de numerales gujarati',
      'Kutch (India)',
      'Usado en monedas de los estados principescos.',
    ),
    (
      'Tamil',
      '௦ ௧ ௨ ௩ ௪ ௫ ௬ ௭ ௮ ௯',
      'Tamil Nadu, Sri Lanka',
      'Usado en monedas antiguas del sur de India.',
    ),
    (
      'Sánscrito (índico antiguo)',
      'Variantes brahmi / kharosthi',
      'India antigua',
      'Para monedas muy antiguas; los glifos pueden no renderizarse en todos los dispositivos.',
    ),
    (
      'Tibetano',
      '༠ ༡ ༢ ༣ ༤ ༥ ༦ ༧ ༨ ༩',
      'Tíbet, Mongolia',
      'Base del sistema mongol.',
    ),
    (
      'Mongol',
      'Derivado del tibetano',
      'Mongolia',
      'Aún aparece en billetes de tögrög.',
    ),
    (
      'Birmano',
      '၀ ၁ ၂ ၃ ၄ ၅ ၆ ၇ ၈ ၉',
      'Myanmar',
      'Usado en monedas y billetes de Myanmar.',
    ),
    (
      'Tailandés',
      '๐ ๑ ๒ ๓ ๔ ๕ ๖ ๗ ๘ ๙',
      'Tailandia',
      'Usado en monedas tailandesas modernas.',
    ),
    (
      'Lao',
      '໐ ໑ ໒ ໓ ໔ ໕ ໖ ໗ ໘ ໙',
      'Laos',
      'Similar al tailandés.',
    ),
    (
      'Javanés',
      '꧐ ꧑ ꧒ ꧓ ꧔ ꧕ ꧖ ꧗ ꧘ ꧙',
      'Java (Indonesia)',
      'Usado en monedas históricas de Java.',
    ),
    (
      'Chino normal',
      '〇 一 二 三 四 五 六 七 八 九',
      'China, Japón, Corea',
      'Uso cotidiano.',
    ),
    (
      'Chino oficial (formal/financiero)',
      '零 壹 貳 叁 肆 伍 陸 柒 捌 玖',
      'China',
      'Sistema antifalsificación en billetes y monedas.',
    ),
    (
      'Chino comercial',
      '〇 一 二 三 四 五 六 七 八 九 (variante)',
      'China',
      'Similar al normal, usado en contexto comercial.',
    ),
    (
      'Coreano (Hangul formal)',
      '영 일 이 삼 사 오 육 칠 팔 구',
      'Corea',
      'Contextos formales; las monedas modernas usan árabe occidental.',
    ),
    (
      'Etíope (Ge\'ez)',
      '፩ ፪ ፫ ፬ ፭ ፮ ፯ ፰ ፱',
      'Etiopía, Eritrea',
      'Sistema alfabético sin cero; variantes para decenas y centenas.',
    ),
    (
      'Hebreo',
      'א ב ג ד ה ו ז ח ט',
      'Israel',
      'Sin cero; sistema alfabético usado en monedas antiguas.',
    ),
    (
      'Griego (jónico)',
      'α β γ δ ε ϝ ζ η θ',
      'Grecia antigua',
      'Sin cero; sistema alfabético usado en monedas antiguas y bizantinas.',
    ),
    (
      'Romano',
      'I II III IV V VI VII VIII IX',
      'Imperio Romano, Europa medieval',
      'Fundamental en numismática occidental.',
    ),
    (
      'Georgiano',
      'ა ბ გ დ ე ვ ზ ჱ თ ი (1-10) · კ ლ მ ნ (20-50) · რ ს ტ (100-300)',
      'Georgia',
      'Sistema alfabético tradicional; el georgiano moderno usa árabe occidental.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(
            'Sistemas de numeración documentados en monedas. Útil para '
            'interpretar fechas y valores grabados.',
            style: theme.textTheme.bodySmall,
          ),
        ),
        ..._datos.map((fila) {
          final (sistema, ejemplo, paises, nota) = fila;
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(sistema, style: theme.textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(
                    paises,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SelectableText(
                    ejemplo,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    nota,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.65),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}

// =====================================================================
// Pestaña 2: Hégira ↔ Gregoriano
// =====================================================================

class _TablaHejira extends StatefulWidget {
  const _TablaHejira();

  @override
  State<_TablaHejira> createState() => _TablaHejiraState();
}

class _TablaHejiraState extends State<_TablaHejira> {
  final TextEditingController _ctrlHejira = TextEditingController();
  final TextEditingController _ctrlGregoriano = TextEditingController();

  String? _resultadoHejira;
  String? _resultadoGreg;
  String? _errorHejira;
  String? _errorGreg;

  // Rango de validez del Umm al-Qura (tabla oficial saudí)
  static const int _ummAlQuraMin = 1356;
  static const int _ummAlQuraMax = 1500;

  @override
  void dispose() {
    _ctrlHejira.dispose();
    _ctrlGregoriano.dispose();
    super.dispose();
  }

  /// Determina si un año Hégira está dentro del rango exacto de Umm al-Qura.
  static bool _enRangoExacto(int h) => h >= _ummAlQuraMin && h <= _ummAlQuraMax;

    /// Convierte Hégira -> Gregoriano con la mejor precisión disponible.
  /// - Dentro de 1356–1500 AH: Umm al-Qura (tabla oficial).
  /// - Fuera de rango: Misri (tabular) aproximado.
  static (DateTime, bool) _hejiraAGregoriano(int h) {
    final exacto = _enRangoExacto(h);
    final tipo = exacto ? HijriCalendarType.ummAlQura : HijriCalendarType.misri;
    final hijri = Hijri.fromHijri(h, 1, 1, type: tipo);
    return (hijri.toDateTime(), exacto);
  }

  /// Convierte Gregoriano -> Hégira.
  static (int, bool) _gregorianoAHejira(DateTime g) {
    // Primero probamos con Umm al-Qura; si el año resultante está fuera de
    // rango, caemos a Misri (tabular).
    final hijriUmm = Hijri.fromDate(g, type: HijriCalendarType.ummAlQura);
    if (_enRangoExacto(hijriUmm.year)) {
      return (hijriUmm.year, true);
    }
    final hijriMisri = Hijri.fromDate(g, type: HijriCalendarType.misri);
    return (hijriMisri.year, false);
  }

  static final _mesesEs = <String>[
    'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
    'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre',
  ];

  static String _fmtFecha(DateTime d) =>
      '${d.day} de ${_mesesEs[d.month - 1]} de ${d.year}';

  void _convertirHejira() {
    final v = _ctrlHejira.text.trim();
    final n = int.tryParse(v);
    if (n == null || n < 1) {
      setState(() {
        _errorHejira = 'Introduce un año Hégira válido';
        _resultadoHejira = null;
      });
      return;
    }
    final (fecha, exacto) = _hejiraAGregoriano(n);
    final motor = exacto ? 'Umm al-Qura (exacto)' : 'Tabular (aproximado)';
    setState(() {
      _errorHejira = null;
      _resultadoHejira =
          'El 1 de Muharram de $n H correspondió al '
          '${_fmtFecha(fecha)}.\n'
          'Año gregoriano aproximado: ${fecha.year} G.\n'
          'Motor: $motor.';
    });
  }

  void _convertirGregoriano() {
    final v = _ctrlGregoriano.text.trim();
    final n = int.tryParse(v);
    if (n == null || n < 622) {
      setState(() {
        _errorGreg = 'Introduce un año gregoriano válido (≥ 622)';
        _resultadoGreg = null;
      });
      return;
    }
    final (h, exacto) = _gregorianoAHejira(DateTime(n, 1, 1));
    final motor = exacto ? 'Umm al-Qura (exacto)' : 'Tabular (aproximado)';
    setState(() {
      _errorGreg = null;
      _resultadoGreg =
          'El 1 de enero de $n G cayó en el año $h H.\n'
          'Motor: $motor.';
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        Text(
          'Conversión entre el calendario islámico (Hégira) y el gregoriano. '
          'Muchas monedas de países musulmanes llevan la fecha en Hégira.',
          style: theme.textTheme.bodySmall,
        ),
        const SizedBox(height: 12),

        // Rango de validez
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.10),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: theme.colorScheme.primary.withOpacity(0.4)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline, size: 18, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Conversión exacta (Umm al-Qura) para años '
                  '$_ummAlQuraMin–$_ummAlQuraMax H. '
                  'Fuera de ese rango se usa el calendario tabular '
                  '(aproximado ±1-2 días).',
                  style: theme.textTheme.bodySmall,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Hégira -> Gregoriano
        Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Hégira → Gregoriano', style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                TextField(
                  controller: _ctrlHejira,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Año Hégira',
                    hintText: 'Ej. 1324',
                    errorText: _errorHejira,
                    prefixIcon: const Icon(Icons.mosque_outlined),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _convertirHejira,
                    child: const Text('Convertir'),
                  ),
                ),
                if (_resultadoHejira != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _resultadoHejira!,
                      style: theme.textTheme.bodyLarge,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),

        // Gregoriano -> Hégira
        Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Gregoriano → Hégira', style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                TextField(
                  controller: _ctrlGregoriano,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Año gregoriano',
                    hintText: 'Ej. 1906',
                    errorText: _errorGreg,
                    prefixIcon: const Icon(Icons.calendar_month_outlined),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _convertirGregoriano,
                    child: const Text('Convertir'),
                  ),
                ),
                if (_resultadoGreg != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _resultadoGreg!,
                      style: theme.textTheme.bodyLarge,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),

        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            'Nota: la conversión da el día en que comienza el año Hégira. '
            'El calendario islámico es lunar, por lo que un año Hégira cae a '
            'caballo entre dos años gregorianos.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      ],
    );
  }
}
