import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'database_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final DatabaseService _databaseService = DatabaseService();

  User? get currentUser => _auth.currentUser;

  String _getFriendlyErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found for that email.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'email-already-in-use':
        return 'The account already exists for that email.';
      case 'invalid-email':
        return 'The email address is invalid.';
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'invalid-credential':
        return 'Invalid credentials provided.';
      case 'operation-not-allowed':
        return 'This sign-in method is not allowed.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'network-request-failed':
        return 'Network error. Please check your connection.';
      default:
        return 'An authentication error occurred. (${e.message})';
    }
  }

  Future<UserCredential> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _databaseService.seedInitialData(
        userCredential.user!.uid,
        email,
        name,
      );

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(_getFriendlyErrorMessage(e));
    } catch (e) {
      throw Exception('Database Error: $e');
    }
  }

  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw Exception(_getFriendlyErrorMessage(e));
    } catch (e) {
      throw Exception('An error occurred during sign in.');
    }
  }

  Future<UserCredential> signInWithGoogle() async {
    try {
      await _googleSignIn.signOut();
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        throw Exception('Google Sign-In canceled');
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      if (userCredential.additionalUserInfo?.isNewUser ?? false) {
        await _databaseService.seedInitialData(
          userCredential.user!.uid,
          userCredential.user!.email ?? '',
          userCredential.user!.displayName ?? 'New User',
        );
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(_getFriendlyErrorMessage(e));
    } catch (e) {
      throw Exception('Google Sign-In Error: $e');
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw Exception(_getFriendlyErrorMessage(e));
    } catch (e) {
      throw Exception('An error occurred during password reset.');
    }
  }
}
