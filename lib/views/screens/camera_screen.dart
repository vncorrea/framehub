import 'dart:io';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _cameraController;
  late Future<void> _initializeControllerFuture;
  XFile? _capturedImage;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      final frontCamera = cameras.first;

      _cameraController = CameraController(
        frontCamera,
        ResolutionPreset.medium,
      );

      _initializeControllerFuture = _cameraController!.initialize();

      setState(() {}); // só atualiza a UI após configurar tudo
    } catch (e) {
      debugPrint('Erro ao inicializar câmera: $e');
    }
  }

  Future<void> _takePicture() async {
    try {
      await _initializeControllerFuture;

      final image = await _cameraController!.takePicture();
      setState(() => _capturedImage = image);
    } catch (e) {
      debugPrint('Erro ao tirar foto: $e');
    }
  }

  Future<void> _uploadToFirebase() async {
    if (_capturedImage == null) return;

    setState(() => _isUploading = true);

    try {
      final file = File(_capturedImage!.path);
      final fileName = const Uuid().v4();
      final ref = FirebaseStorage.instance.ref().child('fotos/$fileName.jpg');

      await ref.putFile(file);
      final url = await ref.getDownloadURL();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Imagem enviada com sucesso!")),
      );
    } catch (e) {
      debugPrint("Erro ao enviar imagem: $e");
    } finally {
      setState(() {
        _isUploading = false;
        _capturedImage = null;
      });
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_cameraController == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Câmera")),
      body: _capturedImage == null
          ? FutureBuilder(
              future: _initializeControllerFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return Stack(
                    children: [
                      CameraPreview(_cameraController!),
                      Positioned(
                        bottom: 30,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: FloatingActionButton(
                            onPressed: _takePicture,
                            child: const Icon(Icons.camera),
                          ),
                        ),
                      ),
                    ],
                  );
                } else if (snapshot.hasError) {
                  return Center(child: Text("Erro: ${snapshot.error}"));
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              },
            )
          : Column(
              children: [
                Expanded(child: Image.file(File(_capturedImage!.path))),
                if (_isUploading)
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: CircularProgressIndicator(),
                  )
                else
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => setState(() => _capturedImage = null),
                        icon: const Icon(Icons.cancel),
                        label: const Text("Cancelar"),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      ),
                      ElevatedButton.icon(
                        onPressed: _uploadToFirebase,
                        icon: const Icon(Icons.check),
                        label: const Text("Confirmar"),
                      ),
                    ],
                  ),
              ],
            ),
    );
  }
}