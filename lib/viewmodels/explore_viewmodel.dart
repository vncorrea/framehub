import 'package:flutter/material.dart';
import '../core/services/explore_service.dart';
import '../models/tag_model.dart';
import '../models/post_model.dart';

class ExploreViewModel extends ChangeNotifier {
  final ExploreService _exploreService;

  List<Tag> _tags = [];
  List<Tag> get tags => _tags;

  List<Post> _posts = [];
  List<Post> get posts => _posts;

  String? _selectedTag;
  String? get selectedTag => _selectedTag;

  bool _isLoadingTags = true;
  bool get isLoadingTags => _isLoadingTags;

  bool _isLoadingPosts = true;
  bool get isLoadingPosts => _isLoadingPosts;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  ExploreViewModel({ExploreService? exploreService})
      : _exploreService = exploreService ?? ExploreService() {
    _listenToTags();
    _listenToPosts(); // Inicialmente sem filtro
  }

  void _listenToTags() {
    _exploreService.getTagsStream().listen((tagsData) {
      _tags = tagsData;
      _isLoadingTags = false;
      notifyListeners();
    }, onError: (error) {
      _errorMessage = error.toString();
      _isLoadingTags = false;
      notifyListeners();
    });
  }

  void _listenToPosts() {
    _isLoadingPosts = true;
    _exploreService.getPostsStream(tag: _selectedTag).listen((postsData) {
      _posts = postsData;
      _isLoadingPosts = false;
      notifyListeners();
    }, onError: (error) {
      _errorMessage = error.toString();
      _isLoadingPosts = false;
      notifyListeners();
    });
  }

  /// Atualiza a tag selecionada e reescuta os posts filtrados
  void updateSelectedTag(String? tag) {
    _selectedTag = tag;
    _listenToPosts();
  }
}