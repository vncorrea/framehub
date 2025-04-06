import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/tag_model.dart';
import '../../models/post_model.dart';

class ExploreService {
  final FirebaseFirestore _firestore;

  ExploreService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Retorna um stream com a lista de tags da coleção "tag"
  Stream<List<Tag>> getTagsStream() {
    return _firestore
        .collection('tag') // nome exato da sua coleção
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Tag.fromMap(doc.data(), doc.id))
            .toList());
  }

  /// Retorna um stream com a lista de posts da coleção "posts".
  /// Se `tag` for informado, filtra os posts que contêm essa tag no array "tags".
 Stream<List<Post>> getPostsStream({String? tag}) {
  Query query = _firestore.collection('posts').orderBy('timestamp', descending: true);
  if (tag != null && tag.isNotEmpty) {
    query = query.where('tags', arrayContains: tag);
    print("Query filtrada por tag: $tag");
  } else {
    print("Query sem filtro de tag");
  }
  return query.snapshots().map((snapshot) => snapshot.docs
    .map((doc) => Post.fromMap(doc.data() as Map<String, dynamic>, doc.id))
    .toList());
}
}