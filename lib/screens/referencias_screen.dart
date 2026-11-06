import 'package:flutter/material.dart';
import 'package:flutter_expandable_table/flutter_expandable_table.dart';
import 'package:hijri_plus/hijri_plus.dart' as hp;

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
              Tab(text: 'Numeración internacional'),
              Tab(text: 'Hégira ↔ Gregoriano'),
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

class _SistemaNumerico {
  final String nombre;
  final String nota;
  final Map<String, String> valores;

  const _SistemaNumerico({
    required this.nombre,
    required this.nota,
    required this.valores,
  });
}

const List<String> _columnas = [
  '0', 'half', '1', '2', '3', '4', '5', '6', '7', '8', '9',
  '10', '20', '50', '100', '200', '500', '1000', '2000',
];

const List<_SistemaNumerico> _sistemas = [
  _SistemaNumerico(
    nombre: 'Árabe occidental',
    nota: 'Estándar internacional.',
    valores: {
      '0': '0', 'half': '½', '1': '1', '2': '2', '3': '3', '4': '4',
      '5': '5', '6': '6', '7': '7', '8': '8', '9': '9',
      '10': '10', '20': '20', '50': '50', '100': '100', '200': '200',
      '500': '500', '1000': '1000', '2000': '2000',
    },
  ),
  _SistemaNumerico(
    nombre: 'Árabe-índico occidental (persa)',
    nota: 'Cambian 4, 5 y 6.',
    valores: {
      '0': '۰', 'half': '۱/۲', '1': '۱', '2': '۲', '3': '۳', '4': '۴',
      '5': '۵', '6': '۶', '7': '۷', '8': '۸', '9': '۹',
      '10': '۱۰', '20': '۲۰', '50': '۵۰', '100': '۱۰۰',
      '200': '۲۰۰', '500': '۵۰۰', '1000': '۱۰۰۰', '2000': '۲۰۰۰',
    },
  ),
  _SistemaNumerico(
    nombre: 'Árabe-índico oriental',
    nota: 'Egipto, Arabia Saudita, Golfo Pérsico.',
    valores: {
      '0': '٠', 'half': '١/٢', '1': '١', '2': '٢', '3': '٣', '4': '٤',
      '5': '٥', '6': '٦', '7': '٧', '8': '٨', '9': '٩',
      '10': '١٠', '20': '٢٠', '50': '٥٠', '100': '١٠٠',
      '200': '٢٠٠', '500': '٥٠٠', '1000': '١٠٠٠', '2000': '٢٠٠٠',
    },
  ),
  _SistemaNumerico(
    nombre: 'Árabe-turco (abjad)',
    nota: 'Letras árabes con valor numérico.',
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
      '0': '০', 'half': '১/২', '1': '১', '2': '২', '3': '৩', '4': '৪',
      '5': '৫', '6': '৬', '7': '৭', '8': '৮', '9': '৯',
      '10': '১০', '20': '২০', '50': '৫০', '100': '১০০',
      '200': '২০০', '500': '৫০০', '1000': '১০০০', '2000': '২০০০',
    },
  ),
  _SistemaNumerico(
    nombre: 'Bengalí',
    nota: 'Bangladés, India (Bengala Occidental).',
    valores: {
      '0': '০', 'half': '১/২', '1': '১', '2': '২', '3': '৩', '4': '৪',
      '5': '৫', '6': '৬', '7': '৭', '8': '৮', '9': '৯',
      '10': '১০', '20': '২০', '50': '৫০', '100': '১০০',
      '200': '২০০', '500': '৫০০', '1000': '১০০০', '2000': '২০০০',
    },
  ),
  _SistemaNumerico(
    nombre: 'Birmano',
    nota: 'Myanmar.',
    valores: {
      '0': '၀', 'half': '၁/၂', '1': '၁', '2': '၂', '3': '၃', '4': '၄',
      '5': '၅', '6': '၆', '7': '၇', '8': '၈', '9': '၉',
      '10': '၁၀', '20': '၂၀', '50': '၅၀', '100': '၁၀၀',
      '200': '၂၀၀', '500': '၅၀၀', '1000': '၁၀၀၀', '2000': '၂၀၀၀',
    },
  ),
  _SistemaNumerico(
    nombre: 'Chino comercial',
    nota: 'Similar al normal, uso comercial. ½ = 半.',
    valores: {
      '0': '〇', 'half': '半', '1': '一', '2': '二', '3': '三', '4': '四',
      '5': '五', '6': '六', '7': '七', '8': '八', '9': '九',
      '10': '十', '20': '廿', '50': '五十', '100': '百',
      '200': '二百', '500': '五百', '1000': '千', '2000': '二千',
    },
  ),
  _SistemaNumerico(
    nombre: 'Chino formal (oficial/financiero)',
    nota: 'Antifalsificación en billetes y monedas. ½ = 半.',
    valores: {
      '0': '零', 'half': '半', '1': '壹', '2': '貳', '3': '叁', '4': '肆',
      '5': '伍', '6': '陸', '7': '柒', '8': '捌', '9': '玖',
      '10': '拾', '20': '貳拾', '50': '伍拾', '100': '佰',
      '200': '貳佰', '500': '伍佰', '1000': '仟', '2000': '貳仟',
    },
  ),
  _SistemaNumerico(
    nombre: 'Chino normal (ordinary)',
    nota: 'China, Japón, Corea. ½ = 半.',
    valores: {
      '0': '〇', 'half': '半', '1': '一', '2': '二', '3': '三', '4': '四',
      '5': '五', '6': '六', '7': '七', '8': '八', '9': '九',
      '10': '十', '20': '廿', '50': '五十', '100': '百',
      '200': '二百', '500': '五百', '1000': '千', '2000': '二千',
    },
  ),
  _SistemaNumerico(
    nombre: 'Coreano (Hangul formal)',
    nota: 'Contextos formales. ½ = 반 (ban, mitad).',
    valores: {
      '0': '영', 'half': '반', '1': '일', '2': '이', '3': '삼', '4': '사',
      '5': '오', '6': '육', '7': '칠', '8': '팔', '9': '구',
      '10': '십', '20': '이십', '50': '오십', '100': '백',
      '200': '이백', '500': '오백', '1000': '천', '2000': '이천',
    },
  ),
  _SistemaNumerico(
    nombre: 'Devanagari',
    nota: 'India (hindi), Nepal.',
    valores: {
      '0': '०', 'half': '१/२', '1': '१', '2': '२', '3': '३', '4': '४',
      '5': '५', '6': '६', '7': '७', '8': '८', '9': '९',
      '10': '१०', '20': '२०', '50': '५०', '100': '१००',
      '200': '२००', '500': '५००', '1000': '१०००', '2000': '२०००',
    },
  ),
  _SistemaNumerico(
    nombre: 'Etíope (Ge\'ez)',
    nota: 'Sistema alfabético sin cero.',
    valores: {
      '1': '፩', '2': '፪', '3': '፫', '4': '፬', '5': '፭',
      '6': '፮', '7': '፯', '8': '፰', '9': '፱',
      '10': '፲', '20': '፳', '50': '፶', '100': '፻',
      '200': '፪፻', '500': '፭፻', '1000': '፲፻', '2000': '፳፻',
    },
  ),
  _SistemaNumerico(
    nombre: 'Georgiano',
    nota: 'Sistema alfabético tradicional. Moderno usa árabe occidental.',
    valores: {
      '1': 'ა', '2': 'ბ', '3': 'გ', '4': 'დ', '5': 'ე',
      '6': 'ვ', '7': 'ზ', '8': 'ჱ', '9': 'თ',
      '10': 'ი', '20': 'კ', '50': 'ნ', '100': 'რ',
      '200': 'ს', '500': 'ფ', '1000': 'ჩ', '2000': 'ჩჩ',
    },
  ),
  _SistemaNumerico(
    nombre: 'Griego (jónico)',
    nota: 'Sin cero. Alfabético, monedas antiguas y bizantinas.',
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
      '0': '૦', 'half': '૧/૨', '1': '૧', '2': '૨', '3': '૩', '4': '૪',
      '5': '૫', '6': '૬', '7': '૭', '8': '૮', '9': '૯',
      '10': '૧૦', '20': '૨૦', '50': '૫૦', '100': '૧૦૦',
      '200': '૨૦૦', '500': '૫૦૦', '1000': '૧૦૦૦', '2000': '૨૦૦૦',
    },
  ),
  _SistemaNumerico(
    nombre: 'Hebreo',
    nota: 'Sin cero. Alfabético, monedas antiguas.',
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
      '0': '٠', 'half': '١/٢', '1': '١', '2': '٢', '3': '٣', '4': '٤',
      '5': '٥', '6': '٦', '7': '٧', '8': '٨', '9': '٩',
      '10': '١٠', '20': '٢٠', '50': '٥٠', '100': '١٠٠',
      '200': '٢٠٠', '500': '٥٠٠', '1000': '١٠٠٠', '2000': '٢٠٠٠',
    },
  ),
  _SistemaNumerico(
    nombre: 'Javanés',
    nota: 'Java (Indonesia). Monedas históricas.',
    valores: {
      '0': '꧐', '1': '꧑', '2': '꧒', '3': '꧓', '4': '꧔',
      '5': '꧕', '6': '꧖', '7': '꧗', '8': '꧘', '9': '꧙',
      '10': '꧑꧐', '20': '꧒꧐', '50': '꧕꧐', '100': '꧑꧐꧐',
      '200': '꧒꧐꧐', '500': '꧕꧐꧐', '1000': '꧑꧐꧐꧐', '2000': '꧒꧐꧐꧐',
    },
  ),
  _SistemaNumerico(
    nombre: 'Kutch',
    nota: 'Mismos glifos que el gujarati. Estados principescos.',
    valores: {
      '0': '૦', 'half': '૧/૨', '1': '૧', '2': '૨', '3': '૩', '4': '૪',
      '5': '૫', '6': '૬', '7': '૭', '8': '૮', '9': '૯',
      '10': '૧૦', '20': '૨૦', '50': '૫૦', '100': '૧૦૦',
      '200': '૨૦૦', '500': '૫૦૦', '1000': '૧૦૦૦', '2000': '૨૦૦૦',
    },
  ),
  _SistemaNumerico(
    nombre: 'Lao',
    nota: 'Laos. Similar al tailandés.',
    valores: {
      '0': '໐', '1': '໑', '2': '໒', '3': '໓', '4': '໔',
      '5': '໕', '6': '໖', '7': '໗', '8': '໘', '9': '໙',
      '10': '໑໐', '20': '໒໐', '50': '໕໐', '100': '໑໐໐',
      '200': '໒໐໐', '500': '໕໐໐', '1000': '໑໐໐໐', '2000': '໒໐໐໐',
    },
  ),
  _SistemaNumerico(
    nombre: 'Mongol',
    nota: 'Derivado del tibetano. Billetes de tögrög.',
    valores: {
      '0': '᠐', 'half': '᠑/᠒', '1': '᠑', '2': '᠒', '3': '᠓', '4': '᠔',
      '5': '᠕', '6': '᠖', '7': '᠗', '8': '᠘', '9': '᠙',
      '10': '᠑᠐', '20': '᠒᠐', '50': '᠕᠐', '100': '᠑᠐᠐',
      '200': '᠒᠐᠐', '500': '᠕᠐᠐', '1000': '᠑᠐᠐᠐', '2000': '᠒᠐᠐᠐',
    },
  ),
  _SistemaNumerico(
    nombre: 'Romano',
    nota: 'Fundamental en numismática occidental. Sin cero. ½ = S (semis).',
    valores: {
      'half': 'S', '1': 'I', '2': 'II', '3': 'III', '4': 'IV',
      '5': 'V', '6': 'VI', '7': 'VII', '8': 'VIII', '9': 'IX',
      '10': 'X', '20': 'XX', '50': 'L', '100': 'C',
      '200': 'CC', '500': 'D', '1000': 'M', '2000': 'MM',
    },
  ),
  _SistemaNumerico(
    nombre: 'Tamil',
    nota: 'Tamil Nadu, Sri Lanka. Monedas del sur de India.',
    valores: {
      '0': '௦', 'half': '௧/௨', '1': '௧', '2': '௨', '3': '௩', '4': '௪',
      '5': '௫', '6': '௬', '7': '௭', '8': '௮', '9': '௯',
      '10': '௧௦', '20': '௨௦', '50': '௫௦', '100': '௧௦௦',
      '200': '௨௦௦', '500': '௫௦௦', '1000': '௧௦௦௦', '2000': '௨௦௦௦',
    },
  ),
  _SistemaNumerico(
    nombre: 'Tibetano',
    nota: 'Tíbet, Mongolia. Base del mongol.',
    valores: {
      '0': '༠', 'half': '༡/༢', '1': '༡', '2': '༢', '3': '༣', '4': '༤',
      '5': '༥', '6': '༦', '7': '༧', '8': '༨', '9': '༩',
      '10': '༡༠', '20': '༢༠', '50': '༥༠', '100': '༡༠༠',
      '200': '༢༠༠', '500': '༥༠༠', '1000': '༡༠༠༠', '2000': '༢༠༠༠',
    },
  ),
  _SistemaNumerico(
    nombre: 'Tailandés',
    nota: 'Tailandia. Monedas modernas.',
    valores: {
      '0': '๐', 'half': '๑/๒', '1': '๑', '2': '๒', '3': '๓', '4': '๔',
      '5': '๕', '6': '๖', '7': '๗', '8': '๘', '9': '๙',
      '10': '๑๐', '20': '๒๐', '50': '๕๐', '100': '๑๐๐',
      '200': '๒๐๐', '500': '๕๐๐', '1000': '๑๐๐๐', '2000': '๒๐๐๐',
    },
  ),
];

const List<String> _notaInicial = [
  'Las celdas en gris indican que ese sistema no tiene glifo propio para ese valor.',
  'Los valores compuestos (IV en romano, ๕๐ en tailandés) se muestran completos.',
  'Algunos sistemas alfabéticos (romano, griego, hebreo) no tienen glifo para el 0.',
  'Pulsa una celda para ver el sistema, valor, glifo y nota.',
];

class _TablaNumeracion extends StatelessWidget {
  const _TablaNumeracion();

  static const double _anchoNombre = 200;
  static const double _anchoCelda = 56;
  static const double _altoFila = 48;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Construimos la tabla con flutter_expandable_table (sticky headers).
    final header = TableRow(
      children: [
        TableCell(
          child: Container(
            width: _anchoNombre,
            height: _altoFila,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            alignment: Alignment.centerLeft,
            color: theme.colorScheme.surfaceContainerHighest,
            child: Text(
              'Sistema',
              style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
        ),
        ..._columnas.map((c) => TableCell(
              child: Container(
                width: _anchoCelda,
                height: _altoFila,
                alignment: Alignment.center,
                color: theme.colorScheme.surfaceContainerHighest,
                child: Text(
                  c == 'half' ? '½' : c,
                  style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
            )),
      ],
    );

    final rows = _sistemas.map((s) {
      return TableRow(
        children: [
          TableCell(
            child: Container(
              width: _anchoNombre,
              height: _altoFila,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              alignment: Alignment.centerLeft,
              child: Tooltip(
                message: s.nota,
                child: Text(
                  s.nombre,
                  style: theme.textTheme.bodySmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
          ..._columnas.map((c) {
            final valor = s.valores[c];
            final vacia = valor == null || valor.isEmpty;
            return TableCell(
              child: Container(
                width: _anchoCelda,
                height: _altoFila,
                alignment: Alignment.center,
                color: vacia ? theme.colorScheme.surfaceContainerHighest : null,
                child: vacia
                    ? null
                    : InkWell(
                        onTap: () => _mostrarDialogo(context, s, c, valor),
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
          }),
        ],
      );
    }).toList();

    return Column(
      children: [
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
                style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              ..._notaInicial.map((linea) => Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('◇ ', style: theme.textTheme.bodySmall),
                        Expanded(
                          child: Text(linea, style: theme.textTheme.bodySmall),
                        ),
                      ],
                    ),
                  )),
            ],
          ),
        ),
                Expanded(
          child: ExpandableTable(
            firstHeaderCell: ExpandableTableCell(
              child: Container(
                width: _anchoNombre,
                height: _altoFila,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                alignment: Alignment.centerLeft,
                child: Text(
                  'Sistema',
                  style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
            ),
            headers: _columnas.map((c) {
              return ExpandableTableHeader(
                child: Container(
                  width: _anchoCelda,
                  height: _altoFila,
                  alignment: Alignment.center,
                  child: Text(
                    c == 'half' ? '½' : c,
                    style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
              );
            }).toList(),
            rows: _sistemas.map((s) {
              return ExpandableTableRow(
                firstCell: ExpandableTableCell(
                  child: Container(
                    width: _anchoNombre,
                    height: _altoFila,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    alignment: Alignment.centerLeft,
                    child: Tooltip(
                      message: s.nota,
                      child: Text(
                        s.nombre,
                        style: theme.textTheme.bodySmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),
                children: _columnas.map((c) {
                  final valor = s.valores[c];
                  final vacia = valor == null || valor.isEmpty;
                  return ExpandableTableCell(
                    child: Container(
                      width: _anchoCelda,
                      height: _altoFila,
                      alignment: Alignment.center,
                      color: vacia ? theme.colorScheme.surfaceContainerHighest : null,
                      child: vacia
                          ? null
                          : InkWell(
                              onTap: () => _mostrarDialogo(context, s, c, valor),
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
            }).toList(),
            firstColumnWidth: _anchoNombre,
            defaultsColumnWidth: _anchoCelda,
            defaultsRowHeight: _altoFila,
            headerHeight: _altoFila,
            scrollShadowColor: theme.colorScheme.primary.withOpacity(0.3),
            visibleScrollbar: true,
          ),
        ),
  }

  void _mostrarDialogo(
    BuildContext context,
    _SistemaNumerico sistema,
    String columna,
    String valor,
  ) {
    final etiqueta = columna == 'half' ? '½' : columna;
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(sistema.nombre),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Valor: $etiqueta'),
            const SizedBox(height: 6),
            Text('Glifo: $valor'),
            const SizedBox(height: 6),
            if (sistema.nota.isNotEmpty) Text('Nota: ${sistema.nota}'),
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

  static const int _ummMin = 1356;
  static const int _ummMax = 1500;

  @override
  void dispose() {
    _ctrlHejira.dispose();
    _ctrlGregoriano.dispose();
    super.dispose();
  }

  static bool _enRangoExacto(int h) => h >= _ummMin && h <= _ummMax;

    /// Hégira -> Gregoriano (fecha del 1 de Muharram).
  /// - Dentro de 1356–1500: hijri_plus (Umm al-Qura).
  /// - Fuera: fórmula tabular manual (aproximada).
  static (DateTime, bool) _hijriAGreg(int h) {
    if (_enRangoExacto(h)) {
      final calendar = hp.UmmAlQuraCalendar();
      final hijri = hp.HijriDate(h, 1, 1);
      final civil = calendar.toGregorian(hijri);
      final g = civil.date; // GregorianDate
      return (DateTime(g.year, g.month, g.day), true);
    }
    // Fórmula tabular aproximada.
    final g = (h + 622 - (h * 0.970224)).round();
    return (DateTime(g, 1, 1), false);
  }

  /// Gregoriano -> Hégira (año).
  static (int, bool) _gregAHijri(DateTime g) {
    if (g.year >= 1937 && g.year <= 2077) {
      final calendar = hp.UmmAlQuraCalendar();
      final civil = hp.GregorianDate(g.year, g.month, g.day);
      final hijri = calendar.toHijri(civil);
      return (hijri.date.year, true);
    }
    final h = ((g.year - 622) * 33 / 32).round();
    return (h, false);
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
    return n != null && n >= 1600 && n <= 9999;
  }

  void _convertirHejira() {
    final n = int.tryParse(_ctrlHejira.text.trim());
    if (n == null) {
      setState(() {
        _errorHejira = 'Año Hégira inválido';
        _resultadoHejira = null;
      });
      return;
    }
    final (fecha, exacto) = _hijriAGreg(n);
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

  void _convertirGreg() {
    final n = int.tryParse(_ctrlGregoriano.text.trim());
    if (n == null) {
      setState(() {
        _errorGreg = 'Año gregoriano inválido';
        _resultadoGreg = null;
      });
      return;
    }
    final (h, exacto) = _gregAHijri(DateTime(n, 1, 1));
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
          'Conversión entre el calendario islámico (Hégira) y el gregoriano.',
          style: theme.textTheme.bodySmall,
        ),
        const SizedBox(height: 12),
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
                  'Conversión exacta (Umm al-Qura) para 1356–1500 H '
                  '(1937–2077 G). Fuera de ese rango se usa el calendario '
                  'tabular (aproximado ±1-2 días).',
                  style: theme.textTheme.bodySmall,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _bloqueConversion(
          theme: theme,
          titulo: 'Hégira → Gregoriano',
          ctrl: _ctrlHejira,
          label: 'Año Hégira',
          hint: 'Ej. 1324',
          icono: Icons.mosque_outlined,
          error: _errorHejira,
          resultado: _resultadoHejira,
          valido: _validoHejira(),
          onConvertir: _convertirHejira,
          onLimpiar: _limpiarHejira,
        ),
        const SizedBox(height: 12),
        _bloqueConversion(
          theme: theme,
          titulo: 'Gregoriano → Hégira',
          ctrl: _ctrlGregoriano,
          label: 'Año gregoriano',
          hint: 'Ej. 1600',
          icono: Icons.calendar_month_outlined,
          error: _errorGreg,
          resultado: _resultadoGreg,
          valido: _validoGreg(),
          onConvertir: _convertirGreg,
          onLimpiar: _limpiarGreg,
        ),
      ],
    );
  }

  Widget _bloqueConversion({
    required ThemeData theme,
    required String titulo,
    required TextEditingController ctrl,
    required String label,
    required String hint,
    required IconData icono,
    required String? error,
    required String? resultado,
    required bool valido,
    required VoidCallback onConvertir,
    required VoidCallback onLimpiar,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(titulo, style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            TextField(
              controller: ctrl,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.done,
              onChanged: (_) => setState(() {}),
              onSubmitted: (_) {
                if (valido) onConvertir();
              },
              decoration: InputDecoration(
                labelText: label,
                hintText: hint,
                errorText: error,
                prefixIcon: Icon(icono),
                suffixIcon: resultado != null
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        tooltip: 'Limpiar',
                        onPressed: onLimpiar,
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: valido ? onConvertir : null,
                icon: const Icon(Icons.sync_alt),
                label: const Text('Convertir'),
              ),
            ),
            if (resultado != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(resultado, style: theme.textTheme.bodyLarge),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
