import 'package:firebase_auth/firebase_auth.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth;
  
  FirebaseAuthService(
    FirebaseAuth? auth
  ):_auth = auth ??= FirebaseAuth.instance;
  
  Future<UserCredential> createUser(String email, String password) async {
    try {
      final result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      return result;
    }on FirebaseAuthException catch (e) {
      final errorMessage = switch (e.code){
        "email-already-in-use" => "Email already in use",
        "invalid-email" => "Invalid email address",
        "operation-not-allowed" => "Operation not allowed",
        "weak-password" => "Weak password",
        _ => "Register failed"
      };
      throw Exception(errorMessage);
    } catch (e) {
      throw Exception("Register failed: ${e.toString()}");
    }
  }

  Future<UserCredential> signInUser(String email, String password) async {
    try {
      final result = await _auth.signInWithEmailAndPassword(email: email, password: password);
      return result;
    } on FirebaseAuthException catch (e) {
      final errorMessage = switch (e.code) {
        "user-not-found" => "User not found",
        "wrong-password" => "Wrong password",
        "invalid-email" => "Invalid email address",
        "user-disabled" => "User disabled",
        _ => "Login failed"
      };
      throw Exception(errorMessage);
    } catch (e) {
      throw Exception("Login failed: ${e.toString()}");
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw Exception("Sign out failed: ${e.toString()}");
    }
  }

  Future<User?> userChanges() => _auth.userChanges().first;
}