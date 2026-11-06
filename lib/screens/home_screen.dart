import 'dart:async';

import 'package:flutter/material.dart';

import '../db/database_helper.dart';
import '../models/moneda.dart';
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

  List<Moneda> _monedas = const [];
  bool _cargando = true;
  String _queryActual = '';
  Timer? _debounce;
  OverlayEntry? _overlayAyuda;

  @override
  void initState() {
    super.initState();
    _busquedaFocus.addListener(_onFocusCambia);
    _cargarMonedas();
  }

  @override
  void dispose() {
    _quitarOverlay();
    _debounce?.cancel();
    _busquedaFocus.removeListener(_onFocusCambia);
    _busquedaFocus.dispose();
    _busquedaCtrl.dispose();
    super.dispose();
  }

  void _onFocusCambia() {
    setState(() {}); // actualiza hint
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
        top: offset.dy + kToolbarHeight + 64,
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
              'conmemorativas o FAO.',
              style: Theme.of(ctx).textTheme.bodySmall,
            ),
          ),
        ),
      ),
    );
    overlay.insert(_overlayAyuda!);
  }

  void _quitarOverlay() {
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
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const FormScreen()),
    );
    if (resultado == true && mounted) await _cargarMonedas();
  }

  Future<void> _abrirDetalle(Moneda moneda) async {
    if (moneda.id == null) return;
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => DetalleScreen(id: moneda.id!)),
    );
    if (resultado == true && mounted) await _cargarMonedas();
  }

  Future<void> _abrirAjustes() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AjustesScreen()),
    );
    if (mounted) await _cargarMonedas();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: _TituloCubanum(),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
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
                    ? 'País, metal, año, Sheldon, FAO…'
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

/// Título CUBANUM con 3 líneas de la bandera cubana encima del texto.
class _TituloCubanum extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 3 líneas: azul, blanco, rojo
        Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            _LineaColor(color: Color(0xFF002A8F)), // azul turquí
            SizedBox(width: 2),
            _LineaColor(color: Colors.white),
            SizedBox(width: 2),
            _LineaColor(color: Color(0xFFCF142B)), // rojo
          ],
        ),
        const SizedBox(height: 2),
        Text(
          'CUBANUM',
          style: theme.appBarTheme.titleTextStyle ??
              theme.textTheme.titleLarge?.copyWith(letterSpacing: 1.2),
        ),
      ],
    );
  }
}

class _LineaColor extends StatelessWidget {
  final Color color;
  const _LineaColor({required this.color});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 16,
      height: 3,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(1),
        border: Border.all(color: Colors.black12, width: 0.3),
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
