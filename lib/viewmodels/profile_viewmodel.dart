import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/post_model.dart';

class ProfileViewModel extends ChangeNotifier {
  final String userId;
  final FirebaseFirestore _firestore;

  AppUser? _userProfile;
  AppUser? get userProfile => _userProfile;

  bool _isLoadingProfile = true;
  bool get isLoadingProfile => _isLoadingProfile;

  String? _errorProfile;
  String? get errorProfile => _errorProfile;

  List<Post> _userPosts = [];
  List<Post> get userPosts => _userPosts;

  bool _isLoadingPosts = true;
  bool get isLoadingPosts => _isLoadingPosts;

  String? _errorPosts;
  String? get errorPosts => _errorPosts;

  ProfileViewModel({required this.userId, FirebaseFirestore? firestore})
      : assert(userId.isNotEmpty, "userId cannot be empty"),
        _firestore = firestore ?? FirebaseFirestore.instance {
    print("ProfileViewModel: userId = $userId"); // Verificação
    _listenToProfile();
    _listenToPosts();
  }

  void _listenToProfile() {
    _firestore.collection('users').doc(userId).snapshots().listen((doc) {
      if (doc.exists && doc.data() != null) {
        _userProfile = AppUser.fromMap(doc.data()!, doc.id);
      } else {
        _errorProfile = "Perfil não encontrado.";
      }
      _isLoadingProfile = false;
      notifyListeners();
    }, onError: (error) {
      _errorProfile = error.toString();
      _isLoadingProfile = false;
      notifyListeners();
    });
  }

  void _listenToPosts() {
    _firestore
        .collection('posts')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .listen((snapshot) {
      _userPosts = snapshot.docs
          .map((doc) => Post.fromMap(doc.data(), doc.id))
          .toList();
      _isLoadingPosts = false;
      notifyListeners();
    }, onError: (error) {
      _errorPosts = error.toString();
      _isLoadingPosts = false;
      notifyListeners();
    });
  }
}