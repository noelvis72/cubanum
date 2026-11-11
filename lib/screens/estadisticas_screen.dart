import 'package:flutter/material.dart';

import '../db/database_helper.dart';
import '../models/moneda.dart';

class EstadisticasScreen extends StatefulWidget {
  const EstadisticasScreen({super.key});

  @override
  State<EstadisticasScreen> createState() => _EstadisticasScreenState();
}

class _EstadisticasScreenState extends State<EstadisticasScreen> {
  final DatabaseHelper _db = DatabaseHelper.instance;
  bool _cargando = true;

  int _totalMonedas = 0;
  int _totalVendidas = 0;

  // Invertido por moneda
  final Map<String, double> _invertido = {'CUP': 0, 'USD': 0, 'EUR': 0};
  // Valor estimado por moneda
  final Map<String, double> _valorEstimado = {'CUP': 0, 'USD': 0, 'EUR': 0};
  // Recuperado por ventas
  final Map<String, double> _recuperado = {'CUP': 0, 'USD': 0, 'EUR': 0};

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    final monedas = await _db.obtenerTodas();
    if (!mounted) return;

    int total = 0;
    int vendidas = 0;
    final inv = <String, double>{'CUP': 0, 'USD': 0, 'EUR': 0};
    final val = <String, double>{'CUP': 0, 'USD': 0, 'EUR': 0};
    final rec = <String, double>{'CUP': 0, 'USD': 0, 'EUR': 0};

    for (final m in monedas) {
      total++;
      if (m.vendida) vendidas++;

      // Dinero invertido: se suma de TODAS las monedas (compradas).
      if (m.precioCompra != null && m.precioCompra! > 0) {
        final k = _normalizar(m.monedaPrecio);
        inv[k] = (inv[k] ?? 0) + m.precioCompra!;
      }

      // Valor estimado: SOLO de las monedas NO vendidas.
      if (!m.vendida && m.valorEstimado != null && m.valorEstimado! > 0) {
        final k = _normalizar(m.valorEstimadoMoneda);
        val[k] = (val[k] ?? 0) + m.valorEstimado!;
      }

      // Dinero recuperado: solo de las vendidas (que tengan precio de venta).
      if (m.precioVenta != null && m.precioVenta! > 0) {
        final k = _normalizar(m.monedaVenta);
        rec[k] = (rec[k] ?? 0) + m.precioVenta!;
      }
    }

    setState(() {
      _totalMonedas = total;
      _totalVendidas = vendidas;
      _invertido
        ..clear()
        ..addAll(inv);
      _valorEstimado
        ..clear()
        ..addAll(val);
      _recuperado
        ..clear()
        ..addAll(rec);
      _cargando = false;
    });
  }

  static String _normalizar(String m) {
    final u = m.trim().toUpperCase();
    if (u == 'EUR' || u == 'USD' || u == 'CUP') return u;
    return 'CUP';
  }

  static String _fmt(double v) {
    if (v == 0) return '0';
    if (v == v.roundToDouble()) return v.toStringAsFixed(0);
    return v.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Estadísticas')),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _cargar,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
                children: [
                  _BloqueEstadistica(
                    titulo: 'Colección',
                    icono: Icons.inventory_2_outlined,
                    filas: [
                      ('Monedas totales', '$_totalMonedas'),
                      ('Monedas vendidas', '$_totalVendidas'),
                      ('En colección', '${_totalMonedas - _totalVendidas}'),
                    ],
                  ),
                  _BloqueEstadistica(
                    titulo: 'Dinero invertido (compras)',
                    icono: Icons.shopping_bag_outlined,
                    filas: [
                      ('CUP', _fmt(_invertido['CUP'] ?? 0)),
                      ('USD', _fmt(_invertido['USD'] ?? 0)),
                      ('EUR', _fmt(_invertido['EUR'] ?? 0)),
                    ],
                  ),
                  _BloqueEstadistica(
                    titulo: 'Valor estimado actual',
                    icono: Icons.trending_up,
                    filas: [
                      ('CUP', _fmt(_valorEstimado['CUP'] ?? 0)),
                      ('USD', _fmt(_valorEstimado['USD'] ?? 0)),
                      ('EUR', _fmt(_valorEstimado['EUR'] ?? 0)),
                    ],
                  ),
                  _BloqueEstadistica(
                    titulo: 'Dinero recuperado (ventas)',
                    icono: Icons.sell_outlined,
                    filas: [
                      ('CUP', _fmt(_recuperado['CUP'] ?? 0)),
                      ('USD', _fmt(_recuperado['USD'] ?? 0)),
                      ('EUR', _fmt(_recuperado['EUR'] ?? 0)),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      'Las cifras se agrupan por la moneda en la que se registró '
                      'cada operación. No hay conversión entre monedas.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _BloqueEstadistica extends StatelessWidget {
  final String titulo;
  final IconData icono;
  final List<(String, String)> filas;

  const _BloqueEstadistica({
    required this.titulo,
    required this.icono,
    required this.filas,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
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
            const SizedBox(height: 10),
            for (final (etiqueta, valor) in filas)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        etiqueta,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.65),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Text(
                      valor,
                      style: theme.textTheme.titleMedium,
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
