import 'dart:io';
import 'package:flutter/material.dart';
import '../models/moneda.dart';

class MonedaCard extends StatelessWidget {
  final Moneda moneda;
  final VoidCallback onTap;

  const MonedaCard({super.key, required this.moneda, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final titulo = [
      if (moneda.pais.trim().isNotEmpty) moneda.pais.trim(),
      if (moneda.denominacion.trim().isNotEmpty) moneda.denominacion.trim(),
    ].join(' · ');

    final subtitulo = [
      if (moneda.anio.trim().isNotEmpty) moneda.anio.trim(),
      if (moneda.gradoSheldon.trim().isNotEmpty) moneda.gradoSheldon.trim(),
    ].join(' · ');

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              _Miniatura(ruta: moneda.fotoAnverso),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      titulo.isEmpty ? 'Sin identificar' : titulo,
                      style: theme.textTheme.titleLarge,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (subtitulo.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitulo,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurface.withOpacity(0.75),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    if (moneda.vendida) ...[
                      const SizedBox(height: 8),
                      const _ChipVendida(),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.chevron_right, color: scheme.onSurface.withOpacity(0.4)),
            ],
          ),
        ),
      ),
    );
  }
}

class _Miniatura extends StatelessWidget {
  final String? ruta;
  const _Miniatura({required this.ruta});

  static const double _tamano = 64;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    Widget envolver(Widget hijo) => Container(
          width: _tamano,
          height: _tamano,
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: scheme.outline.withOpacity(0.6)),
          ),
          clipBehavior: Clip.antiAlias,
          child: hijo,
        );

    if (ruta == null || ruta!.isEmpty) {
      return envolver(_Placeholder(scheme: scheme));
    }
    return envolver(
      Image.file(
        File(ruta!),
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _Placeholder(scheme: scheme),
      ),
    );
  }
}

class _Placeholder extends StatelessWidget {
  final ColorScheme scheme;
  const _Placeholder({required this.scheme});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Icon(
        Icons.monetization_on_outlined,
        size: 32,
        color: scheme.primary.withOpacity(0.7),
      ),
    );
  }
}

class _ChipVendida extends StatelessWidget {
  const _ChipVendida();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: scheme.outline.withOpacity(0.25),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: scheme.outline.withOpacity(0.7), width: 0.8),
      ),
      child: Text(
        'Vendida',
        style: theme.textTheme.labelSmall?.copyWith(
          color: scheme.onSurface.withOpacity(0.75),
          fontWeight: FontWeight.w600,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}
