import 'package:flutter/material.dart';
import '../core/services/feed_service.dart';
import '../models/post_model.dart';

class FeedViewModel extends ChangeNotifier {
  final FeedService _feedService;
  
  List<Post> _posts = [];
  List<Post> get posts => _posts;
  
  bool _isLoading = true;
  bool get isLoading => _isLoading;
  
  String? _errorMessage;
  String? get errorMessage => _errorMessage;
  
  FeedViewModel({FeedService? feedService})
      : _feedService = feedService ?? FeedService() {
    _listenToPosts();
  }
  
  void _listenToPosts() {
    _feedService.getPostsStream().listen((postsData) {
      _posts = postsData;
      _isLoading = false;
      notifyListeners();
    }, onError: (error) {
      _errorMessage = error.toString();
      _isLoading = false;
      notifyListeners();
    });
  }
}