import 'package:ez_save/repositories/auth_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authRepositoryProvider = Provider<AuthService>((ref) {
  return AuthService(FirebaseAuth.instance);
});
