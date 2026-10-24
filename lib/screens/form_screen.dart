import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../db/database_helper.dart';
import '../models/moneda.dart';

class FormScreen extends StatefulWidget {
  final Moneda? moneda;
  const FormScreen({super.key, this.moneda});
  bool get esEdicion => moneda != null;

  @override
  State<FormScreen> createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();
  final _db = DatabaseHelper.instance;

  late final TextEditingController _paisCtrl;
  late final TextEditingController _periodoCtrl;
  late final TextEditingController _denominacionCtrl;
  late final TextEditingController _anioCtrl;
  late final TextEditingController _cecaCtrl;
  late final TextEditingController _kmCtrl;
  late final TextEditingController _metalCtrl;
  late final TextEditingController _pesoCtrl;
  late final TextEditingController _diametroCtrl;
  late final TextEditingController _grosorCtrl;
  late final TextEditingController _formaCtrl;
  late final TextEditingController _cantoCtrl;
  late final TextEditingController _detallesCtrl;
  late final TextEditingController _precioCompraCtrl;
  late final TextEditingController _proveedorCtrl;
  late final TextEditingController _lugarCompraCtrl;
  late final TextEditingController _valorEstimadoCtrl;
  late final TextEditingController _precioVentaCtrl;
  late final TextEditingController _ubicacionCtrl;
  late final TextEditingController _etiquetasCtrl;
  late final TextEditingController _notasCtrl;

  bool _perteneceOnu = false;
  String? _periodoAcunacion;
  String? _gradoSheldon;
  String _autenticidad = 'Original';
  String _monedaPrecio = 'EUR';
  DateTime? _fechaCompra;
  DateTime? _fechaVenta;
  String? _fotoAnverso;
  String? _fotoReverso;
  String? _fotoCanto;
  String? _fotoKm;
  bool _guardando = false;

  static const _periodos = <String>[
    'Colonial', 'Republicano', 'Medieval', 'Moderno', 'Contemporáneo', 'Otro',
  ];
  static const _gradosSheldon = <String>[
    'Poor', 'Fair', 'About Good', 'Good', 'Very Good',
    'Fine', 'Very Fine', 'Extremely Fine', 'About Uncirculated', 'Mint State',
  ];
  static const _autenticidades = <String>[
    'Original', 'Falsificación de época', 'Réplica moderna',
  ];
  static const _monedasPrecio = <String>['EUR', 'USD', 'CUP'];

  final List<TextInputFormatter> _numFormatters = [
    FilteringTextInputFormatter.allow(RegExp(r'[0-9\.,]')),
  ];

  @override
  void initState() {
    super.initState();
    final m = widget.moneda;

    _paisCtrl          = TextEditingController(text: m?.pais ?? '');
    _periodoCtrl       = TextEditingController();
    _denominacionCtrl  = TextEditingController(text: m?.denominacion ?? '');
    _anioCtrl          = TextEditingController(text: m?.anio ?? '');
    _cecaCtrl          = TextEditingController(text: m?.ceca ?? '');
    _kmCtrl            = TextEditingController(text: m?.kmCatalogo ?? '');
    _metalCtrl         = TextEditingController(text: m?.metal ?? '');
    _pesoCtrl          = TextEditingController(text: _numATexto(m?.pesoG));
    _diametroCtrl      = TextEditingController(text: _numATexto(m?.diametroMm));
    _grosorCtrl        = TextEditingController(text: _numATexto(m?.grosorMm));
    _formaCtrl         = TextEditingController(text: m?.forma ?? '');
    _cantoCtrl         = TextEditingController(text: m?.canto ?? '');
    _detallesCtrl      = TextEditingController(text: m?.detallesVisibles ?? '');
    _precioCompraCtrl  = TextEditingController(text: _numATexto(m?.precioCompra));
    _proveedorCtrl     = TextEditingController(text: m?.proveedor ?? '');
    _lugarCompraCtrl   = TextEditingController(text: m?.lugarCompra ?? '');
    _valorEstimadoCtrl = TextEditingController(text: _numATexto(m?.valorEstimado));
    _precioVentaCtrl   = TextEditingController(text: _numATexto(m?.precioVenta));
    _ubicacionCtrl     = TextEditingController(text: m?.ubicacion ?? '');
    _etiquetasCtrl     = TextEditingController(text: m?.etiquetas ?? '');
    _notasCtrl         = TextEditingController(text: m?.notas ?? '');

    _perteneceOnu = m?.perteneceOnu ?? false;
    _autenticidad = (m != null && m.autenticidad.isNotEmpty) ? m.autenticidad : 'Original';
    _monedaPrecio = (m != null && m.monedaPrecio.isNotEmpty) ? m.monedaPrecio : 'EUR';
    _fechaCompra  = m?.fechaCompra;
    _fechaVenta   = m?.fechaVenta;
    _fotoAnverso  = m?.fotoAnverso;
    _fotoReverso  = m?.fotoReverso;
    _fotoCanto    = m?.fotoCanto;
    _fotoKm       = m?.fotoKm;
    _gradoSheldon = (m != null && m.gradoSheldon.isNotEmpty) ? m.gradoSheldon : null;

    final periodoGuardado = m?.periodoAcunacion ?? '';
    if (_periodos.contains(periodoGuardado)) {
      _periodoAcunacion = periodoGuardado;
    } else if (periodoGuardado.isNotEmpty) {
      _periodoAcunacion = 'Otro';
      _periodoCtrl.text = periodoGuardado;
    }
  }

  @override
  void dispose() {
    for (final c in [
      _paisCtrl, _periodoCtrl, _denominacionCtrl, _anioCtrl, _cecaCtrl,
      _kmCtrl, _metalCtrl, _pesoCtrl, _diametroCtrl, _grosorCtrl,
      _formaCtrl, _cantoCtrl, _detallesCtrl, _precioCompraCtrl,
      _proveedorCtrl, _lugarCompraCtrl, _valorEstimadoCtrl,
      _precioVentaCtrl, _ubicacionCtrl, _etiquetasCtrl, _notasCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  static String _numATexto(double? v) {
    if (v == null) return '';
    if (v == v.roundToDouble()) return v.toStringAsFixed(0);
    return v.toString();
  }

  static double? _parseNum(String texto) {
    final t = texto.trim().replaceAll(',', '.');
    if (t.isEmpty) return null;
    return double.tryParse(t);
  }

  Future<DateTime?> _elegirFecha(DateTime? inicial) async {
    final ahora = DateTime.now();
    final f = await showDatePicker(
      context: context,
      initialDate: inicial ?? ahora,
      firstDate: DateTime(1500),
      lastDate: DateTime(ahora.year + 1),
      helpText: 'Selecciona fecha',
      cancelText: 'Cancelar',
      confirmText: 'Aceptar',
    );
    if (!mounted) return null;
    return f;
  }

  Future<String?> _elegirYcopiarImagen() async {
    try {
      final pick = await _picker.pickImage(source: ImageSource.gallery);
      if (pick == null) return null;
      final dirDocs = await getApplicationDocumentsDirectory();
      final dirFotos = Directory(p.join(dirDocs.path, 'fotos'));
      if (!await dirFotos.exists()) {
        await dirFotos.create(recursive: true);
      }
      final ext = p.extension(pick.path);
      final nombre = '${DateTime.now().microsecondsSinceEpoch}$ext';
      final destino = p.join(dirFotos.path, nombre);
      await File(pick.path).copy(destino);
      return destino;
    } catch (e) {
      if (!mounted) return null;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo cargar la imagen: $e')),
      );
      return null;
    }
  }

  Future<void> _seleccionarFoto(String cual) async {
    final nueva = await _elegirYcopiarImagen();
    if (nueva == null || !mounted) return;
    setState(() {
      switch (cual) {
        case 'anverso': _fotoAnverso = nueva; break;
        case 'reverso': _fotoReverso = nueva; break;
        case 'canto':   _fotoCanto   = nueva; break;
        case 'km':      _fotoKm      = nueva; break;
      }
    });
  }

  void _quitarFoto(String cual) {
    setState(() {
      switch (cual) {
        case 'anverso': _fotoAnverso = null; break;
        case 'reverso': _fotoReverso = null; break;
        case 'canto':   _fotoCanto   = null; break;
        case 'km':      _fotoKm      = null; break;
      }
    });
  }

  Future<void> _guardar() async {
    final okForm = _formKey.currentState?.validate() ?? false;
    if (!okForm) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Revisa los campos marcados en rojo.')),
      );
      return;
    }

    setState(() => _guardando = true);

    final pesoVal      = _parseNum(_pesoCtrl.text);
    final diametroVal  = _parseNum(_diametroCtrl.text);
    final grosorVal    = _parseNum(_grosorCtrl.text);
    final pCompraVal   = _parseNum(_precioCompraCtrl.text);
    final vEstimadoVal = _parseNum(_valorEstimadoCtrl.text);
    final pVentaVal    = _parseNum(_precioVentaCtrl.text);

    final periodoFinal = _periodoAcunacion == 'Otro'
        ? _periodoCtrl.text.trim()
        : (_periodoAcunacion ?? '');

    final base = widget.moneda ?? Moneda.empty();

    final moneda = base.copyWith(
      pais: _paisCtrl.text.trim(),
      perteneceOnu: _perteneceOnu,
      periodoAcunacion: periodoFinal,
      denominacion: _denominacionCtrl.text.trim(),
      anio: _anioCtrl.text.trim(),
      ceca: _cecaCtrl.text.trim(),
      kmCatalogo: _kmCtrl.text.trim(),
      metal: _metalCtrl.text.trim(),
      pesoG: pesoVal,
      diametroMm: diametroVal,
      grosorMm: grosorVal,
      forma: _formaCtrl.text.trim(),
      canto: _cantoCtrl.text.trim(),
      gradoSheldon: _gradoSheldon ?? '',
      detallesVisibles: _detallesCtrl.text.trim(),
      autenticidad: _autenticidad,
      precioCompra: pCompraVal,
      monedaPrecio: _monedaPrecio,
      proveedor: _proveedorCtrl.text.trim(),
      lugarCompra: _lugarCompraCtrl.text.trim(),
      fechaCompra: _fechaCompra,
      valorEstimado: vEstimadoVal,
      precioVenta: pVentaVal,
      fechaVenta: _fechaVenta,
      fotoAnverso: _fotoAnverso,
      fotoReverso: _fotoReverso,
      fotoCanto: _fotoCanto,
      fotoKm: _fotoKm,
      notas: _notasCtrl.text.trim(),
      etiquetas: _etiquetasCtrl.text.trim(),
      ubicacion: _ubicacionCtrl.text.trim(),
      limpiarPesoG: pesoVal == null,
      limpiarDiametroMm: diametroVal == null,
      limpiarGrosorMm: grosorVal == null,
      limpiarPrecioCompra: pCompraVal == null,
      limpiarValorEstimado: vEstimadoVal == null,
      limpiarPrecioVenta: pVentaVal == null,
      limpiarFechaCompra: _fechaCompra == null,
      limpiarFechaVenta: _fechaVenta == null,
      limpiarFotoAnverso: _fotoAnverso == null,
      limpiarFotoReverso: _fotoReverso == null,
      limpiarFotoCanto: _fotoCanto == null,
      limpiarFotoKm: _fotoKm == null,
    );

    try {
      if (widget.esEdicion) {
        await _db.actualizar(moneda);
      } else {
        await _db.insertar(moneda);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _guardando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo guardar: $e')),
      );
      return;
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(widget.esEdicion ? 'Moneda actualizada' : 'Moneda guardada'),
        duration: const Duration(milliseconds: 800),
      ),
    );
    await Future.delayed(const Duration(milliseconds: 250));
    if (!mounted) return;
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final titulo = widget.esEdicion ? 'Editar moneda' : 'Nueva moneda';

    return Scaffold(
      appBar: AppBar(title: Text(titulo)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _guardando ? null : _guardar,
        icon: _guardando
            ? const SizedBox(
                width: 18, height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.save_outlined),
        label: Text(_guardando ? 'Guardando…' : 'Guardar'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 96),
          child: Column(
            children: [
              _BloqueFormulario(
                titulo: 'Identificación',
                icono: Icons.badge_outlined,
                hijos: [
                  _TextoForm(
                    controller: _paisCtrl,
                    etiqueta: 'País *',
                    icono: Icons.public,
                    validadorObligatorio: true,
                  ),
                  _TextoForm(
                    controller: _denominacionCtrl,
                    etiqueta: 'Denominación *',
                    icono: Icons.circle_outlined,
                    validadorObligatorio: true,
                  ),
                  _Dropdown<String>(
                    etiqueta: 'Período de acuñación',
                    icono: Icons.history_edu_outlined,
                    valor: _periodoAcunacion,
                    items: _periodos,
                    onChanged: (v) => setState(() => _periodoAcunacion = v),
                  ),
                  if (_periodoAcunacion == 'Otro')
                    _TextoForm(
                      controller: _periodoCtrl,
                      etiqueta: 'Especifica el período',
                      icono: Icons.edit_outlined,
                    ),
                  _TextoForm(
                    controller: _anioCtrl,
                    etiqueta: 'Año (admite rangos: 1902-1915, c. 1890)',
                    icono: Icons.calendar_today_outlined,
                  ),
                  _TextoForm(
                    controller: _cecaCtrl,
                    etiqueta: 'Ceca',
                    icono: Icons.location_city_outlined,
                  ),
                  _TextoForm(
                    controller: _kmCtrl,
                    etiqueta: 'KM# (catálogo Krause)',
                    icono: Icons.menu_book_outlined,
                  ),
                  _TextoForm(
                    controller: _metalCtrl,
                    etiqueta: 'Metal',
                    icono: Icons.bolt_outlined,
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    title: Text(
                      'Pertenece a la ONU',
                      style: theme.textTheme.bodyLarge,
                    ),
                    value: _perteneceOnu,
                    onChanged: (v) => setState(() => _perteneceOnu = v),
                  ),
                ],
              ),
              _BloqueFormulario(
                titulo: 'Características físicas',
                icono: Icons.straighten,
                hijos: [
                  Row(children: [
                    Expanded(
                      child: _TextoForm(
                        controller: _pesoCtrl,
                        etiqueta: 'Peso (g)',
                        icono: Icons.scale_outlined,
                        tipoTeclado: const TextInputType.numberWithOptions(decimal: true),
                        formatters: _numFormatters,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _TextoForm(
                        controller: _diametroCtrl,
                        etiqueta: 'Diámetro (mm)',
                        icono: Icons.radio_button_unchecked,
                        tipoTeclado: const TextInputType.numberWithOptions(decimal: true),
                        formatters: _numFormatters,
                      ),
                    ),
                  ]),
                  Row(children: [
                    Expanded(
                      child: _TextoForm(
                        controller: _grosorCtrl,
                        etiqueta: 'Grosor (mm)',
                        icono: Icons.height,
                        tipoTeclado: const TextInputType.numberWithOptions(decimal: true),
                        formatters: _numFormatters,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _TextoForm(
                        controller: _formaCtrl,
                        etiqueta: 'Forma',
                        icono: Icons.crop_free,
                      ),
                    ),
                  ]),
                  _TextoForm(
                    controller: _cantoCtrl,
                    etiqueta: 'Canto',
                    icono: Icons.line_weight,
                  ),
                ],
              ),
              _BloqueFormulario(
                titulo: 'Estado y autenticidad',
                icono: Icons.verified_outlined,
                hijos: [
                  FormField<String>(
                    initialValue: _gradoSheldon,
                    validator: (v) {
                      if (v == null || v.isEmpty) {
                        return 'Selecciona un grado Sheldon';
                      }
                      return null;
                    },
                    builder: (state) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          DropdownButtonFormField<String>(
                            value: _gradoSheldon,
                            isExpanded: true,
                            decoration: InputDecoration(
                              labelText: 'Grado Sheldon *',
                              prefixIcon: const Icon(Icons.star_outline),
                              errorText: state.errorText,
                            ),
                            items: _gradosSheldon
                                .map((e) => DropdownMenuItem<String>(
                                      value: e,
                                      child: Text(e),
                                    ))
                                .toList(),
                            onChanged: (v) {
                              setState(() => _gradoSheldon = v);
                              state.didChange(v);
                            },
                          ),
                          const SizedBox(height: 12),
                        ],
                      );
                    },
                  ),
                  _Dropdown<String>(
                    etiqueta: 'Autenticidad',
                    icono: Icons.gavel_outlined,
                    valor: _autenticidad,
                    items: _autenticidades,
                    onChanged: (v) => setState(() => _autenticidad = v ?? 'Original'),
                  ),
                  _TextoForm(
                    controller: _detallesCtrl,
                    etiqueta: 'Detalles visibles',
                    icono: Icons.zoom_in,
                    maxLineas: 3,
                  ),
                ],
              ),
              _BloqueFormulario(
                titulo: 'Adquisición y valoración',
                icono: Icons.shopping_bag_outlined,
                hijos: [
                  Row(children: [
                    Expanded(
                      flex: 2,
                      child: _TextoForm(
                        controller: _precioCompraCtrl,
                        etiqueta: 'Precio de compra',
                        icono: Icons.euro_outlined,
                        tipoTeclado: const TextInputType.numberWithOptions(decimal: true),
                        formatters: _numFormatters,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _Dropdown<String>(
                        etiqueta: 'Moneda',
                        icono: Icons.currency_exchange,
                        valor: _monedaPrecio,
                        items: _monedasPrecio,
                        onChanged: (v) => setState(() => _monedaPrecio = v ?? 'EUR'),
                      ),
                    ),
                  ]),
                  _SelectorFecha(
                    etiqueta: 'Fecha de compra',
                    valor: _fechaCompra,
                    onElegir: () async {
                      final f = await _elegirFecha(_fechaCompra);
                      if (f != null && mounted) {
                        setState(() => _fechaCompra = f);
                      }
                    },
                    onLimpiar: _fechaCompra == null
                        ? null
                        : () => setState(() => _fechaCompra = null),
                  ),
                  _TextoForm(
                    controller: _proveedorCtrl,
                    etiqueta: 'Proveedor',
                    icono: Icons.person_outline,
                  ),
                  _TextoForm(
                    controller: _lugarCompraCtrl,
                    etiqueta: 'Lugar de compra',
                    icono: Icons.place_outlined,
                  ),
                  _TextoForm(
                    controller: _valorEstimadoCtrl,
                    etiqueta: 'Valor estimado actual',
                    icono: Icons.trending_up,
                    tipoTeclado: const TextInputType.numberWithOptions(decimal: true),
                    formatters: _numFormatters,
                  ),
                  const Divider(height: 28),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text('Venta (opcional)', style: theme.textTheme.titleSmall),
                  ),
                  _TextoForm(
                    controller: _precioVentaCtrl,
                    etiqueta: 'Precio de venta',
                    icono: Icons.sell_outlined,
                    tipoTeclado: const TextInputType.numberWithOptions(decimal: true),
                    formatters: _numFormatters,
                  ),
                  _SelectorFecha(
                    etiqueta: 'Fecha de venta',
                    valor: _fechaVenta,
                    onElegir: () async {
                      final f = await _elegirFecha(_fechaVenta);
                      if (f != null && mounted) {
                        setState(() => _fechaVenta = f);
                      }
                    },
                    onLimpiar: _fechaVenta == null
                        ? null
                        : () => setState(() => _fechaVenta = null),
                  ),
                ],
              ),
              _BloqueFormulario(
                titulo: 'Multimedia',
                icono: Icons.photo_camera_outlined,
                hijos: [
                  _SelectorImagen(
                    etiqueta: 'Anverso',
                    ruta: _fotoAnverso,
                    onElegir: () => _seleccionarFoto('anverso'),
                    onQuitar: _fotoAnverso == null ? null : () => _quitarFoto('anverso'),
                  ),
                  _SelectorImagen(
                    etiqueta: 'Reverso',
                    ruta: _fotoReverso,
                    onElegir: () => _seleccionarFoto('reverso'),
                    onQuitar: _fotoReverso == null ? null : () => _quitarFoto('reverso'),
                  ),
                  _SelectorImagen(
                    etiqueta: 'Canto (opcional)',
                    ruta: _fotoCanto,
                    onElegir: () => _seleccionarFoto('canto'),
                    onQuitar: _fotoCanto == null ? null : () => _quitarFoto('canto'),
                  ),
                  _SelectorImagen(
                    etiqueta: 'KM# (opcional)',
                    ruta: _fotoKm,
                    onElegir: () => _seleccionarFoto('km'),
                    onQuitar: _fotoKm == null ? null : () => _quitarFoto('km'),
                  ),
                ],
              ),
              _BloqueFormulario(
                titulo: 'Ubicación y notas',
                icono: Icons.inventory_2_outlined,
                hijos: [
                  _TextoForm(
                    controller: _ubicacionCtrl,
                    etiqueta: 'Ubicación en la colección',
                    icono: Icons.shelves,
                  ),
                  _TextoForm(
                    controller: _etiquetasCtrl,
                    etiqueta: 'Etiquetas (separadas por comas)',
                    icono: Icons.local_offer_outlined,
                  ),
                  _TextoForm(
                    controller: _notasCtrl,
                    etiqueta: 'Notas personales',
                    icono: Icons.notes,
                    maxLineas: 5,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =====================================================================
// Widgets privados
// =====================================================================

class _BloqueFormulario extends StatelessWidget {
  final String titulo;
  final IconData icono;
  final List<Widget> hijos;
  const _BloqueFormulario({
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
            const SizedBox(height: 12),
            ...hijos,
          ],
        ),
      ),
    );
  }
}

class _TextoForm extends StatelessWidget {
  final TextEditingController controller;
  final String etiqueta;
  final IconData icono;
  final int maxLineas;
  final TextInputType? tipoTeclado;
  final List<TextInputFormatter>? formatters;
  final bool validadorObligatorio;

  const _TextoForm({
    required this.controller,
    required this.etiqueta,
    required this.icono,
    this.maxLineas = 1,
    this.tipoTeclado,
    this.formatters,
    this.validadorObligatorio = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        maxLines: maxLineas,
        keyboardType: tipoTeclado,
        inputFormatters: formatters,
        textInputAction:
            maxLineas > 1 ? TextInputAction.newline : TextInputAction.next,
        decoration: InputDecoration(
          labelText: etiqueta,
          prefixIcon: Icon(icono),
          alignLabelWithHint: maxLineas > 1,
        ),
        validator: (v) {
          if (!validadorObligatorio) return null;
          if (v == null || v.trim().isEmpty) return 'Campo obligatorio';
          return null;
        },
      ),
    );
  }
}

class _Dropdown<T> extends StatelessWidget {
  final String etiqueta;
  final IconData icono;
  final T? valor;
  final List<T> items;
  final ValueChanged<T?> onChanged;

  const _Dropdown({
    required this.etiqueta,
    required this.icono,
    required this.valor,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<T>(
        value: valor,
        isExpanded: true,
        decoration: InputDecoration(labelText: etiqueta, prefixIcon: Icon(icono)),
        items: items
            .map((e) => DropdownMenuItem<T>(value: e, child: Text('$e')))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }
}

class _SelectorFecha extends StatelessWidget {
  final String etiqueta;
  final DateTime? valor;
  final VoidCallback onElegir;
  final VoidCallback? onLimpiar;

  const _SelectorFecha({
    required this.etiqueta,
    required this.valor,
    required this.onElegir,
    this.onLimpiar,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fmt = DateFormat('dd/MM/yyyy');
    final texto = valor == null ? 'Sin fecha' : fmt.format(valor!);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onElegir,
        borderRadius: BorderRadius.circular(10),
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: etiqueta,
            prefixIcon: const Icon(Icons.event_outlined),
            suffixIcon: onLimpiar == null
                ? const Icon(Icons.arrow_drop_down)
                : IconButton(
                    icon: const Icon(Icons.clear),
                    tooltip: 'Quitar fecha',
                    onPressed: onLimpiar,
                  ),
          ),
          child: Text(
            texto,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: valor == null
                  ? theme.colorScheme.onSurface.withOpacity(0.6)
                  : theme.colorScheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}

class _SelectorImagen extends StatelessWidget {
  final String etiqueta;
  final String? ruta;
  final VoidCallback onElegir;
  final VoidCallback? onQuitar;

  const _SelectorImagen({
    required this.etiqueta,
    required this.ruta,
    required this.onElegir,
    this.onQuitar,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: scheme.outline.withOpacity(0.6)),
            ),
            clipBehavior: Clip.antiAlias,
            child: ruta == null
                ? Icon(Icons.image_outlined, color: scheme.primary.withOpacity(0.6))
                : Image.file(
                    File(ruta!),
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Icon(
                      Icons.broken_image_outlined,
                      color: scheme.primary.withOpacity(0.6),
                    ),
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(etiqueta, style: theme.textTheme.bodyLarge),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  children: [
                    OutlinedButton.icon(
                      onPressed: onElegir,
                      icon: const Icon(Icons.photo_library_outlined, size: 18),
                      label: Text(ruta == null ? 'Elegir' : 'Cambiar'),
                    ),
                    if (onQuitar != null)
                      TextButton.icon(
                        onPressed: onQuitar,
                        icon: const Icon(Icons.delete_outline, size: 18),
                        label: const Text('Quitar'),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
