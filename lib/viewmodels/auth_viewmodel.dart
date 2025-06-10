import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../core/services/auth_service.dart';
import '../models/user_model.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthService _authService;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  AppUser? _user;
  AppUser? get user => _user;

  AuthViewModel({AuthService? authService})
    : _authService = authService ?? AuthService();

  /// Realiza o login com email e senha utilizando o AuthService.
  /// Retorna true se o login for bem-sucedido, ou false caso contrário.
  Future<bool> login(String email, String password) async {
    _setLoading(true);
    try {
      AppUser? loggedInUser = await _authService.signIn(
        email: email,
        password: password,
      );
      if (loggedInUser != null) {
        _user = loggedInUser;
        _errorMessage = null;
        return true;
      } else {
        _errorMessage = "Falha ao recuperar os dados do usuário.";
        return false;
      }
    } on FirebaseAuthException catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (e) {
      _errorMessage = "Erro inesperado: $e";
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> register(
    String name,
    String email,
    String phone,
    String password,
    String username
  ) async {
    _setLoading(true);
    try {
      AppUser? newUser = await _authService.signUp(
        name: name,
        email: email,
        phone: phone,
        password: password,
        username: username
      );
      if (newUser != null) {
        _user = newUser;
        _errorMessage = null;
        return true;
      } else {
        _errorMessage = "Erro ao registrar usuário.";
        return false;
      }
    } on FirebaseAuthException catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (e) {
      _errorMessage = "Erro inesperado: $e";
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> forgotPassword(String email) async {
    _setLoading(true);
    try {
      await _authService.sendPasswordResetEmail(email: email);
      _errorMessage = null;
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (e) {
      _errorMessage = "Erro inesperado: $e";
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  /// Limpa a mensagem de erro.
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
