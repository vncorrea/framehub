import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import '../../models/user_model.dart';
import '../../models/post_model.dart';

class ProfileService {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  ProfileService({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance;

  /// Busca os dados do usuário pela ID
  Future<AppUser?> getUserById(String userId) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> doc =
          await _firestore.collection('users').doc(userId).get();
      if (doc.exists && doc.data() != null) {
        return AppUser.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  /// Retorna um stream com os posts do usuário
  Stream<List<Post>> getPostsByUser(String userId) {
    return _firestore
        .collection('posts')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Post.fromMap(doc.data(), doc.id))
            .toList());
  }

  /// Atualiza os dados do perfil do usuário, incluindo username
  Future<void> updateProfile({
    required String userId,
    String? name,
    String? phone,
    String? username,
  }) async {
    try {
      Map<String, dynamic> updateData = {};
      if (name != null) updateData['name'] = name;
      if (phone != null) updateData['phone'] = phone;
      if (username != null) updateData['username'] = username;
      await _firestore.collection('users').doc(userId).update(updateData);
    } catch (e) {
      rethrow;
    }
  }

  /// Verifica se o username já existe (exceto para o próprio userId)
  Future<bool> isUsernameTaken(String username, String userId) async {
    final query = await _firestore
        .collection('users')
        .where('username', isEqualTo: username)
        .get();
    for (var doc in query.docs) {
      if (doc.id != userId) {
        return true;
      }
    }
    return false;
  }

  /// Faz upload da foto de perfil e atualiza a URL no perfil do usuário
  Future<String> uploadProfilePicture(String userId, File imageFile) async {
    try {
      // Cria uma referência única para a imagem
      final storageRef = _storage.ref().child('profile_pictures/$userId.jpg');
      
      // Faz upload do arquivo
      await storageRef.putFile(imageFile);
      
      // Obtém a URL de download
      String downloadUrl = await storageRef.getDownloadURL();
      
      // Atualiza a URL no documento do usuário
      await _firestore.collection('users').doc(userId).update({
        'profilePictureUrl': downloadUrl,
      });
      
      return downloadUrl;
    } catch (e) {
      rethrow;
    }
  }
}