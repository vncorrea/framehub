import 'dart:io';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:fluttertoast/fluttertoast.dart';

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
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      final camera = cameras.first;

      _cameraController = CameraController(camera, ResolutionPreset.medium);
      _initializeControllerFuture = _cameraController!.initialize();

      setState(() {});
    } catch (e) {
      debugPrint('Erro ao inicializar câmera: $e');
    }
  }

  Future<void> _takePicture() async {
    try {
      await _initializeControllerFuture;
      final image = await _cameraController!.takePicture();
      setState(() {
        _capturedImage = image;
      });
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
    final downloadUrl = await ref.getDownloadURL();

    await FirebaseFirestore.instance.collection('fotos').add({
      'image_url': downloadUrl,
      'description': _textController.text.trim(),
      'timestamp': FieldValue.serverTimestamp(),
    });

    Fluttertoast.showToast(
      msg: "Foto enviada com sucesso!",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );

    setState(() {
      _capturedImage = null;
      _textController.clear();
    });
  } catch (e) {
    debugPrint("Erro ao enviar: $e");

    Fluttertoast.showToast(
      msg: "Erro ao enviar imagem",
      backgroundColor: Colors.red,
    );
  } finally {
    setState(() => _isUploading = false);
  }
}

  @override
  void dispose() {
    _cameraController?.dispose();
    _textController.dispose();
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
      appBar: AppBar(title: const Text("Tirar Foto")),
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
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              },
            )
          : Column(
              children: [
                Expanded(child: Image.file(File(_capturedImage!.path))),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: _textController,
                    decoration: const InputDecoration(
                      labelText: "Descrição",
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                ),
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
                        onPressed: () {
                          setState(() {
                            _capturedImage = null;
                            _textController.clear();
                          });
                        },
                        icon: const Icon(Icons.cancel),
                        label: const Text("Cancelar"),
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