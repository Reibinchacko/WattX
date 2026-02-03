import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'database_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final DatabaseService _databaseService = DatabaseService();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Helper to map Firebase errors to user-friendly messages
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

  // Sign Up
  Future<UserCredential> signUp({
    required String email,
    required String password,
    required String name,
    String role = 'user',
  }) async {
    try {
      // Create user in Firebase Auth
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Seed initial data to Realtime Database
      await _databaseService.seedInitialData(
        userCredential.user!.uid,
        email,
        name,
        role: role,
      );

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(_getFriendlyErrorMessage(e));
    } catch (e) {
      throw Exception('Database Error: $e');
    }
  }

  // Sign In
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

  // Sign In with Google
  Future<UserCredential> signInWithGoogle() async {
    try {
      // Force account selection by signing out first
      await _googleSignIn.signOut();
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        throw Exception('Google Sign-In canceled');
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Once signed in, return the UserCredential
      UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      // Check if user is new (no record in database)
      if (userCredential.additionalUserInfo?.isNewUser ?? false) {
        // Seed initial data for new Google users
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

  // Sign Out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Reset Password
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
