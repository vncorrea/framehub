import '../../models/post_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FeedService {
  final FirebaseFirestore _firestore;

  FeedService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Retorna um stream com a lista de posts, ordenados do mais recente para o mais antigo.
  Stream<List<Post>> getPostsStream() {
    return _firestore
        .collection('posts')
        // .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Post.fromMap(doc.data(), doc.id))
            .toList());
  }
}