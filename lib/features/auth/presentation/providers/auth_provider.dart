import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/user.dart';
import '../../domain/repositories/user_repository.dart';

final userRepositoryProvider = Provider<UserRepository>((ref) {
  throw UnimplementedError('Override this provider');
});

class AuthState {
  final User? currentUser;
  final List<User> users;
  final bool isLoading;
  final String? error;

  AuthState({
    this.currentUser,
    this.users = const [],
    this.isLoading = false,
    this.error,
  });

  AuthState copyWith({
    User? currentUser,
    List<User>? users,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      currentUser: currentUser ?? this.currentUser,
      users: users ?? this.users,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final UserRepository _userRepository;

  AuthNotifier(this._userRepository) : super(AuthState());

  Future<void> loadUsers() async {
    try {
      final users = await _userRepository.getUsers();
      state = state.copyWith(users: users, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> login(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      state = state.copyWith(
        error: 'Por favor ingrese email y contraseña',
        isLoading: false,
      );
      return;
    }

    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await _userRepository.login(email, password);
      if (user == null) {
        state = state.copyWith(
          isLoading: false,
          error: 'Credenciales inválidas',
        );
      } else {
        state = state.copyWith(
          currentUser: user,
          isLoading: false,
          error: null,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Error al iniciar sesión: ${e.toString()}',
      );
    }
  }

  Future<void> createUser(User user) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _userRepository.createUser(user);
      await loadUsers();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> deleteUser(int id) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _userRepository.deleteUser(id);
      await loadUsers();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> updateUser(User user) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _userRepository.updateUser(user);
      await loadUsers();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  void logout() {
    state = AuthState();
  }

  bool get isAuthenticated => state.currentUser != null;
  bool get isAdmin => state.currentUser?.roleId == 2;
  bool get isEditor => state.currentUser?.roleId == 1;
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final repository = ref.watch(userRepositoryProvider);
  return AuthNotifier(repository);
});
