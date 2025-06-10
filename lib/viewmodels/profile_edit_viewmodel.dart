import 'package:flutter/material.dart';
import 'dart:io';
import '../core/services/profile_service.dart';
import '../models/user_model.dart';

class ProfileEditViewModel extends ChangeNotifier {
  final String userId;
  final ProfileService _profileService;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  AppUser? _userProfile;
  AppUser? get userProfile => _userProfile;

  String? _username;
  String? get username => _username;

  set username(String? value) {
    _username = value;
    notifyListeners();
  }

  ProfileEditViewModel({
    required this.userId,
    ProfileService? profileService,
  }) : _profileService = profileService ?? ProfileService() {
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    _setLoading(true);
    try {
      _userProfile = await _profileService.getUserById(userId);
      _username = _userProfile?.username;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateProfile({
    String? name,
    String? phone,
    String? username,
  }) async {
    _setLoading(true);
    try {
      if (username != null && username.isNotEmpty) {
        final taken = await _profileService.isUsernameTaken(username, userId);
        if (taken) {
          _errorMessage = 'Este nome de usuário já está em uso.';
          _setLoading(false);
          return false;
        }
      }
      await _profileService.updateProfile(
        userId: userId,
        name: name,
        phone: phone,
        username: username,
      );
      await _loadUserProfile(); // Recarrega o perfil após a atualização
      _errorMessage = null;
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateProfilePicture(File imageFile) async {
    _setLoading(true);
    try {
      await _profileService.uploadProfilePicture(userId, imageFile);
      await _loadUserProfile(); // Recarrega o perfil após a atualização
      _errorMessage = null;
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
} 