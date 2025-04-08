import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../models/tag_model.dart';

final Map<String, IconData> iconMap = {
  "restaurant": Icons.restaurant,
  "travel": Icons.flight,
  "beach_access": Icons.beach_access,
  "camera_alt": Icons.camera_alt,
};

class CameraScreen extends StatefulWidget {
  final String userId;

  const CameraScreen({Key? key, required this.userId}) : super(key: key);

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _cameraController;
  late Future<void> _initializeControllerFuture;
  XFile? _capturedImage;
  bool _isUploading = false;
  final TextEditingController _textController = TextEditingController();
  List<Tag> _tags = [];
  List<String> _selectedTags = [];

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _fetchTags();
  }

  Future<void> _fetchTags() async {
    final snapshot = await FirebaseFirestore.instance.collection('tag').get();
    setState(() {
      _tags = snapshot.docs.map((doc) => Tag.fromMap(doc.data(), doc.id)).toList();
    });
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
      final ref = FirebaseStorage.instance.ref().child('posts/$fileName.jpg');
      await ref.putFile(file);
      final downloadUrl = await ref.getDownloadURL();

      await FirebaseFirestore.instance.collection('posts').add({
        'userId': widget.userId,
        'imageUrl': downloadUrl,
        'caption': _textController.text.trim(),
        'tags': _selectedTags,
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
        _selectedTags.clear();
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

  Widget _buildTagChip(Tag tag, bool isSelected, void Function() onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: ChoiceChip(
        avatar: Icon(iconMap[tag.icon] ?? Icons.help, size: 20),
        label: Text(tag.name),
        selected: isSelected,
        onSelected: (_) => onTap(),
        selectedColor: Colors.blueAccent.withOpacity(0.3),
        labelStyle: TextStyle(
          color: isSelected ? Colors.blue : Colors.black,
        ),
      ),
    );
  }

  Widget _buildTagBar() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        color: Colors.white.withOpacity(0.85),
        height: 60,
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: _tags.map((tag) {
            final isSelected = _selectedTags.contains(tag.name);
            return _buildTagChip(tag, isSelected, () {
              setState(() {
                if (isSelected) {
                  _selectedTags.remove(tag.name);
                } else {
                  _selectedTags.add(tag.name);
                }
              });
            });
          }).toList(),
        ),
      ),
    );
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
      body: Stack(
        children: [
          _capturedImage == null
              ? FutureBuilder(
                  future: _initializeControllerFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      return CameraPreview(_cameraController!);
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
                                _selectedTags.clear();
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
                    const SizedBox(height: 16),
                  ],
                ),
          _buildTagBar(),
          if (_capturedImage == null)
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
      ),
    );
  }
}