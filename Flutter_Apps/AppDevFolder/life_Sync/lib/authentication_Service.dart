import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      final user = userCredential.user;

      if (user != null) {
        await _db.collection('users').doc(user.uid).set(
          {
            'email': user.email,
            'displayName': user.displayName,
            'photoUrl': user.photoURL,
            'balance': 0.0,
            'createdAt': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true),
        );
      }

      return user;
    } catch (e) {
      print('Error signing in with Google: $e');
      return null;
    }
  }

  Future<User?> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = credential.user;
      
      if (user != null) {
        await user.updateDisplayName(displayName);
        await _db.collection('users').doc(user.uid).set({
          'email': email,
          'displayName': displayName,
          'photoUrl': '',
          'balance': 0.0,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      
      return user;
    } on FirebaseAuthException catch (e) {
      print('Error signing up: $e');
      rethrow;
    } catch (e) {
      print('Error signing up: $e');
      rethrow;
    }
  }

  Future<User?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user;
    } on FirebaseAuthException catch (e) {
      print('Error signing in: $e');
      rethrow;
    } catch (e) {
      print('Error signing in: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
  }

  User? getCurrentUser() => _auth.currentUser;
}