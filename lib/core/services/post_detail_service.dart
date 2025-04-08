import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/post_model.dart';

class PostDetailService {
  final FirebaseFirestore _firestore;

  PostDetailService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

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
}