import 'package:flutter/material.dart';
import '../core/services/post_detail_service.dart';
import '../models/post_model.dart';

class PostDetailViewModel extends ChangeNotifier {
  final String postId;
  final PostDetailService _service;

  bool isLoading = true;
  String? errorMessage;
  Post? post;

  PostDetailViewModel({required this.postId, PostDetailService? service})
      : _service = service ?? PostDetailService() {
    loadPost();
  }

  Future<void> loadPost() async {
    try {
      post = await _service.getPostById(postId);
      errorMessage = null;
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}