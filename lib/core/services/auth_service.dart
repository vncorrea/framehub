import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/user_model.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  AuthService({FirebaseAuth? firebaseAuth, FirebaseFirestore? firestore})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  /// Cadastro de usuário: cria conta com Firebase Auth e salva dados adicionais no Firestore.
  Future<AppUser?> signUp({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    try {
      // Cria usuário no Firebase Authentication.
      UserCredential credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Monta o objeto AppUser com os dados fornecidos.
      AppUser user = AppUser(
        id: credential.user!.uid,
        name: name,
        email: email,
        phone: phone,
        profilePictureUrl: null,
      );

      // Salva os dados do usuário no Firestore.
      await _firestore.collection('users').doc(user.id).set(user.toMap());

      return user;
    } on FirebaseAuthException catch (e) {
      // Trate os erros específicos do FirebaseAuth
      print('Erro no cadastro: ${e.message}');
      rethrow;
    } catch (e) {
      // Trate outros erros inesperados
      print('Erro inesperado no cadastro: $e');
      rethrow;
    }
  }

  /// Login de usuário: autentica com Firebase Auth e retorna os dados do usuário a partir do Firestore.
  Future<AppUser?> signIn({required String email, required String password}) async {
    try {
      // Autentica o usuário
      UserCredential credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Busca os dados do usuário no Firestore.
      DocumentSnapshot<Map<String, dynamic>> doc = await _firestore
          .collection('users')
          .doc(credential.user!.uid)
          .get();

      if (doc.exists && doc.data() != null) {
        return AppUser.fromMap(doc.data()!, doc.id);
      } else {
        return null;
      }
    } on FirebaseAuthException catch (e) {
      print('Erro no login: ${e.message}');
      rethrow;
    } catch (e) {
      print('Erro inesperado no login: $e');
      rethrow;
    }
  }

  /// Envia email de recuperação de senha.
  Future<void> sendPasswordResetEmail({required String email}) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      print('Erro ao enviar email de recuperação: ${e.message}');
      rethrow;
    } catch (e) {
      print('Erro inesperado ao enviar email de recuperação: $e');
      rethrow;
    }
  }

  /// Finaliza a sessão do usuário.
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      print('Erro ao finalizar sessão: $e');
      rethrow;
    }
  }

  /// Stream para monitorar alterações no estado de autenticação do usuário.
  Stream<User?> get user {
    return _firebaseAuth.authStateChanges();
  }
}