import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../db/database_helper.dart';
import '../models/moneda.dart';
import 'form_screen.dart';

class DetalleScreen extends StatefulWidget {
  final int id;
  const DetalleScreen({super.key, required this.id});

  @override
  State<DetalleScreen> createState() => _DetalleScreenState();
}

class _DetalleScreenState extends State<DetalleScreen> {
  final DatabaseHelper _db = DatabaseHelper.instance;

  Moneda? _moneda;
  bool _cargando = true;
  bool _huboCambios = false;

  final PageController _pageCtrl = PageController();
  int _paginaActual = 0;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  Future<void> _cargar() async {
    final m = await _db.obtenerPorId(widget.id);
    if (!mounted) return;
    setState(() {
      _moneda = m;
      _cargando = false;
      _paginaActual = 0;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_pageCtrl.hasClients) _pageCtrl.jumpToPage(0);
    });
  }

  Future<void> _editar() async {
    final m = _moneda;
    if (m == null) return;
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => FormScreen(moneda: m)),
    );
    if (!mounted) return;
    if (resultado == true) {
      _huboCambios = true;
      await _cargar();
    }
  }

  Future<void> _confirmarEliminar() async {
    final m = _moneda;
    if (m == null || m.id == null) return;

    final confirmado = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar moneda'),
        content: Text(
          '¿Seguro que quieres eliminar esta moneda?\n\n'
          '${m.pais} · ${m.denominacion}'
          '${m.anio.isNotEmpty ? ' (${m.anio})' : ''}\n\n'
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
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmado != true || !mounted) return;
    await _db.eliminar(m.id!);
    if (!mounted) return;
    Navigator.pop(context, true);
  }

  static String _num(double v) {
    if (v == v.roundToDouble()) return v.toStringAsFixed(0);
    return v.toString();
  }

  static String _fecha(DateTime f) => DateFormat('dd/MM/yyyy').format(f);

  static String _precio(double v, String divisa) =>
      '${_num(v)} ${divisa.isEmpty ? '' : divisa}'.trim();

  @override
  Widget build(BuildContext context) {
    if (_cargando) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_moneda == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detalle')),
        body: _NoExiste(onVolver: () => Navigator.pop(context, _huboCambios)),
      );
    }

    final m = _moneda!;

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        Navigator.pop(context, _huboCambios);
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Detalle'),
          actions: [
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'Editar',
              onPressed: _editar,
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Eliminar',
              onPressed: _confirmarEliminar,
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
          children: [
            if (m.vendida) const _BannerVendida(),
            _GaleriaFotos(
              moneda: m,
              pageCtrl: _pageCtrl,
              onPage: (i) {
                if (i != _paginaActual) setState(() => _paginaActual = i);
              },
              paginaActual: _paginaActual,
            ),
            const SizedBox(height: 16),
            _Encabezado(moneda: m),
            const SizedBox(height: 12),
            _BloqueDetalle(
              titulo: 'Identificación',
              icono: Icons.badge_outlined,
              filas: [
                _FilaDato('País', m.pais),
                _FilaDato('Denominación', m.denominacion),
                _FilaDato('Período', m.periodoAcunacion),
                _FilaDato('Año', m.anio),
                _FilaDato('Ceca', m.ceca),
                _FilaDato('KM#', m.kmCatalogo),
                _FilaDato('Metal', m.metal),
                _FilaDato('Pertenece a la ONU', m.perteneceOnu ? 'Sí' : 'No'),
              ],
            ),
            _BloqueDetalle(
              titulo: 'Características físicas',
              icono: Icons.straighten,
              filas: [
                if (m.pesoG != null) _FilaDato('Peso', '${_num(m.pesoG!)} g'),
                if (m.diametroMm != null) _FilaDato('Diámetro', '${_num(m.diametroMm!)} mm'),
                if (m.grosorMm != null) _FilaDato('Grosor', '${_num(m.grosorMm!)} mm'),
                _FilaDato('Forma', m.forma),
                _FilaDato('Canto', m.canto),
              ],
            ),
            _BloqueDetalle(
              titulo: 'Estado y autenticidad',
              icono: Icons.verified_outlined,
              filas: [
                _FilaDato('Grado Sheldon', m.gradoSheldon),
                _FilaDato('Autenticidad', m.autenticidad),
                _FilaDato('Detalles visibles', m.detallesVisibles),
              ],
            ),
            _BloqueDetalle(
              titulo: 'Adquisición y valoración',
              icono: Icons.shopping_bag_outlined,
              filas: [
                if (m.precioCompra != null)
                  _FilaDato('Precio de compra', _precio(m.precioCompra!, m.monedaPrecio)),
                if (m.fechaCompra != null)
                  _FilaDato('Fecha de compra', _fecha(m.fechaCompra!)),
                _FilaDato('Proveedor', m.proveedor),
                _FilaDato('Lugar de compra', m.lugarCompra),
                if (m.valorEstimado != null)
                  _FilaDato('Valor estimado', _precio(m.valorEstimado!, m.monedaPrecio)),
                if (m.precioVenta != null)
                  _FilaDato('Precio de venta', _precio(m.precioVenta!, m.monedaPrecio)),
                if (m.fechaVenta != null)
                  _FilaDato('Fecha de venta', _fecha(m.fechaVenta!)),
              ],
            ),
            _BloqueDetalle(
              titulo: 'Ubicación y notas',
              icono: Icons.inventory_2_outlined,
              filas: [
                _FilaDato('Ubicación', m.ubicacion),
                _FilaDato('Etiquetas', m.etiquetas),
                _FilaDato('Notas', m.notas),
              ],
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

// =====================================================================
// Widgets internos
// =====================================================================

class _BannerVendida extends StatelessWidget {
  const _BannerVendida();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: scheme.outline.withOpacity(0.20),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: scheme.outline.withOpacity(0.6)),
      ),
      child: Row(
        children: [
          Icon(Icons.sell_outlined, color: scheme.onSurface.withOpacity(0.8)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Vendida',
              style: theme.textTheme.titleMedium?.copyWith(
                color: scheme.onSurface.withOpacity(0.9),
                letterSpacing: 0.6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Encabezado extends StatelessWidget {
  final Moneda moneda;
  const _Encabezado({required this.moneda});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final titulo = [
      if (moneda.pais.trim().isNotEmpty) moneda.pais.trim(),
      if (moneda.denominacion.trim().isNotEmpty) moneda.denominacion.trim(),
    ].join(' · ');
    final subtitulo = [
      if (moneda.anio.trim().isNotEmpty) moneda.anio.trim(),
      if (moneda.gradoSheldon.trim().isNotEmpty) moneda.gradoSheldon.trim(),
    ].join(' · ');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titulo.isEmpty ? 'Sin identificar' : titulo,
          style: theme.textTheme.headlineSmall,
        ),
        if (subtitulo.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            subtitulo,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.75),
            ),
          ),
        ],
      ],
    );
  }
}

/// Modelo interno para la galería: empareja ruta con su etiqueta correcta.
class _FotoItem {
  final String ruta;
  final String etiqueta;
  const _FotoItem(this.ruta, this.etiqueta);
}

class _GaleriaFotos extends StatelessWidget {
  final Moneda moneda;
  final PageController pageCtrl;
  final ValueChanged<int> onPage;
  final int paginaActual;

  const _GaleriaFotos({
    required this.moneda,
    required this.pageCtrl,
    required this.onPage,
    required this.paginaActual,
  });

  List<_FotoItem> get _fotos {
    final r = <_FotoItem>[];
    final a = moneda.fotoAnverso;
    final b = moneda.fotoReverso;
    final c = moneda.fotoCanto;
    final d = moneda.fotoKm;
    if (a != null && a.isNotEmpty) r.add(_FotoItem(a, 'Anverso'));
    if (b != null && b.isNotEmpty) r.add(_FotoItem(b, 'Reverso'));
    if (c != null && c.isNotEmpty) r.add(_FotoItem(c, 'Canto'));
    if (d != null && d.isNotEmpty) r.add(_FotoItem(d, 'KM#'));
    return r;
  }

  @override
  Widget build(BuildContext context) {
    final fotos = _fotos;
    if (fotos.isEmpty) return const _PlaceholderFoto();

    if (fotos.length == 1) {
      return _MarcoFoto(child: _FotoConEtiqueta(foto: fotos.first));
    }

    return Column(
      children: [
        SizedBox(
          height: 240,
          child: PageView.builder(
            controller: pageCtrl,
            onPageChanged: onPage,
            itemCount: fotos.length,
            itemBuilder: (_, i) => _MarcoFoto(
              child: _FotoConEtiqueta(foto: fotos[i]),
            ),
          ),
        ),
        const SizedBox(height: 8),
        _Puntitos(total: fotos.length, actual: paginaActual),
      ],
    );
  }
}

class _MarcoFoto extends StatelessWidget {
  final Widget child;
  const _MarcoFoto({required this.child});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: scheme.outline.withOpacity(0.6)),
      ),
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }
}

class _FotoConEtiqueta extends StatelessWidget {
  final _FotoItem foto;
  const _FotoConEtiqueta({required this.foto});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.file(
          File(foto.ruta),
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Center(
            child: Icon(
              Icons.broken_image_outlined,
              size: 56,
              color: scheme.primary.withOpacity(0.6),
            ),
          ),
        ),
        Positioned(
          left: 8,
          bottom: 8,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: scheme.surface.withOpacity(0.85),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: scheme.outline.withOpacity(0.5)),
            ),
            child: Text(foto.etiqueta, style: Theme.of(context).textTheme.labelSmall),
          ),
        ),
      ],
    );
  }
}

class _PlaceholderFoto extends StatelessWidget {
  const _PlaceholderFoto();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      height: 220,
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: scheme.outline.withOpacity(0.6)),
      ),
      child: Center(
        child: Icon(
          Icons.image_outlined,
          size: 64,
          color: scheme.primary.withOpacity(0.55),
        ),
      ),
    );
  }
}

class _Puntitos extends StatelessWidget {
  final int total;
  final int actual;
  const _Puntitos({required this.total, required this.actual});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(total, (i) {
        final activo = i == actual;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: activo ? 18 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: activo ? scheme.primary : scheme.outline.withOpacity(0.5),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}

/// Data class: fila etiqueta/valor. El bloque renderiza solo las no vacías.
class _FilaDato {
  final String etiqueta;
  final String? valor;
  const _FilaDato(this.etiqueta, this.valor);
}

class _BloqueDetalle extends StatelessWidget {
  final String titulo;
  final IconData icono;
  final List<_FilaDato> filas;

  const _BloqueDetalle({
    required this.titulo,
    required this.icono,
    required this.filas,
  });

  @override
  Widget build(BuildContext context) {
    final visibles = filas
        .where((f) => (f.valor?.trim().isNotEmpty ?? false))
        .toList();
    if (visibles.isEmpty) return const SizedBox.shrink();

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
            const SizedBox(height: 10),
            for (final f in visibles)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 130,
                      child: Text(
                        f.etiqueta,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.65),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: SelectableText(f.valor!, style: theme.textTheme.bodyLarge),
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

class _NoExiste extends StatelessWidget {
  final VoidCallback onVolver;
  const _NoExiste({required this.onVolver});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off, size: 72, color: scheme.primary.withOpacity(0.7)),
            const SizedBox(height: 16),
            Text(
              'Esta moneda ya no existe.',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Puede que la hayas eliminado desde otra pantalla.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onVolver,
              icon: const Icon(Icons.arrow_back),
              label: const Text('Volver'),
            ),
          ],
        ),
      ),
    );
  }
}
