import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../models/moneda.dart';

class DatabaseHelper {
  DatabaseHelper._();
  static final DatabaseHelper instance = DatabaseHelper._();

  static const String _dbNombre = 'cubanum.db';
  static const int _dbVersion = 3;
  static const String tablaMonedas = 'monedas';
  static const String tablaPaises = 'paises_personalizados';
  static const String tablaMetales = 'metales_personalizados';

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
        id                     INTEGER PRIMARY KEY AUTOINCREMENT,
        pais                   TEXT    NOT NULL DEFAULT '',
        pertenece_onu          INTEGER NOT NULL DEFAULT 0,
        conmemorativa          INTEGER NOT NULL DEFAULT 0,
        fao                    INTEGER NOT NULL DEFAULT 0,
        periodo_acunacion      TEXT    NOT NULL DEFAULT '',
        denominacion           TEXT    NOT NULL DEFAULT '',
        anio                   TEXT    NOT NULL DEFAULT '',
        ceca                   TEXT    NOT NULL DEFAULT '',
        km_catalogo            TEXT    NOT NULL DEFAULT '',
        acunadas               INTEGER,
        peso_g                 REAL,
        diametro_mm            REAL,
        grosor_mm              REAL,
        forma                  TEXT    NOT NULL DEFAULT '',
        metal                  TEXT    NOT NULL DEFAULT '',
        ley                    TEXT    NOT NULL DEFAULT '',
        canto                  TEXT    NOT NULL DEFAULT '',
        alineacion             TEXT    NOT NULL DEFAULT '',
        grado_sheldon          TEXT    NOT NULL DEFAULT '',
        detalles_visibles      TEXT    NOT NULL DEFAULT '',
        autenticidad           TEXT    NOT NULL DEFAULT 'Original',
        precio_compra          REAL,
        moneda_precio          TEXT    NOT NULL DEFAULT 'CUP',
        lugar_compra           TEXT    NOT NULL DEFAULT '',
        fecha_compra           TEXT,
        valor_estimado         REAL,
        valor_estimado_moneda  TEXT    NOT NULL DEFAULT 'CUP',
        precio_venta           REAL,
        moneda_venta           TEXT    NOT NULL DEFAULT 'CUP',
        fecha_venta            TEXT,
        foto_anverso           TEXT,
        foto_reverso           TEXT,
        foto_canto             TEXT,
        foto_km                TEXT,
        notas                  TEXT    NOT NULL DEFAULT '',
        ubicacion              TEXT    NOT NULL DEFAULT ''
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

    await db.execute('CREATE INDEX idx_monedas_pais ON $tablaMonedas(pais)');
    await db.execute('CREATE INDEX idx_monedas_denominacion ON $tablaMonedas(denominacion)');
    await db.execute('CREATE INDEX idx_monedas_anio ON $tablaMonedas(anio)');
    await db.execute('CREATE INDEX idx_monedas_km ON $tablaMonedas(km_catalogo)');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // v1 -> v2: nuevos campos y tablas de listas personalizadas.
    // Nota: proveedor y etiquetas se dejan físicamente en la tabla (SQLite
    // antiguo no permite DROP COLUMN) pero ya no se usan desde el modelo.
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
  }
  // ---------------- Monedas ----------------

  Future<int> insertar(Moneda moneda) async {
    final db = await database;
    final map = moneda.toMap()..remove('id');
    return db.insert(tablaMonedas, map);
  }

  Future<int> actualizar(Moneda moneda) async {
    if (moneda.id == null) {
      throw ArgumentError('No se puede actualizar una moneda sin id.');
    }
    final db = await database;
    return db.update(
      tablaMonedas,
      moneda.toMap(),
      where: 'id = ?',
      whereArgs: [moneda.id],
    );
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

    // Condiciones booleanas por palabra clave
    final quiereConmemorativa = qLower == 'conmemorativa' ||
        qLower == 'conmemorativas' ||
        qLower == 'conmemorativo';
    final quiereFao = qLower == 'fao';

    final condiciones = <String>[
      'pais           LIKE ?',
      'denominacion   LIKE ?',
      'anio           LIKE ?',
      'km_catalogo    LIKE ?',
      'ceca           LIKE ?',
      'metal          LIKE ?',
      'grado_sheldon  LIKE ?',
      'periodo_acunacion LIKE ?',
      'forma          LIKE ?',
      'canto          LIKE ?',
      'autenticidad   LIKE ?',
      'lugar_compra   LIKE ?',
      'ubicacion      LIKE ?',
    ];
    final args = <Object?>[
      like, like, like, like, like, like, like, like, like,
      like, like, like, like,
    ];

    if (quiereConmemorativa) {
      condiciones.add('conmemorativa = 1');
    }
    if (quiereFao) {
      condiciones.add('fao = 1');
    }

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

  Future<void> vaciar() async {
    final db = await database;
    await db.delete(tablaMonedas);
  }

  // ---------------- Países personalizados ----------------

  Future<int> insertarPaisPersonalizado(String nombre) async {
    final db = await database;
    final n = nombre.trim();
    if (n.isEmpty) return -1;
    return db.insert(
      tablaPaises,
      {'nombre': n},
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  Future<List<String>> obtenerPaisesPersonalizados() async {
    final db = await database;
    final rows = await db.query(
      tablaPaises,
      orderBy: 'nombre COLLATE NOCASE ASC',
    );
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
    return db.insert(
      tablaMetales,
      {'nombre': n},
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  Future<List<String>> obtenerMetalesPersonalizados() async {
    final db = await database;
    final rows = await db.query(
      tablaMetales,
      orderBy: 'nombre COLLATE NOCASE ASC',
    );
    return rows.map((r) => (r['nombre'] as String?) ?? '').where((s) => s.isNotEmpty).toList();
  }

  Future<int> eliminarMetalPersonalizado(String nombre) async {
    final db = await database;
    return db.delete(tablaMetales, where: 'nombre = ?', whereArgs: [nombre]);
  }

  // ---------------- Utilidades ----------------

  Future<void> cerrar() async {
    await _db?.close();
    _db = null;
  }
}
