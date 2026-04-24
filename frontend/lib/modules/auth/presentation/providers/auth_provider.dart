import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/errors/app_exceptions.dart';
import 'package:frontend/core/storage/shared_pref_service.dart';
import 'package:frontend/modules/auth/data/datasources/auth_api.dart';
import 'package:frontend/modules/auth/data/models/user_model.dart';
import 'package:frontend/modules/auth/data/repositories/auth_respository.dart';

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(
    authApi: AuthApi(),
    prefs:   SharedPrefService.instance,
  ),
);

// ─── State ────────────────────────────────────────────────────────────────────
sealed class AuthState {
  const AuthState();
}

final class AuthLoading extends AuthState {
  const AuthLoading();
}

final class AuthAuthenticated extends AuthState {
  const AuthAuthenticated(this.user);
  final UserModel user;
}

final class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

// After register — go to profile completion
final class AuthRegistered extends AuthState {
  const AuthRegistered(this.user);
  final UserModel user;
}

// Token exists but profile not complete — app restart / new device
final class AuthNeedsProfile extends AuthState {
  const AuthNeedsProfile(this.user);
  final UserModel user;
}

final class AuthError extends AuthState {
  const AuthError(this.message);
  final String message;
}

// ─── Notifier ─────────────────────────────────────────────────────────────────
class AuthNotifier extends Notifier<AuthState> {
  late final AuthRepository _repository;

  @override
  AuthState build() {
    _repository = ref.read(authRepositoryProvider);
    Future.microtask(restoreSession);
    return const AuthLoading();
  }

  // ── Restore session ───────────────────────────────────────────────────────
  Future<void> restoreSession() async {
    final user = _repository.tryRestoreSession();

    if (user == null) {
      state = const AuthUnauthenticated();
      return;
    }

    // is_profile_completed false → force back to onboarding
    if (!user.isProfileComplete) {
      state = AuthNeedsProfile(user);
      return;
    }

    state = AuthAuthenticated(user);
  }

  // ── Register ──────────────────────────────────────────────────────────────
  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    state = const AuthLoading();
    try {
      final user = await _repository.register(
        name: name,
        email:    email,
        password: password,
        role: role,
      );
      // Backend returns is_profile_completed: false
      // Go to profile completion screens
      state = AuthRegistered(user);
    } on AppException catch (e) {
      state = AuthError(e.message);
    } catch (_) {
      state = const AuthError('An unexpected error occurred.');
    }
  }

  // ── Login ─────────────────────────────────────────────────────────────────
  Future<void> login({
    required String email,
    required String password,
  }) async {
    state = const AuthLoading();
    try {
      final user = await _repository.login(
        email:    email,
        password: password,
      );

      if (!user.isProfileComplete) {
        state = AuthNeedsProfile(user);
        return;
      }

      state = AuthAuthenticated(user);
    } on AppException catch (e) {
      state = AuthError(e.message);
    } catch (_) {
      state = const AuthError('An unexpected error occurred.');
    }
  }

  // ── Complete profile ──────────────────────────────────────────────────────
  Future<void> completeProfile() async {
    final current = state;
    final user = switch (current) {
      AuthRegistered(:final user)   => user,
      AuthNeedsProfile(:final user) => user,
      _                             => null,
    };
    if (user == null) return;

    state = const AuthLoading();
    try {
      await _repository.markProfileComplete();
      state = AuthAuthenticated(
        user.copyWith(
          isProfileComplete: true,
          onboardingStep:    99,
        ),
      );
    } on AppException catch (e) {
      state = AuthError(e.message);
    } catch (_) {
      state = const AuthError('An unexpected error occurred.');
    }
  }

  // ── Update onboarding step ────────────────────────────────────────────────
  Future<void> updateOnboardingStep(int step) async {
    await _repository.updateOnboardingStep(step);
  }

  // ── Logout ────────────────────────────────────────────────────────────────
  Future<void> logout() async {
    state = const AuthLoading();
    try {
      await _repository.logout();
    } finally {
      state = const AuthUnauthenticated();
    }
  }

  UserModel? get currentUser =>
      state is AuthAuthenticated ? (state as AuthAuthenticated).user : null;

  void clearError() {
    if (state is AuthError) state = const AuthUnauthenticated();
  }
}

// ─── Providers ────────────────────────────────────────────────────────────────
final authProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);

final currentUserProvider = Provider<UserModel?>(
  (ref) => ref.watch(
    authProvider.select((s) => s is AuthAuthenticated ? s.user : null),
  ),
);

final isAuthenticatedProvider = Provider<bool>(
  (ref) => ref.watch(authProvider) is AuthAuthenticated,
);

final userRoleProvider = Provider<String?>(
  (ref) => ref.watch(
    authProvider.select(
      (s) => s is AuthAuthenticated ? s.user.role : null,
    ),
  ),
);

// Convenience provider for onboarding step
final onboardingStepProvider = Provider<int>(
  (ref) => ref.watch(
    authProvider.select((s) {
      if (s is AuthRegistered)   return s.user.onboardingStep;
      if (s is AuthNeedsProfile) return s.user.onboardingStep;
      if (s is AuthAuthenticated) return s.user.onboardingStep;
      return 0;
    }),
  ),
);