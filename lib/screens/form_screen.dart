import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../db/database_helper.dart';
import '../models/moneda.dart';
import 'camara_screen.dart';

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
  late final TextEditingController _acunadasCtrl;
  late final TextEditingController _pesoCtrl;
  late final TextEditingController _diametroCtrl;
  late final TextEditingController _grosorCtrl;
  late final TextEditingController _leyCtrl;
  late final TextEditingController _detallesCtrl;
  late final TextEditingController _precioCompraCtrl;
  late final TextEditingController _lugarCompraCtrl;
  late final TextEditingController _valorEstimadoCtrl;
  late final TextEditingController _precioVentaCtrl;
  late final TextEditingController _ubicacionCtrl;
  late final TextEditingController _notasCtrl;

  bool _perteneceOnu = false;
  bool _conmemorativa = false;
  bool _fao = false;
  String? _paisSeleccionado;
  String? _formaSeleccionada;
  String? _metalSeleccionado;
  String? _cantoSeleccionado;
  String? _alineacionSeleccionada;
  String? _gradoSheldon;
  String _autenticidad = 'Original';
  String _monedaPrecio = 'CUP';
  String _valorEstimadoMoneda = 'CUP';
  String _monedaVenta = 'CUP';

  DateTime? _fechaCompra;
  DateTime? _fechaVenta;

  String? _fotoAnverso;
  String? _fotoReverso;
  String? _fotoCanto;
  String? _fotoKm;

  bool _guardando = false;

  List<String> _paisesPersonalizados = [];
  List<String> _metalesPersonalizados = [];
  List<String> _cantosPersonalizados = [];

  static const _formas = <String>[
    'Redonda', 'Triangular', 'Cuadrada', 'Ovalada', 'Rectangular', 'Múltiples lados',
  ];

  static const _cantos = <String>[
    'Liso', 'Estriado', 'Serrado', 'Epigráfico con leyenda',
    'Estriado interrumpido', 'Reticulado', 'Acanalado', 'En espiguilla',
  ];

  static const _alineaciones = <String>['Medalla', 'Moneda'];

  static const _metalesBase = <String>[
    'Oro', 'Plata', 'Cobre', 'Bronce', 'Latón', 'CuNi', 'Aluminio',
    'Zinc', 'Hierro', 'Platino', 'Bimetálica', 'Trimetálica', 'Acero recubierto',
  ];

  static const _gradosSheldon = <String>[
    'Poor', 'Fair', 'About Good', 'Good', 'Very Good',
    'Fine', 'Very Fine', 'Extremely Fine', 'About Uncirculated', 'Mint State',
  ];

  static const _autenticidades = <String>[
    'Original', 'Falsificación de época', 'Réplica moderna',
  ];

  static const _monedasPrecio = <String>['EUR', 'USD', 'CUP'];

  static const _paisesBase = <String>[
    'Afganistán', 'Albania', 'Alemania', 'Andorra', 'Angola',
    'Antigua y Barbuda', 'Arabia Saudita', 'Argelia', 'Argentina', 'Armenia',
    'Australia', 'Austria', 'Azerbaiyán', 'Bahamas', 'Bangladés',
    'Barbados', 'Baréin', 'Bélgica', 'Belice', 'Benín',
    'Bielorrusia', 'Bolivia', 'Bosnia y Herzegovina', 'Botsuana', 'Brasil',
    'Brunéi', 'Bulgaria', 'Burkina Faso', 'Burundi', 'Bután',
    'Cabo Verde', 'Camboya', 'Camerún', 'Canadá', 'Catar',
    'Chad', 'Chequia', 'Chile', 'China', 'Chipre',
    'Colombia', 'Comoras', 'Corea del Norte', 'Corea del Sur', 'Costa de Marfil',
    'Costa Rica', 'Croacia', 'Cuba', 'Dinamarca', 'Dominica',
    'Ecuador', 'Egipto', 'El Salvador', 'Emiratos Árabes Unidos', 'Eritrea',
    'Eslovaquia', 'Eslovenia', 'España', 'Estados Unidos', 'Estonia',
    'Etiopía', 'Filipinas', 'Finlandia', 'Fiyi', 'Francia',
    'Gabón', 'Gambia', 'Georgia', 'Ghana', 'Granada',
    'Grecia', 'Guatemala', 'Guinea', 'Guinea-Bisáu', 'Guinea Ecuatorial',
    'Guyana', 'Haití', 'Honduras', 'Hungría', 'India',
    'Indonesia', 'Irak', 'Irán', 'Irlanda', 'Islandia',
    'Islas Marshall', 'Islas Salomón', 'Israel', 'Italia', 'Jamaica',
    'Japón', 'Jordania', 'Kazajistán', 'Kenia', 'Kirguistán',
    'Kiribati', 'Kuwait', 'Laos', 'Lesoto', 'Letonia',
    'Líbano', 'Liberia', 'Libia', 'Liechtenstein', 'Lituania',
    'Luxemburgo', 'Macedonia del Norte', 'Madagascar', 'Malasia', 'Malaui',
    'Maldivas', 'Malí', 'Malta', 'Marruecos', 'Mauricio',
    'Mauritania', 'México', 'Micronesia', 'Moldavia', 'Mónaco',
    'Mongolia', 'Montenegro', 'Mozambique', 'Namibia', 'Nauru',
    'Nepal', 'Nicaragua', 'Níger', 'Nigeria', 'Noruega',
    'Nueva Zelanda', 'Omán', 'Países Bajos', 'Pakistán', 'Palaos',
    'Palestina', 'Panamá', 'Papúa Nueva Guinea', 'Paraguay', 'Perú',
    'Polonia', 'Portugal', 'Reino Unido', 'República Centroafricana', 'República del Congo',
    'República Democrática del Congo', 'República Dominicana', 'Ruanda', 'Rumanía', 'Rusia',
    'Samoa', 'San Cristóbal y Nieves', 'San Marino', 'San Vicente y las Granadinas', 'Santa Lucía',
    'Santo Tomé y Príncipe', 'Senegal', 'Serbia', 'Seychelles', 'Sierra Leona',
    'Singapur', 'Siria', 'Somalia', 'Sri Lanka', 'Suazilandia',
    'Sudáfrica', 'Sudán', 'Sudán del Sur', 'Suecia', 'Suiza',
    'Surinam', 'Tailandia', 'Tanzania', 'Tayikistán', 'Timor Oriental',
    'Togo', 'Tonga', 'Trinidad y Tobago', 'Túnez', 'Turkmenistán',
    'Turquía', 'Tuvalu', 'Ucrania', 'Uganda', 'Uruguay',
    'Uzbekistán', 'Vanuatu', 'Vaticano', 'Venezuela', 'Vietnam',
    'Yemen', 'Yibuti', 'Zambia', 'Zimbabue',
    'Antillas Neerlandesas', 'Hong Kong', 'Macao', 'Puerto Rico',
    'Islas Caimán', 'Islas Feroe', 'Groenlandia', 'Gibraltar',
    'Islas Malvinas', 'Nueva Caledonia', 'Polinesia Francesa', 'Reunión',
    'Guadalupe', 'Martinica', 'Guayana Francesa', 'Isla de Man',
    'Jersey', 'Guernsey', 'Islas Vírgenes Británicas', 'Islas Vírgenes de los EE.UU.',
    'Samoa Americana', 'Guam', 'Islas Marianas del Norte', 'Tokelau',
    'Niue', 'Islas Cook', 'Wallis y Futuna', 'San Pedro y Miquelón',
    'Santa Elena', 'Islas Pitcairn', 'Islas Turcas y Caicos', 'Bermudas',
    'Anguila', 'Montserrat', 'Islas Cocos', 'Isla de Navidad',
    'Islas Heard y McDonald', 'Islas Georgias del Sur', 'Somalilandia',
    'Kosovo', 'Taiwán', 'Unión Soviética', 'Yugoslavia', 'Checoslovaquia',
    'Alemania Oriental', 'Alemania Occidental', 'Imperio Austrohúngaro',
    'Imperio Otomano', 'Imperio Romano', 'Imperio Español', 'República de Cuba (1902-1959)',
  ];

  final List<TextInputFormatter> _numFormatters = [
    FilteringTextInputFormatter.allow(RegExp(r'[0-9\.,]')),
  ];

  final List<TextInputFormatter> _intFormatters = [
    FilteringTextInputFormatter.digitsOnly,
  ];

  @override
  void initState() {
    super.initState();
    final m = widget.moneda;

    _paisCtrl          = TextEditingController();
    _periodoCtrl       = TextEditingController(text: m?.periodoAcunacion ?? '');
    _denominacionCtrl  = TextEditingController(text: m?.denominacion ?? '');
    _anioCtrl          = TextEditingController(text: m?.anio ?? '');
    _cecaCtrl          = TextEditingController(text: m?.ceca ?? '');
    _kmCtrl            = TextEditingController(text: m?.kmCatalogo ?? '');
    _metalCtrl         = TextEditingController();
    _acunadasCtrl      = TextEditingController(text: m?.acunadas?.toString() ?? '');
    _pesoCtrl          = TextEditingController(text: _numATexto(m?.pesoG));
    _diametroCtrl      = TextEditingController(text: _numATexto(m?.diametroMm));
    _grosorCtrl        = TextEditingController(text: _numATexto(m?.grosorMm));
    _leyCtrl           = TextEditingController(text: m?.ley ?? '');
    _detallesCtrl      = TextEditingController(text: m?.detallesVisibles ?? '');
    _precioCompraCtrl  = TextEditingController(text: _numATexto(m?.precioCompra));
    _lugarCompraCtrl   = TextEditingController(text: m?.lugarCompra ?? '');
    _valorEstimadoCtrl = TextEditingController(text: _numATexto(m?.valorEstimado));
    _precioVentaCtrl   = TextEditingController(text: _numATexto(m?.precioVenta));
    _ubicacionCtrl     = TextEditingController(text: m?.ubicacion ?? '');
    _notasCtrl         = TextEditingController(text: m?.notas ?? '');

    _perteneceOnu  = m?.perteneceOnu ?? false;
    _conmemorativa = m?.conmemorativa ?? false;
    _fao           = m?.fao ?? false;
    _autenticidad  = (m != null && m.autenticidad.isNotEmpty) ? m.autenticidad : 'Original';
    _monedaPrecio  = (m != null && m.monedaPrecio.isNotEmpty) ? m.monedaPrecio : 'CUP';
    _valorEstimadoMoneda = (m != null && m.valorEstimadoMoneda.isNotEmpty) ? m.valorEstimadoMoneda : 'CUP';
    _monedaVenta = (m != null && m.monedaVenta.isNotEmpty) ? m.monedaVenta : 'CUP';
    _fechaCompra   = m?.fechaCompra;
    _fechaVenta    = m?.fechaVenta;
    _fotoAnverso   = m?.fotoAnverso;
    _fotoReverso   = m?.fotoReverso;
    _fotoCanto     = m?.fotoCanto;
    _fotoKm        = m?.fotoKm;
    _gradoSheldon  = (m != null && m.gradoSheldon.isNotEmpty) ? m.gradoSheldon : null;

    if (m != null) {
      if (_paisesBase.contains(m.pais)) {
        _paisSeleccionado = m.pais;
      } else if (m.pais.isNotEmpty) {
        _paisSeleccionado = m.pais;
      }
      if (_formas.contains(m.forma)) _formaSeleccionada = m.forma;
      if (_metalesBase.contains(m.metal)) {
        _metalSeleccionado = m.metal;
      } else if (m.metal.isNotEmpty) {
        _metalSeleccionado = m.metal;
      }
      if (_cantos.contains(m.canto)) _cantoSeleccionado = m.canto;
      if (m.canto.isNotEmpty) _cantoSeleccionado = m.canto;
      if (_alineaciones.contains(m.alineacion)) _alineacionSeleccionada = m.alineacion;
    }

    _cargarListasPersonalizadas();
  }

  Future<void> _cargarListasPersonalizadas() async {
    final paises = await _db.obtenerPaisesPersonalizados();
    final metales = await _db.obtenerMetalesPersonalizados();
    final cantos = await _db.obtenerCantosPersonalizados();
    if (!mounted) return;
    setState(() {
      _paisesPersonalizados = paises;
      _metalesPersonalizados = metales;
      _cantosPersonalizados = cantos;
    });
  }

  @override
  void dispose() {
    for (final c in [
      _paisCtrl, _periodoCtrl, _denominacionCtrl, _anioCtrl, _cecaCtrl,
      _kmCtrl, _metalCtrl, _acunadasCtrl, _pesoCtrl, _diametroCtrl, _grosorCtrl,
      _leyCtrl, _detallesCtrl, _precioCompraCtrl,
      _lugarCompraCtrl, _valorEstimadoCtrl,
      _precioVentaCtrl, _ubicacionCtrl, _notasCtrl,
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

  static int? _parseInt(String texto) {
    final t = texto.trim();
    if (t.isEmpty) return null;
    return int.tryParse(t);
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

  Future<String?> _pedirTextoNuevo({
    required String titulo,
    required String hint,
  }) async {
    final ctrl = TextEditingController();
    final resultado = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(titulo),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: InputDecoration(hintText: hint),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              final v = ctrl.text.trim();
              Navigator.pop(ctx, v.isEmpty ? null : v);
            },
            child: const Text('Añadir'),
          ),
        ],
      ),
    );
    ctrl.dispose();
    return resultado;
  }

  Future<void> _agregarPaisPersonalizado() async {
    final nombre = await _pedirTextoNuevo(
      titulo: 'Añadir país o territorio',
      hint: 'Ej: Cuba colonial',
    );
    if (nombre == null || !mounted) return;
    await _db.insertarPaisPersonalizado(nombre);
    await _cargarListasPersonalizadas();
    if (!mounted) return;
    setState(() => _paisSeleccionado = nombre);
  }

  Future<void> _agregarMetalPersonalizado() async {
    final nombre = await _pedirTextoNuevo(
      titulo: 'Añadir metal o aleación',
      hint: 'Ej: Cuproníquel dorado',
    );
    if (nombre == null || !mounted) return;
    await _db.insertarMetalPersonalizado(nombre);
    await _cargarListasPersonalizadas();
    if (!mounted) return;
    setState(() => _metalSeleccionado = nombre);
  }

  Future<void> _agregarCantoPersonalizado() async {
    final nombre = await _pedirTextoNuevo(
      titulo: 'Añadir canto',
      hint: 'Ej: Canto con inscripción',
    );
    if (nombre == null || !mounted) return;
    await _db.insertarCantoPersonalizado(nombre);
    await _cargarListasPersonalizadas();
    if (!mounted) return;
    setState(() => _cantoSeleccionado = nombre);
  }

  Future<String?> _elegirYcopiarImagen(ImageSource source) async {
    try {
      final pick = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 2000,
        maxHeight: 2000,
      );
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
    final nueva = await _elegirYcopiarImagen(ImageSource.gallery);
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

  Future<void> _tomarFotoConCamara(String cual) async {
    final ruta = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const CamaraScreen()),
    );
    if (ruta == null || !mounted) return;
    setState(() {
      switch (cual) {
        case 'anverso': _fotoAnverso = ruta; break;
        case 'reverso': _fotoReverso = ruta; break;
        case 'canto':   _fotoCanto   = ruta; break;
        case 'km':      _fotoKm      = ruta; break;
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
    final acunadasVal  = _parseInt(_acunadasCtrl.text);
    final pCompraVal   = _parseNum(_precioCompraCtrl.text);
    final vEstimadoVal = _parseNum(_valorEstimadoCtrl.text);
    final pVentaVal    = _parseNum(_precioVentaCtrl.text);

    final base = widget.moneda ?? Moneda.empty();

    final moneda = base.copyWith(
      pais: (_paisSeleccionado ?? '').trim(),
      perteneceOnu: _perteneceOnu,
      conmemorativa: _conmemorativa,
      fao: _fao,
      periodoAcunacion: _periodoCtrl.text.trim(),
      denominacion: _denominacionCtrl.text.trim(),
      anio: _anioCtrl.text.trim(),
      ceca: _cecaCtrl.text.trim(),
      kmCatalogo: _kmCtrl.text.trim(),
      acunadas: acunadasVal,
      pesoG: pesoVal,
      diametroMm: diametroVal,
      grosorMm: grosorVal,
      forma: _formaSeleccionada ?? '',
      metal: _metalSeleccionado ?? '',
      ley: _leyCtrl.text.trim(),
      canto: _cantoSeleccionado ?? '',
      alineacion: _alineacionSeleccionada ?? '',
      gradoSheldon: _gradoSheldon ?? '',
      detallesVisibles: _detallesCtrl.text.trim(),
      autenticidad: _autenticidad,
      precioCompra: pCompraVal,
      monedaPrecio: _monedaPrecio,
      lugarCompra: _lugarCompraCtrl.text.trim(),
      fechaCompra: _fechaCompra,
      valorEstimado: vEstimadoVal,
      valorEstimadoMoneda: _valorEstimadoMoneda,
      precioVenta: pVentaVal,
      monedaVenta: _monedaVenta,
      fechaVenta: _fechaVenta,
      fotoAnverso: _fotoAnverso,
      fotoReverso: _fotoReverso,
      fotoCanto: _fotoCanto,
      fotoKm: _fotoKm,
      notas: _notasCtrl.text.trim(),
      ubicacion: _ubicacionCtrl.text.trim(),
      limpiarAcunadas: acunadasVal == null,
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

    final paisesCompletos = <String>{
      ..._paisesBase,
      ..._paisesPersonalizados,
      if (_paisSeleccionado != null && _paisSeleccionado!.isNotEmpty) _paisSeleccionado!,
    }.toList()..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

    final metalesCompletos = <String>{
      ..._metalesBase,
      ..._metalesPersonalizados,
      if (_metalSeleccionado != null && _metalSeleccionado!.isNotEmpty) _metalSeleccionado!,
    }.toList()..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

    final cantosCompletos = <String>{
      ..._cantos,
      ..._cantosPersonalizados,
      if (_cantoSeleccionado != null && _cantoSeleccionado!.isNotEmpty) _cantoSeleccionado!,
    }.toList()..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

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
              // ---------------- Identificación ----------------
              _BloqueFormulario(
                titulo: 'Identificación',
                icono: Icons.badge_outlined,
                hijos: [
                  _DropdownConOtro(
                    etiqueta: 'País *',
                    icono: Icons.public,
                    valor: _paisSeleccionado,
                    items: paisesCompletos,
                    onChanged: (v) => setState(() => _paisSeleccionado = v),
                    onAgregarOtro: _agregarPaisPersonalizado,
                    validadorObligatorio: true,
                  ),
                  _TextoForm(
                    controller: _denominacionCtrl,
                    etiqueta: 'Denominación *',
                    icono: Icons.circle_outlined,
                    validadorObligatorio: true,
                  ),
                  _TextoForm(
                    controller: _periodoCtrl,
                    etiqueta: 'Período de acuñación',
                    icono: Icons.history_edu_outlined,
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
                    controller: _acunadasCtrl,
                    etiqueta: 'Acuñadas (unidades)',
                    icono: Icons.numbers,
                    tipoTeclado: const TextInputType.numberWithOptions(decimal: false),
                    formatters: _intFormatters,
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    title: Text('Pertenece a la ONU', style: theme.textTheme.bodyLarge),
                    value: _perteneceOnu,
                    onChanged: (v) => setState(() => _perteneceOnu = v),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    title: Text('Conmemorativa', style: theme.textTheme.bodyLarge),
                    value: _conmemorativa,
                    onChanged: (v) => setState(() => _conmemorativa = v),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    title: Text('FAO', style: theme.textTheme.bodyLarge),
                    value: _fao,
                    onChanged: (v) => setState(() => _fao = v),
                  ),
                ],
              ),

              // ---------------- Características físicas ----------------
              _BloqueFormulario(
                titulo: 'Características físicas',
                icono: Icons.straighten,
                hijos: [
                  _TextoForm(
                    controller: _pesoCtrl,
                    etiqueta: 'Peso (g)',
                    icono: Icons.scale_outlined,
                    tipoTeclado: const TextInputType.numberWithOptions(decimal: true),
                    formatters: _numFormatters,
                  ),
                  _TextoForm(
                    controller: _diametroCtrl,
                    etiqueta: 'Diámetro (mm)',
                    icono: Icons.radio_button_unchecked,
                    tipoTeclado: const TextInputType.numberWithOptions(decimal: true),
                    formatters: _numFormatters,
                  ),
                  _TextoForm(
                    controller: _grosorCtrl,
                    etiqueta: 'Grosor (mm)',
                    icono: Icons.height,
                    tipoTeclado: const TextInputType.numberWithOptions(decimal: true),
                    formatters: _numFormatters,
                  ),
                  _Dropdown<String>(
                    etiqueta: 'Forma',
                    icono: Icons.crop_free,
                    valor: _formaSeleccionada,
                    items: _formas,
                    onChanged: (v) => setState(() => _formaSeleccionada = v),
                  ),
                  _DropdownConOtro(
                    etiqueta: 'Metal',
                    icono: Icons.bolt_outlined,
                    valor: _metalSeleccionado,
                    items: metalesCompletos,
                    onChanged: (v) => setState(() => _metalSeleccionado = v),
                    onAgregarOtro: _agregarMetalPersonalizado,
                    validadorObligatorio: false,
                  ),
                  _TextoForm(
                    controller: _leyCtrl,
                    etiqueta: 'Ley (pureza, ej. 0.900)',
                    icono: Icons.science_outlined,
                    tipoTeclado: const TextInputType.numberWithOptions(decimal: true),
                    formatters: _numFormatters,
                  ),
                  _DropdownConOtro(
                    etiqueta: 'Canto',
                    icono: Icons.line_weight,
                    valor: _cantoSeleccionado,
                    items: cantosCompletos,
                    onChanged: (v) => setState(() => _cantoSeleccionado = v),
                    onAgregarOtro: _agregarCantoPersonalizado,
                    validadorObligatorio: false,
                  ),
                  _Dropdown<String>(
                    etiqueta: 'Alineación',
                    icono: Icons.swap_horiz,
                    valor: _alineacionSeleccionada,
                    items: _alineaciones,
                    onChanged: (v) => setState(() => _alineacionSeleccionada = v),
                  ),
                ],
              ),

              // ---------------- Conservación y autenticidad ----------------
              _BloqueFormulario(
                titulo: 'Conservación y autenticidad',
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
                                .map((e) => DropdownMenuItem<String>(value: e, child: Text(e)))
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

              // ---------------- Adquisición y valoración ----------------
              _BloqueFormulario(
                titulo: 'Adquisición y valoración',
                icono: Icons.shopping_bag_outlined,
                hijos: [
                  _TextoForm(
                    controller: _precioCompraCtrl,
                    etiqueta: 'Precio de compra',
                    icono: Icons.attach_money,
                    tipoTeclado: const TextInputType.numberWithOptions(decimal: true),
                    formatters: _numFormatters,
                  ),
                  _Dropdown<String>(
                    etiqueta: 'Moneda del precio',
                    icono: Icons.currency_exchange,
                    valor: _monedaPrecio,
                    items: _monedasPrecio,
                    onChanged: (v) => setState(() => _monedaPrecio = v ?? 'CUP'),
                  ),
                  _SelectorFecha(
                    etiqueta: 'Fecha de compra',
                    valor: _fechaCompra,
                    onElegir: () async {
                      final f = await _elegirFecha(_fechaCompra);
                      if (f != null && mounted) setState(() => _fechaCompra = f);
                    },
                    onLimpiar: _fechaCompra == null ? null : () => setState(() => _fechaCompra = null),
                  ),
                  _TextoForm(
                    controller: _lugarCompraCtrl,
                    etiqueta: 'Lugar de compra',
                    icono: Icons.place_outlined,
                  ),
                  _TextoForm(
                    controller: _valorEstimadoCtrl,
                    etiqueta: 'Valor estimado',
                    icono: Icons.trending_up,
                    tipoTeclado: const TextInputType.numberWithOptions(decimal: true),
                    formatters: _numFormatters,
                  ),
                  _Dropdown<String>(
                    etiqueta: 'Moneda del valor estimado',
                    icono: Icons.currency_exchange,
                    valor: _valorEstimadoMoneda,
                    items: _monedasPrecio,
                    onChanged: (v) => setState(() => _valorEstimadoMoneda = v ?? 'CUP'),
                  ),
                  const Divider(height: 28),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text('Venta (opcional)', style: theme.textTheme.titleMedium),
                  ),
                  _TextoForm(
                    controller: _precioVentaCtrl,
                    etiqueta: 'Precio de venta',
                    icono: Icons.sell_outlined,
                    tipoTeclado: const TextInputType.numberWithOptions(decimal: true),
                    formatters: _numFormatters,
                  ),
                  _Dropdown<String>(
                    etiqueta: 'Moneda de la venta',
                    icono: Icons.currency_exchange,
                    valor: _monedaVenta,
                    items: _monedasPrecio,
                    onChanged: (v) => setState(() => _monedaVenta = v ?? 'CUP'),
                  ),
                  _SelectorFecha(
                    etiqueta: 'Fecha de venta',
                    valor: _fechaVenta,
                    onElegir: () async {
                      final f = await _elegirFecha(_fechaVenta);
                      if (f != null && mounted) setState(() => _fechaVenta = f);
                    },
                    onLimpiar: _fechaVenta == null ? null : () => setState(() => _fechaVenta = null),
                  ),
                ],
              ),

              // ---------------- Multimedia ----------------
              _BloqueFormulario(
                titulo: 'Multimedia',
                icono: Icons.photo_camera_outlined,
                hijos: [
                  _SelectorImagen(
                    etiqueta: 'Anverso',
                    ruta: _fotoAnverso,
                    onGaleria: () => _seleccionarFoto('anverso'),
                    onCamara: () => _tomarFotoConCamara('anverso'),
                    onQuitar: _fotoAnverso == null ? null : () => _quitarFoto('anverso'),
                  ),
                  _SelectorImagen(
                    etiqueta: 'Reverso',
                    ruta: _fotoReverso,
                    onGaleria: () => _seleccionarFoto('reverso'),
                    onCamara: () => _tomarFotoConCamara('reverso'),
                    onQuitar: _fotoReverso == null ? null : () => _quitarFoto('reverso'),
                  ),
                  _SelectorImagen(
                    etiqueta: 'Canto (opcional)',
                    ruta: _fotoCanto,
                    onGaleria: () => _seleccionarFoto('canto'),
                    onCamara: () => _tomarFotoConCamara('canto'),
                    onQuitar: _fotoCanto == null ? null : () => _quitarFoto('canto'),
                  ),
                  _SelectorImagen(
                    etiqueta: 'KM# (opcional)',
                    ruta: _fotoKm,
                    onGaleria: () => _seleccionarFoto('km'),
                    onCamara: () => _tomarFotoConCamara('km'),
                    onQuitar: _fotoKm == null ? null : () => _quitarFoto('km'),
                  ),
                ],
              ),

              // ---------------- Ubicación y notas ----------------
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
        textInputAction: maxLineas > 1 ? TextInputAction.newline : TextInputAction.next,
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
            .map((e) => DropdownMenuItem<T>(
                  value: e,
                  child: Text('$e', overflow: TextOverflow.ellipsis),
                ))
            .toList(),
        selectedItemBuilder: (context) => items
            .map((e) => Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '$e',
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }
}

class _DropdownConOtro extends StatelessWidget {
  final String etiqueta;
  final IconData icono;
  final String? valor;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  final VoidCallback onAgregarOtro;
  final bool validadorObligatorio;

  const _DropdownConOtro({
    required this.etiqueta,
    required this.icono,
    required this.valor,
    required this.items,
    required this.onChanged,
    required this.onAgregarOtro,
    this.validadorObligatorio = false,
  });

  @override
  Widget build(BuildContext context) {
    final itemsVisibles = <String>[...items, 'OTRO…'];

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<String>(
        value: (valor == null || valor!.isEmpty) ? null : valor,
        isExpanded: true,
        decoration: InputDecoration(labelText: etiqueta, prefixIcon: Icon(icono)),
        items: itemsVisibles
            .map((e) => DropdownMenuItem<String>(
                  value: e,
                  child: Text(
                    e,
                    style: e == 'OTRO…' ? const TextStyle(fontStyle: FontStyle.italic) : null,
                    overflow: TextOverflow.ellipsis,
                  ),
                ))
            .toList(),
        onChanged: (v) {
          if (v == 'OTRO…') {
            onAgregarOtro();
          } else {
            onChanged(v);
          }
        },
        validator: (v) {
          if (!validadorObligatorio) return null;
          if (v == null || v.isEmpty || v == 'OTRO…') return 'Campo obligatorio';
          return null;
        },
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
  final VoidCallback onGaleria;
  final VoidCallback onCamara;
  final VoidCallback? onQuitar;

  const _SelectorImagen({
    required this.etiqueta,
    required this.ruta,
    required this.onGaleria,
    required this.onCamara,
    this.onQuitar,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(etiqueta, style: theme.textTheme.bodyLarge),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
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
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _BotonMini(
                            icono: Icons.photo_library_outlined,
                            etiqueta: ruta == null ? 'Galería' : 'Cambiar',
                            onTap: onGaleria,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: _BotonMini(
                            icono: Icons.photo_camera_outlined,
                            etiqueta: 'Cámara',
                            onTap: onCamara,
                          ),
                        ),
                      ],
                    ),
                    if (onQuitar != null) ...[
                      const SizedBox(height: 6),
                      _BotonMini(
                        icono: Icons.delete_outline,
                        etiqueta: 'Quitar imagen',
                        onTap: onQuitar!,
                        color: scheme.error,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BotonMini extends StatelessWidget {
  final IconData icono;
  final String etiqueta;
  final VoidCallback onTap;
  final Color? color;

  const _BotonMini({
    required this.icono,
    required this.etiqueta,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final colorFinal = color ?? scheme.primary;
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icono, size: 16, color: colorFinal),
      label: Text(
        etiqueta,
        style: TextStyle(fontSize: 12, color: colorFinal),
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        minimumSize: const Size(0, 34),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        side: BorderSide(color: colorFinal.withOpacity(0.5)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
