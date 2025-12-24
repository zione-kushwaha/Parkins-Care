import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../../core/error/exceptions.dart';
import '../models/user_model.dart';
import '../../domain/entities/user_entity.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<UserModel> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
    required UserRole role,
  });

  Future<UserModel> signInWithGoogle();

  Future<void> signOut();

  Future<UserModel?> getCurrentUser();

  Future<void> resetPassword({required String email});

  Future<UserModel> updateProfile({
    required String userId,
    required Map<String, dynamic> updates,
  });

  Stream<UserModel?> get authStateChanges;
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth firebaseAuth;
  final FirebaseFirestore firestore;

  AuthRemoteDataSourceImpl({
    required this.firebaseAuth,
    required this.firestore,
  });

  @override
  Future<UserModel> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential userCredential = await firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);

      if (userCredential.user == null) {
        throw const AuthException('Sign in failed');
      }

      // Get user data from Firestore
      final DocumentSnapshot userDoc = await firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      if (!userDoc.exists) {
        throw const AuthException('User data not found');
      }

      final Map<String, dynamic> userData =
          userDoc.data() as Map<String, dynamic>;

      // Update last login time
      await firestore.collection('users').doc(userCredential.user!.uid).update({
        'lastLoginAt': DateTime.now().toIso8601String(),
      });

      return UserModel.fromJson({
        'id': userCredential.user!.uid,
        ...userData,
        'lastLoginAt': DateTime.now().toIso8601String(),
      });
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.message ?? 'Sign in failed');
    } catch (e) {
      throw AuthException(e.toString());
    }
  }

  @override
  Future<UserModel> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
    required UserRole role,
  }) async {
    try {
      final UserCredential userCredential = await firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);

      if (userCredential.user == null) {
        throw const AuthException('Sign up failed');
      }

      // Create user document in Firestore
      final UserModel newUser = UserModel(
        id: userCredential.user!.uid,
        email: email,
        name: name,
        role: role,
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
      );

      await firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .set(newUser.toJson());

      return newUser;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        throw const AuthException('Email already in use');
      } else if (e.code == 'weak-password') {
        throw const AuthException('Password is too weak');
      }
      throw AuthException(e.message ?? 'Sign up failed');
    } catch (e) {
      throw AuthException(e.toString());
    }
  }

  @override
  Future<UserModel> signInWithGoogle() async {
    try {
      // Initialize GoogleSignIn
      final GoogleSignIn googleSignIn = GoogleSignIn();

      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        throw const AuthException('Google sign in was cancelled');
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the credential
      final UserCredential userCredential = await firebaseAuth
          .signInWithCredential(credential);

      if (userCredential.user == null) {
        throw const AuthException('Google sign in failed');
      }

      // Check if user document exists in Firestore
      final DocumentSnapshot userDoc = await firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      UserModel user;

      if (!userDoc.exists) {
        // Create new user document for first-time Google sign in
        user = UserModel(
          id: userCredential.user!.uid,
          email: userCredential.user!.email ?? '',
          name: userCredential.user!.displayName ?? 'User',
          role: UserRole.patient, // Default role
          createdAt: DateTime.now(),
          lastLoginAt: DateTime.now(),
        );

        await firestore
            .collection('users')
            .doc(userCredential.user!.uid)
            .set(user.toJson());
      } else {
        // Update existing user's last login time
        final Map<String, dynamic> userData =
            userDoc.data() as Map<String, dynamic>;

        await firestore
            .collection('users')
            .doc(userCredential.user!.uid)
            .update({'lastLoginAt': DateTime.now().toIso8601String()});

        user = UserModel.fromJson({
          'id': userCredential.user!.uid,
          ...userData,
          'lastLoginAt': DateTime.now().toIso8601String(),
        });
      }

      return user;
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.message ?? 'Google sign in failed');
    } catch (e) {
      throw AuthException(e.toString());
    }
  }

  @override
  Future<void> signOut() async {
    try {
      // Sign out from both Firebase and Google
      await Future.wait([firebaseAuth.signOut(), GoogleSignIn().signOut()]);
    } catch (e) {
      throw AuthException(e.toString());
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final User? currentUser = firebaseAuth.currentUser;

      if (currentUser == null) {
        return null;
      }

      final DocumentSnapshot userDoc = await firestore
          .collection('users')
          .doc(currentUser.uid)
          .get();

      if (!userDoc.exists) {
        return null;
      }

      final Map<String, dynamic> userData =
          userDoc.data() as Map<String, dynamic>;

      return UserModel.fromJson({'id': currentUser.uid, ...userData});
    } catch (e) {
      throw AuthException(e.toString());
    }
  }

  @override
  Future<void> resetPassword({required String email}) async {
    try {
      await firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.message ?? 'Reset password failed');
    } catch (e) {
      throw AuthException(e.toString());
    }
  }

  @override
  Future<UserModel> updateProfile({
    required String userId,
    required Map<String, dynamic> updates,
  }) async {
    try {
      await firestore.collection('users').doc(userId).update(updates);

      final DocumentSnapshot userDoc = await firestore
          .collection('users')
          .doc(userId)
          .get();

      final Map<String, dynamic> userData =
          userDoc.data() as Map<String, dynamic>;

      return UserModel.fromJson({'id': userId, ...userData});
    } catch (e) {
      throw FirestoreException(e.toString());
    }
  }

  @override
  Stream<UserModel?> get authStateChanges {
    return firebaseAuth.authStateChanges().asyncMap((User? user) async {
      if (user == null) return null;

      try {
        final DocumentSnapshot userDoc = await firestore
            .collection('users')
            .doc(user.uid)
            .get();

        if (!userDoc.exists) return null;

        final Map<String, dynamic> userData =
            userDoc.data() as Map<String, dynamic>;

        return UserModel.fromJson({'id': user.uid, ...userData});
      } catch (e) {
        return null;
      }
    });
  }
}
