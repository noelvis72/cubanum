import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../db/database_helper.dart';
import '../services/export_service.dart';
import '../services/backup_service.dart';
import '../theme/app_theme.dart';
import '../theme/theme_provider.dart';
import 'estadisticas_screen.dart';
import 'referencias_screen.dart';

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
  List<String> _cantosPersonalizados = [];
  List<String> _acabadosPersonalizados = [];
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
    final cantos = await _db.obtenerCantosPersonalizados();
    final acabados = await _db.obtenerAcabadosPersonalizados();
    if (!mounted) return;
    setState(() {
      _paisesPersonalizados = paises;
      _metalesPersonalizados = metales;
      _cantosPersonalizados = cantos;
      _acabadosPersonalizados = acabados;
      _cargandoListas = false;
    });
  }

  // -----------------------------------------------------------------
  // Exportación
  // -----------------------------------------------------------------

  Future<void> _exportarPdf() async {
    if (_exportando) return;

    final prefs = await SharedPreferences.getInstance();
    final nombreGuardado = prefs.getString('cubanum_nombre_coleccionista') ?? '';
    final nombreCtrl = TextEditingController(text: nombreGuardado);
    final fechaCtrl = TextEditingController(
      text: DateFormat('dd/MM/yyyy').format(DateTime.now()),
    );
    int paso = 0;
    bool conFotos = true;

    final resultado = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          return AlertDialog(
            title: Text(paso == 0 ? 'Datos del catálogo' : 'Modo de exportación'),
            content: paso == 0
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: nombreCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Coleccionista',
                          hintText: 'Nombre y apellidos',
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: fechaCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Fecha',
                          hintText: 'dd/mm/aaaa',
                          prefixIcon: Icon(Icons.calendar_today_outlined),
                        ),
                      ),
                    ],
                  )
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      RadioListTile<bool>(
                        contentPadding: EdgeInsets.zero,
                        value: true,
                        groupValue: conFotos,
                        onChanged: (v) => setDialogState(() => conFotos = v ?? true),
                        title: const Text('Catálogo visual (con fotos)'),
                        subtitle: const Text('~3 monedas por página'),
                      ),
                      RadioListTile<bool>(
                        contentPadding: EdgeInsets.zero,
                        value: false,
                        groupValue: conFotos,
                        onChanged: (v) => setDialogState(() => conFotos = v ?? true),
                        title: const Text('Listado compacto (sin fotos)'),
                        subtitle: const Text('~20 monedas por página'),
                      ),
                    ],
                  ),
            actions: paso == 0
                ? [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Cancelar'),
                    ),
                    ElevatedButton(
                      onPressed: () => setDialogState(() => paso = 1),
                      child: const Text('Siguiente'),
                    ),
                  ]
                : [
                    TextButton(
                      onPressed: () => setDialogState(() => paso = 0),
                      child: const Text('Atrás'),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text('Exportar'),
                    ),
                  ],
          );
        },
      ),
    );

    final nombre = nombreCtrl.text.trim();
    final fecha = fechaCtrl.text.trim();
    nombreCtrl.dispose();
    fechaCtrl.dispose();

    if (resultado != true || !mounted) return;

    if (nombre.isNotEmpty) {
      await prefs.setString('cubanum_nombre_coleccionista', nombre);
    }

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
      final ok = await ExportService.generarPdf(
        monedas,
        nombreColeccionista: nombre.isEmpty ? 'Coleccionista' : nombre,
        fecha: fecha.isEmpty ? DateFormat('dd/MM/yyyy').format(DateTime.now()) : fecha,
        conFotos: conFotos,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(ok ? 'PDF guardado' : 'Exportación cancelada')),
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
      final ok = await ExportService.generarExcel(monedas);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(ok ? 'Excel guardado' : 'Exportación cancelada')),
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

  // -----------------------------------------------------------------
  // Backup
  // -----------------------------------------------------------------
  
  Future<void> _crearBackup() async {
  if (_exportando) return;
  setState(() => _exportando = true);
  try {
    final ok = await BackupService.crearBackup();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(ok ? 'Copia de seguridad guardada' : 'Copia cancelada')),
    );
  } catch (e) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error al crear copia: $e')),
    );
  } finally {
    if (mounted) setState(() => _exportando = false);
  }

  // -----------------------------------------------------------------
  // Borrado
  // -----------------------------------------------------------------

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

  Future<void> _confirmarBorrarVendidas() async {
    final totalVendidas = await _db.contarVendidas();
    if (!mounted) return;

    if (totalVendidas == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay monedas vendidas para borrar')),
      );
      return;
    }

    final confirmado = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Borrar monedas vendidas'),
        content: Text(
          'Se eliminarán $totalVendidas monedas vendidas de forma permanente.\n\n'
          'Sus datos y sus fotos también se borrarán.\n\n'
          'Esta acción no se puede deshacer.',
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
            child: const Text('Borrar'),
          ),
        ],
      ),
    );

    if (confirmado != true || !mounted) return;
    await _db.eliminarVendidas();
    if (!mounted) return;
    await _cargarTotal();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Se eliminaron $totalVendidas monedas vendidas')),
    );
  }

  // -----------------------------------------------------------------
  // Listas personalizadas
  // -----------------------------------------------------------------

  Future<void> _eliminarPais(String nombre) async {
    await _db.eliminarPaisPersonalizado(nombre);
    await _cargarListasPersonalizadas();
  }

  Future<void> _eliminarMetal(String nombre) async {
    await _db.eliminarMetalPersonalizado(nombre);
    await _cargarListasPersonalizadas();
  }

  Future<void> _eliminarCanto(String nombre) async {
    await _db.eliminarCantoPersonalizado(nombre);
    await _cargarListasPersonalizadas();
  }

  Future<void> _eliminarAcabado(String nombre) async {
    await _db.eliminarAcabadoPersonalizado(nombre);
    await _cargarListasPersonalizadas();
  }

  // -----------------------------------------------------------------
  // Navegación
  // -----------------------------------------------------------------

  Future<void> _abrirReferencias(int tab) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ReferenciasScreen(initialTab: tab),
      ),
    );
  }

  Future<void> _abrirEstadisticas() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const EstadisticasScreen()),
    );
  }

  // -----------------------------------------------------------------
  // Build
  // -----------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProvider = context.watch<ThemeProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Herramientas')),
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

          // ---------------- Copia de seguridad ----------------
          _SeccionAjustes(
            titulo: 'Copia de seguridad',
            icono: Icons.settings_backup_restore,
            hijos: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                enabled: !_exportando,
                leading: const Icon(Icons.save_alt),
                title: const Text('Crear copia de seguridad'),
                subtitle: const Text('Guarda la colección en un ZIP'),
                trailing: _exportando
                    ? const SizedBox(
                        width: 18, height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.chevron_right),
                onTap: _exportando ? null : _crearBackup,
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                enabled: !_exportando,
                leading: const Icon(Icons.restore),
                title: const Text('Restaurar copia de seguridad'),
                subtitle: const Text('Reemplaza la colección actual por una copia'),
                trailing: const Icon(Icons.chevron_right),
                onTap: _exportando ? null : () {
                  // Nota: la restauración está en el Home también.
                  // Aquí podrías llamar al servicio de restauración.
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Usa el icono de backup del Home para restaurar')),
                  );
                },
              ),
            ],
          ),

          // ---------------- Referencias numismáticas ----------------
          _SeccionAjustes(
            titulo: 'Referencias numismáticas',
            icono: Icons.menu_book_outlined,
            hijos: [
              _CardHerramienta(
                titulo: 'Conversión\nHégira ↔ Gregoriano',
                onTap: () => _abrirReferencias(1),
              ),
              const SizedBox(height: 8),
              _CardHerramienta(
                titulo: 'Sistemas Standard\nNumérico Internacional',
                onTap: () => _abrirReferencias(0),
              ),
              const SizedBox(height: 8),
              _CardHerramienta(
                titulo: 'Estadísticas\nde la colección',
                onTap: _abrirEstadisticas,
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
                  'Países, metales, cantos y acabados que añadiste con "OTRO…"',
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
                _SubLista(
                  titulo: 'Cantos',
                  icono: Icons.line_weight,
                  items: _cantosPersonalizados,
                  onEliminar: _eliminarCanto,
                ),
                _SubLista(
                  titulo: 'Acabados',
                  icono: Icons.auto_awesome_outlined,
                  items: _acabadosPersonalizados,
                  onEliminar: _eliminarAcabado,
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
              const Divider(height: 8),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  Icons.delete_sweep_outlined,
                  color: theme.colorScheme.error,
                ),
                title: Text(
                  'Borrar monedas vendidas',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
                subtitle: const Text('Elimina las vendidas y sus fotos'),
                onTap: _confirmarBorrarVendidas,
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
                      'Control numismático personal · v1.1.0',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.75),
                      ),
                    ),
                    const SizedBox(height: 10),
                    _LineaAcerca('Desarrollador', 'Noelvis Torres Abreu'),
                    const SizedBox(height: 4),
                    _LineaAcerca('Programado en', 'Flutter 3.47.8 · Dart 3.13 · SQLite · GitHub Actions'),
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
// Selector de temas (tarjetas horizontales)
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
                    color: seleccionado ? t.colorScheme.primary : t.colorScheme.outline,
                    width: seleccionado ? 2 : 1,
                  ),
                ),
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                      Icon(Icons.check_circle, color: t.colorScheme.primary, size: 18),
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
// Tarjeta de acceso a herramienta
// =====================================================================

class _CardHerramienta extends StatelessWidget {
  final String titulo;
  final VoidCallback onTap;

  const _CardHerramienta({required this.titulo, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.colorScheme.outline.withOpacity(0.4),
            ),
          ),
          child: Text(
            titulo,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium?.copyWith(height: 1.3),
          ),
        ),
      ),
    );
  }
}

// =====================================================================
// Sub-lista de listas personalizadas
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
        Expanded(child: Text(valor, style: theme.textTheme.bodyMedium)),
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
