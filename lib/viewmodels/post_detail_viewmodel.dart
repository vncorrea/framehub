import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../core/services/post_detail_service.dart';
import '../models/post_model.dart';
import 'dart:async';

class PostDetailViewModel extends ChangeNotifier {
  final String postId;
  final PostDetailService _service;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  StreamSubscription<Post>? _postSubscription;

  bool isLoading = true;
  bool isEditing = false;
  String? errorMessage;
  Post? post;
  String? editedCaption;

  PostDetailViewModel({required this.postId, PostDetailService? service})
      : _service = service ?? PostDetailService() {
    _listenToPost();
  }

  bool get isCurrentUserPost {
    return post?.userId == _auth.currentUser?.uid;
  }

  void _listenToPost() {
    _postSubscription?.cancel();
    _postSubscription = _service.getPostStream(postId).listen(
      (updatedPost) {
        post = updatedPost;
        if (!isEditing) {
          editedCaption = post?.caption;
        }
        isLoading = false;
        errorMessage = null;
        notifyListeners();
      },
      onError: (error) {
        errorMessage = error.toString();
        isLoading = false;
        notifyListeners();
      },
    );
  }

  void startEditing() {
    isEditing = true;
    editedCaption = post?.caption;
    notifyListeners();
  }

  void cancelEditing() {
    isEditing = false;
    editedCaption = post?.caption;
    notifyListeners();
  }

  Future<void> saveEdit() async {
    if (editedCaption == null || editedCaption!.isEmpty) {
      errorMessage = "A caption não pode estar vazia";
      notifyListeners();
      return;
    }

    try {
      await _service.updatePostCaption(postId, editedCaption!);
      isEditing = false;
      errorMessage = null;
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
    }
  }

  void updateCaption(String newCaption) {
    editedCaption = newCaption;
    notifyListeners();
  }

  @override
  void dispose() {
    _postSubscription?.cancel();
    super.dispose();
  }
}