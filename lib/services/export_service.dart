import 'dart:io';
import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as xlsio;

import '../models/moneda.dart';

class ExportService {
  ExportService._();

  static final _fmtFecha = DateFormat('dd/MM/yyyy', 'es');
  static final _fmtNombre = DateFormat('yyyy-MM-dd_HHmm');

  static Future<File> _prepararDestino(
    String extension, {
    String? rutaDestino,
  }) async {
    if (rutaDestino != null) {
      final f = File(rutaDestino);
      await f.parent.create(recursive: true);
      return f;
    }
    final dirDocs = await getApplicationDocumentsDirectory();
    final dirExport = Directory(p.join(dirDocs.path, 'export'));
    if (!await dirExport.exists()) {
      await dirExport.create(recursive: true);
    }
    final nombre = 'cubanum_${_fmtNombre.format(DateTime.now())}.$extension';
    return File(p.join(dirExport.path, nombre));
  }

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

  // ---------------- PDF ----------------

  static Future<File> generarPdf(
    List<Moneda> monedas, {
    String? rutaDestino,
  }) async {
    if (monedas.isEmpty) {
      throw Exception('No hay monedas para exportar');
    }

    final doc = pw.Document();
    final fechaGeneracion = _fmtFecha.format(DateTime.now());

    final fotosAnverso = <int, Uint8List?>{};
    final fotosReverso = <int, Uint8List?>{};
    for (final m in monedas) {
      fotosAnverso[m.id ?? 0] = await _leerImagen(m.fotoAnverso);
      fotosReverso[m.id ?? 0] = await _leerImagen(m.fotoReverso);
    }

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.fromLTRB(36, 48, 36, 48),
        header: (ctx) => pw.Container(
          alignment: pw.Alignment.centerRight,
          margin: const pw.EdgeInsets.only(bottom: 12),
          child: pw.Text(
            'CUBANUM',
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.grey700,
              letterSpacing: 1.5,
            ),
          ),
        ),
        footer: (ctx) => pw.Container(
          alignment: pw.Alignment.centerRight,
          margin: const pw.EdgeInsets.only(top: 12),
          child: pw.Text(
            'Página ${ctx.pageNumber} de ${ctx.pagesCount}',
            style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
          ),
        ),
        build: (ctx) {
          final widgets = <pw.Widget>[];

          // Portada
          widgets.add(pw.SizedBox(height: 60));
          widgets.add(
            pw.Center(
              child: pw.Column(
                children: [
                  pw.Text(
                    'CUBANUM',
                    style: pw.TextStyle(
                      fontSize: 42,
                      fontWeight: pw.FontWeight.bold,
                      letterSpacing: 3,
                      color: PdfColors.brown800,
                    ),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Text(
                    'Catálogo numismático',
                    style: pw.TextStyle(
                      fontSize: 18,
                      color: PdfColors.brown600,
                      fontStyle: pw.FontStyle.italic,
                    ),
                  ),
                  pw.SizedBox(height: 24),
                  pw.Text(
                    'Generado el $fechaGeneracion',
                    style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
                  ),
                  pw.SizedBox(height: 6),
                  pw.Text(
                    '${monedas.length} ${monedas.length == 1 ? 'moneda' : 'monedas'} en la colección',
                    style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
                  ),
                ],
              ),
            ),
          );
          widgets.add(pw.SizedBox(height: 40));
          widgets.add(pw.Divider(color: PdfColors.brown300, thickness: 0.8));
          widgets.add(pw.NewPage());

          for (var i = 0; i < monedas.length; i++) {
            final m = monedas[i];
            widgets.add(_bloqueMoneda(m, fotosAnverso, fotosReverso));
            if (i < monedas.length - 1) {
              widgets.add(pw.SizedBox(height: 12));
              widgets.add(pw.Divider(color: PdfColors.grey400, thickness: 0.6));
              widgets.add(pw.SizedBox(height: 12));
            }
          }
          return widgets;
        },
      ),
    );

    final bytes = await doc.save();
    final archivo = await _prepararDestino('pdf', rutaDestino: rutaDestino);
    await archivo.writeAsBytes(bytes, flush: true);
    return archivo;
  }

  static pw.Widget _bloqueMoneda(
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
    ].join(' · ');

    final subtitulo = [
      if (m.anio.trim().isNotEmpty) m.anio.trim(),
      if (m.gradoSheldon.trim().isNotEmpty) m.gradoSheldon.trim(),
    ].join(' · ');

    final filas = <pw.Widget>[];
    void addFila(String etiqueta, String? valor) {
      final v = valor?.trim() ?? '';
      if (v.isEmpty) return;
      filas.add(
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(vertical: 1.5),
          child: pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.SizedBox(
                width: 110,
                child: pw.Text(
                  etiqueta,
                  style: pw.TextStyle(
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.grey800,
                  ),
                ),
              ),
              pw.Expanded(
                child: pw.Text(
                  v,
                  style: const pw.TextStyle(fontSize: 10, color: PdfColors.black),
                ),
              ),
            ],
          ),
        ),
      );
    }

    addFila('País', m.pais);
    addFila('Denominación', m.denominacion);
    addFila('Período', m.periodoAcunacion);
    addFila('Año', m.anio);
    addFila('Ceca', m.ceca);
    addFila('KM#', m.kmCatalogo);
    addFila('Metal', m.metal);
    addFila('ONU', m.perteneceOnu ? 'Sí' : 'No');
    if (m.pesoG != null) addFila('Peso', '${_numATexto(m.pesoG!)} g');
    if (m.diametroMm != null) addFila('Diámetro', '${_numATexto(m.diametroMm!)} mm');
    if (m.grosorMm != null) addFila('Grosor', '${_numATexto(m.grosorMm!)} mm');
    addFila('Forma', m.forma);
    addFila('Canto', m.canto);
    addFila('Grado Sheldon', m.gradoSheldon);
    addFila('Autenticidad', m.autenticidad);
    addFila('Detalles visibles', m.detallesVisibles);

    if (m.precioCompra != null) {
      addFila('Precio compra', '${_numATexto(m.precioCompra!)} ${m.monedaPrecio}');
    }
    if (m.fechaCompra != null) {
      addFila('Fecha compra', _fmtFecha.format(m.fechaCompra!));
    }
    addFila('Proveedor', m.proveedor);
    addFila('Lugar compra', m.lugarCompra);
    if (m.valorEstimado != null) {
      addFila('Valor estimado', '${_numATexto(m.valorEstimado!)} ${m.monedaPrecio}');
    }
    if (m.precioVenta != null) {
      addFila('Precio venta', '${_numATexto(m.precioVenta!)} ${m.monedaPrecio}');
    }
    if (m.fechaVenta != null) {
      addFila('Fecha venta', _fmtFecha.format(m.fechaVenta!));
    }
    addFila('Ubicación', m.ubicacion);
    addFila('Etiquetas', m.etiquetas);
    addFila('Notas', m.notas);

    final columnaFotos = pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        if (anverso != null)
          pw.Container(
            margin: const pw.EdgeInsets.only(bottom: 6),
            child: pw.Image(
              pw.MemoryImage(anverso),
              width: 130,
              height: 130,
              fit: pw.BoxFit.cover,
            ),
          ),
        if (reverso != null)
          pw.Container(
            child: pw.Image(
              pw.MemoryImage(reverso),
              width: 130,
              height: 130,
              fit: pw.BoxFit.cover,
            ),
          ),
        if (anverso == null && reverso == null)
          pw.Container(
            width: 130,
            height: 130,
            decoration: pw.BoxDecoration(
              color: PdfColors.grey300,
              border: pw.Border.all(color: PdfColors.grey500, width: 0.5),
            ),
            child: pw.Center(
              child: pw.Text(
                'Sin foto',
                style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
              ),
            ),
          ),
      ],
    );

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          titulo.isEmpty ? 'Sin identificar' : titulo,
          style: pw.TextStyle(
            fontSize: 15,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.brown800,
          ),
        ),
        if (subtitulo.isNotEmpty) ...[
          pw.SizedBox(height: 2),
          pw.Text(
            subtitulo,
            style: pw.TextStyle(
              fontSize: 10,
              color: PdfColors.grey700,
              fontStyle: pw.FontStyle.italic,
            ),
          ),
        ],
        pw.SizedBox(height: 8),
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            columnaFotos,
            pw.SizedBox(width: 14),
            pw.Expanded(child: pw.Column(children: filas)),
          ],
        ),
      ],
    );
  }

  // ---------------- Excel ----------------

  static Future<File> generarExcel(
    List<Moneda> monedas, {
    String? rutaDestino,
  }) async {
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
      ('Período', (m) => m.periodoAcunacion, 'text'),
      ('Denominación', (m) => m.denominacion, 'text'),
      ('Año', (m) => m.anio, 'text'),
      ('Ceca', (m) => m.ceca, 'text'),
      ('KM#', (m) => m.kmCatalogo, 'text'),
      ('Metal', (m) => m.metal, 'text'),
      ('Peso (g)', (m) => m.pesoG?.toString() ?? '', 'num'),
      ('Diámetro (mm)', (m) => m.diametroMm?.toString() ?? '', 'num'),
      ('Grosor (mm)', (m) => m.grosorMm?.toString() ?? '', 'num'),
      ('Forma', (m) => m.forma, 'text'),
      ('Canto', (m) => m.canto, 'text'),
      ('Grado Sheldon', (m) => m.gradoSheldon, 'text'),
      ('Detalles visibles', (m) => m.detallesVisibles, 'text'),
      ('Autenticidad', (m) => m.autenticidad, 'text'),
      ('Precio compra', (m) => m.precioCompra?.toString() ?? '', 'num'),
      ('Moneda precio', (m) => m.monedaPrecio, 'text'),
      ('Proveedor', (m) => m.proveedor, 'text'),
      ('Lugar compra', (m) => m.lugarCompra, 'text'),
      ('Fecha compra', (m) => m.fechaCompra?.toIso8601String() ?? '', 'date'),
      ('Valor estimado', (m) => m.valorEstimado?.toString() ?? '', 'num'),
      ('Precio venta', (m) => m.precioVenta?.toString() ?? '', 'num'),
      ('Fecha venta', (m) => m.fechaVenta?.toIso8601String() ?? '', 'date'),
      ('Ubicación', (m) => m.ubicacion, 'text'),
      ('Etiquetas', (m) => m.etiquetas, 'text'),
      ('Notas', (m) => m.notas, 'text'),
    ];

    // Encabezados
    for (var c = 0; c < columnas.length; c++) {
      final rango = sheet.getRangeByIndex(1, c + 1);
      rango.setText(columnas[c].$1);
      rango.cellStyle.bold = true;
      rango.cellStyle.backColor = '#EADFCB';
      rango.cellStyle.fontColor = '#3B2F2F';
    }

    // Datos
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

    final bytes = workbook.save();
    workbook.dispose();

    final archivo = await _prepararDestino('xlsx', rutaDestino: rutaDestino);
    await archivo.writeAsBytes(bytes, flush: true);
    return archivo;
  }
}
