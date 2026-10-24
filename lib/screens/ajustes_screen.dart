import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../db/database_helper.dart';
import '../services/export_service.dart';
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

  @override
  void initState() {
    super.initState();
    _cargarTotal();
  }

  Future<void> _cargarTotal() async {
    final total = await _db.contar();
    if (!mounted) return;
    setState(() {
      _totalMonedas = total;
      _cargandoTotal = false;
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProvider = context.watch<ThemeProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Ajustes')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
        children: [
          _SeccionAjustes(
            titulo: 'Apariencia',
            icono: Icons.palette_outlined,
            hijos: [
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text('Tema oscuro', style: theme.textTheme.bodyLarge),
                subtitle: Text(
                  themeProvider.oscuro ? 'Gabinete nocturno' : 'Catálogo de museo',
                  style: theme.textTheme.bodySmall,
                ),
                value: themeProvider.oscuro,
                onChanged: (v) => themeProvider.alternar(v),
              ),
            ],
          ),
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
                    const SizedBox(height: 8),
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
