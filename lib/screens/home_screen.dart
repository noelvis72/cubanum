import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';

import '../db/database_helper.dart';
import '../models/moneda.dart';
import '../services/backup_service.dart';
import '../widgets/bottom_sheet_filtro.dart';
import '../widgets/filtro_chip.dart';
import '../widgets/moneda_card.dart';
import 'ajustes_screen.dart';
import 'detalle_screen.dart';
import 'form_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _busquedaCtrl = TextEditingController();
  final FocusNode _busquedaFocus = FocusNode();
  final DatabaseHelper _db = DatabaseHelper.instance;

  // ---- Datos ----
  List<Moneda> _monedas = const [];
  bool _cargando = true;
  String _queryActual = '';

  // ---- Estado de filtros ----
  List<String> _filtroPaises = [];
  List<String> _filtroMetales = [];
  List<String> _filtroFormas = [];
  List<String> _filtroMonedasCompra = [];
  List<String> _filtroAutenticidades = [];
  int? _filtroAnioDesde;
  int? _filtroAnioHasta;

  // ---- Estado de UI ----
  bool _chipsVisibles = true;
  bool _vistaCuadricula = false;
  final Set<String> _paisesExpandidos = {};

  // ---- Timers ----
  Timer? _debounce;
  Timer? _overlayTimer;
  OverlayEntry? _overlayAyuda;

  // ---- Opciones dinámicas para los bottom sheets ----
  List<MapEntry<String, int>> _opcionesPaises = [];
  List<MapEntry<String, int>> _opcionesMetales = [];
  List<MapEntry<String, int>> _opcionesFormas = [];

  bool get _hayFiltrosActivos =>
      _filtroPaises.isNotEmpty ||
      _filtroMetales.isNotEmpty ||
      _filtroFormas.isNotEmpty ||
      _filtroMonedasCompra.isNotEmpty ||
      _filtroAutenticidades.isNotEmpty ||
      _filtroAnioDesde != null ||
      _filtroAnioHasta != null ||
      _queryActual.isNotEmpty;

  int get _numFiltrosActivos {
    var n = 0;
    if (_filtroPaises.isNotEmpty) n++;
    if (_filtroMetales.isNotEmpty) n++;
    if (_filtroFormas.isNotEmpty) n++;
    if (_filtroMonedasCompra.isNotEmpty) n++;
    if (_filtroAutenticidades.isNotEmpty) n++;
    if (_filtroAnioDesde != null || _filtroAnioHasta != null) n++;
    return n;
  }

  @override
  void initState() {
    super.initState();
    _busquedaFocus.addListener(_onFocusCambia);
    _cargarPreferencias();
    _cargarOpciones();
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

  // -----------------------------------------------------------------
  // Preferencias (vista lista/cuadrícula)
  // -----------------------------------------------------------------

  Future<void> _cargarPreferencias() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _vistaCuadricula = prefs.getBool('cubanum_vista_cuadricula') ?? false;
    });
  }

  Future<void> _guardarPreferenciaVista() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('cubanum_vista_cuadricula', _vistaCuadricula);
  }

  // -----------------------------------------------------------------
  // Opciones dinámicas para los bottom sheets
  // -----------------------------------------------------------------

  Future<void> _cargarOpciones() async {
    final paises = await _db.obtenerPaisesConMonedas();
    final metales = await _db.obtenerMetalesConMonedas();
    final formas = await _db.obtenerFormasConMonedas();
    if (!mounted) return;
    setState(() {
      _opcionesPaises = paises;
      _opcionesMetales = metales;
      _opcionesFormas = formas;
    });
  }

  // -----------------------------------------------------------------
  // Carga de monedas
  // -----------------------------------------------------------------

  Future<void> _cargarMonedas() async {
    if (_monedas.isEmpty) setState(() => _cargando = true);

    final tieneFiltros =
        _filtroPaises.isNotEmpty ||
        _filtroMetales.isNotEmpty ||
        _filtroFormas.isNotEmpty ||
        _filtroMonedasCompra.isNotEmpty ||
        _filtroAutenticidades.isNotEmpty ||
        _filtroAnioDesde != null ||
        _filtroAnioHasta != null;

    final lista = (!tieneFiltros && _queryActual.isEmpty)
        ? await _db.obtenerTodas()
        : await _db.obtenerMonedasConFiltros(
            texto: _queryActual.isEmpty ? null : _queryActual,
            paises: _filtroPaises.isEmpty ? null : _filtroPaises,
            metales: _filtroMetales.isEmpty ? null : _filtroMetales,
            formas: _filtroFormas.isEmpty ? null : _filtroFormas,
            monedasCompra: _filtroMonedasCompra.isEmpty ? null : _filtroMonedasCompra,
            autenticidades: _filtroAutenticidades.isEmpty ? null : _filtroAutenticidades,
            anioDesde: _filtroAnioDesde,
            anioHasta: _filtroAnioHasta,
          );

    if (!mounted) return;
    setState(() {
      _monedas = lista;
      _cargando = false;
      // Si cambian los filtros, colapsar todos los países
      if (tieneFiltros || _queryActual.isNotEmpty) {
        _paisesExpandidos.clear();
      }
    });
  }

  // -----------------------------------------------------------------
  // Búsqueda
  // -----------------------------------------------------------------

  void _onBusquedaCambiada(String valor) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () async {
      final q = valor.trim();
      if (q == _queryActual) return;
      _queryActual = q;
      _paisesExpandidos.clear();
      await _cargarMonedas();
    });
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
              'conmemorativas, FAO, Hégira (AH), vendidas o reselladas.',
              style: Theme.of(ctx).textTheme.bodySmall,
            ),
          ),
        ),
      ),
    );
    overlay.insert(_overlayAyuda!);

    _overlayTimer?.cancel();
    _overlayTimer = Timer(const Duration(seconds: 5), () {
      _quitarOverlay();
    });
  }

  void _quitarOverlay() {
    _overlayTimer?.cancel();
    _overlayTimer = null;
    _overlayAyuda?.remove();
    _overlayAyuda = null;
  }

  // -----------------------------------------------------------------
  // Limpiar filtros
  // -----------------------------------------------------------------

  void _limpiarFiltros() {
    setState(() {
      _filtroPaises.clear();
      _filtroMetales.clear();
      _filtroFormas.clear();
      _filtroMonedasCompra.clear();
      _filtroAutenticidades.clear();
      _filtroAnioDesde = null;
      _filtroAnioHasta = null;
      _busquedaCtrl.clear();
      _queryActual = '';
      _paisesExpandidos.clear();
    });
    _cargarMonedas();
  }

  // -----------------------------------------------------------------
  // Bottom sheets de filtros
  // -----------------------------------------------------------------

  Future<void> _abrirFiltroPaises() async {
    final res = await mostrarBottomSheetSeleccionMultiple(
      context: context,
      titulo: 'Filtrar por país',
      opciones: _opcionesPaises,
      seleccionadosIniciales: _filtroPaises,
    );
    if (res == null || !mounted) return;
    setState(() {
      _filtroPaises = res;
      _paisesExpandidos.clear();
    });
    await _cargarMonedas();
  }

  Future<void> _abrirFiltroMetales() async {
    final res = await mostrarBottomSheetSeleccionMultiple(
      context: context,
      titulo: 'Filtrar por metal',
      opciones: _opcionesMetales,
      seleccionadosIniciales: _filtroMetales,
    );
    if (res == null || !mounted) return;
    setState(() {
      _filtroMetales = res;
      _paisesExpandidos.clear();
    });
    await _cargarMonedas();
  }

  Future<void> _abrirFiltroFormas() async {
    final res = await mostrarBottomSheetSeleccionMultiple(
      context: context,
      titulo: 'Filtrar por forma',
      opciones: _opcionesFormas,
      seleccionadosIniciales: _filtroFormas,
    );
    if (res == null || !mounted) return;
    setState(() {
      _filtroFormas = res;
      _paisesExpandidos.clear();
    });
    await _cargarMonedas();
  }

  Future<void> _abrirFiltroMonedaCompra() async {
    final opciones = <MapEntry<String, int>>[
      const MapEntry('CUP', 0),
      const MapEntry('USD', 0),
      const MapEntry('EUR', 0),
    ];
    final res = await mostrarBottomSheetSeleccionMultiple(
      context: context,
      titulo: 'Moneda de compra',
      opciones: opciones,
      seleccionadosIniciales: _filtroMonedasCompra,
      mostrarBuscador: false,
    );
    if (res == null || !mounted) return;
    setState(() {
      _filtroMonedasCompra = res;
      _paisesExpandidos.clear();
    });
    await _cargarMonedas();
  }

  Future<void> _abrirFiltroAutenticidad() async {
    final opciones = <MapEntry<String, int>>[
      const MapEntry('Original', 0),
      const MapEntry('Falsificación de época', 0),
      const MapEntry('Réplica moderna', 0),
    ];
    final res = await mostrarBottomSheetSeleccionMultiple(
      context: context,
      titulo: 'Autenticidad',
      opciones: opciones,
      seleccionadosIniciales: _filtroAutenticidades,
      mostrarBuscador: false,
    );
    if (res == null || !mounted) return;
    setState(() {
      _filtroAutenticidades = res;
      _paisesExpandidos.clear();
    });
    await _cargarMonedas();
  }

  Future<void> _abrirFiltroAnio() async {
    final res = await mostrarBottomSheetRangoAnio(
      context: context,
      desdeInicial: _filtroAnioDesde,
      hastaInicial: _filtroAnioHasta,
    );
    if (res == null || !mounted) return;
    setState(() {
      _filtroAnioDesde = res.$1;
      _filtroAnioHasta = res.$2;
      _paisesExpandidos.clear();
    });
    await _cargarMonedas();
  }

  // -----------------------------------------------------------------
  // Navegación
  // -----------------------------------------------------------------

  Future<void> _abrirFormulario() async {
    _busquedaFocus.unfocus();
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const FormScreen()),
    );
    if (resultado == true && mounted) {
      await _cargarOpciones();
      await _cargarMonedas();
    }
  }

  Future<void> _abrirDetalle(Moneda moneda) async {
    _busquedaFocus.unfocus();
    if (moneda.id == null) return;
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => DetalleScreen(id: moneda.id!)),
    );
    if (resultado == true && mounted) {
      await _cargarOpciones();
      await _cargarMonedas();
    }
  }

  Future<void> _abrirAjustes() async {
    _busquedaFocus.unfocus();
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AjustesScreen()),
    );
    if (mounted) {
      await _cargarOpciones();
      await _cargarMonedas();
    }
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
    final guardado = await BackupService.crearBackup();
    if (!mounted) return;
    if (guardado) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Copia de seguridad guardada')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Copia cancelada o no se pudo guardar')),
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
    await _cargarOpciones();
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

  // -----------------------------------------------------------------
  // Build
  // -----------------------------------------------------------------

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
              icon: const Icon(
                Icons.save,
                color: Color(0xFFCF142B),
                shadows: [
                  Shadow(color: Color(0x66000000), blurRadius: 2, offset: Offset(0, 1)),
                ],
              ),
              tooltip: 'Copia de seguridad',
              onPressed: _abrirDialogoBackup,
            ),
            // Icono de ojo con badge
            _buildIconoOjo(),
            IconButton(
              icon: Icon(
                Icons.handyman_outlined,
                color: theme.colorScheme.primary,
                shadows: const [
                  Shadow(color: Color(0x66000000), blurRadius: 2, offset: Offset(0, 1)),
                ],
              ),
              tooltip: 'Herramientas',
              onPressed: _abrirAjustes,
            ),
            IconButton(
              icon: Icon(
                _vistaCuadricula ? Icons.view_list : Icons.grid_view,
                color: theme.colorScheme.primary,
              ),
              tooltip: _vistaCuadricula ? 'Vista lista' : 'Vista cuadrícula',
              onPressed: () {
                setState(() => _vistaCuadricula = !_vistaCuadricula);
                _guardarPreferenciaVista();
              },
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
            // Campo de búsqueda
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
              child: TextField(
                controller: _busquedaCtrl,
                focusNode: _busquedaFocus,
                onChanged: _onBusquedaCambiada,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: _busquedaFocus.hasFocus
                      ? 'País, metal, año, Sheldon, FAO, AH, vendidas…'
                      : 'Buscar en la colección…',
                  prefixIcon: Icon(Icons.search,
                      color: theme.colorScheme.onSurface.withOpacity(0.6)),
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
            // Fila de chips
            if (_chipsVisibles) _buildFilaChips(theme),
            // Contador de resultados
            if (_hayFiltrosActivos && !_cargando) _buildContadorResultados(theme),
            // Lista / cuadrícula / vacío
            Expanded(
              child: _cargando
                  ? const Center(child: CircularProgressIndicator())
                  : _buildContenido(theme),
            ),
          ],
        ),
      ),
    );
  }

  // -----------------------------------------------------------------
  // Icono de ojo
  // -----------------------------------------------------------------

  Widget _buildIconoOjo() {
    final theme = Theme.of(context);
    final icono = Icon(
      _chipsVisibles ? Icons.visibility_off : Icons.visibility,
      color: theme.colorScheme.primary,
    );

    final iconButton = IconButton(
      icon: _numFiltrosActivos > 0
          ? Badge(
              label: Text('$_numFiltrosActivos'),
              child: icono,
            )
          : icono,
      tooltip: _chipsVisibles ? 'Ocultar filtros' : 'Mostrar filtros',
      onPressed: () {
        setState(() => _chipsVisibles = !_chipsVisibles);
      },
    );

    return iconButton;
  }

  // -----------------------------------------------------------------
  // Fila de chips
  // -----------------------------------------------------------------

  Widget _buildFilaChips(ThemeData theme) {
    // Resumen del rango de años para el chip
    final tieneRango = _filtroAnioDesde != null || _filtroAnioHasta != null;
    final textoRango = tieneRango
        ? '${_filtroAnioDesde ?? "…"}-${_filtroAnioHasta ?? "…"}'
        : '';

    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        children: [
          FiltroChip(
            etiqueta: 'País',
            seleccionados: _filtroPaises,
            onTap: _abrirFiltroPaises,
            onLimpiar: () {
              setState(() => _filtroPaises.clear());
              _cargarMonedas();
            },
            icono: Icons.public,
          ),
          FiltroChip(
            etiqueta: 'Año',
            seleccionados: tieneRango ? [textoRango] : const [],
            onTap: _abrirFiltroAnio,
            onLimpiar: tieneRango
                ? () {
                    setState(() {
                      _filtroAnioDesde = null;
                      _filtroAnioHasta = null;
                    });
                    _cargarMonedas();
                  }
                : null,
            icono: Icons.calendar_today_outlined,
          ),
          FiltroChip(
            etiqueta: 'Metal',
            seleccionados: _filtroMetales,
            onTap: _abrirFiltroMetales,
            onLimpiar: () {
              setState(() => _filtroMetales.clear());
              _cargarMonedas();
            },
            icono: Icons.bolt_outlined,
          ),
          FiltroChip(
            etiqueta: 'Moneda',
            seleccionados: _filtroMonedasCompra,
            onTap: _abrirFiltroMonedaCompra,
            onLimpiar: () {
              setState(() => _filtroMonedasCompra.clear());
              _cargarMonedas();
            },
            icono: Icons.currency_exchange,
          ),
          FiltroChip(
            etiqueta: 'Falsa/Réplica',
            seleccionados: _filtroAutenticidades,
            onTap: _abrirFiltroAutenticidad,
            onLimpiar: () {
              setState(() => _filtroAutenticidades.clear());
              _cargarMonedas();
            },
            icono: Icons.gavel_outlined,
          ),
          FiltroChip(
            etiqueta: 'Forma',
            seleccionados: _filtroFormas,
            onTap: _abrirFiltroFormas,
            onLimpiar: () {
              setState(() => _filtroFormas.clear());
              _cargarMonedas();
            },
            icono: Icons.crop_free,
          ),
        ],
      ),
    );
  }

  // -----------------------------------------------------------------
  // Contador de resultados
  // -----------------------------------------------------------------

  Widget _buildContadorResultados(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '${_monedas.length} ${_monedas.length == 1 ? "resultado" : "resultados"} con filtros aplicados',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ),
          TextButton(
            onPressed: _limpiarFiltros,
            child: const Text('Limpiar filtros'),
          ),
        ],
      ),
    );
  }

  // -----------------------------------------------------------------
  // Contenido (lista, cuadrícula o vacío)
  // -----------------------------------------------------------------

  Widget _buildContenido(ThemeData theme) {
    if (_monedas.isEmpty) {
      return _EstadoVacio(
        hayFiltro: _hayFiltrosActivos,
        onRecargar: _cargarMonedas,
      );
    }

    if (_vistaCuadricula) {
      return RefreshIndicator(
        onRefresh: _cargarMonedas,
        child: _buildCuadricula(),
      );
    }

    // Vista de lista
    if (_hayFiltrosActivos) {
      // Con filtros: listado plano
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

    // Sin filtros: agrupación colapsable por país
    return RefreshIndicator(
      onRefresh: _cargarMonedas,
      child: _buildListaAgrupada(),
    );
  }

  // -----------------------------------------------------------------
  // Agrupación colapsable por país
  // -----------------------------------------------------------------

  Widget _buildListaAgrupada() {
    // Construir mapa país -> monedas
    final porPais = <String, List<Moneda>>{};
    for (final m in _monedas) {
      final key = m.pais.isEmpty ? 'Sin país' : m.pais;
      porPais.putIfAbsent(key, () => []).add(m);
    }
    // Ordenar países alfabéticamente
    final paises = porPais.keys.toList()
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

    // Construir lista plana de widgets (encabezados + monedas)
    final items = <Widget>[];
    for (final pais in paises) {
      final monedasPais = porPais[pais]!;
      final expandido = _paisesExpandidos.contains(pais);

      items.add(
        Material(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          child: InkWell(
            onTap: () {
              setState(() {
                if (expandido) {
                  _paisesExpandidos.remove(pais);
                } else {
                  _paisesExpandidos.add(pais);
                }
              });
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Icon(
                    expandido ? Icons.expand_less : Icons.expand_more,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '$pais (${monedasPais.length})',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      if (expandido) {
        for (final m in monedasPais) {
          items.add(
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: MonedaCard(moneda: m, onTap: () => _abrirDetalle(m)),
            ),
          );
        }
      }
    }

    return ListView(
      padding: const EdgeInsets.only(bottom: 96),
      children: items,
    );
  }

  // -----------------------------------------------------------------
  // Cuadrícula
  // -----------------------------------------------------------------

  Widget _buildCuadricula() {
    final ancho = MediaQuery.of(context).size.width;
    final columnas = ancho > 600 ? 3 : 2;

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 96),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columnas,
        childAspectRatio: 0.72,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: _monedas.length,
      itemBuilder: (context, index) {
        final m = _monedas[index];
        return _MonedaCelda(
          moneda: m,
          onTap: () => _abrirDetalle(m),
        );
      },
    );
  }
}

// =====================================================================
// Título CUBANUM con fondo oscuro redondeado, ShaderMask y estrella
// =====================================================================

class _TituloCubanum extends StatelessWidget {
  const _TituloCubanum();

  @override
  Widget build(BuildContext context) {
    const baseStyle = TextStyle(
      fontWeight: FontWeight.w900,
      letterSpacing: 1.2,
      fontSize: 20,
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
              left: 7,
              top: (32 - 10) / 2,
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

// =====================================================================
// Celda de la cuadrícula
// =====================================================================

class _MonedaCelda extends StatelessWidget {
  final Moneda moneda;
  final VoidCallback onTap;

  const _MonedaCelda({required this.moneda, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Miniatura
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  moneda.fotoAnverso == null || moneda.fotoAnverso!.isEmpty
                      ? Container(
                          color: scheme.surfaceContainerHighest,
                          child: Icon(
                            Icons.monetization_on_outlined,
                            size: 48,
                            color: scheme.primary.withOpacity(0.6),
                          ),
                        )
                      : Image.file(
                          File(moneda.fotoAnverso!),
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: scheme.surfaceContainerHighest,
                            child: Icon(
                              Icons.broken_image_outlined,
                              size: 48,
                              color: scheme.primary.withOpacity(0.6),
                            ),
                          ),
                        ),
                  if (moneda.vendida)
                    Positioned(
                      top: 6,
                      right: 6,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          color: Color(0xFF4A7C59),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // Info
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    moneda.pais.isEmpty ? 'Sin país' : moneda.pais,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    [
                      if (moneda.denominacion.isNotEmpty) moneda.denominacion,
                      if (moneda.anio.isNotEmpty)
                        (moneda.esHejira ? '${moneda.anio} AH' : moneda.anio),
                    ].join(' · '),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurface.withOpacity(0.7),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =====================================================================
// Estado vacío
// =====================================================================

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
                        ? 'Cambia el criterio de búsqueda para mejores resultados.'
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
