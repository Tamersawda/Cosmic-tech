import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/constants/api_constansts.dart';
import 'package:frontend/core/errors/app_exceptions.dart';
import 'package:frontend/core/network/dio_client.dart';
import 'package:frontend/core/storage/shared_pref_service.dart';
import 'package:frontend/modules/auth/presentation/providers/auth_provider.dart';

// ─── State ────────────────────────────────────────────────────────────────────
sealed class UserProfileState {
  const UserProfileState();
}

final class UserProfileIdle extends UserProfileState {
  const UserProfileIdle();
}

final class UserProfileLoading extends UserProfileState {
  const UserProfileLoading();
}

final class UserProfileSuccess extends UserProfileState {
  const UserProfileSuccess();
}

final class UserProfileError extends UserProfileState {
  const UserProfileError(this.message);
  final String message;
}

// ─── Basic info from SharedPrefs (no API call needed) ─────────────────────────
class UserBasicInfo {
  final String name;
  final String email;
  const UserBasicInfo({required this.name, required this.email});
}

// ─── Notifier ─────────────────────────────────────────────────────────────────
class UserProfileNotifier extends Notifier<UserProfileState> {
  @override
  UserProfileState build() => const UserProfileIdle();

  // ── Get name + email from SharedPreferences (already saved at register) ───
  // No API call needed — data was saved during registration
  UserBasicInfo getBasicInfo() {
    final prefs = SharedPrefService.instance;
    return UserBasicInfo(
      name: prefs.getName() ?? '',
      email: prefs.getEmail() ?? '',
    );
  }

  // ── Submit profile ────────────────────────────────────────────────────────
  Future<void> submitProfile({
    required String phone,
    required String dob,
    required String gender,
    required bool agreed,
  }) async {
    final error = _validate(
      phone: phone,
      dob: dob,
      gender: gender,
      agreed: agreed,
    );
    if (error != null) {
      state = UserProfileError(error);
      return;
    }

    state = const UserProfileLoading();

    try {
      final dio = DioClient.instance.client;
      final info = getBasicInfo();

      // Step 1: personal details
      await dio.post(
        ApiConstansts.userCompleteProfile,
        data: {
          'step': 1,
          'name': info.name.trim(),
          'phoneNumber': phone.trim(),
          'dateOfBirth': dob,
          'gender': gender.toLowerCase(),
        },
      );

      // Step 2: medical history (optional fields, send defaults)
      await dio.post(
        ApiConstansts.userCompleteProfile,
        data: {
          'step': 2,
          'medicalHistory': 'None',
          'allergies': ['None'],
          'currentMedications': ['None'],
        },
      );

      // Step 3: emergency contact (completes onboarding)
      await dio.post(
        ApiConstansts.userCompleteProfile,
        data: {
          'step': 3,
          'emergencyContact': {
            'name': info.name.trim(),
            'phoneNumber': phone.trim(),
          },
        },
      );

      // Mark profile complete in auth provider
      await ref.read(authProvider.notifier).completeProfile();

      state = const UserProfileSuccess();
    } on AppException catch (e) {
      state = UserProfileError(e.message);
    } catch (_) {
      state = const UserProfileError(
        'Failed to save profile. Please try again.',
      );
    }
  }

  // ─── Validation ───────────────────────────────────────────────────────────
  String? _validate({
    required String phone,
    required String dob,
    required String gender,
    required bool agreed,
  }) {
    if (phone.trim().isEmpty) return 'Phone number is required.';
    if (phone.trim().length < 7) return 'Enter a valid phone number.';
    if (!RegExp(r'^[0-9+\-\s()]+$').hasMatch(phone.trim())) {
      return 'Phone number contains invalid characters.';
    }
    if (dob.isEmpty) return 'Date of birth is required.';
    final dobDate = DateTime.tryParse(dob);
    if (dobDate == null) return 'Enter a valid date of birth.';
    final now = DateTime.now();
    final age =
        now.year -
        dobDate.year -
        ((now.month < dobDate.month ||
                (now.month == dobDate.month && now.day < dobDate.day))
            ? 1
            : 0);
    if (age < 10) return 'You must be at least 10 years old.';
    if (age > 100) return 'Enter a valid date of birth.';
    if (dobDate.isAfter(now)) return 'Date of birth cannot be in the future.';
    if (gender.isEmpty) return 'Please select a gender.';
    if (!agreed) return 'Please accept the Terms & Conditions.';
    return null;
  }

  void clearError() {
    if (state is UserProfileError) state = const UserProfileIdle();
  }
}

final userProfileProvider =
    NotifierProvider<UserProfileNotifier, UserProfileState>(
      UserProfileNotifier.new,
    );
