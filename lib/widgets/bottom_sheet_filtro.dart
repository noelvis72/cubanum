import 'package:flutter/material.dart';

/// Bottom sheet reutilizable para seleccionar múltiples opciones de una lista.
Future<List<String>?> mostrarBottomSheetSeleccionMultiple({
  required BuildContext context,
  required String titulo,
  required List<MapEntry<String, int>> opciones,
  required List<String> seleccionadosIniciales,
  bool mostrarBuscador = true,
}) async {
  final seleccionados = <String>{...seleccionadosIniciales};
  String filtro = '';

  final resultado = await showModalBottomSheet<List<String>>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
      final theme = Theme.of(ctx);
      final scheme = theme.colorScheme;

      return StatefulBuilder(
        builder: (ctx, setSheetState) {
          final opcionesFiltradas = opciones
              .where((e) =>
                  filtro.isEmpty ||
                  e.key.toLowerCase().contains(filtro.toLowerCase()))
              .toList();

          final totalVisibles = opcionesFiltradas.length;
          final marcadosVisibles =
              opcionesFiltradas.where((e) => seleccionados.contains(e.key)).length;
          bool? estadoCheckbox;
          if (marcadosVisibles == 0) {
            estadoCheckbox = false;
          } else if (marcadosVisibles == totalVisibles) {
            estadoCheckbox = true;
          } else {
            estadoCheckbox = null;
          }

          void toggleTodos() {
            setSheetState(() {
              if (estadoCheckbox == true) {
                for (final op in opcionesFiltradas) {
                  seleccionados.remove(op.key);
                }
              } else {
                for (final op in opcionesFiltradas) {
                  seleccionados.add(op.key);
                }
              }
            });
          }

          return Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(ctx).size.height * 0.75,
            ),
            decoration: BoxDecoration(
              color: scheme.surface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 8, bottom: 4),
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: scheme.outline.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 4, 16, 8),
                  child: Row(
                    children: [
                      Checkbox(
                        tristate: true,
                        value: estadoCheckbox,
                        onChanged: (_) => toggleTodos(),
                      ),
                      Expanded(
                        child: Text(titulo, style: theme.textTheme.titleLarge),
                      ),
                      if (seleccionados.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: Text(
                            '${seleccionados.length} sel.',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: scheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                if (mostrarBuscador && opciones.length > 8)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Buscar…',
                        prefixIcon: const Icon(Icons.search, size: 20),
                        isDense: true,
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onChanged: (v) => setSheetState(() => filtro = v),
                    ),
                  ),
                const SizedBox(height: 8),
                Flexible(
                  child: opcionesFiltradas.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text('Sin opciones', style: theme.textTheme.bodyMedium),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          itemCount: opcionesFiltradas.length,
                          itemBuilder: (_, i) {
                            final op = opcionesFiltradas[i];
                            final sel = seleccionados.contains(op.key);
                            return CheckboxListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                              title: Text(op.key),
                              subtitle: Text('${op.value}'),
                              value: sel,
                              dense: true,
                              onChanged: (v) {
                                setSheetState(() {
                                  if (v == true) {
                                    seleccionados.add(op.key);
                                  } else {
                                    seleccionados.remove(op.key);
                                  }
                                });
                              },
                            );
                          },
                        ),
                ),
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, null),
                        child: const Text('Cancelar'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(ctx, seleccionados.toList()),
                        child: const Text('Aplicar'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );

  return resultado;
}

/// Bottom sheet para el chip "Año" (rango numérico).
Future<(int?, int?)?> mostrarBottomSheetRangoAnio({
  required BuildContext context,
  required int? desdeInicial,
  required int? hastaInicial,
}) async {
  final desdeCtrl = TextEditingController(text: desdeInicial?.toString() ?? '');
  final hastaCtrl = TextEditingController(text: hastaInicial?.toString() ?? '');
  String? error;

  final resultado = await showModalBottomSheet<(int?, int?)>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
      final theme = Theme.of(ctx);
      final scheme = theme.colorScheme;

      return Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Container(
              decoration: BoxDecoration(
                color: scheme.surface,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 8, bottom: 4),
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: scheme.outline.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text('Rango de años', style: theme.textTheme.titleLarge),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: desdeCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Desde',
                              hintText: 'Ej. 1900',
                              prefixIcon: Icon(Icons.arrow_downward, size: 18),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: hastaCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Hasta',
                              hintText: 'Ej. 1990',
                              prefixIcon: Icon(Icons.arrow_upward, size: 18),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (error != null)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                      child: Text(error!,
                          style: theme.textTheme.bodySmall?.copyWith(color: scheme.error)),
                    ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, null),
                          child: const Text('Cancelar'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () {
                            final d = desdeCtrl.text.trim().isEmpty
                                ? null
                                : int.tryParse(desdeCtrl.text.trim());
                            final h = hastaCtrl.text.trim().isEmpty
                                ? null
                                : int.tryParse(hastaCtrl.text.trim());

                            if (desdeCtrl.text.trim().isNotEmpty && d == null) {
                              setSheetState(() => error = 'Año "Desde" inválido');
                              return;
                            }
                            if (hastaCtrl.text.trim().isNotEmpty && h == null) {
                              setSheetState(() => error = 'Año "Hasta" inválido');
                              return;
                            }
                            if (d != null && (d < 1 || d > 9999)) {
                              setSheetState(() => error = 'Año "Desde" fuera de rango');
                              return;
                            }
                            if (h != null && (h < 1 || h > 9999)) {
                              setSheetState(() => error = 'Año "Hasta" fuera de rango');
                              return;
                            }
                            if (d != null && h != null && d > h) {
                              setSheetState(() =>
                                  error = '"Desde" no puede ser mayor que "Hasta"');
                              return;
                            }
                            if (d == null && h == null) {
                              Navigator.pop(ctx, (null, null));
                              return;
                            }
                            Navigator.pop(ctx, (d, h));
                          },
                          child: const Text('Aplicar'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );
    },
  );

  desdeCtrl.dispose();
  hastaCtrl.dispose();
  return resultado;
}

/// Bottom sheet para seleccionar UNA sola opción de una lista.
/// Devuelve la opción seleccionada, o null si cancela.
Future<String?> mostrarBottomSheetSeleccionUnica({
  required BuildContext context,
  required String titulo,
  required List<String> opciones,
  String? seleccionadoInicial,
  String? textoOtro,
  VoidCallback? onAgregarOtro,
}) async {
  String filtro = '';

  final resultado = await showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
      final theme = Theme.of(ctx);
      final scheme = theme.colorScheme;

      return StatefulBuilder(
        builder: (ctx, setSheetState) {
          final opcionesFiltradas = opciones
              .where((e) =>
                  filtro.isEmpty || e.toLowerCase().contains(filtro.toLowerCase()))
              .toList();

          return Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(ctx).size.height * 0.75,
            ),
            decoration: BoxDecoration(
              color: scheme.surface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 8, bottom: 4),
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: scheme.outline.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(titulo, style: theme.textTheme.titleLarge),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Buscar…',
                      prefixIcon: const Icon(Icons.search, size: 20),
                      isDense: true,
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onChanged: (v) => setSheetState(() => filtro = v),
                  ),
                ),
                const SizedBox(height: 8),
                Flexible(
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      ...opcionesFiltradas.map((op) {
                        final sel = op == seleccionadoInicial;
                        return ListTile(
                          title: Text(op),
                          trailing: sel
                              ? Icon(Icons.check, color: scheme.primary)
                              : null,
                          selected: sel,
                          onTap: () => Navigator.pop(ctx, op),
                        );
                      }),
                      if (onAgregarOtro != null)
                        ListTile(
                          leading: const Icon(Icons.add),
                          title: Text(
                            textoOtro ?? 'Añadir nuevo…',
                            style: const TextStyle(fontStyle: FontStyle.italic),
                          ),
                          onTap: () {
                            Navigator.pop(ctx);
                            onAgregarOtro();
                          },
                        ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, null),
                        child: const Text('Cancelar'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );

  return resultado;
}
