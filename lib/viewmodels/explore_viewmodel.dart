import 'dart:async';
import 'package:flutter/material.dart';
import '../core/services/explore_service.dart';
import '../models/tag_model.dart';
import '../models/post_model.dart';

class ExploreViewModel extends ChangeNotifier {
  final ExploreService _exploreService;

  List<Tag> _tags = [];
  List<Tag> get tags => _tags;

  List<Post> _posts = [];
  List<Post> get posts {
    if (_searchQuery.isEmpty) return _posts;
    return _posts.where((post) =>
      post.caption.toLowerCase().contains(_searchQuery)
    ).toList();
  }

  String? _selectedTag;
  String? get selectedTag => _selectedTag;

  bool _isLoadingTags = true;
  bool get isLoadingTags => _isLoadingTags;

  bool _isLoadingPosts = true;
  bool get isLoadingPosts => _isLoadingPosts;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  StreamSubscription<List<Post>>? _postsSubscription;

  ExploreViewModel({ExploreService? exploreService})
      : _exploreService = exploreService ?? ExploreService() {
    _listenToTags();
    _listenToPosts();
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
    // Cancele a assinatura anterior, se houver
    _postsSubscription?.cancel();

    // Limpe a lista para garantir que, se nenhum post for retornado, ela fique vazia
    _posts = [];
    _isLoadingPosts = true;
    notifyListeners();

    _postsSubscription =
        _exploreService.getPostsStream(tag: _selectedTag)?.listen((postsData) {
      _posts = postsData;
      _isLoadingPosts = false;
      print("Posts carregados: ${_posts.length}");
      notifyListeners();
    }, onError: (error) {
      _errorMessage = error.toString();
      _isLoadingPosts = false;
      notifyListeners();
    });
  }

  void updateSelectedTag(String? tag) {
    _selectedTag = tag?.toLowerCase(); // Caso você esteja normalizando os valores
    print("Selected tag updated: $_selectedTag");
    _listenToPosts();
  }

  void updateSearchQuery(String query) {
    _searchQuery = query.toLowerCase();
    notifyListeners();
  }

  @override
  void dispose() {
    _postsSubscription?.cancel();
    super.dispose();
  }
}