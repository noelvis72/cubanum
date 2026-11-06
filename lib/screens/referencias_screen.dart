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
              Tab(icon: Icon(Icons.grid_on), text: 'Numeración internacional'),
              Tab(icon: Icon(Icons.event_note), text: 'Hégira ↔ Gregoriano'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _TablaNumeracion(),
            _TablaHejira(),
          ],
        ),
      ),
    );
  }
}

// =====================================================================
// Pestaña 1: Tabla de numeración internacional
// =====================================================================

/// Datos de un sistema numérico para la tabla comparativa.
/// Cada valor del enum corresponde a una columna de la tabla.
class _SistemaNumerico {
  final String nombre;
  final String nota;
  /// Mapa valor -> glifo o composición. Si un valor no está en el mapa,
  /// se muestra celda gris (sin glifo).
  /// Clave especial: 'half' para la fracción 1/2.
  final Map<String, String> valores;

  const _SistemaNumerico({
    required this.nombre,
    required this.nota,
    required this.valores,
  });
}

/// Columnas de la tabla, en orden de aparición.
/// 'half' representa la fracción 1/2.
const List<String> _columnas = [
  '0', 'half', '1', '2', '3', '4', '5', '6', '7', '8', '9',
  '10', '20', '50', '100', '200', '500', '1000', '2000',
];

const List<_SistemaNumerico> _sistemas = [
  _SistemaNumerico(
    nombre: 'Árabe occidental',
    nota: 'Estándar internacional. Usado en la mayoría del mundo.',
    valores: {
      '0': '0', 'half': '½', '1': '1', '2': '2', '3': '3', '4': '4',
      '5': '5', '6': '6', '7': '7', '8': '8', '9': '9',
      '10': '10', '20': '20', '50': '50', '100': '100', '200': '200',
      '500': '500', '1000': '1000', '2000': '2000',
    },
  ),
  _SistemaNumerico(
    nombre: 'Árabe-índico occidental (persa)',
    nota: 'Variante del oriental. Cambian 4, 5 y 6.',
    valores: {
      '0': '۰', 'half': '½', '1': '۱', '2': '۲', '3': '۳', '4': '۴',
      '5': '۵', '6': '۶', '7': '۷', '8': '۸', '9': '۹',
      '10': '۱۰', '20': '۲۰', '50': '۵۰', '100': '۱۰۰',
      '200': '۲۰۰', '500': '۵۰۰', '1000': '۱۰۰۰', '2000': '۲۰۰۰',
    },
  ),
  _SistemaNumerico(
    nombre: 'Árabe-índico oriental',
    nota: 'Egipto, Arabia Saudita, Golfo Pérsico.',
    valores: {
      '0': '٠', 'half': '½', '1': '١', '2': '٢', '3': '٣', '4': '٤',
      '5': '٥', '6': '٦', '7': '٧', '8': '٨', '9': '٩',
      '10': '١٠', '20': '٢٠', '50': '٥٠', '100': '١٠٠',
      '200': '٢٠٠', '500': '٥٠٠', '1000': '١٠٠٠', '2000': '٢٠٠٠',
    },
  ),
  _SistemaNumerico(
    nombre: 'Árabe-turco (abjad)',
    nota: 'Sistema alfabético otomano. Letras árabes con valor numérico.',
    valores: {
      '1': 'ا', '2': 'ب', '3': 'ج', '4': 'د', '5': 'ه',
      '6': 'و', '7': 'ز', '8': 'ح', '9': 'ط',
      '10': 'ي', '20': 'ك', '50': 'ن', '100': 'ق',
      '200': 'ر', '500': 'ش', '1000': 'غ', '2000': 'غغ',
    },
  ),
  _SistemaNumerico(
    nombre: 'Assamés',
    nota: 'Comparte glifos con el bengalí.',
    valores: {
      '0': '০', 'half': '½', '1': '১', '2': '২', '3': '৩', '4': '৪',
      '5': '৫', '6': '৬', '7': '৭', '8': '৮', '9': '৯',
      '10': '১০', '20': '২০', '50': '৫০', '100': '১০০',
      '200': '২০০', '500': '৫০০', '1000': '১০০০', '2000': '২০০০',
    },
  ),
  _SistemaNumerico(
    nombre: 'Bengalí',
    nota: 'Bangladés, India (Bengala Occidental).',
    valores: {
      '0': '০', 'half': '½', '1': '১', '2': '২', '3': '৩', '4': '৪',
      '5': '৫', '6': '৬', '7': '৭', '8': '৮', '9': '৯',
      '10': '১০', '20': '২০', '50': '৫০', '100': '১০০',
      '200': '২০০', '500': '৫০০', '1000': '১০০০', '2000': '২০০০',
    },
  ),
  _SistemaNumerico(
    nombre: 'Birmano',
    nota: 'Myanmar.',
    valores: {
      '0': '၀', 'half': '½', '1': '၁', '2': '၂', '3': '၃', '4': '၄',
      '5': '၅', '6': '၆', '7': '၇', '8': '၈', '9': '၉',
      '10': '၁၀', '20': '၂၀', '50': '၅၀', '100': '၁၀၀',
      '200': '၂၀၀', '500': '၅၀၀', '1000': '၁၀၀၀', '2000': '၂၀၀၀',
    },
  ),
  _SistemaNumerico(
    nombre: 'Chino comercial',
    nota: 'Similar al normal, uso comercial.',
    valores: {
      '0': '〇', 'half': '半', '1': '一', '2': '二', '3': '三', '4': '四',
      '5': '五', '6': '六', '7': '七', '8': '八', '9': '九',
      '10': '十', '20': '廿', '50': '五十', '100': '百',
      '200': '二百', '500': '五百', '1000': '千', '2000': '二千',
    },
  ),
  _SistemaNumerico(
    nombre: 'Chino formal (oficial/financiero)',
    nota: 'Sistema antifalsificación en billetes y monedas.',
    valores: {
      '0': '零', 'half': '半', '1': '壹', '2': '貳', '3': '叁', '4': '肆',
      '5': '伍', '6': '陸', '7': '柒', '8': '捌', '9': '玖',
      '10': '拾', '20': '貳拾', '50': '伍拾', '100': '佰',
      '200': '貳佰', '500': '伍佰', '1000': '仟', '2000': '貳仟',
    },
  ),
  _SistemaNumerico(
    nombre: 'Chino normal',
    nota: 'China, Japón, Corea. Uso cotidiano.',
    valores: {
      '0': '〇', 'half': '半', '1': '一', '2': '二', '3': '三', '4': '四',
      '5': '五', '6': '六', '7': '七', '8': '八', '9': '九',
      '10': '十', '20': '廿', '50': '五十', '100': '百',
      '200': '二百', '500': '五百', '1000': '千', '2000': '二千',
    },
  ),
  _SistemaNumerico(
    nombre: 'Coreano (Hangul formal)',
    nota: 'Contextos formales. Monedas modernas usan árabe occidental.',
    valores: {
      '0': '영', '1': '일', '2': '이', '3': '삼', '4': '사', '5': '오',
      '6': '육', '7': '칠', '8': '팔', '9': '구',
      '10': '십', '20': '이십', '50': '오십', '100': '백',
      '200': '이백', '500': '오백', '1000': '천', '2000': '이천',
    },
  ),
  _SistemaNumerico(
    nombre: 'Devanagari',
    nota: 'India (hindi), Nepal.',
    valores: {
      '0': '०', 'half': '½', '1': '१', '2': '२', '3': '३', '4': '४',
      '5': '५', '6': '६', '7': '७', '8': '८', '9': '९',
      '10': '१०', '20': '२०', '50': '५०', '100': '१००',
      '200': '२००', '500': '५००', '1000': '१०००', '2000': '२०००',
    },
  ),
  _SistemaNumerico(
    nombre: 'Etíope (Ge\'ez)',
    nota: 'Sistema alfabético sin cero. Variantes para decenas y centenas.',
    valores: {
      '1': '፩', '2': '፪', '3': '፫', '4': '፬', '5': '፭',
      '6': '፮', '7': '፯', '8': '፰', '9': '፱',
      '10': '፲', '20': '፳', '50': '፶', '100': '፻',
      '200': '፪፻', '500': '፭፻', '1000': '፲፻', '2000': '፳፻',
    },
  ),
  _SistemaNumerico(
    nombre: 'Georgiano',
    nota: 'Sistema alfabético tradicional. El georgiano moderno usa árabe occidental.',
    valores: {
      '1': 'ა', '2': 'ბ', '3': 'გ', '4': 'დ', '5': 'ე',
      '6': 'ვ', '7': 'ზ', '8': 'ჱ', '9': 'თ',
      '10': 'ი', '20': 'კ', '50': 'ნ', '100': 'რ',
      '200': 'ს', '500': 'ფ', '1000': 'ჩ', '2000': 'ჩჩ',
    },
  ),
  _SistemaNumerico(
    nombre: 'Griego (jónico)',
    nota: 'Sin cero. Sistema alfabético usado en monedas antiguas y bizantinas.',
    valores: {
      '1': 'α', '2': 'β', '3': 'γ', '4': 'δ', '5': 'ε',
      '6': 'ϝ', '7': 'ζ', '8': 'η', '9': 'θ',
      '10': 'ι', '20': 'κ', '50': 'ν', '100': 'ρ',
      '200': 'σ', '500': 'υρ', '1000': '͵α', '2000': '͵β',
    },
  ),
  _SistemaNumerico(
    nombre: 'Gujarati',
    nota: 'Gujarat (India). Derivado del devanagari.',
    valores: {
      '0': '૦', 'half': '½', '1': '૧', '2': '૨', '3': '૩', '4': '૪',
      '5': '૫', '6': '૬', '7': '૭', '8': '૮', '9': '૯',
      '10': '૧૦', '20': '૨૦', '50': '૫૦', '100': '૧૦૦',
      '200': '૨૦૦', '500': '૫૦૦', '1000': '૧૦૦૦', '2000': '૨૦૦૦',
    },
  ),
  _SistemaNumerico(
    nombre: 'Hebreo',
    nota: 'Sin cero. Sistema alfabético usado en monedas antiguas.',
    valores: {
      '1': 'א', '2': 'ב', '3': 'ג', '4': 'ד', '5': 'ה',
      '6': 'ו', '7': 'ז', '8': 'ח', '9': 'ט',
      '10': 'י', '20': 'כ', '50': 'נ', '100': 'ק',
      '200': 'ר', '500': 'ת"ק', '1000': 'א׳', '2000': 'ב׳ אלפים',
    },
  ),
  _SistemaNumerico(
    nombre: 'Hyderabad Arabic',
    nota: 'Variante local del árabe-índico oriental. Monedas del Nizam.',
    valores: {
      '0': '٠', 'half': '½', '1': '١', '2': '٢', '3': '٣', '4': '٤',
      '5': '٥', '6': '٦', '7': '٧', '8': '٨', '9': '٩',
      '10': '١٠', '20': '٢٠', '50': '٥٠', '100': '١٠٠',
      '200': '٢٠٠', '500': '٥٠٠', '1000': '١٠٠٠', '2000': '٢٠٠٠',
    },
  ),
  _SistemaNumerico(
    nombre: 'Javanés',
    nota: 'Java (Indonesia). Monedas históricas de Java.',
    valores: {
      '0': '꧐', 'half': '½', '1': '꧑', '2': '꧒', '3': '꧓', '4': '꧔',
      '5': '꧕', '6': '꧖', '7': '꧗', '8': '꧘', '9': '꧙',
      '10': '꧑꧐', '20': '꧒꧐', '50': '꧕꧐', '100': '꧑꧐꧐',
      '200': '꧒꧐꧐', '500': '꧕꧐꧐', '1000': '꧑꧐꧐꧐', '2000': '꧒꧐꧐꧐',
    },
  ),
  _SistemaNumerico(
    nombre: 'Kutch',
    nota: 'Usa los mismos glifos que el gujarati. Monedas de estados principescos.',
    valores: {
      '0': '૦', 'half': '½', '1': '૧', '2': '૨', '3': '૩', '4': '૪',
      '5': '૫', '6': '૬', '7': '૭', '8': '૮', '9': '૯',
      '10': '૧૦', '20': '૨૦', '50': '૫૦', '100': '૧૦૦',
      '200': '૨૦૦', '500': '૫૦૦', '1000': '૧૦૦૦', '2000': '૨૦૦૦',
    },
  ),
  _SistemaNumerico(
    nombre: 'Lao',
    nota: 'Laos. Similar al tailandés.',
    valores: {
      '0': '໐', 'half': '½', '1': '໑', '2': '໒', '3': '໓', '4': '໔',
      '5': '໕', '6': '໖', '7': '໗', '8': '໘', '9': '໙',
      '10': '໑໐', '20': '໒໐', '50': '໕໐', '100': '໑໐໐',
      '200': '໒໐໐', '500': '໕໐໐', '1000': '໑໐໐໐', '2000': '໒໐໐໐',
    },
  ),
  _SistemaNumerico(
    nombre: 'Mongol',
    nota: 'Derivado del tibetano. Aún en billetes de tögrög.',
    valores: {
      '0': '᠐', 'half': '½', '1': '᠑', '2': '᠒', '3': '᠓', '4': '᠔',
      '5': '᠕', '6': '᠖', '7': '᠗', '8': '᠘', '9': '᠙',
      '10': '᠑᠐', '20': '᠒᠐', '50': '᠕᠐', '100': '᠑᠐᠐',
      '200': '᠒᠐᠐', '500': '᠕᠐᠐', '1000': '᠑᠐᠐᠐', '2000': '᠒᠐᠐᠐',
    },
  ),
  _SistemaNumerico(
    nombre: 'Romano',
    nota: 'Fundamental en numismática occidental. Sin cero.',
    valores: {
      'half': 'S', '1': 'I', '2': 'II', '3': 'III', '4': 'IV',
      '5': 'V', '6': 'VI', '7': 'VII', '8': 'VIII', '9': 'IX',
      '10': 'X', '20': 'XX', '50': 'L', '100': 'C',
      '200': 'CC', '500': 'D', '1000': 'M', '2000': 'MM',
    },
  ),
  _SistemaNumerico(
    nombre: 'Tamil',
    nota: 'Tamil Nadu, Sri Lanka. Monedas antiguas del sur de India.',
    valores: {
      '0': '௦', 'half': '½', '1': '௧', '2': '௨', '3': '௩', '4': '௪',
      '5': '௫', '6': '௬', '7': '௭', '8': '௮', '9': '௯',
      '10': '௧௦', '20': '௨௦', '50': '௫௦', '100': '௧௦௦',
      '200': '௨௦௦', '500': '௫௦௦', '1000': '௧௦௦௦', '2000': '௨௦௦௦',
    },
  ),
  _SistemaNumerico(
    nombre: 'Tibetano',
    nota: 'Tíbet, Mongolia. Base del sistema mongol.',
    valores: {
      '0': '༠', 'half': '½', '1': '༡', '2': '༢', '3': '༣', '4': '༤',
      '5': '༥', '6': '༦', '7': '༧', '8': '༨', '9': '༩',
      '10': '༡༠', '20': '༢༠', '50': '༥༠', '100': '༡༠༠',
      '200': '༢༠༠', '500': '༥༠༠', '1000': '༡༠༠༠', '2000': '༢༠༠༠',
    },
  ),
  _SistemaNumerico(
    nombre: 'Tailandés',
    nota: 'Tailandia. Usado en monedas modernas.',
    valores: {
      '0': '๐', 'half': '½', '1': '๑', '2': '๒', '3': '๓', '4': '๔',
      '5': '๕', '6': '๖', '7': '๗', '8': '๘', '9': '๙',
      '10': '๑๐', '20': '๒๐', '50': '๕๐', '100': '๑๐๐',
      '200': '๒๐๐', '500': '๕๐๐', '1000': '๑๐๐๐', '2000': '๒๐๐๐',
    },
  ),
];

/// Texto de ayuda al inicio de la tabla, en viñetas.
const List<String> _notaInicial = [
  'Las celdas en gris indican que ese sistema no tiene glifo propio para ese valor.',
  'Los valores compuestos (por ejemplo, IV en romano, ๕๐ en tailandés) se muestran completos.',
  'Algunos sistemas alfabéticos (romano, griego, hebreo) no tienen glifo para el 0.',
  'Los glifos marcados con ◻ no están disponibles en este dispositivo: toca la celda para ver el nombre de la letra.',
];

class _TablaNumeracion extends StatelessWidget {
  const _TablaNumeracion();

  static const double _anchoNombre = 200;
  static const double _anchoCelda = 48;
  static const double _altoFila = 48;
  static const double _altoCabecera = 44;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Un único ScrollController horizontal para sincronizar la cabecera
    // con el cuerpo de la tabla.
    return _TablaNumeracionScroll(
      theme: theme,
      anchoNombre: _anchoNombre,
      anchoCelda: _anchoCelda,
      altoFila: _altoFila,
      altoCabecera: _altoCabecera,
    );
  }
}

class _TablaNumeracionScroll extends StatefulWidget {
  final ThemeData theme;
  final double anchoNombre;
  final double anchoCelda;
  final double altoFila;
  final double altoCabecera;

  const _TablaNumeracionScroll({
    required this.theme,
    required this.anchoNombre,
    required this.anchoCelda,
    required this.altoFila,
    required this.altoCabecera,
  });

  @override
  State<_TablaNumeracionScroll> createState() => _TablaNumeracionScrollState();
}

class _TablaNumeracionScrollState extends State<_TablaNumeracionScroll> {
  final _horizontalCtrl = ScrollController();

  @override
  void dispose() {
    _horizontalCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;
    final totalAnchoNumeros = _columnas.length * widget.anchoCelda;

    return Column(
      children: [
        // Nota inicial en viñetas
        Container(
          margin: const EdgeInsets.fromLTRB(12, 12, 12, 4),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: theme.colorScheme.primary.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Cómo leer esta tabla',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              ..._notaInicial.map((linea) => Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('◇ ', style: theme.textTheme.bodySmall),
                        Expanded(
                          child: Text(
                            linea,
                            style: theme.textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                  )),
            ],
          ),
        ),

        // Cabecera de la tabla: columna fija "Sistema" + cabecera de números
        Row(
          children: [
            Container(
              width: widget.anchoNombre,
              height: widget.altoCabecera,
              color: theme.colorScheme.surfaceContainerHighest,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              alignment: Alignment.centerLeft,
              child: Text(
                'Sistema',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                controller: _horizontalCtrl,
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _columnas.map((c) {
                    return SizedBox(
                      width: widget.anchoCelda,
                      height: widget.altoCabecera,
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest,
                          border: Border(
                            left: BorderSide(
                              color: theme.colorScheme.outline.withOpacity(0.3),
                              width: 0.5,
                            ),
                          ),
                        ),
                        child: Text(
                          c == 'half' ? '½' : c,
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),

        // Cuerpo de la tabla
        Expanded(
          child: Row(
            children: [
              // Columna fija: nombres de sistemas
              SizedBox(
                width: widget.anchoNombre,
                child: ListView.builder(
                  itemCount: _sistemas.length,
                  itemBuilder: (_, i) {
                    final s = _sistemas[i];
                    return _CeldaNombre(
                      sistema: s,
                      ancho: widget.anchoNombre,
                      alto: widget.altoFila,
                    );
                  },
                ),
              ),
              // Cuerpo con scroll horizontal
              Expanded(
                child: SingleChildScrollView(
                  controller: _horizontalCtrl,
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: totalAnchoNumeros,
                    child: ListView.builder(
                      itemCount: _sistemas.length,
                      itemBuilder: (_, i) {
                        final s = _sistemas[i];
                        return _FilaSistema(
                          sistema: s,
                          anchoCelda: widget.anchoCelda,
                          alto: widget.altoFila,
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CeldaNombre extends StatelessWidget {
  final _SistemaNumerico sistema;
  final double ancho;
  final double alto;

  const _CeldaNombre({
    required this.sistema,
    required this.ancho,
    required this.alto,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: ancho,
      height: alto,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: theme.colorScheme.outline.withOpacity(0.2), width: 0.5),
          right: BorderSide(color: theme.colorScheme.outline.withOpacity(0.3), width: 0.5),
        ),
      ),
      alignment: Alignment.centerLeft,
      child: Tooltip(
        message: sistema.nota,
        child: Text(
          sistema.nombre,
          style: theme.textTheme.bodySmall,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}

class _FilaSistema extends StatelessWidget {
  final _SistemaNumerico sistema;
  final double anchoCelda;
  final double alto;

  const _FilaSistema({
    required this.sistema,
    required this.anchoCelda,
    required this.alto,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: _columnas.map((c) {
        final valor = sistema.valores[c];
        final vacia = valor == null || valor.isEmpty;
        return SizedBox(
          width: anchoCelda,
          height: alto,
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: vacia ? theme.colorScheme.surfaceContainerHighest : null,
              border: Border(
                top: BorderSide(color: theme.colorScheme.outline.withOpacity(0.2), width: 0.5),
                left: BorderSide(color: theme.colorScheme.outline.withOpacity(0.2), width: 0.5),
              ),
            ),
            child: vacia
                ? null
                : InkWell(
                    onTap: () => _mostrarDialogo(context, sistema, c, valor),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: Text(
                        valor,
                        style: theme.textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.clip,
                      ),
                    ),
                  ),
          ),
        );
      }).toList(),
    );
  }

  void _mostrarDialogo(
    BuildContext context,
    _SistemaNumerico sistema,
    String columna,
    String valor,
  ) {
    // Mostrar siempre el diálogo al pulsar una celda (útil para copiar
    // o ver el detalle aunque el glifo se renderice bien).
    final etiquetaValor = columna == 'half' ? '½' : columna;
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(sistema.nombre),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Valor: $etiquetaValor'),
            const SizedBox(height: 6),
            Text('Glifo: $valor'),
            const SizedBox(height: 6),
            if (sistema.nota.isNotEmpty)
              Text('Nota: ${sistema.nota}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cerrar'),
          ),
        ],
      ),
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

  static const int _ummAlQuraMin = 1356;
  static const int _ummAlQuraMax = 1500;

  @override
  void dispose() {
    _ctrlHejira.dispose();
    _ctrlGregoriano.dispose();
    super.dispose();
  }

  static bool _enRangoExacto(int h) => h >= _ummAlQuraMin && h <= _ummAlQuraMax;

  static (DateTime, bool) _hejiraAGregoriano(int h) {
    final exacto = _enRangoExacto(h);
    final tipo = exacto ? HijriCalendarType.ummAlQura : HijriCalendarType.misri;
    final hijri = Hijri.fromHijri(h, 1, 1, type: tipo);
    return (hijri.toDateTime(), exacto);
  }

  static (int, bool) _gregorianoAHejira(DateTime g) {
    final hijriUmm = Hijri.fromDate(g, type: HijriCalendarType.ummAlQura);
    if (_enRangoExacto(hijriUmm.year)) return (hijriUmm.year, true);
    final hijriMisri = Hijri.fromDate(g, type: HijriCalendarType.misri);
    return (hijriMisri.year, false);
  }

  static final _mesesEs = <String>[
    'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
    'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre',
  ];

  static String _fmtFecha(DateTime d) =>
      '${d.day} de ${_mesesEs[d.month - 1]} de ${d.year}';

  bool _validoHejira() {
    final v = _ctrlHejira.text.trim();
    final n = int.tryParse(v);
    return n != null && n >= 100 && n <= 9999;
  }

  bool _validoGreg() {
    final v = _ctrlGregoriano.text.trim();
    final n = int.tryParse(v);
    return n != null && n >= 1000 && n <= 9999;
  }

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

  void _limpiarHejira() {
    setState(() {
      _ctrlHejira.clear();
      _resultadoHejira = null;
      _errorHejira = null;
    });
  }

  void _limpiarGreg() {
    setState(() {
      _ctrlGregoriano.clear();
      _resultadoGreg = null;
      _errorGreg = null;
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

        // Aviso de rango
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
                  textInputAction: TextInputAction.done,
                  onChanged: (_) => setState(() {}),
                  onSubmitted: (_) {
                    if (_validoHejira()) _convertirHejira();
                  },
                  decoration: InputDecoration(
                    labelText: 'Año Hégira',
                    hintText: 'Ej. 1324',
                    errorText: _errorHejira,
                    prefixIcon: const Icon(Icons.mosque_outlined),
                    suffixIcon: _resultadoHejira != null
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            tooltip: 'Limpiar',
                            onPressed: _limpiarHejira,
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _validoHejira() ? _convertirHejira : null,
                    icon: const Icon(Icons.sync_alt),
                    label: const Text('Convertir'),
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
                  textInputAction: TextInputAction.done,
                  onChanged: (_) => setState(() {}),
                  onSubmitted: (_) {
                    if (_validoGreg()) _convertirGregoriano();
                  },
                  decoration: InputDecoration(
                    labelText: 'Año gregoriano',
                    hintText: 'Ej. 1906',
                    errorText: _errorGreg,
                    prefixIcon: const Icon(Icons.calendar_month_outlined),
                    suffixIcon: _resultadoGreg != null
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            tooltip: 'Limpiar',
                            onPressed: _limpiarGreg,
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _validoGreg() ? _convertirGregoriano : null,
                    icon: const Icon(Icons.sync_alt),
                    label: const Text('Convertir'),
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
