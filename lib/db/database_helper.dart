import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../models/moneda.dart';

class DatabaseHelper {
  DatabaseHelper._();
  static final DatabaseHelper instance = DatabaseHelper._();

  static const String _dbNombre = 'cubanum.db';
  static const int _dbVersion = 8;
  static const String tablaMonedas = 'monedas';
  static const String tablaPaises = 'paises_personalizados';
  static const String tablaMetales = 'metales_personalizados';
  static const String tablaCantos = 'cantos_personalizados';
  static const String tablaAcabados = 'acabados_personalizados';
  static const String tablaVentas = 'ventas';

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dir = await getApplicationDocumentsDirectory();
    final ruta = p.join(dir.path, _dbNombre);
    return openDatabase(
      ruta,
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      onConfigure: _onConfigure,
    );
  }

  Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tablaMonedas (
        id                            INTEGER PRIMARY KEY AUTOINCREMENT,
        pais                          TEXT    NOT NULL DEFAULT '',
        pertenece_onu                 INTEGER NOT NULL DEFAULT 0,
        conmemorativa                 INTEGER NOT NULL DEFAULT 0,
        fao                           INTEGER NOT NULL DEFAULT 0,
        periodo_acunacion             TEXT    NOT NULL DEFAULT '',
        denominacion                  TEXT    NOT NULL DEFAULT '',
        anio                          TEXT    NOT NULL DEFAULT '',
        es_hejira                     INTEGER NOT NULL DEFAULT 0,
        ceca                          TEXT    NOT NULL DEFAULT '',
        km_catalogo                   TEXT    NOT NULL DEFAULT '',
        acunadas                      INTEGER,
        peso_g                        REAL,
        diametro_mm                   REAL,
        grosor_mm                     REAL,
        forma                         TEXT    NOT NULL DEFAULT '',
        metal                         TEXT    NOT NULL DEFAULT '',
        ley                           TEXT    NOT NULL DEFAULT '',
        canto                         TEXT    NOT NULL DEFAULT '',
        alineacion                    TEXT    NOT NULL DEFAULT '',
        resellada                     INTEGER NOT NULL DEFAULT 0,
        contramarcada                 INTEGER NOT NULL DEFAULT 0,
        notas_resello_contramarca     TEXT    NOT NULL DEFAULT '',
        acabado                       TEXT    NOT NULL DEFAULT '',
        variante                      INTEGER NOT NULL DEFAULT 0,
        notas_variante                TEXT    NOT NULL DEFAULT '',
        grado_sheldon                 TEXT    NOT NULL DEFAULT '',
        detalles_visibles             TEXT    NOT NULL DEFAULT '',
        autenticidad                  TEXT    NOT NULL DEFAULT 'Original',
        precio_compra                 REAL,
        moneda_precio                 TEXT    NOT NULL DEFAULT 'CUP',
        lugar_compra                  TEXT    NOT NULL DEFAULT '',
        fecha_compra                  TEXT,
        valor_estimado                REAL,
        valor_estimado_moneda         TEXT    NOT NULL DEFAULT 'CUP',
        precio_venta                  REAL,
        moneda_venta                  TEXT    NOT NULL DEFAULT 'CUP',
        fecha_venta                   TEXT,
        foto_anverso                  TEXT,
        foto_reverso                  TEXT,
        foto_canto                    TEXT,
        foto_km                       TEXT,
        notas                         TEXT    NOT NULL DEFAULT '',
        ubicacion                     TEXT    NOT NULL DEFAULT ''
      )
    ''');

    await db.execute('''
      CREATE TABLE $tablaPaises (
        id     INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL UNIQUE
      )
    ''');

    await db.execute('''
      CREATE TABLE $tablaMetales (
        id     INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL UNIQUE
      )
    ''');

    await db.execute('''
      CREATE TABLE $tablaCantos (
        id     INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL UNIQUE
      )
    ''');

    await db.execute('''
      CREATE TABLE $tablaAcabados (
        id     INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL UNIQUE
      )
    ''');

    await db.execute('''
      CREATE TABLE $tablaVentas (
        id             INTEGER PRIMARY KEY AUTOINCREMENT,
        id_moneda      INTEGER,
        descripcion    TEXT NOT NULL DEFAULT '',
        precio         REAL NOT NULL DEFAULT 0,
        moneda         TEXT NOT NULL DEFAULT 'CUP',
        fecha_venta    TEXT
      )
    ''');

    await db.execute('CREATE INDEX idx_monedas_pais ON $tablaMonedas(pais)');
    await db.execute('CREATE INDEX idx_monedas_denominacion ON $tablaMonedas(denominacion)');
    await db.execute('CREATE INDEX idx_monedas_anio ON $tablaMonedas(anio)');
    await db.execute('CREATE INDEX idx_monedas_km ON $tablaMonedas(km_catalogo)');
    await db.execute('CREATE INDEX idx_monedas_metal ON $tablaMonedas(metal)');
    await db.execute('CREATE INDEX idx_monedas_autenticidad ON $tablaMonedas(autenticidad)');
    await db.execute('CREATE INDEX idx_monedas_forma ON $tablaMonedas(forma)');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE $tablaMonedas ADD COLUMN conmemorativa INTEGER NOT NULL DEFAULT 0');
      await db.execute('ALTER TABLE $tablaMonedas ADD COLUMN fao INTEGER NOT NULL DEFAULT 0');
      await db.execute('ALTER TABLE $tablaMonedas ADD COLUMN acunadas INTEGER');
      await db.execute('ALTER TABLE $tablaMonedas ADD COLUMN ley TEXT NOT NULL DEFAULT ""');
      await db.execute('ALTER TABLE $tablaMonedas ADD COLUMN alineacion TEXT NOT NULL DEFAULT ""');
      await db.execute('ALTER TABLE $tablaMonedas ADD COLUMN valor_estimado_moneda TEXT NOT NULL DEFAULT "CUP"');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS $tablaPaises (
          id     INTEGER PRIMARY KEY AUTOINCREMENT,
          nombre TEXT NOT NULL UNIQUE
        )
      ''');
      await db.execute('''
        CREATE TABLE IF NOT EXISTS $tablaMetales (
          id     INTEGER PRIMARY KEY AUTOINCREMENT,
          nombre TEXT NOT NULL UNIQUE
        )
      ''');
    }

    if (oldVersion < 3) {
      await db.execute('ALTER TABLE $tablaMonedas ADD COLUMN moneda_venta TEXT NOT NULL DEFAULT "CUP"');
    }

    if (oldVersion < 4) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS $tablaCantos (
          id     INTEGER PRIMARY KEY AUTOINCREMENT,
          nombre TEXT NOT NULL UNIQUE
        )
      ''');
    }

    if (oldVersion < 5) {
      await db.execute('ALTER TABLE $tablaMonedas ADD COLUMN es_hejira INTEGER NOT NULL DEFAULT 0');
    }

    if (oldVersion < 6) {
      await db.execute('ALTER TABLE $tablaMonedas ADD COLUMN resellada INTEGER NOT NULL DEFAULT 0');
      await db.execute('CREATE INDEX IF NOT EXISTS idx_monedas_metal ON $tablaMonedas(metal)');
      await db.execute('CREATE INDEX IF NOT EXISTS idx_monedas_autenticidad ON $tablaMonedas(autenticidad)');
      await db.execute('CREATE INDEX IF NOT EXISTS idx_monedas_forma ON $tablaMonedas(forma)');
    }

    if (oldVersion < 7) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS $tablaVentas (
          id             INTEGER PRIMARY KEY AUTOINCREMENT,
          id_moneda      INTEGER,
          descripcion    TEXT NOT NULL DEFAULT '',
          precio         REAL NOT NULL DEFAULT 0,
          moneda         TEXT NOT NULL DEFAULT 'CUP',
          fecha_venta    TEXT
        )
      ''');

      final vendidas = await db.query(
        tablaMonedas,
        where: 'precio_venta IS NOT NULL',
      );
      for (final row in vendidas) {
        final m = Moneda.fromMap(row);
        await db.insert(tablaVentas, {
          'id_moneda': m.id,
          'descripcion': '${m.pais} · ${m.denominacion} · ${m.anio}',
          'precio': m.precioVenta ?? 0,
          'moneda': m.monedaVenta,
          'fecha_venta': m.fechaVenta?.toIso8601String(),
        });
      }
    }

    if (oldVersion < 8) {
      await db.execute('ALTER TABLE $tablaMonedas ADD COLUMN contramarcada INTEGER NOT NULL DEFAULT 0');
      await db.execute('ALTER TABLE $tablaMonedas ADD COLUMN notas_resello_contramarca TEXT NOT NULL DEFAULT ""');
      await db.execute('ALTER TABLE $tablaMonedas ADD COLUMN acabado TEXT NOT NULL DEFAULT ""');
      await db.execute('ALTER TABLE $tablaMonedas ADD COLUMN variante INTEGER NOT NULL DEFAULT 0');
      await db.execute('ALTER TABLE $tablaMonedas ADD COLUMN notas_variante TEXT NOT NULL DEFAULT ""');
      await db.execute('''
        CREATE TABLE IF NOT EXISTS $tablaAcabados (
          id     INTEGER PRIMARY KEY AUTOINCREMENT,
          nombre TEXT NOT NULL UNIQUE
        )
      ''');
    }
  }

  // ---------------- Monedas ----------------

  Future<int> insertar(Moneda moneda) async {
    final db = await database;
    final map = moneda.toMap()..remove('id');
    final id = await db.insert(tablaMonedas, map);
    if (moneda.precioVenta != null) {
      await db.insert(tablaVentas, {
        'id_moneda': id,
        'descripcion': '${moneda.pais} · ${moneda.denominacion} · ${moneda.anio}',
        'precio': moneda.precioVenta,
        'moneda': moneda.monedaVenta,
        'fecha_venta': moneda.fechaVenta?.toIso8601String(),
      });
    }
    return id;
  }

  Future<int> actualizar(Moneda moneda) async {
    if (moneda.id == null) {
      throw ArgumentError('No se puede actualizar una moneda sin id.');
    }
    final db = await database;

    await db.delete(tablaVentas, where: 'id_moneda = ?', whereArgs: [moneda.id]);

    final filas = await db.update(
      tablaMonedas,
      moneda.toMap(),
      where: 'id = ?',
      whereArgs: [moneda.id],
    );

    if (moneda.precioVenta != null) {
      await db.insert(tablaVentas, {
        'id_moneda': moneda.id,
        'descripcion': '${moneda.pais} · ${moneda.denominacion} · ${moneda.anio}',
        'precio': moneda.precioVenta,
        'moneda': moneda.monedaVenta,
        'fecha_venta': moneda.fechaVenta?.toIso8601String(),
      });
    }

    return filas;
  }

  Future<int> eliminar(int id) async {
    final db = await database;
    return db.delete(tablaMonedas, where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Moneda>> obtenerTodas() async {
    final db = await database;
    final rows = await db.query(
      tablaMonedas,
      orderBy: 'pais COLLATE NOCASE ASC, anio ASC, denominacion COLLATE NOCASE ASC',
    );
    return rows.map(Moneda.fromMap).toList();
  }

  Future<Moneda?> obtenerPorId(int id) async {
    final db = await database;
    final rows = await db.query(
      tablaMonedas,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return Moneda.fromMap(rows.first);
  }

  Future<List<Moneda>> buscar(String query) async {
    final q = query.trim();
    if (q.isEmpty) return obtenerTodas();
    final db = await database;
    final like = '%$q%';
    final qLower = q.toLowerCase();

    final quiereConmemorativa = qLower == 'conmemorativa' ||
        qLower == 'conmemorativas' ||
        qLower == 'conmemorativo';
    final quiereFao = qLower == 'fao';
    final quiereAh = qLower == 'ah' ||
        qLower == 'hegira' ||
        qLower == 'hégira' ||
        qLower == 'hejira' ||
        qLower == 'islamica' ||
        qLower == 'islámica';
    final quiereVendidas = qLower == 'vendida' ||
        qLower == 'vendidas' ||
        qLower == 'vendido' ||
        qLower == 'vendidos';
    final quiereReselladas = qLower == 'resellada' ||
        qLower == 'reselladas' ||
        qLower == 'resellado' ||
        qLower == 'resellados' ||
        qLower == 'resello' ||
        qLower == 'resellos';
    final quiereContramarcadas = qLower == 'contramarcada' ||
        qLower == 'contramarcadas' ||
        qLower == 'contramarca' ||
        qLower == 'contramarcas';

    final condiciones = <String>[
      'pais              LIKE ?',
      'denominacion      LIKE ?',
      'anio              LIKE ?',
      'km_catalogo       LIKE ?',
      'ceca              LIKE ?',
      'metal             LIKE ?',
      'grado_sheldon     LIKE ?',
      'periodo_acunacion LIKE ?',
      'forma             LIKE ?',
      'canto             LIKE ?',
      'acabado           LIKE ?',
      'autenticidad      LIKE ?',
      'lugar_compra      LIKE ?',
      'ubicacion         LIKE ?',
    ];
    final args = <Object?>[
      like, like, like, like, like, like, like, like, like, like, like,
      like, like, like,
    ];

    if (quiereConmemorativa) condiciones.add('conmemorativa = 1');
    if (quiereFao) condiciones.add('fao = 1');
    if (quiereAh) condiciones.add('es_hejira = 1');
    if (quiereVendidas) condiciones.add('precio_venta IS NOT NULL');
    if (quiereReselladas) condiciones.add('resellada = 1');
    if (quiereContramarcadas) condiciones.add('contramarcada = 1');

    final rows = await db.query(
      tablaMonedas,
      where: condiciones.join(' OR '),
      whereArgs: args,
      orderBy: 'pais COLLATE NOCASE ASC, anio ASC, denominacion COLLATE NOCASE ASC',
    );
    return rows.map(Moneda.fromMap).toList();
  }

  Future<int> contar() async {
    final db = await database;
    final res = await db.rawQuery('SELECT COUNT(*) AS c FROM $tablaMonedas');
    return (res.first['c'] as int?) ?? 0;
  }

  Future<int> contarVendidas() async {
    final db = await database;
    final res = await db.rawQuery(
      'SELECT COUNT(*) AS c FROM $tablaMonedas WHERE precio_venta IS NOT NULL',
    );
    return (res.first['c'] as int?) ?? 0;
  }

  Future<void> vaciar() async {
    final db = await database;
    await db.delete(tablaMonedas);
  }

  Future<int> eliminarVendidas() async {
    final db = await database;
    final rows = await db.query(
      tablaMonedas,
      columns: ['id', 'foto_anverso', 'foto_reverso', 'foto_canto', 'foto_km'],
      where: 'precio_venta IS NOT NULL',
    );

    for (final row in rows) {
      for (final col in ['foto_anverso', 'foto_reverso', 'foto_canto', 'foto_km']) {
        final ruta = row[col] as String?;
        if (ruta != null && ruta.isNotEmpty) {
          final archivo = File(ruta);
          if (await archivo.exists()) {
            try {
              await archivo.delete();
            } catch (_) {}
          }
        }
      }
    }

    return db.delete(tablaMonedas, where: 'precio_venta IS NOT NULL');
  }

  // ---------------- Ventas ----------------

  Future<List<Map<String, dynamic>>> obtenerVentas() async {
    final db = await database;
    return db.query(tablaVentas, orderBy: 'fecha_venta DESC');
  }

  Future<Map<String, double>> totalRecuperadoPorMoneda() async {
    final db = await database;
    final rows = await db.rawQuery('''
      SELECT moneda, SUM(precio) AS total
      FROM $tablaVentas
      GROUP BY moneda
    ''');
    final map = <String, double>{'CUP': 0, 'USD': 0, 'EUR': 0};
    for (final row in rows) {
      final k = (row['moneda'] as String?) ?? 'CUP';
      final v = (row['total'] as num?)?.toDouble() ?? 0;
      map[k] = (map[k] ?? 0) + v;
    }
    return map;
  }

  // ---------------- Países personalizados ----------------

  Future<int> insertarPaisPersonalizado(String nombre) async {
    final db = await database;
    final n = nombre.trim();
    if (n.isEmpty) return -1;
    return db.insert(tablaPaises, {'nombre': n}, conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  Future<List<String>> obtenerPaisesPersonalizados() async {
    final db = await database;
    final rows = await db.query(tablaPaises, orderBy: 'nombre COLLATE NOCASE ASC');
    return rows.map((r) => (r['nombre'] as String?) ?? '').where((s) => s.isNotEmpty).toList();
  }

  Future<int> eliminarPaisPersonalizado(String nombre) async {
    final db = await database;
    return db.delete(tablaPaises, where: 'nombre = ?', whereArgs: [nombre]);
  }

  // ---------------- Metales personalizados ----------------

  Future<int> insertarMetalPersonalizado(String nombre) async {
    final db = await database;
    final n = nombre.trim();
    if (n.isEmpty) return -1;
    return db.insert(tablaMetales, {'nombre': n}, conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  Future<List<String>> obtenerMetalesPersonalizados() async {
    final db = await database;
    final rows = await db.query(tablaMetales, orderBy: 'nombre COLLATE NOCASE ASC');
    return rows.map((r) => (r['nombre'] as String?) ?? '').where((s) => s.isNotEmpty).toList();
  }

  Future<int> eliminarMetalPersonalizado(String nombre) async {
    final db = await database;
    return db.delete(tablaMetales, where: 'nombre = ?', whereArgs: [nombre]);
  }

  // ---------------- Cantos personalizados ----------------

  Future<int> insertarCantoPersonalizado(String nombre) async {
    final db = await database;
    final n = nombre.trim();
    if (n.isEmpty) return -1;
    return db.insert(tablaCantos, {'nombre': n}, conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  Future<List<String>> obtenerCantosPersonalizados() async {
    final db = await database;
    final rows = await db.query(tablaCantos, orderBy: 'nombre COLLATE NOCASE ASC');
    return rows.map((r) => (r['nombre'] as String?) ?? '').where((s) => s.isNotEmpty).toList();
  }

  Future<int> eliminarCantoPersonalizado(String nombre) async {
    final db = await database;
    return db.delete(tablaCantos, where: 'nombre = ?', whereArgs: [nombre]);
  }

  // ---------------- Acabados personalizados ----------------

  Future<int> insertarAcabadoPersonalizado(String nombre) async {
    final db = await database;
    final n = nombre.trim();
    if (n.isEmpty) return -1;
    return db.insert(tablaAcabados, {'nombre': n}, conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  Future<List<String>> obtenerAcabadosPersonalizados() async {
    final db = await database;
    final rows = await db.query(tablaAcabados, orderBy: 'nombre COLLATE NOCASE ASC');
    return rows.map((r) => (r['nombre'] as String?) ?? '').where((s) => s.isNotEmpty).toList();
  }

  Future<int> eliminarAcabadoPersonalizado(String nombre) async {
    final db = await database;
    return db.delete(tablaAcabados, where: 'nombre = ?', whereArgs: [nombre]);
  }

  // =====================================================================
  // FILTROS
  // =====================================================================

  Future<List<MapEntry<String, int>>> obtenerPaisesConMonedas() async {
    final db = await database;
    final rows = await db.rawQuery('''
      SELECT pais, COUNT(*) AS total
      FROM $tablaMonedas
      WHERE pais != ''
      GROUP BY pais
      ORDER BY pais COLLATE NOCASE ASC
    ''');
    return rows
        .map((r) => MapEntry((r['pais'] as String?) ?? '', (r['total'] as int?) ?? 0))
        .where((e) => e.key.isNotEmpty)
        .toList();
  }

  Future<List<MapEntry<String, int>>> obtenerMetalesConMonedas() async {
    final db = await database;
    final rows = await db.rawQuery('''
      SELECT metal, COUNT(*) AS total
      FROM $tablaMonedas
      WHERE metal != ''
      GROUP BY metal
      ORDER BY metal COLLATE NOCASE ASC
    ''');
    return rows
        .map((r) => MapEntry((r['metal'] as String?) ?? '', (r['total'] as int?) ?? 0))
        .where((e) => e.key.isNotEmpty)
        .toList();
  }

  Future<List<MapEntry<String, int>>> obtenerFormasConMonedas() async {
    final db = await database;
    final rows = await db.rawQuery('''
      SELECT forma, COUNT(*) AS total
      FROM $tablaMonedas
      WHERE forma != ''
      GROUP BY forma
      ORDER BY forma COLLATE NOCASE ASC
    ''');
    return rows
        .map((r) => MapEntry((r['forma'] as String?) ?? '', (r['total'] as int?) ?? 0))
        .where((e) => e.key.isNotEmpty)
        .toList();
  }

  Future<List<Moneda>> obtenerMonedasConFiltros({
    String? texto,
    List<String>? paises,
    List<String>? metales,
    List<String>? formas,
    List<String>? monedasCompra,
    List<String>? autenticidades,
    int? anioDesde,
    int? anioHasta,
  }) async {
    final db = await database;
    final condiciones = <String>[];
    final args = <Object?>[];

    final q = (texto ?? '').trim();
    if (q.isNotEmpty) {
      final like = '%$q%';
      final qLower = q.toLowerCase();

      final quiereConmemorativa = qLower == 'conmemorativa' ||
          qLower == 'conmemorativas' ||
          qLower == 'conmemorativo';
      final quiereFao = qLower == 'fao';
      final quiereAh = qLower == 'ah' ||
          qLower == 'hegira' ||
          qLower == 'hégira' ||
          qLower == 'hejira' ||
          qLower == 'islamica' ||
          qLower == 'islámica';
      final quiereVendidas = qLower == 'vendida' ||
          qLower == 'vendidas' ||
          qLower == 'vendido' ||
          qLower == 'vendidos';
      final quiereReselladas = qLower == 'resellada' ||
          qLower == 'reselladas' ||
          qLower == 'resellado' ||
          qLower == 'resellados' ||
          qLower == 'resello' ||
          qLower == 'resellos';
      final quiereContramarcadas = qLower == 'contramarcada' ||
          qLower == 'contramarcadas' ||
          qLower == 'contramarca' ||
          qLower == 'contramarcas';

      final camposTexto = <String>[
        'pais              LIKE ?',
        'denominacion      LIKE ?',
        'anio              LIKE ?',
        'km_catalogo       LIKE ?',
        'ceca              LIKE ?',
        'metal             LIKE ?',
        'grado_sheldon     LIKE ?',
        'periodo_acunacion LIKE ?',
        'forma             LIKE ?',
        'canto             LIKE ?',
        'acabado           LIKE ?',
        'autenticidad      LIKE ?',
        'lugar_compra      LIKE ?',
        'ubicacion         LIKE ?',
      ];
      for (var i = 0; i < camposTexto.length; i++) {
        args.add(like);
      }
      if (quiereConmemorativa) camposTexto.add('conmemorativa = 1');
      if (quiereFao) camposTexto.add('fao = 1');
      if (quiereAh) camposTexto.add('es_hejira = 1');
      if (quiereVendidas) camposTexto.add('precio_venta IS NOT NULL');
      if (quiereReselladas) camposTexto.add('resellada = 1');
      if (quiereContramarcadas) camposTexto.add('contramarcada = 1');

      condiciones.add('(${camposTexto.join(' OR ')})');
    }

    if (paises != null && paises.isNotEmpty) {
      final placeholders = List.filled(paises.length, '?').join(', ');
      condiciones.add('pais IN ($placeholders)');
      args.addAll(paises);
    }

    if (metales != null && metales.isNotEmpty) {
      final placeholders = List.filled(metales.length, '?').join(', ');
      condiciones.add('metal IN ($placeholders)');
      args.addAll(metales);
    }

    if (formas != null && formas.isNotEmpty) {
      final placeholders = List.filled(formas.length, '?').join(', ');
      condiciones.add('forma IN ($placeholders)');
      args.addAll(formas);
    }

    if (monedasCompra != null && monedasCompra.isNotEmpty) {
      final placeholders = List.filled(monedasCompra.length, '?').join(', ');
      condiciones.add('moneda_precio IN ($placeholders)');
      args.addAll(monedasCompra);
    }

    if (autenticidades != null && autenticidades.isNotEmpty) {
      final placeholders = List.filled(autenticidades.length, '?').join(', ');
      condiciones.add('autenticidad IN ($placeholders)');
      args.addAll(autenticidades);
    }

    if (anioDesde != null || anioHasta != null) {
      condiciones.add("anio GLOB '[0-9]*'");
      if (anioDesde != null) {
        condiciones.add('CAST(anio AS INTEGER) >= ?');
        args.add(anioDesde);
      }
      if (anioHasta != null) {
        condiciones.add('CAST(anio AS INTEGER) <= ?');
        args.add(anioHasta);
      }
    }

    final whereClause = condiciones.isEmpty ? null : condiciones.join(' AND ');

    final rows = await db.query(
      tablaMonedas,
      where: whereClause,
      whereArgs: args.isEmpty ? null : args,
      orderBy: 'pais COLLATE NOCASE ASC, anio ASC, denominacion COLLATE NOCASE ASC',
    );
    return rows.map(Moneda.fromMap).toList();
  }

  // ---------------- Utilidades ----------------

  Future<String> rutaDb() async {
    final dir = await getApplicationDocumentsDirectory();
    return p.join(dir.path, _dbNombre);
  }

  Future<void> cerrar() async {
    await _db?.close();
    _db = null;
  }
}
