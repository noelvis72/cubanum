import 'dart:async';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

import '../db/database_helper.dart';
import '../models/moneda.dart';
import '../services/backup_service.dart';
import '../widgets/moneda_card.dart';
import 'ajustes_screen.dart';
import 'detalle_screen.dart';
import 'estadisticas_screen.dart';
import 'form_screen.dart';
import 'referencias_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _busquedaCtrl = TextEditingController();
  final FocusNode _busquedaFocus = FocusNode();
  final DatabaseHelper _db = DatabaseHelper.instance;

  List<Moneda> _monedas = const [];
  bool _cargando = true;
  String _queryActual = '';
  Timer? _debounce;
  Timer? _overlayTimer;
  OverlayEntry? _overlayAyuda;

  @override
  void initState() {
    super.initState();
    _busquedaFocus.addListener(_onFocusCambia);
    _cargarMonedas();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _comprobarRecordatorioSalva();
    });
  }

  @override
  void dispose() {
    _quitarOverlay();
    _debounce?.cancel();
    _overlayTimer?.cancel();
    _busquedaFocus.removeListener(_onFocusCambia);
    _busquedaFocus.dispose();
    _busquedaCtrl.dispose();
    super.dispose();
  }

  void _onFocusCambia() {
    setState(() {});
    if (_busquedaFocus.hasFocus) {
      _mostrarOverlay();
    } else {
      _quitarOverlay();
    }
  }

  void _mostrarOverlay() {
    _quitarOverlay();
    final overlay = Overlay.of(context);
    final box = context.findRenderObject() as RenderBox?;
    if (box == null) return;
    final offset = box.localToGlobal(Offset.zero);

    _overlayAyuda = OverlayEntry(
      builder: (ctx) => Positioned(
        top: offset.dy + kToolbarHeight + 80,
        left: 16,
        right: 16,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Theme.of(ctx).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: Theme.of(ctx).colorScheme.outline.withOpacity(0.5),
              ),
              boxShadow: const [
                BoxShadow(color: Color(0x33000000), blurRadius: 8, offset: Offset(0, 2)),
              ],
            ),
            child: Text(
              'Puedes buscar por país, metal, año, grado Sheldon, '
              'conmemorativas, FAO o Hégira (AH).',
              style: Theme.of(ctx).textTheme.bodySmall,
            ),
          ),
        ),
      ),
    );
    overlay.insert(_overlayAyuda!);

    _overlayTimer?.cancel();
    _overlayTimer = Timer(const Duration(seconds: 7), () {
      _quitarOverlay();
    });
  }

  void _quitarOverlay() {
    _overlayTimer?.cancel();
    _overlayTimer = null;
    _overlayAyuda?.remove();
    _overlayAyuda = null;
  }

  Future<void> _cargarMonedas() async {
    if (_monedas.isEmpty) setState(() => _cargando = true);
    final lista = _queryActual.isEmpty
        ? await _db.obtenerTodas()
        : await _db.buscar(_queryActual);
    if (!mounted) return;
    setState(() {
      _monedas = lista;
      _cargando = false;
    });
  }

  void _onBusquedaCambiada(String valor) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () async {
      final q = valor.trim();
      if (q == _queryActual) return;
      _queryActual = q;
      await _cargarMonedas();
    });
  }

  Future<void> _abrirFormulario() async {
    _busquedaFocus.unfocus();
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const FormScreen()),
    );
    if (resultado == true && mounted) await _cargarMonedas();
  }

  Future<void> _abrirDetalle(Moneda moneda) async {
    _busquedaFocus.unfocus();
    if (moneda.id == null) return;
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => DetalleScreen(id: moneda.id!)),
    );
    if (resultado == true && mounted) await _cargarMonedas();
  }

  Future<void> _abrirAjustes() async {
    _busquedaFocus.unfocus();
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AjustesScreen()),
    );
    if (mounted) await _cargarMonedas();
  }

  Future<void> _abrirReferencias() async {
    _busquedaFocus.unfocus();
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ReferenciasScreen()),
    );
  }

  Future<void> _abrirEstadisticas() async {
    _busquedaFocus.unfocus();
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const EstadisticasScreen()),
    );
  }

  Future<void> _abrirDialogoBackup() async {
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Copia de seguridad'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.save_alt),
              title: const Text('Crear copia de seguridad'),
              subtitle: const Text('Guarda la colección en un ZIP'),
              onTap: () async {
                Navigator.pop(ctx);
                await _crearBackupDesdeHome();
              },
            ),
            ListTile(
              leading: const Icon(Icons.restore),
              title: const Text('Restaurar copia de seguridad'),
              subtitle: const Text('Reemplaza la colección actual'),
              onTap: () async {
                Navigator.pop(ctx);
                await _restaurarBackupDesdeHome();
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
  }

  Future<void> _crearBackupDesdeHome() async {
    final archivo = await BackupService.crearBackup();
    if (!mounted) return;
    if (archivo != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Copia creada: ${p.basename(archivo.path)}')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo crear la copia')),
      );
    }
  }

  Future<void> _restaurarBackupDesdeHome() async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Restaurar copia de seguridad'),
        content: const Text(
          'Esto REEMPLAZARÁ todas las monedas y fotos actuales por las de '
          'la copia de seguridad.\n\n'
          'Se guardará una copia automática de la colección actual.\n\n'
          '¿Continuar?',
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
            child: const Text('Restaurar'),
          ),
        ],
      ),
    );
    if (confirmado != true || !mounted) return;

    final ok = await BackupService.restaurarBackup();
    if (!mounted) return;
    await _cargarMonedas();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok
            ? 'Copia restaurada correctamente'
            : 'No se pudo restaurar la copia'),
      ),
    );
  }

  Future<void> _comprobarRecordatorioSalva() async {
    final debe = await BackupService.debeRecordarSalva();
    if (!debe || !mounted) return;
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Recordatorio de copia de seguridad'),
        content: const Text(
          'Llevas más de 30 días sin hacer una copia de seguridad de tu '
          'colección.\n\n'
          '¿Quieres crear una ahora para no perder tus monedas?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Ahora no'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await _crearBackupDesdeHome();
            },
            child: const Text('Crear copia'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: const _TituloCubanum(),
          actions: [
            IconButton(
              icon: Icon(
                Icons.settings_backup_restore,
                color: const Color(0xFFCF142B),
                shadows: const [
                  Shadow(color: Color(0x66000000), blurRadius: 2, offset: Offset(0, 1)),
                ],
              ),
              tooltip: 'Copia de seguridad',
              onPressed: _abrirDialogoBackup,
            ),
            IconButton(
              icon: Icon(
                Icons.menu_book_outlined,
                color: theme.colorScheme.primary,
                shadows: const [
                  Shadow(color: Color(0x66000000), blurRadius: 2, offset: Offset(0, 1)),
                ],
              ),
              tooltip: 'Referencias',
              onPressed: _abrirReferencias,
            ),
            IconButton(
              icon: Icon(
                Icons.bar_chart_outlined,
                color: theme.colorScheme.primary,
                shadows: const [
                  Shadow(color: Color(0x66000000), blurRadius: 2, offset: Offset(0, 1)),
                ],
              ),
              tooltip: 'Estadísticas',
              onPressed: _abrirEstadisticas,
            ),
            IconButton(
              icon: Icon(
                Icons.settings_outlined,
                color: theme.colorScheme.primary,
                shadows: const [
                  Shadow(color: Color(0x66000000), blurRadius: 2, offset: Offset(0, 1)),
                ],
              ),
              tooltip: 'Ajustes',
              onPressed: _abrirAjustes,
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _abrirFormulario,
          tooltip: 'Añadir moneda',
          child: const Icon(Icons.add),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
              child: TextField(
                controller: _busquedaCtrl,
                focusNode: _busquedaFocus,
                onChanged: _onBusquedaCambiada,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: _busquedaFocus.hasFocus
                      ? 'País, metal, año, Sheldon, FAO, AH…'
                      : 'Buscar en la colección…',
                  prefixIcon: Icon(Icons.search, color: theme.colorScheme.onSurface.withOpacity(0.6)),
                  suffixIcon: ValueListenableBuilder<TextEditingValue>(
                    valueListenable: _busquedaCtrl,
                    builder: (context, value, _) {
                      if (value.text.isEmpty) return const SizedBox.shrink();
                      return IconButton(
                        icon: const Icon(Icons.clear),
                        tooltip: 'Borrar',
                        onPressed: () {
                          _busquedaCtrl.clear();
                          _onBusquedaCambiada('');
                        },
                      );
                    },
                  ),
                ),
              ),
            ),
            Expanded(
              child: _cargando
                  ? const Center(child: CircularProgressIndicator())
                  : _buildLista(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLista() {
    if (_monedas.isEmpty) {
      return _EstadoVacio(
        hayFiltro: _queryActual.isNotEmpty,
        onRecargar: _cargarMonedas,
      );
    }

    return RefreshIndicator(
      onRefresh: _cargarMonedas,
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 4, bottom: 96),
        itemCount: _monedas.length,
        itemBuilder: (context, index) {
          final m = _monedas[index];
          return MonedaCard(moneda: m, onTap: () => _abrirDetalle(m));
        },
      ),
    );
  }
}

/// Título CUBANUM con fondo oscuro redondeado, ShaderMask y estrella.
class _TituloCubanum extends StatelessWidget {
  const _TituloCubanum();

  @override
  Widget build(BuildContext context) {
    final baseStyle = const TextStyle(
      fontWeight: FontWeight.w900,
      letterSpacing: 2.0,
      fontSize: 22,
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF1E222B),
        borderRadius: BorderRadius.circular(8),
      ),
      child: SizedBox(
        height: 32,
        child: Stack(
          alignment: Alignment.centerLeft,
          children: [
            Text(
              'CUBANUM',
              style: baseStyle.copyWith(
                color: Colors.black,
                shadows: const [
                  Shadow(color: Colors.black, blurRadius: 2, offset: Offset(1, 1)),
                  Shadow(color: Colors.black, blurRadius: 2, offset: Offset(-1, 1)),
                  Shadow(color: Colors.black, blurRadius: 2, offset: Offset(1, -1)),
                  Shadow(color: Colors.black, blurRadius: 2, offset: Offset(-1, -1)),
                ],
              ),
            ),
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF001C66),
                  Color(0xFF002A8F),
                  Color(0xFFFFFFFF),
                  Color(0xFFE00019),
                  Color(0xFF9B0011),
                ],
                stops: [0.0, 0.2, 0.5, 0.8, 1.0],
              ).createShader(bounds),
              child: Text(
                'CUBANUM',
                style: baseStyle.copyWith(color: Colors.white),
              ),
            ),
            Positioned(
              left: 8,
              top: (32 - 10) / 2 - 1,
              child: const IgnorePointer(
                child: Icon(Icons.star, size: 10, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EstadoVacio extends StatelessWidget {
  final bool hayFiltro;
  final Future<void> Function() onRecargar;

  const _EstadoVacio({required this.hayFiltro, required this.onRecargar});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return RefreshIndicator(
      onRefresh: onRecargar,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.18),
          Center(
            child: Column(
              children: [
                Icon(
                  hayFiltro ? Icons.search_off : Icons.monetization_on_outlined,
                  size: 72,
                  color: scheme.primary.withOpacity(0.75),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    hayFiltro
                        ? 'Sin resultados para esa búsqueda.'
                        : 'Tu colección está vacía.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleLarge,
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    hayFiltro
                        ? 'Prueba con otro país, denominación o año.'
                        : 'Pulsa el botón “+” para añadir tu primera moneda.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
