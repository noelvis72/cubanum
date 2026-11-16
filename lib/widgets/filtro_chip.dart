import 'package:flutter/material.dart';

/// Chip reutilizable para los filtros del Home.
///
/// Muestra:
///  - Sin selección: solo el nombre del filtro (ej. "País").
///  - Con 1 valor: ese valor (ej. "Cuba").
///  - Con 2-3 valores: "Cuba +2".
///  - Con 4+ valores: "Cuba +5".
///
/// Si [activo] es true, se muestra como seleccionado.
/// Al pulsarlo, se llama a [onTap].
/// Si [onLimpiar] no es null y hay selección, aparece una X para limpiar.
class FiltroChip extends StatelessWidget {
  final String etiqueta;
  final List<String> seleccionados;
  final VoidCallback onTap;
  final VoidCallback? onLimpiar;
  final IconData? icono;

  const FiltroChip({
    super.key,
    required this.etiqueta,
    required this.seleccionados,
    required this.onTap,
    this.onLimpiar,
    this.icono,
  });

  bool get activo => seleccionados.isNotEmpty;

  String get _texto {
    if (seleccionados.isEmpty) return etiqueta;
    if (seleccionados.length == 1) return seleccionados.first;
    final resto = seleccionados.length - 1;
    return '${seleccionados.first} +$resto';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Material(
        color: activo
            ? scheme.primary.withOpacity(0.15)
            : scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: activo
                    ? scheme.primary
                    : scheme.outline.withOpacity(0.5),
                width: activo ? 1.4 : 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icono != null) ...[
                  Icon(
                    icono,
                    size: 16,
                    color: activo ? scheme.primary : scheme.onSurface.withOpacity(0.7),
                  ),
                  const SizedBox(width: 6),
                ],
                Text(
                  _texto,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: activo ? scheme.primary : scheme.onSurface,
                    fontWeight: activo ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
                if (activo && onLimpiar != null) ...[
                  const SizedBox(width: 6),
                  InkWell(
                    onTap: onLimpiar,
                    borderRadius: BorderRadius.circular(10),
                    child: Icon(
                      Icons.close,
                      size: 16,
                      color: scheme.primary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
