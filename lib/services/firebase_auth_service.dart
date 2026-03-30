import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/user_model.dart';

/// Firebase Authentication service
class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  // Auth state stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Current user
  User? get currentUser => _auth.currentUser;

  /// Register with email and password
  Future<AppUser?> registerWithEmail({
    required String email,
    required String password,
    required String displayName,
    String? phoneNumber,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        // Create user document in Realtime Database
        final appUser = AppUser(
          uid: credential.user!.uid,
          email: email,
          phoneNumber: phoneNumber,
          displayName: displayName,
          createdAt: DateTime.now(),
        );

        await _database
            .child('users')
            .child(credential.user!.uid)
            .set(appUser.toJson());

        // Update display name in Firebase Auth
        await credential.user!.updateDisplayName(displayName);

        return appUser;
      }
      return null;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    }
  }

  /// Sign in with email and password
  Future<AppUser?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        // Get user data from Realtime Database
        final snapshot =
            await _database.child('users').child(credential.user!.uid).get();

        if (snapshot.exists && snapshot.value != null) {
          final data = snapshot.value as Map<dynamic, dynamic>;
          return AppUser.fromJson(Map<String, dynamic>.from(data));
        }
      }
      return null;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    }
  }

  /// Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Get current app user
  Future<AppUser?> getCurrentAppUser() async {
    final user = _auth.currentUser;
    if (user != null) {
      final snapshot = await _database.child('users').child(user.uid).get();
      if (snapshot.exists && snapshot.value != null) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        return AppUser.fromJson(Map<String, dynamic>.from(data));
      }
    }
    return null;
  }

  /// Update user home area
  Future<void> updateHomeArea(String userId, String areaId) async {
    await _database.child('users').child(userId).update({
      'homeAreaId': areaId,
    });
  }

  /// Update notification areas
  Future<void> updateNotificationAreas(
      String userId, List<String> areas) async {
    await _database.child('users').child(userId).update({
      'notificationAreas': areas,
    });
  }

  /// Add notification area
  Future<void> addNotificationArea(String userId, String areaId) async {
    final snapshot = await _database
        .child('users')
        .child(userId)
        .child('notificationAreas')
        .get();
    List<dynamic> currentAreas = [];
    if (snapshot.exists && snapshot.value != null) {
      currentAreas = List<dynamic>.from(snapshot.value as List);
    }
    if (!currentAreas.contains(areaId)) {
      currentAreas.add(areaId);
      await _database.child('users').child(userId).update({
        'notificationAreas': currentAreas,
      });
    }
  }

  /// Remove notification area
  Future<void> removeNotificationArea(String userId, String areaId) async {
    final snapshot = await _database
        .child('users')
        .child(userId)
        .child('notificationAreas')
        .get();
    if (snapshot.exists && snapshot.value != null) {
      List<dynamic> currentAreas = List<dynamic>.from(snapshot.value as List);
      currentAreas.remove(areaId);
      await _database.child('users').child(userId).update({
        'notificationAreas': currentAreas,
      });
    }
  }

  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  /// Handle auth errors
  String _handleAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'operation-not-allowed':
        return 'Email/password accounts are not enabled.';
      case 'weak-password':
        return 'The password is too weak.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Wrong password provided.';
      default:
        return e.message ?? 'Authentication error';
    }
  }
}
