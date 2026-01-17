import 'dart:async';
import 'package:ez_save/core/router/app_paths.dart';
import 'package:ez_save/views/providers/auth_provider.dart';
import 'package:ez_save/views/providers/shared_prefs_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthViewModel extends AsyncNotifier<User?> {
  @override
  FutureOr<User?> build() {
    return ref.read(authRepositoryProvider).currentUser;
  }

  User? get currentUser => ref.read(authRepositoryProvider).currentUser;

  Stream<User?> get authStateChanges => ref.read(authRepositoryProvider).authStateChanges;

  Future<void> signInWithGoogle(BuildContext context) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final response = await ref.read(authRepositoryProvider).signInWithGoogle();

      if (response.isSuccess) {
        return response.data;
      } else {
        debugPrint('Google Sign-In failed: ${response.error}');
        // if (context.mounted) showTopOverlayError(context, response.error.toString());
        throw Exception(response.error);
      }
    });
  }

  Future<void> signInWithApple(BuildContext context) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final response = await ref.read(authRepositoryProvider).signInWithApple();

      if (response.isSuccess) {
        return response.data;
      } else {
        debugPrint('Apple Sign-In failed: ${response.error}');
        // if (context.mounted) showTopOverlayError(context, response.error.toString());
        throw Exception(response.error);
      }
    });
  }

  Future<void> signInAnonymously(BuildContext context) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final response = await ref.read(authRepositoryProvider).signInAnonymously();

      if (response.isSuccess) {
        if (context.mounted) {
          context.go(AppPaths.home.path);
        }
        return response.data;
      } else {
        debugPrint('Anonymous Sign-In failed: ${response.error}');
        // if (context.mounted) showTopOverlayError(context, response.error.toString());
        throw Exception(response.error);
      }
    });
  }

  Future<void> signOut(BuildContext context) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final response = await ref.read(authRepositoryProvider).signOut();

      if (response.isSuccess) {
        if (context.mounted) {
          final container = ProviderScope.containerOf(context);
          final sharedPrefsService = container.read(sharedPrefsRepositoryProvider);
          await sharedPrefsService.clear();

          if (context.mounted) context.go(AppPaths.welcome.path);
        }
        return null;
      } else {
        // if (context.mounted) showTopOverlayError(context, response.error.toString());
        throw Exception(response.error);
      }
    });
  }

  Future<void> deleteAccount(BuildContext context) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      var response = await ref.read(authRepositoryProvider).deletionRequested();
      if (!response.isSuccess || !context.mounted) {
        // if (context.mounted) showTopOverlayError(context, response.error.toString());
        throw Exception(response.error);
      }
      response = await ref.read(authRepositoryProvider).deleteAccount(context);
      if (!response.isSuccess) {
        // if (context.mounted) showTopOverlayError(context, response.error.toString());
        throw Exception(response.error);
      }
      return null;
    });
  }
}

final authViewModelProvider = AsyncNotifierProvider<AuthViewModel, User?>(() {
  return AuthViewModel();
});
