import 'package:chatting_app/model/profile.dart';
import 'package:chatting_app/services/firebase_auth_service.dart';
import 'package:chatting_app/static/firebase_auth_status.dart';
import 'package:flutter/widgets.dart';

class FirebaseAuthProvider extends ChangeNotifier{
  final FirebaseAuthService _service;
  FirebaseAuthProvider(this._service);

  String? _message;
  Profile? _profile;
  FirebaseAuthStatus _authStatus = FirebaseAuthStatus.unauthenticated; 

  String? get message => _message;
  Profile? get profile => _profile;
  FirebaseAuthStatus get authStatus => _authStatus;

  Future createAccount(String email, String password) async {
    try{
      _authStatus = FirebaseAuthStatus.creatingAccount;
      notifyListeners();

      await _service.createUser(email, password);

      _authStatus = FirebaseAuthStatus.accountCreated;
      _message = "Account created successfully";
    } catch (e) {
      _message = e.toString();
      _authStatus = FirebaseAuthStatus.error;
    }
    notifyListeners();
  }

  Future signInUser(String email, String password) async {
    try {
      _authStatus = FirebaseAuthStatus.authenticating;
      notifyListeners();

      final result = await _service.signInUser(email, password);
      _profile = Profile(
        name: result.user?.displayName,
        email: result.user?.email,
        photoUrl: result.user?.photoURL,
      );

      _authStatus = FirebaseAuthStatus.authenticated;
      _message = "Signed in successfully";
    } catch (e) {
      _message = e.toString();
      _authStatus = FirebaseAuthStatus.error;
    }
    notifyListeners();
  }

  Future signOutUser() async {
    try {
      _authStatus = FirebaseAuthStatus.signingOut;
      notifyListeners();

      await _service.signOut();

      _authStatus = FirebaseAuthStatus.unauthenticated;
      _message = "Signed out successfully";
    } catch (e) {
      _message = e.toString();
      _authStatus = FirebaseAuthStatus.error;
    }
    notifyListeners();
  }

  Future updateProfile() async {
    final user = await _service.userChanges();
    _profile = Profile(
      name: user?.displayName,
      email: user?.email,
      photoUrl: user?.photoURL,
    );
    notifyListeners();
  }
}