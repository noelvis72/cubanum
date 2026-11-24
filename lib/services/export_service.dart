import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';

import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as xlsio;

import '../models/moneda.dart';

class ExportService {
  ExportService._();

  static final _fmtFecha = DateFormat('dd/MM/yyyy', 'es');

  static String _numATexto(double v) {
    if (v == v.roundToDouble()) return v.toStringAsFixed(0);
    return v.toString();
  }

  static Future<Uint8List?> _leerImagen(String? ruta) async {
    if (ruta == null || ruta.isEmpty) return null;
    final f = File(ruta);
    if (!await f.exists()) return null;
    try {
      return await f.readAsBytes();
    } catch (_) {
      return null;
    }
  }
  static Future<Uint8List?> _leerIconoAsset() async {
    try {
      final data = await rootBundle.load('assets/icon/icon.png');
      return data.buffer.asUint8List();
    } catch (_) {
      return null;
    }
  }
  // =====================================================================
  // PDF
  // =====================================================================

  /// Genera el PDF y abre el diálogo "Guardar como" de Android.
  /// Devuelve true si el usuario guardó el archivo, false si canceló o falló.
  static Future<bool> generarPdf(
    List<Moneda> monedas, {
    String nombreColeccionista = 'Coleccionista',
    String fecha = '',
    bool conFotos = true,
  }) async {
    if (monedas.isEmpty) {
      throw Exception('No hay monedas para exportar');
    }

    final doc = pw.Document();
    final fechaTexto = fecha.isEmpty ? _fmtFecha.format(DateTime.now()) : fecha;
    final iconoBytes = await _leerIconoAsset();
    
    final fotosAnverso = <int, Uint8List?>{};
    final fotosReverso = <int, Uint8List?>{};
    if (conFotos) {
      for (final m in monedas) {
        fotosAnverso[m.id ?? 0] = await _leerImagen(m.fotoAnverso);
        fotosReverso[m.id ?? 0] = await _leerImagen(m.fotoReverso);
      }
    }

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.fromLTRB(36, 48, 36, 48),

        header: (ctx) => pw.Container(
          alignment: pw.Alignment.centerRight,
          margin: const pw.EdgeInsets.only(bottom: 8),
          child: pw.Text(
            'CUBANUM',
            style: pw.TextStyle(
              fontSize: 10,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.grey600,
              letterSpacing: 1.5,
            ),
          ),
        ),

        footer: (ctx) => pw.Container(
          alignment: pw.Alignment.centerRight,
          margin: const pw.EdgeInsets.only(top: 10),
          child: pw.Text(
            '$nombreColeccionista · $fechaTexto · Página ${ctx.pageNumber} de ${ctx.pagesCount}',
            style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
          ),
        ),

        build: (ctx) {
          final widgets = <pw.Widget>[];

          // ---------- PORTADA ----------
          widgets.add(pw.SizedBox(height: 60));
          widgets.add(
            pw.Center(
              child: pw.Container(
                width: 420,
                height: 520,
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.brown800, width: 3),
                ),
                child: pw.Container(
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.brown400, width: 1),
                  ),
                  child: pw.Column(
                    mainAxisAlignment: pw.MainAxisAlignment.center,
                    children: [
                      pw.SizedBox(height: 20),
                      pw.Text(
                        'CUBANUM',
                        style: pw.TextStyle(
                          fontSize: 36,
                          fontWeight: pw.FontWeight.bold,
                          letterSpacing: 4,
                          color: PdfColors.brown900,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        'Catálogo numismático',
                        style: pw.TextStyle(
                          fontSize: 14,
                          color: PdfColors.brown600,
                          fontStyle: pw.FontStyle.italic,
                        ),
                      ),
                      pw.SizedBox(height: 40),
                      if (iconoBytes != null)
                        pw.Container(
                          width: 200,
                          height: 200,
                          child: pw.Image(
                            pw.MemoryImage(iconoBytes),
                            fit: pw.BoxFit.contain,
                          ),
                        )
                      else
                        pw.Container(
                          width: 200,
                          height: 200,
                          decoration: pw.BoxDecoration(
                            color: PdfColors.amber200,
                            shape: pw.BoxShape.circle,
                            border: pw.Border.all(color: PdfColors.amber800, width: 5),
                          ),
                          child: pw.Center(
                            child: pw.Text(
                              'CUBANUM',
                              style: pw.TextStyle(
                                fontSize: 22,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColors.brown900,
                                letterSpacing: 2,
                              ),
                            ),
                          ),
                        ),
                      pw.SizedBox(height: 40),
                      pw.Text(
                        nombreColeccionista,
                        style: pw.TextStyle(
                          fontSize: 16,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.brown900,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        fechaTexto,
                        style: const pw.TextStyle(
                          fontSize: 12,
                          color: PdfColors.grey700,
                        ),
                      ),
                      pw.SizedBox(height: 20),
                      pw.Text(
                        '${monedas.length} ${monedas.length == 1 ? "moneda" : "monedas"} en la colección',
                        style: const pw.TextStyle(
                          fontSize: 11,
                          color: PdfColors.grey700,
                        ),
                      ),
                      pw.SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          );

          widgets.add(pw.NewPage());

          // ---------- MONEDAS O LISTADO ----------
          if (conFotos) {
            for (var i = 0; i < monedas.length; i++) {
              widgets.add(
                _bloqueMonedaConFotos(
                  monedas[i],
                  fotosAnverso,
                  fotosReverso,
                ),
              );
              if (i < monedas.length - 1) {
                widgets.add(pw.Wrap(
                  children: [
                    pw.Divider(color: PdfColors.grey400, thickness: 0.5),
                  ],
                ));
                widgets.add(pw.SizedBox(height: 6));
              }
            }
          } else {
            for (var i = 0; i < monedas.length; i++) {
              widgets.add(_filaCompacta(monedas[i]));
            }
          }

          // ---------- RESUMEN FINAL ----------
          widgets.add(pw.NewPage());
          widgets.add(_resumenFinal(monedas, nombreColeccionista, fechaTexto));

          return widgets;
        },
      ),
    );

    final bytes = await doc.save();

    final ahora = DateTime.now();
    final nombreArchivo =
        'Cubanum_Catalogo_${ahora.year}${ahora.month.toString().padLeft(2, '0')}${ahora.day.toString().padLeft(2, '0')}_${ahora.hour.toString().padLeft(2, '0')}${ahora.minute.toString().padLeft(2, '0')}.pdf';

    final uri = await FilePicker.platform.saveFile(
      dialogTitle: 'Guardar catálogo PDF',
      fileName: nombreArchivo,
      bytes: Uint8List.fromList(bytes),
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    return uri != null;
  }

  // ---------- Bloque de moneda con fotos ----------

  static pw.Widget _bloqueMonedaConFotos(
    Moneda m,
    Map<int, Uint8List?> fotosAnverso,
    Map<int, Uint8List?> fotosReverso,
  ) {
    final id = m.id ?? 0;
    final anverso = fotosAnverso[id];
    final reverso = fotosReverso[id];

    final titulo = [
      if (m.pais.trim().isNotEmpty) m.pais.trim(),
      if (m.denominacion.trim().isNotEmpty) m.denominacion.trim(),
      if (m.anio.trim().isNotEmpty)
        (m.esHejira ? '${m.anio} AH' : m.anio),
      if (m.gradoSheldon.trim().isNotEmpty) m.gradoSheldon.trim(),
    ].join(' · ');

    final filas = <(String, String)>[];
    void add(String etiqueta, String? valor) {
      final v = valor?.trim() ?? '';
      if (v.isEmpty) return;
      filas.add((etiqueta, v));
    }

    add('País', m.pais);
    add('Período', m.periodoAcunacion);
    add('Año', m.anio.isEmpty ? '' : (m.esHejira ? '${m.anio} AH' : m.anio));
    add('Ceca', m.ceca);
    add('KM#', m.kmCatalogo);
    add('Metal', m.metal);
    add('Ley', m.ley);
    if (m.pesoG != null) add('Peso', '${_numATexto(m.pesoG!)} g');
    if (m.diametroMm != null) add('Diámetro', '${_numATexto(m.diametroMm!)} mm');
    if (m.grosorMm != null) add('Grosor', '${_numATexto(m.grosorMm!)} mm');
    add('Forma', m.forma);
    add('Canto', m.canto);
add('Acabado', m.acabado);
add('Alineación', m.alineacion);
add('Resello', m.resellada ? 'Sí' : 'No');
add('Contramarcada', m.contramarcada ? 'Sí' : 'No');
add('Notas resello/contramarca', m.notasReselloContramarca);
add('Variante', m.variante ? 'Sí' : 'No');
add('Notas variante', m.notasVariante);
add('Grado', m.gradoSheldon);
    add('Autenticidad', m.autenticidad);
    if (m.precioCompra != null) {
      add('Precio compra', '${_numATexto(m.precioCompra!)} ${m.monedaPrecio}');
    }
    if (m.precioVenta != null) {
      add('Precio venta', '${_numATexto(m.precioVenta!)} ${m.monedaVenta}');
    }
    add('Ubicación', m.ubicacion);

    final mitad = (filas.length / 2).ceil();
    final col1 = filas.take(mitad).toList();
    final col2 = filas.skip(mitad).toList();

    pw.Widget construirColumna(List<(String, String)> items) {
      return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: items.map((fila) {
          return pw.Padding(
            padding: const pw.EdgeInsets.symmetric(vertical: 1),
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.SizedBox(
                  width: 70,
                  child: pw.Text(
                    fila.$1,
                    style: pw.TextStyle(
                      fontSize: 8,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.grey800,
                    ),
                  ),
                ),
                pw.Expanded(
                  child: pw.Text(
                    fila.$2,
                    style: const pw.TextStyle(fontSize: 8, color: PdfColors.black),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      );
    }

    pw.Widget fotoWidget(Uint8List? bytes) {
      if (bytes == null) {
        return pw.Container(
          width: 85,
          height: 85,
          decoration: pw.BoxDecoration(
            color: PdfColors.grey300,
            border: pw.Border.all(color: PdfColors.grey500, width: 0.5),
          ),
          child: pw.Center(
            child: pw.Text(
              'Sin foto',
              style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
            ),
          ),
        );
      }
      return pw.Container(
        width: 85,
        height: 85,
        child: pw.Image(
          pw.MemoryImage(bytes),
          fit: pw.BoxFit.cover,
        ),
      );
    }

    return pw.Wrap(
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              titulo.isEmpty ? 'Sin identificar' : titulo,
              style: pw.TextStyle(
                fontSize: 12,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.brown800,
              ),
            ),
            pw.SizedBox(height: 4),
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Column(
                  children: [
                    fotoWidget(anverso),
                    pw.SizedBox(height: 2),
                    fotoWidget(reverso),
                  ],
                ),
                pw.SizedBox(width: 10),
                pw.Expanded(
                  child: pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Expanded(child: construirColumna(col1)),
                      pw.SizedBox(width: 8),
                      pw.Expanded(child: construirColumna(col2)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  // ---------- Fila compacta (sin fotos) ----------

  static pw.Widget _filaCompacta(Moneda m) {
    final linea1 = [
      if (m.pais.trim().isNotEmpty) m.pais.trim(),
      if (m.denominacion.trim().isNotEmpty) m.denominacion.trim(),
      if (m.anio.trim().isNotEmpty)
        (m.esHejira ? '${m.anio} AH' : m.anio),
    ].join(' · ');

    final partes2 = <String>[];
    if (m.metal.isNotEmpty) partes2.add(m.metal);
    if (m.kmCatalogo.isNotEmpty) partes2.add('KM ${m.kmCatalogo}');
    if (m.ceca.isNotEmpty) partes2.add(m.ceca);
    if (m.precioCompra != null) {
      partes2.add('${_numATexto(m.precioCompra!)} ${m.monedaPrecio}');
    }
    if (m.ubicacion.isNotEmpty) partes2.add(m.ubicacion);
    final linea2 = partes2.join(' · ');

    return pw.Wrap(
      children: [
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 4),
          decoration: const pw.BoxDecoration(
            border: pw.Border(
              bottom: pw.BorderSide(color: PdfColors.grey400, width: 0.5),
            ),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                children: [
                  pw.Expanded(
                    child: pw.Text(
                      linea1.isEmpty ? 'Sin identificar' : linea1,
                      style: pw.TextStyle(
                        fontSize: 10,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.brown800,
                      ),
                    ),
                  ),
                  if (m.gradoSheldon.isNotEmpty)
                    pw.Text(
                      m.gradoSheldon,
                      style: pw.TextStyle(
                        fontSize: 9,
                        fontStyle: pw.FontStyle.italic,
                        color: PdfColors.grey800,
                      ),
                    ),
                ],
              ),
              if (linea2.isNotEmpty)
                pw.Padding(
                  padding: const pw.EdgeInsets.only(top: 1),
                  child: pw.Text(
                    linea2,
                    style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  // ---------- Resumen final ----------

  static pw.Widget _resumenFinal(
    List<Moneda> monedas,
    String nombreColeccionista,
    String fechaTexto,
  ) {
    final porMetal = <String, int>{};
    final porPais = <String, int>{};
    int reselladas = 0;
    int contramarcadas = 0;
    int variantes = 0;
    int conmemorativas = 0;
    int fao = 0;
    int ah = 0;
    int replicas = 0;
    int falsificaciones = 0;

    final invertido = <String, double>{'CUP': 0, 'USD': 0, 'EUR': 0};
    final recuperado = <String, double>{'CUP': 0, 'USD': 0, 'EUR': 0};

    for (final m in monedas) {
      if (m.metal.isNotEmpty) {
        porMetal[m.metal] = (porMetal[m.metal] ?? 0) + 1;
      }
      if (m.pais.isNotEmpty) {
        porPais[m.pais] = (porPais[m.pais] ?? 0) + 1;
      }
      if (m.resellada) reselladas++;
      if (m.contramarcada) contramarcadas++;
      if (m.variante) variantes++;
      if (m.conmemorativa) conmemorativas++;
      if (m.fao) fao++;
      if (m.esHejira) ah++;
      if (m.autenticidad == 'Réplica moderna') replicas++;
      if (m.autenticidad == 'Falsificación de época') falsificaciones++;

      if (m.precioCompra != null && m.precioCompra! > 0) {
        final k = _normalizarMoneda(m.monedaPrecio);
        invertido[k] = (invertido[k] ?? 0) + m.precioCompra!;
      }
      if (m.precioVenta != null && m.precioVenta! > 0) {
        final k = _normalizarMoneda(m.monedaVenta);
        recuperado[k] = (recuperado[k] ?? 0) + m.precioVenta!;
      }
    }

    final metalesOrdenados = porMetal.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final paisesOrdenados = porPais.entries.toList()
      ..sort((a, b) => a.key.toLowerCase().compareTo(b.key.toLowerCase()));

    pw.Widget seccion(String titulo, List<(String, String)> items) {
      return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(height: 10),
          pw.Text(
            titulo,
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.brown800,
            ),
          ),
          pw.SizedBox(height: 4),
          ...items.map((fila) {
            return pw.Padding(
              padding: const pw.EdgeInsets.symmetric(vertical: 1.5),
              child: pw.Row(
                children: [
                  pw.Expanded(
                    child: pw.Text(
                      fila.$1,
                      style: const pw.TextStyle(fontSize: 10),
                    ),
                  ),
                  pw.Text(
                    fila.$2,
                    style: pw.TextStyle(
                      fontSize: 10,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      );
    }

    String fmt(double v) {
      if (v == 0) return '0';
      if (v == v.roundToDouble()) return v.toStringAsFixed(0);
      return v.toStringAsFixed(2);
    }

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'RESUMEN DE LA COLECCIÓN',
          style: pw.TextStyle(
            fontSize: 22,
            fontWeight: pw.FontWeight.bold,
            letterSpacing: 2,
            color: PdfColors.brown900,
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          '$nombreColeccionista · $fechaTexto',
          style: const pw.TextStyle(fontSize: 11, color: PdfColors.grey700),
        ),
        pw.Divider(color: PdfColors.brown400, thickness: 1),
        pw.SizedBox(height: 8),
        pw.Row(
          children: [
            pw.Text(
              'Total de monedas: ',
              style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
            ),
            pw.Text(
              '${monedas.length}',
              style: pw.TextStyle(
                fontSize: 14,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.brown800,
              ),
            ),
          ],
        ),
        if (metalesOrdenados.isNotEmpty)
          seccion(
            'Por metal',
            metalesOrdenados.map((e) => (e.key, '${e.value}')).toList(),
          ),
        if (paisesOrdenados.isNotEmpty)
          seccion(
            'Por país',
            paisesOrdenados.map((e) => (e.key, '${e.value}')).toList(),
          ),
        seccion('Características especiales', [
          ('Reselladas', '$reselladas'),
          ('Contramarcadas', '$contramarcadas'),
          ('Variantes', '$variantes'),
          ('Conmemorativas', '$conmemorativas'),
          ('FAO', '$fao'),
          ('Hégira (AH)', '$ah'),
          ('Réplicas modernas', '$replicas'),
          ('Falsificaciones de época', '$falsificaciones'),
        ]),
        seccion('Dinero invertido (compras)', [
          ('CUP', fmt(invertido['CUP'] ?? 0)),
          ('USD', fmt(invertido['USD'] ?? 0)),
          ('EUR', fmt(invertido['EUR'] ?? 0)),
        ]),
        seccion('Dinero recuperado (ventas)', [
          ('CUP', fmt(recuperado['CUP'] ?? 0)),
          ('USD', fmt(recuperado['USD'] ?? 0)),
          ('EUR', fmt(recuperado['EUR'] ?? 0)),
        ]),
      ],
    );
  }

  static String _normalizarMoneda(String m) {
    final u = m.trim().toUpperCase();
    if (u == 'EUR' || u == 'USD' || u == 'CUP') return u;
    return 'CUP';
  }

  // =====================================================================
  // Excel
  // =====================================================================

  /// Genera el Excel y abre el diálogo "Guardar como" de Android.
  /// Devuelve true si el usuario guardó el archivo, false si canceló o falló.
  static Future<bool> generarExcel(List<Moneda> monedas) async {
    if (monedas.isEmpty) {
      throw Exception('No hay monedas para exportar');
    }

    final workbook = xlsio.Workbook();
    final sheet = workbook.worksheets[0];
    sheet.name = 'Monedas';

    final columnas = <(String, String Function(Moneda), String)>[
      ('ID', (m) => '${m.id ?? ''}', 'text'),
      ('País', (m) => m.pais, 'text'),
      ('Pertenece ONU', (m) => m.perteneceOnu ? 'Sí' : 'No', 'text'),
      ('Conmemorativa', (m) => m.conmemorativa ? 'Sí' : 'No', 'text'),
      ('FAO', (m) => m.fao ? 'Sí' : 'No', 'text'),
      ('Período', (m) => m.periodoAcunacion, 'text'),
      ('Denominación', (m) => m.denominacion, 'text'),
      ('Año', (m) => m.anio.isEmpty ? '' : (m.esHejira ? '${m.anio} AH' : m.anio), 'text'),
      ('Hégira', (m) => m.esHejira ? 'Sí' : 'No', 'text'),
      ('Ceca', (m) => m.ceca, 'text'),
      ('KM#', (m) => m.kmCatalogo, 'text'),
      ('Acuñadas', (m) => m.acunadas?.toString() ?? '', 'num'),
      ('Peso (g)', (m) => m.pesoG?.toString() ?? '', 'num'),
      ('Diámetro (mm)', (m) => m.diametroMm?.toString() ?? '', 'num'),
      ('Grosor (mm)', (m) => m.grosorMm?.toString() ?? '', 'num'),
      ('Forma', (m) => m.forma, 'text'),
      ('Metal', (m) => m.metal, 'text'),
      ('Ley', (m) => m.ley, 'text'),
      ('Canto', (m) => m.canto, 'text'),
      ('Acabado', (m) => m.acabado, 'text'),
      ('Alineación', (m) => m.alineacion, 'text'),
      ('Resello', (m) => m.resellada ? 'Sí' : 'No', 'text'),
      ('Contramarcada', (m) => m.contramarcada ? 'Sí' : 'No', 'text'),
      ('Notas resello/contramarca', (m) => m.notasReselloContramarca, 'text'),
      ('Variante', (m) => m.variante ? 'Sí' : 'No', 'text'),
      ('Notas variante', (m) => m.notasVariante, 'text'),
      ('Grado Sheldon', (m) => m.gradoSheldon, 'text'),
      ('Detalles visibles', (m) => m.detallesVisibles, 'text'),
      ('Autenticidad', (m) => m.autenticidad, 'text'),
      ('Precio compra', (m) => m.precioCompra?.toString() ?? '', 'num'),
      ('Moneda precio', (m) => m.monedaPrecio, 'text'),
      ('Lugar compra', (m) => m.lugarCompra, 'text'),
      ('Fecha compra', (m) => m.fechaCompra?.toIso8601String() ?? '', 'date'),
      ('Valor estimado', (m) => m.valorEstimado?.toString() ?? '', 'num'),
      ('Moneda estimado', (m) => m.valorEstimadoMoneda, 'text'),
      ('Precio venta', (m) => m.precioVenta?.toString() ?? '', 'num'),
      ('Moneda venta', (m) => m.monedaVenta, 'text'),
      ('Fecha venta', (m) => m.fechaVenta?.toIso8601String() ?? '', 'date'),
      ('Ubicación', (m) => m.ubicacion, 'text'),
      ('Notas', (m) => m.notas, 'text'),
    ];

    for (var c = 0; c < columnas.length; c++) {
      final rango = sheet.getRangeByIndex(1, c + 1);
      rango.setText(columnas[c].$1);
      rango.cellStyle.bold = true;
      rango.cellStyle.backColor = '#EADFCB';
      rango.cellStyle.fontColor = '#3B2F2F';
    }

    for (var i = 0; i < monedas.length; i++) {
      final m = monedas[i];
      final fila = i + 2;
      for (var c = 0; c < columnas.length; c++) {
        final (_, selector, tipo) = columnas[c];
        final rango = sheet.getRangeByIndex(fila, c + 1);
        final valorTexto = selector(m);
        if (valorTexto.isEmpty) continue;

        switch (tipo) {
          case 'num':
            final v = double.tryParse(valorTexto);
            if (v != null) {
              rango.setNumber(v);
            } else {
              rango.setText(valorTexto);
            }
            break;
          case 'date':
            final f = DateTime.tryParse(valorTexto);
            if (f != null) {
              rango.setDateTime(f);
              rango.numberFormat = 'dd/MM/yyyy';
            } else {
              rango.setText(valorTexto);
            }
            break;
          default:
            rango.setText(valorTexto);
        }
      }
    }

    for (var c = 0; c < columnas.length; c++) {
      sheet.autoFitColumn(c + 1);
    }

    final bytes = await workbook.save();
    workbook.dispose();

    final ahora = DateTime.now();
    final nombreArchivo =
        'Cubanum_Catalogo_${ahora.year}${ahora.month.toString().padLeft(2, '0')}${ahora.day.toString().padLeft(2, '0')}_${ahora.hour.toString().padLeft(2, '0')}${ahora.minute.toString().padLeft(2, '0')}.xlsx';

    final uri = await FilePicker.platform.saveFile(
      dialogTitle: 'Guardar catálogo Excel',
      fileName: nombreArchivo,
      bytes: Uint8List.fromList(bytes),
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
    );

    return uri != null;
  }
}
