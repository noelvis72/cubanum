class Moneda {
  final int? id;
  final String pais;
  final bool perteneceOnu;
  final bool conmemorativa;
  final bool fao;
  final String periodoAcunacion;
  final String denominacion;
  final String anio;
  final bool esHejira;
  final String ceca;
  final String kmCatalogo;
  final int? acunadas;

  final double? pesoG;
  final double? diametroMm;
  final double? grosorMm;
  final String forma;
  final String metal;
  final String ley;
  final String canto;
  final String alineacion;

  final String gradoSheldon;
  final String detallesVisibles;
  final String autenticidad;

  final double? precioCompra;
  final String monedaPrecio;
  final String lugarCompra;
  final DateTime? fechaCompra;
  final double? valorEstimado;
  final String valorEstimadoMoneda;
  final double? precioVenta;
  final String monedaVenta;
  final DateTime? fechaVenta;

  final String? fotoAnverso;
  final String? fotoReverso;
  final String? fotoCanto;
  final String? fotoKm;

  final String notas;
  final String ubicacion;

  Moneda({
    this.id,
    required this.pais,
    required this.perteneceOnu,
    required this.conmemorativa,
    required this.fao,
    required this.periodoAcunacion,
    required this.denominacion,
    required this.anio,
    required this.esHejira,
    required this.ceca,
    required this.kmCatalogo,
    this.acunadas,
    this.pesoG,
    this.diametroMm,
    this.grosorMm,
    required this.forma,
    required this.metal,
    required this.ley,
    required this.canto,
    required this.alineacion,
    required this.gradoSheldon,
    required this.detallesVisibles,
    required this.autenticidad,
    this.precioCompra,
    required this.monedaPrecio,
    required this.lugarCompra,
    this.fechaCompra,
    this.valorEstimado,
    required this.valorEstimadoMoneda,
    this.precioVenta,
    required this.monedaVenta,
    this.fechaVenta,
    this.fotoAnverso,
    this.fotoReverso,
    this.fotoCanto,
    this.fotoKm,
    required this.notas,
    required this.ubicacion,
  });

  factory Moneda.empty() => Moneda(
        id: null,
        pais: '',
        perteneceOnu: false,
        conmemorativa: false,
        fao: false,
        periodoAcunacion: '',
        denominacion: '',
        anio: '',
        esHejira: false,
        ceca: '',
        kmCatalogo: '',
        acunadas: null,
        pesoG: null,
        diametroMm: null,
        grosorMm: null,
        forma: '',
        metal: '',
        ley: '',
        canto: '',
        alineacion: '',
        gradoSheldon: '',
        detallesVisibles: '',
        autenticidad: 'Original',
        precioCompra: null,
        monedaPrecio: 'CUP',
        lugarCompra: '',
        fechaCompra: null,
        valorEstimado: null,
        valorEstimadoMoneda: 'CUP',
        precioVenta: null,
        monedaVenta: 'CUP',
        fechaVenta: null,
        fotoAnverso: null,
        fotoReverso: null,
        fotoCanto: null,
        fotoKm: null,
        notas: '',
        ubicacion: '',
      );

    bool get vendida => precioVenta != null;

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'pais': pais,
        'pertenece_onu': perteneceOnu ? 1 : 0,
        'conmemorativa': conmemorativa ? 1 : 0,
        'fao': fao ? 1 : 0,
        'periodo_acunacion': periodoAcunacion,
        'denominacion': denominacion,
        'anio': anio,
        'es_hejira': esHejira ? 1 : 0,
        'ceca': ceca,
        'km_catalogo': kmCatalogo,
        'acunadas': acunadas,
        'peso_g': pesoG,
        'diametro_mm': diametroMm,
        'grosor_mm': grosorMm,
        'forma': forma,
        'metal': metal,
        'ley': ley,
        'canto': canto,
        'alineacion': alineacion,
        'grado_sheldon': gradoSheldon,
        'detalles_visibles': detallesVisibles,
        'autenticidad': autenticidad,
        'precio_compra': precioCompra,
        'moneda_precio': monedaPrecio,
        'lugar_compra': lugarCompra,
        'fecha_compra': _fechaATexto(fechaCompra),
        'valor_estimado': valorEstimado,
        'valor_estimado_moneda': valorEstimadoMoneda,
        'precio_venta': precioVenta,
        'moneda_venta': monedaVenta,
        'fecha_venta': _fechaATexto(fechaVenta),
        'foto_anverso': fotoAnverso,
        'foto_reverso': fotoReverso,
        'foto_canto': fotoCanto,
        'foto_km': fotoKm,
        'notas': notas,
        'ubicacion': ubicacion,
      };

  factory Moneda.fromMap(Map<String, dynamic> map) => Moneda(
        id: map['id'] as int?,
        pais: (map['pais'] as String?) ?? '',
        perteneceOnu: (map['pertenece_onu'] as int? ?? 0) == 1,
        conmemorativa: (map['conmemorativa'] as int? ?? 0) == 1,
        fao: (map['fao'] as int? ?? 0) == 1,
        periodoAcunacion: (map['periodo_acunacion'] as String?) ?? '',
        denominacion: (map['denominacion'] as String?) ?? '',
        anio: (map['anio'] as String?) ?? '',
        esHejira: (map['es_hejira'] as int? ?? 0) == 1,
        ceca: (map['ceca'] as String?) ?? '',
        kmCatalogo: (map['km_catalogo'] as String?) ?? '',
        acunadas: _aInt(map['acunadas']),
        pesoG: _aDouble(map['peso_g']),
        diametroMm: _aDouble(map['diametro_mm']),
        grosorMm: _aDouble(map['grosor_mm']),
        forma: (map['forma'] as String?) ?? '',
        metal: (map['metal'] as String?) ?? '',
        ley: (map['ley'] as String?) ?? '',
        canto: (map['canto'] as String?) ?? '',
        alineacion: (map['alineacion'] as String?) ?? '',
        gradoSheldon: (map['grado_sheldon'] as String?) ?? '',
        detallesVisibles: (map['detalles_visibles'] as String?) ?? '',
        autenticidad: (map['autenticidad'] as String?) ?? 'Original',
        precioCompra: _aDouble(map['precio_compra']),
        monedaPrecio: (map['moneda_precio'] as String?) ?? 'CUP',
        lugarCompra: (map['lugar_compra'] as String?) ?? '',
        fechaCompra: _aFecha(map['fecha_compra']),
        valorEstimado: _aDouble(map['valor_estimado']),
        valorEstimadoMoneda: (map['valor_estimado_moneda'] as String?) ?? 'CUP',
        precioVenta: _aDouble(map['precio_venta']),
        monedaVenta: (map['moneda_venta'] as String?) ?? 'CUP',
        fechaVenta: _aFecha(map['fecha_venta']),
        fotoAnverso: map['foto_anverso'] as String?,
        fotoReverso: map['foto_reverso'] as String?,
        fotoCanto: map['foto_canto'] as String?,
        fotoKm: map['foto_km'] as String?,
        notas: (map['notas'] as String?) ?? '',
        ubicacion: (map['ubicacion'] as String?) ?? '',
      );

  static int? _aInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is double) return v.toInt();
    if (v is String) return int.tryParse(v);
    return null;
  }

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
    bool? conmemorativa,
    bool? fao,
    String? periodoAcunacion,
    String? denominacion,
    String? anio,
    bool? esHejira,
    String? ceca,
    String? kmCatalogo,
    int? acunadas,
    double? pesoG,
    double? diametroMm,
    double? grosorMm,
    String? forma,
    String? metal,
    String? ley,
    String? canto,
    String? alineacion,
    String? gradoSheldon,
    String? detallesVisibles,
    String? autenticidad,
    double? precioCompra,
    String? monedaPrecio,
    String? lugarCompra,
    DateTime? fechaCompra,
    double? valorEstimado,
    String? valorEstimadoMoneda,
    double? precioVenta,
    String? monedaVenta,
    DateTime? fechaVenta,
    String? fotoAnverso,
    String? fotoReverso,
    String? fotoCanto,
    String? fotoKm,
    String? notas,
    String? ubicacion,
    bool limpiarAcunadas = false,
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
      conmemorativa: conmemorativa ?? this.conmemorativa,
      fao: fao ?? this.fao,
      periodoAcunacion: periodoAcunacion ?? this.periodoAcunacion,
      denominacion: denominacion ?? this.denominacion,
      anio: anio ?? this.anio,
      esHejira: esHejira ?? this.esHejira,
      ceca: ceca ?? this.ceca,
      kmCatalogo: kmCatalogo ?? this.kmCatalogo,
      acunadas: limpiarAcunadas ? null : (acunadas ?? this.acunadas),
      pesoG: limpiarPesoG ? null : (pesoG ?? this.pesoG),
      diametroMm: limpiarDiametroMm ? null : (diametroMm ?? this.diametroMm),
      grosorMm: limpiarGrosorMm ? null : (grosorMm ?? this.grosorMm),
      forma: forma ?? this.forma,
      metal: metal ?? this.metal,
      ley: ley ?? this.ley,
      canto: canto ?? this.canto,
      alineacion: alineacion ?? this.alineacion,
      gradoSheldon: gradoSheldon ?? this.gradoSheldon,
      detallesVisibles: detallesVisibles ?? this.detallesVisibles,
      autenticidad: autenticidad ?? this.autenticidad,
      precioCompra: limpiarPrecioCompra ? null : (precioCompra ?? this.precioCompra),
      monedaPrecio: monedaPrecio ?? this.monedaPrecio,
      lugarCompra: lugarCompra ?? this.lugarCompra,
      fechaCompra: limpiarFechaCompra ? null : (fechaCompra ?? this.fechaCompra),
      valorEstimado: limpiarValorEstimado ? null : (valorEstimado ?? this.valorEstimado),
      valorEstimadoMoneda: valorEstimadoMoneda ?? this.valorEstimadoMoneda,
      precioVenta: limpiarPrecioVenta ? null : (precioVenta ?? this.precioVenta),
      monedaVenta: monedaVenta ?? this.monedaVenta,
      fechaVenta: limpiarFechaVenta ? null : (fechaVenta ?? this.fechaVenta),
      fotoAnverso: limpiarFotoAnverso ? null : (fotoAnverso ?? this.fotoAnverso),
      fotoReverso: limpiarFotoReverso ? null : (fotoReverso ?? this.fotoReverso),
      fotoCanto: limpiarFotoCanto ? null : (fotoCanto ?? this.fotoCanto),
      fotoKm: limpiarFotoKm ? null : (fotoKm ?? this.fotoKm),
      notas: notas ?? this.notas,
      ubicacion: ubicacion ?? this.ubicacion,
    );
  }

  @override
  String toString() =>
      'Moneda(id: $id, pais: $pais, denominacion: $denominacion, '
      'anio: $anio, esHejira: $esHejira, grado: $gradoSheldon)';
}
