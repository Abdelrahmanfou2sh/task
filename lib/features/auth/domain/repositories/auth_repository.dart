import '../../data/models/user_model.dart';

abstract class AuthRepository {
  Future<UserModel?> signIn(String email, String password);
  Future<UserModel?> signUp(String email, String password, String role);
  Future<void> signOut();
  Future<UserModel?> getCurrentUser();
  Future<String?> getUserRole(String uid);
} 