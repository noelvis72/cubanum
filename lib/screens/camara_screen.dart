import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Pantalla que muestra la vista previa de la cámara y permite tomar una foto.
/// Devuelve la ruta del archivo copiado a la carpeta permanente de la app.
class CamaraScreen extends StatefulWidget {
  const CamaraScreen({super.key});

  @override
  State<CamaraScreen> createState() => _CamaraScreenState();
}

class _CamaraScreenState extends State<CamaraScreen> {
  CameraController? _controller;
  Future<void>? _initializeFuture;
  bool _capturando = false;

  @override
  void initState() {
    super.initState();
    _inicializarCamara();
  }

  Future<void> _inicializarCamara() async {
    try {
      final camaras = await availableCameras();
      if (camaras.isEmpty) {
        if (mounted) Navigator.pop(context);
        return;
      }
      // Usar la cámara trasera por defecto.
      final trasera = camaras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => camaras.first,
      );
      final controller = CameraController(
        trasera,
        ResolutionPreset.medium,
        enableAudio: false,
      );
      _controller = controller;
      _initializeFuture = controller.initialize();
      if (mounted) setState(() {});
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo abrir la cámara: $e')),
      );
      Navigator.pop(context);
    }
  }

  Future<void> _tomarFoto() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized || _capturando) return;

    setState(() => _capturando = true);
    try {
      final XFile foto = await controller.takePicture();

      // Copiar a la carpeta permanente de la app.
      final dirDocs = await getApplicationDocumentsDirectory();
      final dirFotos = Directory(p.join(dirDocs.path, 'fotos'));
      if (!await dirFotos.exists()) {
        await dirFotos.create(recursive: true);
      }
      final ext = p.extension(foto.path);
      final nombre = '${DateTime.now().microsecondsSinceEpoch}$ext';
      final destino = p.join(dirFotos.path, nombre);
      await File(foto.path).copy(destino);

      if (!mounted) return;
      Navigator.pop(context, destino);
    } catch (e) {
      if (!mounted) return;
      setState(() => _capturando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al tomar la foto: $e')),
      );
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Tomar foto'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<void>(
        future: _initializeFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              _controller != null &&
              _controller!.value.isInitialized) {
            return Column(
              children: [
                Expanded(
                  child: Center(
                    child: CameraPreview(_controller!),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: FloatingActionButton(
                    onPressed: _capturando ? null : _tomarFoto,
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    child: _capturando
                        ? const CircularProgressIndicator(strokeWidth: 2)
                        : const Icon(Icons.camera_alt, size: 32),
                  ),
                ),
              ],
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.white),
              ),
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
