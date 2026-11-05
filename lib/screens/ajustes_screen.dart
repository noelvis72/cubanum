import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../db/database_helper.dart';
import '../services/export_service.dart';
import '../theme/app_theme.dart';
import '../theme/theme_provider.dart';

class AjustesScreen extends StatefulWidget {
  const AjustesScreen({super.key});

  @override
  State<AjustesScreen> createState() => _AjustesScreenState();
}

class _AjustesScreenState extends State<AjustesScreen> {
  final DatabaseHelper _db = DatabaseHelper.instance;

  int? _totalMonedas;
  bool _cargandoTotal = true;
  bool _exportando = false;
  List<String> _paisesPersonalizados = [];
  List<String> _metalesPersonalizados = [];
  bool _cargandoListas = true;

  @override
  void initState() {
    super.initState();
    _cargarTotal();
    _cargarListasPersonalizadas();
  }

  Future<void> _cargarTotal() async {
    final total = await _db.contar();
    if (!mounted) return;
    setState(() {
      _totalMonedas = total;
      _cargandoTotal = false;
    });
  }

  Future<void> _cargarListasPersonalizadas() async {
    final paises = await _db.obtenerPaisesPersonalizados();
    final metales = await _db.obtenerMetalesPersonalizados();
    if (!mounted) return;
    setState(() {
      _paisesPersonalizados = paises;
      _metalesPersonalizados = metales;
      _cargandoListas = false;
    });
  }

  Future<void> _exportarPdf() async {
    if (_exportando) return;
    setState(() => _exportando = true);
    try {
      final monedas = await _db.obtenerTodas();
      if (monedas.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No hay monedas que exportar')),
        );
        return;
      }
      final archivo = await ExportService.generarPdf(monedas);
      if (!mounted) return;
      final bytes = await archivo.readAsBytes();
      await Printing.sharePdf(
        bytes: bytes,
        filename: p.basename(archivo.path),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('PDF generado: ${p.basename(archivo.path)}')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al exportar PDF: $e')),
      );
    } finally {
      if (mounted) setState(() => _exportando = false);
    }
  }

  Future<void> _exportarExcel() async {
    if (_exportando) return;
    setState(() => _exportando = true);
    try {
      final monedas = await _db.obtenerTodas();
      if (monedas.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No hay monedas que exportar')),
        );
        return;
      }
      final archivo = await ExportService.generarExcel(monedas);
      if (!mounted) return;
      await Share.shareXFiles(
        [XFile(archivo.path)],
        text: 'Catálogo CUBANUM',
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Excel generado: ${p.basename(archivo.path)}')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al exportar Excel: $e')),
      );
    } finally {
      if (mounted) setState(() => _exportando = false);
    }
  }

  Future<void> _confirmarBorrado() async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Borrar toda la colección'),
        content: const Text(
          'Se eliminarán TODAS las monedas de la base de datos.\n\n'
          'Las fotos no se borran del almacenamiento, pero las fichas '
          'sí desaparecerán y no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(ctx).colorScheme.error,
            ),
            child: const Text('Borrar todo'),
          ),
        ],
      ),
    );
    if (confirmado != true || !mounted) return;
    await _db.vaciar();
    if (!mounted) return;
    await _cargarTotal();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Colección borrada')),
    );
  }

  Future<void> _eliminarPais(String nombre) async {
    await _db.eliminarPaisPersonalizado(nombre);
    await _cargarListasPersonalizadas();
  }

  Future<void> _eliminarMetal(String nombre) async {
    await _db.eliminarMetalPersonalizado(nombre);
    await _cargarListasPersonalizadas();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProvider = context.watch<ThemeProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Ajustes')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
        children: [
          // ---------------- Apariencia ----------------
          _SeccionAjustes(
            titulo: 'Apariencia',
            icono: Icons.palette_outlined,
            hijos: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Text(
                  'Tema actual: ${themeProvider.nombre}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              _SelectorTemas(
                actual: themeProvider.id,
                onCambiar: (id) => themeProvider.cambiar(id),
              ),
            ],
          ),

          // ---------------- Datos ----------------
          _SeccionAjustes(
            titulo: 'Datos',
            icono: Icons.storage_outlined,
            hijos: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                enabled: !_exportando,
                leading: const Icon(Icons.picture_as_pdf_outlined),
                title: const Text('Exportar a PDF'),
                subtitle: const Text('Ficha completa de cada moneda'),
                trailing: _exportando
                    ? const SizedBox(
                        width: 18, height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.chevron_right),
                onTap: _exportando ? null : _exportarPdf,
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                enabled: !_exportando,
                leading: const Icon(Icons.table_chart_outlined),
                title: const Text('Exportar a Excel'),
                subtitle: const Text('Hoja de cálculo con todos los campos'),
                trailing: _exportando
                    ? const SizedBox(
                        width: 18, height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.chevron_right),
                onTap: _exportando ? null : _exportarExcel,
              ),
              const Divider(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Icon(
                      Icons.monetization_on_outlined,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Monedas en la colección',
                        style: theme.textTheme.bodyLarge,
                      ),
                    ),
                    if (_cargandoTotal)
                      const SizedBox(
                        width: 18, height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    else
                      Text('${_totalMonedas ?? 0}', style: theme.textTheme.titleLarge),
                  ],
                ),
              ),
            ],
          ),

          // ---------------- Listas personalizadas ----------------
          _SeccionAjustes(
            titulo: 'Listas personalizadas',
            icono: Icons.list_alt_outlined,
            hijos: [
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  'Países y metales que añadiste con "OTRO…"',
                  style: theme.textTheme.bodySmall,
                ),
              ),
              if (_cargandoListas)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                )
              else ...[
                _SubLista(
                  titulo: 'Países',
                  icono: Icons.public,
                  items: _paisesPersonalizados,
                  onEliminar: _eliminarPais,
                ),
                _SubLista(
                  titulo: 'Metales',
                  icono: Icons.bolt_outlined,
                  items: _metalesPersonalizados,
                  onEliminar: _eliminarMetal,
                ),
              ],
            ],
          ),

          // ---------------- Peligro ----------------
          _SeccionAjustes(
            titulo: 'Peligro',
            icono: Icons.warning_amber_outlined,
            hijos: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  Icons.delete_forever_outlined,
                  color: theme.colorScheme.error,
                ),
                title: Text(
                  'Borrar toda la colección',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
                subtitle: const Text('Esta acción no se puede deshacer'),
                onTap: _confirmarBorrado,
              ),
            ],
          ),

          // ---------------- Acerca de ----------------
          _SeccionAjustes(
            titulo: 'Acerca de',
            icono: Icons.info_outline,
            hijos: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('CUBANUM', style: theme.textTheme.titleLarge),
                    const SizedBox(height: 4),
                    Text(
                      'Control numismático personal · v1.0.0',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.75),
                      ),
                    ),
                    const SizedBox(height: 10),
                    _LineaAcerca('Desarrollador', 'Noelvis Torres Abreu'),
                    const SizedBox(height: 4),
                    _LineaAcerca('Programado en', 'Flutter 3.47.8 · Dart 3.13 · GitHub Actions'),
                    const SizedBox(height: 10),
                    Text(
                      'Gestiona tu colección de monedas de forma local y '
                      'sin conexión: países, períodos, grados Sheldon, '
                      'fotos, precios y valoraciones.',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// =====================================================================
// Selector de temas (5 tarjetas en horizontal)
// =====================================================================

class _SelectorTemas extends StatelessWidget {
  final AppThemeId actual;
  final ValueChanged<AppThemeId> onCambiar;

  const _SelectorTemas({required this.actual, required this.onCambiar});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      height: 108,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: AppThemeId.values.map((id) {
          final t = AppTheme.porId(id);
          final seleccionado = id == actual;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: InkWell(
              onTap: () => onCambiar(id),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 96,
                decoration: BoxDecoration(
                  color: t.scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: seleccionado
                        ? t.colorScheme.primary
                        : t.colorScheme.outline,
                    width: seleccionado ? 2 : 1,
                  ),
                ),
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Muestra de color
                    Container(
                      height: 32,
                      decoration: BoxDecoration(
                        color: t.colorScheme.primary,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      AppTheme.nombre(id),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: t.colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    if (seleccionado)
                      Icon(
                        Icons.check_circle,
                        color: t.colorScheme.primary,
                        size: 18,
                      ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// =====================================================================
// Sub-lista de países/metales personalizados
// =====================================================================

class _SubLista extends StatelessWidget {
  final String titulo;
  final IconData icono;
  final List<String> items;
  final ValueChanged<String> onEliminar;

  const _SubLista({
    required this.titulo,
    required this.icono,
    required this.items,
    required this.onEliminar,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (items.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Icon(icono, size: 18, color: theme.colorScheme.primary.withOpacity(0.5)),
            const SizedBox(width: 8),
            Text(
              '$titulo: (ninguno)',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 6, bottom: 2),
          child: Row(
            children: [
              Icon(icono, size: 18, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                '$titulo (${items.length})',
                style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
        ...items.map((n) => Padding(
              padding: const EdgeInsets.only(left: 26, top: 2, bottom: 2),
              child: Row(
                children: [
                  Expanded(child: Text(n, style: theme.textTheme.bodyMedium)),
                  IconButton(
                    icon: Icon(Icons.delete_outline, size: 20, color: theme.colorScheme.error),
                    tooltip: 'Eliminar',
                    onPressed: () => onEliminar(n),
                  ),
                ],
              ),
            )),
      ],
    );
  }
}

// =====================================================================
// Utilidades
// =====================================================================

class _LineaAcerca extends StatelessWidget {
  final String etiqueta;
  final String valor;
  const _LineaAcerca(this.etiqueta, this.valor);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 110,
          child: Text(
            etiqueta,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.65),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: Text(valor, style: theme.textTheme.bodyMedium),
        ),
      ],
    );
  }
}

class _SeccionAjustes extends StatelessWidget {
  final String titulo;
  final IconData icono;
  final List<Widget> hijos;

  const _SeccionAjustes({
    required this.titulo,
    required this.icono,
    required this.hijos,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icono, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(child: Text(titulo, style: theme.textTheme.titleLarge)),
              ],
            ),
            const SizedBox(height: 8),
            ...hijos,
          ],
        ),
      ),
    );
  }
}
