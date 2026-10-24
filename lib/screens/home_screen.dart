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
  final DatabaseHelper _db = DatabaseHelper.instance;

  List<Moneda> _monedas = const [];
  bool _cargando = true;
  String _queryActual = '';
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _cargarMonedas();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _busquedaCtrl.dispose();
    super.dispose();
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('C U B A N U M'),
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
          _CampoBusqueda(
            controller: _busquedaCtrl,
            onChanged: _onBusquedaCambiada,
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

class _CampoBusqueda extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _CampoBusqueda({required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: 'Buscar por país, denominación, año, KM, ceca…',
          prefixIcon: Icon(Icons.search, color: scheme.onSurface.withOpacity(0.6)),
          suffixIcon: ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (context, value, _) {
              if (value.text.isEmpty) return const SizedBox.shrink();
              return IconButton(
                icon: const Icon(Icons.clear),
                tooltip: 'Borrar',
                onPressed: () {
                  controller.clear();
                  onChanged('');
                },
              );
            },
          ),
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
