import 'package:firebase_auth/firebase_auth.dart';
import 'package:trucker/services/database/database_service.dart';
/*

AUTHENTICATION SERVICE

import 'package:firebase_auth/firebase_auth.dart';
This handles everything to do with authentication in firebase

--------------------------------------------------------------------------------

- Login
- Register
- Logout
- Delete account

 */

class AuthService {
  // get instance of the auth
  final _auth = FirebaseAuth.instance;

  // get current user and uid
  User? getCurrentUser() => _auth.currentUser;
  String getCurrentUid() => _auth.currentUser!.uid;

  // login -> email and pw
  Future<UserCredential> loginEmailPasswod(String email, password) async {
    // attemp login
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      return userCredential;
    }
    // catch any errors
    on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }

  // register -> email and pw
  Future<UserCredential> registerEmailPassword(String email, password) async {
    // attemp login
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      return userCredential;
    }
    // catch any errors
    on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }

  // logout
  Future<void> logout() async {
    await _auth.signOut();
  }

  // delete account
  Future<void> deleteAccount() async {
    //get current uid
    User? user = getCurrentUser();

    if (user != null) {
      //delete users data from firestore
      await DatabaseService().deleteUserInfoFromFirebase(user.uid);

      //delete the users auth record
      await user.delete();
    }
  }
}
