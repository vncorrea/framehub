import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/post_model.dart';

class PostDetailService {
  final FirebaseFirestore _firestore;

  PostDetailService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Retorna um stream com as atualizações do post
  Stream<Post> getPostStream(String postId) {
    return _firestore
        .collection('posts')
        .doc(postId)
        .snapshots()
        .map((doc) => Post.fromMap(doc.data() as Map<String, dynamic>, doc.id));
  }

  /// Busca um post pelo seu id.
  Future<Post> getPostById(String postId) async {
    DocumentSnapshot<Map<String, dynamic>> doc = await _firestore
        .collection('posts')
        .doc(postId)
        .get();

    if (doc.exists && doc.data() != null) {
      return Post.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    } else {
      throw Exception("Post não encontrado");
    }
  }

  /// Atualiza a caption de um post
  Future<void> updatePostCaption(String postId, String newCaption) async {
    try {
      await _firestore
          .collection('posts')
          .doc(postId)
          .update({'caption': newCaption});
    } catch (e) {
      throw Exception("Erro ao atualizar a caption: $e");
    }
  }
}