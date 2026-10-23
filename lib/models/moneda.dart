class Moneda {
  final int? id;
  final String pais;
  final bool perteneceOnu;
  final String periodoAcunacion;
  final String denominacion;
  final String anio;
  final String ceca;
  final String kmCatalogo;
  final String metal;

  final double? pesoG;
  final double? diametroMm;
  final double? grosorMm;
  final String forma;
  final String canto;

  final String gradoSheldon;
  final String detallesVisibles;
  final String autenticidad;

  final double? precioCompra;
  final String monedaPrecio;
  final String proveedor;
  final String lugarCompra;
  final DateTime? fechaCompra;
  final double? valorEstimado;
  final double? precioVenta;
  final DateTime? fechaVenta;

  final String? fotoAnverso;
  final String? fotoReverso;
  final String? fotoCanto;
  final String? fotoKm;

  final String notas;
  final String etiquetas;
  final String ubicacion;

  Moneda({
    this.id,
    required this.pais,
    required this.perteneceOnu,
    required this.periodoAcunacion,
    required this.denominacion,
    required this.anio,
    required this.ceca,
    required this.kmCatalogo,
    required this.metal,
    this.pesoG,
    this.diametroMm,
    this.grosorMm,
    required this.forma,
    required this.canto,
    required this.gradoSheldon,
    required this.detallesVisibles,
    required this.autenticidad,
    this.precioCompra,
    required this.monedaPrecio,
    required this.proveedor,
    required this.lugarCompra,
    this.fechaCompra,
    this.valorEstimado,
    this.precioVenta,
    this.fechaVenta,
    this.fotoAnverso,
    this.fotoReverso,
    this.fotoCanto,
    this.fotoKm,
    required this.notas,
    required this.etiquetas,
    required this.ubicacion,
  });

  factory Moneda.empty() => Moneda(
        id: null,
        pais: '',
        perteneceOnu: false,
        periodoAcunacion: '',
        denominacion: '',
        anio: '',
        ceca: '',
        kmCatalogo: '',
        metal: '',
        pesoG: null,
        diametroMm: null,
        grosorMm: null,
        forma: '',
        canto: '',
        gradoSheldon: '',
        detallesVisibles: '',
        autenticidad: 'Original',
        precioCompra: null,
        monedaPrecio: 'EUR',
        proveedor: '',
        lugarCompra: '',
        fechaCompra: null,
        valorEstimado: null,
        precioVenta: null,
        fechaVenta: null,
        fotoAnverso: null,
        fotoReverso: null,
        fotoCanto: null,
        fotoKm: null,
        notas: '',
        etiquetas: '',
        ubicacion: '',
      );

  bool get vendida => fechaVenta != null || precioVenta != null;

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'pais': pais,
        'pertenece_onu': perteneceOnu ? 1 : 0,
        'periodo_acunacion': periodoAcunacion,
        'denominacion': denominacion,
        'anio': anio,
        'ceca': ceca,
        'km_catalogo': kmCatalogo,
        'metal': metal,
        'peso_g': pesoG,
        'diametro_mm': diametroMm,
        'grosor_mm': grosorMm,
        'forma': forma,
        'canto': canto,
        'grado_sheldon': gradoSheldon,
        'detalles_visibles': detallesVisibles,
        'autenticidad': autenticidad,
        'precio_compra': precioCompra,
        'moneda_precio': monedaPrecio,
        'proveedor': proveedor,
        'lugar_compra': lugarCompra,
        'fecha_compra': _fechaATexto(fechaCompra),
        'valor_estimado': valorEstimado,
        'precio_venta': precioVenta,
        'fecha_venta': _fechaATexto(fechaVenta),
        'foto_anverso': fotoAnverso,
        'foto_reverso': fotoReverso,
        'foto_canto': fotoCanto,
        'foto_km': fotoKm,
        'notas': notas,
        'etiquetas': etiquetas,
        'ubicacion': ubicacion,
      };

  factory Moneda.fromMap(Map<String, dynamic> map) => Moneda(
        id: map['id'] as int?,
        pais: (map['pais'] as String?) ?? '',
        perteneceOnu: (map['pertenece_onu'] as int? ?? 0) == 1,
        periodoAcunacion: (map['periodo_acunacion'] as String?) ?? '',
        denominacion: (map['denominacion'] as String?) ?? '',
        anio: (map['anio'] as String?) ?? '',
        ceca: (map['ceca'] as String?) ?? '',
        kmCatalogo: (map['km_catalogo'] as String?) ?? '',
        metal: (map['metal'] as String?) ?? '',
        pesoG: _aDouble(map['peso_g']),
        diametroMm: _aDouble(map['diametro_mm']),
        grosorMm: _aDouble(map['grosor_mm']),
        forma: (map['forma'] as String?) ?? '',
        canto: (map['canto'] as String?) ?? '',
        gradoSheldon: (map['grado_sheldon'] as String?) ?? '',
        detallesVisibles: (map['detalles_visibles'] as String?) ?? '',
        autenticidad: (map['autenticidad'] as String?) ?? 'Original',
        precioCompra: _aDouble(map['precio_compra']),
        monedaPrecio: (map['moneda_precio'] as String?) ?? 'EUR',
        proveedor: (map['proveedor'] as String?) ?? '',
        lugarCompra: (map['lugar_compra'] as String?) ?? '',
        fechaCompra: _aFecha(map['fecha_compra']),
        valorEstimado: _aDouble(map['valor_estimado']),
        precioVenta: _aDouble(map['precio_venta']),
        fechaVenta: _aFecha(map['fecha_venta']),
        fotoAnverso: map['foto_anverso'] as String?,
        fotoReverso: map['foto_reverso'] as String?,
        fotoCanto: map['foto_canto'] as String?,
        fotoKm: map['foto_km'] as String?,
        notas: (map['notas'] as String?) ?? '',
        etiquetas: (map['etiquetas'] as String?) ?? '',
        ubicacion: (map['ubicacion'] as String?) ?? '',
      );

  static double? _aDouble(dynamic v) {
    if (v == null) return null;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    if (v is String) return double.tryParse(v);
    return null;
  }

  static DateTime? _aFecha(dynamic v) {
    if (v == null) return null;
    if (v is DateTime) return v;
    if (v is String && v.isNotEmpty) return DateTime.tryParse(v);
    if (v is int) return DateTime.fromMillisecondsSinceEpoch(v);
    return null;
  }

  static String? _fechaATexto(DateTime? f) {
    if (f == null) return null;
    final y = f.year.toString().padLeft(4, '0');
    final m = f.month.toString().padLeft(2, '0');
    final d = f.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  Moneda copyWith({
    int? id,
    String? pais,
    bool? perteneceOnu,
    String? periodoAcunacion,
    String? denominacion,
    String? anio,
    String? ceca,
    String? kmCatalogo,
    String? metal,
    double? pesoG,
    double? diametroMm,
    double? grosorMm,
    String? forma,
    String? canto,
    String? gradoSheldon,
    String? detallesVisibles,
    String? autenticidad,
    double? precioCompra,
    String? monedaPrecio,
    String? proveedor,
    String? lugarCompra,
    DateTime? fechaCompra,
    double? valorEstimado,
    double? precioVenta,
    DateTime? fechaVenta,
    String? fotoAnverso,
    String? fotoReverso,
    String? fotoCanto,
    String? fotoKm,
    String? notas,
    String? etiquetas,
    String? ubicacion,
    bool limpiarPesoG = false,
    bool limpiarDiametroMm = false,
    bool limpiarGrosorMm = false,
    bool limpiarPrecioCompra = false,
    bool limpiarValorEstimado = false,
    bool limpiarPrecioVenta = false,
    bool limpiarFechaCompra = false,
    bool limpiarFechaVenta = false,
    bool limpiarFotoAnverso = false,
    bool limpiarFotoReverso = false,
    bool limpiarFotoCanto = false,
    bool limpiarFotoKm = false,
  }) {
    return Moneda(
      id: id ?? this.id,
      pais: pais ?? this.pais,
      perteneceOnu: perteneceOnu ?? this.perteneceOnu,
      periodoAcunacion: periodoAcunacion ?? this.periodoAcunacion,
      denominacion: denominacion ?? this.denominacion,
      anio: anio ?? this.anio,
      ceca: ceca ?? this.ceca,
      kmCatalogo: kmCatalogo ?? this.kmCatalogo,
      metal: metal ?? this.metal,
      pesoG: limpiarPesoG ? null : (pesoG ?? this.pesoG),
      diametroMm: limpiarDiametroMm ? null : (diametroMm ?? this.diametroMm),
      grosorMm: limpiarGrosorMm ? null : (grosorMm ?? this.grosorMm),
      forma: forma ?? this.forma,
      canto: canto ?? this.canto,
      gradoSheldon: gradoSheldon ?? this.gradoSheldon,
      detallesVisibles: detallesVisibles ?? this.detallesVisibles,
      autenticidad: autenticidad ?? this.autenticidad,
      precioCompra: limpiarPrecioCompra ? null : (precioCompra ?? this.precioCompra),
      monedaPrecio: monedaPrecio ?? this.monedaPrecio,
      proveedor: proveedor ?? this.proveedor,
      lugarCompra: lugarCompra ?? this.lugarCompra,
      fechaCompra: limpiarFechaCompra ? null : (fechaCompra ?? this.fechaCompra),
      valorEstimado: limpiarValorEstimado ? null : (valorEstimado ?? this.valorEstimado),
      precioVenta: limpiarPrecioVenta ? null : (precioVenta ?? this.precioVenta),
      fechaVenta: limpiarFechaVenta ? null : (fechaVenta ?? this.fechaVenta),
      fotoAnverso: limpiarFotoAnverso ? null : (fotoAnverso ?? this.fotoAnverso),
      fotoReverso: limpiarFotoReverso ? null : (fotoReverso ?? this.fotoReverso),
      fotoCanto: limpiarFotoCanto ? null : (fotoCanto ?? this.fotoCanto),
      fotoKm: limpiarFotoKm ? null : (fotoKm ?? this.fotoKm),
      notas: notas ?? this.notas,
      etiquetas: etiquetas ?? this.etiquetas,
      ubicacion: ubicacion ?? this.ubicacion,
    );
  }

  @override
  String toString() =>
      'Moneda(id: $id, pais: $pais, denominacion: $denominacion, '
      'anio: $anio, grado: $gradoSheldon)';
}
