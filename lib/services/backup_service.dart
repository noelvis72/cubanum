import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../db/database_helper.dart';

/// Servicio de copia de seguridad y restauración.
///
/// El backup es un ZIP con:
///  - cubanum.db (base de datos completa)
///  - fotos/ (todas las imágenes)
class BackupService {
  BackupService._();

  static const String _claveContador = 'cubanum_salva_contador';
  static const String _claveUltimaSalva = 'cubanum_ultima_salva';

  /// Crea un ZIP con la BD y las fotos, y abre el diálogo nativo
  /// "Guardar como" para que el usuario elija dónde guardarlo.
  static Future<bool> crearBackup() async {
    try {
      final dirDocs = await getApplicationDocumentsDirectory();

      final dbFile = File(p.join(dirDocs.path, 'cubanum.db'));
      final dirFotos = Directory(p.join(dirDocs.path, 'fotos'));

      if (!await dbFile.exists()) {
        throw Exception('No se encontró la base de datos.');
      }

      // Nombre con consecutivo
      final prefs = await SharedPreferences.getInstance();
      final contador = (prefs.getInt(_claveContador) ?? 0) + 1;
      await prefs.setInt(_claveContador, contador);
      final contStr = contador.toString().padLeft(2, '0');

      final ahora = DateTime.now();
      final fecha = '${ahora.day.toString().padLeft(2, '0')}-'
          '${ahora.month.toString().padLeft(2, '0')}-'
          '${ahora.year}';
      final nombre = 'Cubanum_Salva_${fecha}_$contStr.zip';

      // Construir el ZIP en memoria
      final archive = Archive();

      final bytesDb = await dbFile.readAsBytes();
      archive.addFile(
        ArchiveFile('cubanum.db', bytesDb.length, bytesDb),
      );

      if (await dirFotos.exists()) {
        final fotos = await dirFotos.list().toList();
        for (final f in fotos) {
          if (f is File) {
            final nombreFoto = p.basename(f.path);
            final bytesFoto = await f.readAsBytes();
            archive.addFile(
              ArchiveFile('fotos/$nombreFoto', bytesFoto.length, bytesFoto),
            );
          }
        }
      }

      final zipData = ZipEncoder().encode(archive);
      if (zipData == null) {
        throw Exception('Error al crear el ZIP.');
      }

      // Abrir el diálogo nativo "Guardar como"
      final uri = await FilePicker.platform.saveFile(
        dialogTitle: 'Guardar copia de seguridad de CUBANUM',
        fileName: nombre,
        bytes: Uint8List.fromList(zipData),
        type: FileType.custom,
        allowedExtensions: ['zip'],
      );

      // Si el usuario canceló, revertir el contador
      if (uri == null) {
        await prefs.setInt(_claveContador, contador - 1);
        return false;
      }

      await prefs.setString(_claveUltimaSalva, ahora.toIso8601String());
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Restaura un backup desde un ZIP elegido por el usuario.
  /// Devuelve true si la restauración fue exitosa.
  static Future<bool> restaurarBackup() async {
    bool exito = false;

    try {
      // 1. Elegir el archivo
      final resultado = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['zip'],
      );

      if (resultado == null || resultado.files.isEmpty) return false;

      final archivoSeleccionado = File(resultado.files.first.path!);
      if (!await archivoSeleccionado.exists()) return false;

      // 2. Leer el ZIP y verificar que contiene cubanum.db
      final bytes = await archivoSeleccionado.readAsBytes();
      final archive = ZipDecoder().decodeBytes(bytes);

      final archivoDb = archive.files.firstWhere(
        (f) => f.name == 'cubanum.db' && f.isFile,
        orElse: () => throw Exception('El ZIP no contiene cubanum.db'),
      );

      final dirDocs = await getApplicationDocumentsDirectory();
      final rutaDbActual = p.join(dirDocs.path, 'cubanum.db');
      final dirFotosActual = Directory(p.join(dirDocs.path, 'fotos'));
      final rutaDbBackup = p.join(dirDocs.path, 'cubanum.db.bak');
      final rutaFotosBackup = p.join(dirDocs.path, 'fotos.bak');

      // 3. Backup automático de la BD y fotos actuales
      final dbActual = File(rutaDbActual);
      if (await dbActual.exists()) {
        await dbActual.copy(rutaDbBackup);
      }
      if (await dirFotosActual.exists()) {
        final dirFotosBak = Directory(rutaFotosBackup);
        if (await dirFotosBak.exists()) {
          await dirFotosBak.delete(recursive: true);
        }
        await dirFotosActual.rename(rutaFotosBackup);
      }

      // 4. Cerrar la BD antes de sobrescribir el archivo
      await DatabaseHelper.instance.cerrar();
      await Future.delayed(const Duration(milliseconds: 300));

      // 5. Escribir la nueva BD
      final datosDb = archivoDb.content as List<int>;
      await File(rutaDbActual).writeAsBytes(datosDb, flush: true);

      // 6. Extraer las fotos nuevas
      final dirFotosNuevas = Directory(p.join(dirDocs.path, 'fotos'));
      if (!await dirFotosNuevas.exists()) {
        await dirFotosNuevas.create(recursive: true);
      }

      for (final f in archive.files) {
        if (f.isFile && f.name.startsWith('fotos/')) {
          final nombreRel = f.name.substring('fotos/'.length);
          if (nombreRel.isEmpty) continue;
          final archivoFoto = File(p.join(dirFotosNuevas.path, nombreRel));
          final datos = f.content as List<int>;
          await archivoFoto.writeAsBytes(datos, flush: true);
        }
      }

      exito = true;
    } catch (e) {
      exito = false;
    } finally {
      // 7. Reabrir la BD SIEMPRE, pase lo que pase.
      try {
        await DatabaseHelper.instance.contar();
      } catch (_) {
        // Si la reapertura falla, recuperar del backup automático
        try {
          final dirDocs = await getApplicationDocumentsDirectory();
          final rutaDbBackup = p.join(dirDocs.path, 'cubanum.db.bak');
          final rutaDbActual = p.join(dirDocs.path, 'cubanum.db');
          final backup = File(rutaDbBackup);
          if (await backup.exists()) {
            await DatabaseHelper.instance.cerrar();
            await backup.copy(rutaDbActual);
            await DatabaseHelper.instance.contar();
          }
        } catch (_) {}
      }
    }

    return exito;
  }

  /// Devuelve la fecha de la última salva, o null si no hay.
  static Future<DateTime?> ultimaSalva() async {
    final prefs = await SharedPreferences.getInstance();
    final s = prefs.getString(_claveUltimaSalva);
    if (s == null) return null;
    return DateTime.tryParse(s);
  }

  /// Comprueba si han pasado más de [dias] días desde la última salva.
  static Future<bool> debeRecordarSalva({
    int dias = 30,
    int minMonedas = 20,
  }) async {
    final ultima = await ultimaSalva();
    final total = await DatabaseHelper.instance.contar();
    if (total < minMonedas) return false;
    if (ultima == null) return true;
    return DateTime.now().difference(ultima).inDays >= dias;
  }
}
