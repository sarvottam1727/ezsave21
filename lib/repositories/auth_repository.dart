import 'package:ez_save/models/api_res_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

class AuthService {
  AuthService(this._auth);
  final FirebaseAuth _auth;

  /// Set Firebase Auth language code to match app locale
  void setLanguageCode(String languageCode) {
    _auth.setLanguageCode(languageCode);
  }

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<ApiResponse> signInWithGoogle() async {
    try {
      // Initialize GoogleSignIn with configuration from google-services.json
      await _googleSignIn.initialize();

      final GoogleSignInAccount googleUser = await _googleSignIn.authenticate();

      final GoogleSignInAuthentication googleAuth = googleUser.authentication;

      final OAuthCredential credential = GoogleAuthProvider.credential(idToken: googleAuth.idToken);

      // Check if current user is anonymous and should link accounts
      final User? currentUser = _auth.currentUser;
      final bool isAnonymous = currentUser?.isAnonymous ?? false;

      UserCredential result;
      if (isAnonymous) {
        // Link anonymous account with Google credentials
        debugPrint('Linking anonymous account with Google credentials');
        result = await currentUser!.linkWithCredential(credential);
        debugPrint('Account linking successful. UID remains: ${result.user?.uid}');
      } else {
        // Regular sign-in (no linking needed)
        result = await _auth.signInWithCredential(credential);
      }

      final User? user = result.user;

      debugPrint('Google Sign-In successful: ${user?.email}');
      return ApiResponse(data: user);
    } on FirebaseAuthException catch (e) {
      debugPrint('Firebase Auth Error: ${e.code} - ${e.message}');

      // Handle case where the credential is already linked to another account
      if (e.code == 'credential-already-in-use') {
        // The credential is already linked to a different account
        // We need to sign in with that account instead of linking
        debugPrint('Credential already in use. Attempting to sign in with existing account...');

        try {
          // Get the credential from the exception and sign in with it
          final AuthCredential? existingCredential = e.credential;
          if (existingCredential != null) {
            // Save anonymous UID for potential data merge
            final String? anonymousUid = currentUser?.uid;

            // Sign in with the existing account
            final UserCredential result = await _auth.signInWithCredential(existingCredential);
            final User? user = result.user;

            debugPrint('Signed in with existing account: ${user?.email}');
            debugPrint('Anonymous UID was: $anonymousUid, New UID is: ${user?.uid}');

            // Return success with metadata about the account switch
            return ApiResponse(data: user, metadata: anonymousUid != null && user?.uid != anonymousUid ? {'accountSwitch': true, 'anonymousUid': anonymousUid, 'permanentUid': user?.uid} : null);
          }
        } catch (signInError) {
          debugPrint('Failed to sign in with existing credential: $signInError');
          return ApiResponse(error: 'This Google account is already linked to another user. Failed to sign in: $signInError');
        }

        return ApiResponse(error: 'This Google account is already linked to another user. Please sign in with that account instead.');
      } else if (e.code == 'provider-already-linked') {
        return ApiResponse(error: 'This account is already linked with Google.');
      } else if (e.code == 'invalid-credential') {
        return ApiResponse(error: 'The credential is invalid or has expired.');
      } else if (e.code == 'operation-not-allowed') {
        return ApiResponse(error: 'Google Sign-In is not enabled.');
      }

      return ApiResponse(error: 'Firebase authentication failed: ${e.message}');
    } catch (e) {
      debugPrint('Unexpected Google Sign-In Error: $e');
      return ApiResponse(error: 'Unexpected error during Google Sign-In: $e');
    }
  }

  Future<ApiResponse> signInWithApple() async {
    try {
      final AuthorizationCredentialAppleID appleCredential = await SignInWithApple.getAppleIDCredential(scopes: [AppleIDAuthorizationScopes.email, AppleIDAuthorizationScopes.fullName]);

      final OAuthCredential credential = OAuthProvider('apple.com').credential(idToken: appleCredential.identityToken, accessToken: appleCredential.authorizationCode);

      // Check if current user is anonymous and should link accounts
      final User? currentUser = _auth.currentUser;
      final bool isAnonymous = currentUser?.isAnonymous ?? false;

      UserCredential result;
      if (isAnonymous) {
        // Link anonymous account with Apple credentials
        debugPrint('Linking anonymous account with Apple credentials');
        result = await currentUser!.linkWithCredential(credential);
        debugPrint('Account linking successful. UID remains: ${result.user?.uid}');
      } else {
        // Regular sign-in (no linking needed)
        result = await _auth.signInWithCredential(credential);
      }

      final User? user = result.user;

      debugPrint('Apple Sign-In successful: ${user?.email}');
      return ApiResponse(data: user);
    } on SignInWithAppleAuthorizationException catch (e) {
      debugPrint('Apple Sign-In Authorization Error: ${e.code} - ${e.message}');
      if (e.code == AuthorizationErrorCode.canceled) {
        return ApiResponse(error: 'Sign in was canceled');
      }
      return ApiResponse(error: 'Apple Sign-In authorization failed: ${e.message}');
    } on FirebaseAuthException catch (e) {
      debugPrint('Firebase Auth Error: ${e.code} - ${e.message}');

      // Handle case where the credential is already linked to another account
      if (e.code == 'credential-already-in-use') {
        // The credential is already linked to a different account
        // We need to sign in with that account instead of linking
        debugPrint('Credential already in use. Attempting to sign in with existing account...');

        try {
          // Get the credential from the exception and sign in with it
          final AuthCredential? existingCredential = e.credential;
          if (existingCredential != null) {
            // Save anonymous UID for potential data merge
            final String? anonymousUid = currentUser?.uid;

            // Sign in with the existing account
            final UserCredential result = await _auth.signInWithCredential(existingCredential);
            final User? user = result.user;

            debugPrint('Signed in with existing account: ${user?.email}');
            debugPrint('Anonymous UID was: $anonymousUid, New UID is: ${user?.uid}');

            // Return success with metadata about the account switch
            return ApiResponse(data: user, metadata: anonymousUid != null && user?.uid != anonymousUid ? {'accountSwitch': true, 'anonymousUid': anonymousUid, 'permanentUid': user?.uid} : null);
          }
        } catch (signInError) {
          debugPrint('Failed to sign in with existing credential: $signInError');
          return ApiResponse(error: 'This Apple ID is already linked to another user. Failed to sign in: $signInError');
        }

        return ApiResponse(error: 'This Apple ID is already linked to another user. Please sign in with that account instead.');
      } else if (e.code == 'provider-already-linked') {
        return ApiResponse(error: 'This account is already linked with Apple.');
      } else if (e.code == 'invalid-credential') {
        return ApiResponse(error: 'The credential is invalid or has expired.');
      } else if (e.code == 'operation-not-allowed') {
        return ApiResponse(error: 'Apple Sign-In is not enabled.');
      } else if (e.code == 'account-exists-with-different-credential') {
        return ApiResponse(error: 'The account already exists with a different sign-in provider.');
      }

      return ApiResponse(error: 'Firebase authentication failed: ${e.message}');
    } catch (e) {
      debugPrint('Unexpected Apple Sign-In Error: $e');
      return ApiResponse(error: 'Unexpected error during Apple Sign-In: $e');
    }
  }

  Future<ApiResponse> signInAnonymously() async {
    try {
      final UserCredential result = await _auth.signInAnonymously();
      final User? user = result.user;
      return ApiResponse(data: user);
    } catch (e) {
      debugPrint('Unexpected Anonymous Sign-In Error: $e');
      return ApiResponse(error: 'Unexpected error during Anonymous Sign-In: $e');
    }
  }

  Future<ApiResponse> signOut({BuildContext? context}) async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
      return ApiResponse(data: true);
    } catch (e) {
      debugPrint('Error signing out: $e');
      return ApiResponse(error: e);
    }
  }

  Future<ApiResponse> deletionRequested() async {
    var user = _auth.currentUser;
    var userId = user?.uid;
    if (user != null) {
      for (final provider in user.providerData) {
        if (provider.providerId == 'google.com') {
          user = (await signInWithGoogle()).data;
        } else if (provider.providerId == 'apple.com') {
          user = (await signInWithApple()).data;
        } else {
          user = null;
        }
      }
    }
    if (user != null && userId != user.uid) {
      ApiResponse(error: 'Please sign in with the same provider to delete your account');
    }
    return ApiResponse(data: user != null && userId == user.uid);
  }

  Future<ApiResponse> deleteAccount(BuildContext context) async {
    try {
      await _auth.currentUser?.delete();
      return ApiResponse(data: true);
    } catch (e) {
      return ApiResponse(error: 'An error occurred');
    }
  }
}
