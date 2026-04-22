import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:frontend/core/constants/api_constansts.dart';
import 'package:frontend/core/errors/app_exceptions.dart';
import 'package:frontend/core/network/dio_client.dart';
import 'package:frontend/modules/auth/data/models/user_model.dart';

class AuthApi {
  AuthApi({Dio? dio}) : _dio = dio ?? DioClient.instance.client;

  final Dio _dio;

  // ─── Register ─────────────────────────────────────────────────────────────
  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstansts.registrationUrl,
        data: {
          'name': name,
          'email':    email,
          'password': password,
          'role': role,
        },
      );
      return _parseUser(response.data);
    } on DioException catch (e) {
      _logError('register', e);
      throw _handleError(e);
    } on FormatException {
      throw const ParseException();
    } catch (e) {
      _logUnknown('register', e);
      throw const UnknownException();
    }
  }

  // ─── Login ────────────────────────────────────────────────────────────────
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstansts.loginUrl,
        data: {
          'email':    email,
          'password': password,
        },
      );
      return _parseUser(response.data);
    } on DioException catch (e) {
      _logError('login', e);
      throw _handleError(e);
    } on FormatException {
      throw const ParseException();
    } catch (e) {
      _logUnknown('login', e);
      throw const UnknownException();
    }
  }

  // ─── Logout ───────────────────────────────────────────────────────────────
  // Uncomment when backend endpoint is ready
  /*
  Future<void> logout() async {
    try {
      await _dio.post(ApiConstansts.logoutUrl);
    } on DioException catch (e) {
      _logError('logout', e);
      // Only throw on server errors
      // Network errors are silently ignored so local session still clears
      if (e.type == DioExceptionType.badResponse) {
        throw _handleError(e);
      }
    } catch (e) {
      _logUnknown('logout', e);
    }
  }
  */

  // ─── Parse response → UserModel ───────────────────────────────────────────
  UserModel _parseUser(dynamic data) {
    if (data == null) {
      throw const ParseException('Server returned empty response.');
    }
    if (data is! Map<String, dynamic>) {
      throw const ParseException('Unexpected response format.');
    }
    try {
      return UserModel.fromJson(data);
    } catch (_) {
      throw const ParseException('Failed to parse user data.');
    }
  }

  // ─── Error handler ────────────────────────────────────────────────────────
  AppException _handleError(DioException e) {
    switch (e.type) {
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final data       = e.response?.data;

        // ── 400 Bad Request ──────────────────────────────
        if (statusCode == 400) {
          final message = data?['message']?.toString() ??
              'Bad request. Please check your input.';
          return ServerException(message, statusCode: 400);
        }

        // ── 401 Unauthorised ─────────────────────────────
        if (statusCode == 401) {
          final message = data?['message']?.toString() ??
              'Session expired. Please log in again.';
          return UnauthorisedException(message);
        }

        // ── 403 Forbidden ────────────────────────────────
        if (statusCode == 403) {
          final message = data?['message']?.toString() ??
              'You do not have permission to perform this action.';
          return ServerException(message, statusCode: 403);
        }

        // ── 404 Not found ────────────────────────────────
        if (statusCode == 404) {
          final message = data?['message']?.toString() ??
              'The requested resource was not found.';
          return ServerException(message, statusCode: 404);
        }

        // ── 409 Conflict (email already exists) ──────────
        if (statusCode == 409) {
          final message = data?['message']?.toString() ??
              'An account with this email already exists.';
          return ServerException(message, statusCode: 409);
        }

        // ── 422 Validation error ─────────────────────────
        if (statusCode == 422) {
          final errors  = data?['errors'];
          final message = errors != null
              ? (errors as Map).values.first[0].toString()
              : data?['message']?.toString() ?? 'Validation failed.';
          return ServerException(message, statusCode: 422);
        }

        // ── 429 Too many requests ─────────────────────────
        if (statusCode == 429) {
          return const ServerException(
            'Too many attempts. Please wait a moment and try again.',
            statusCode: 429,
          );
        }

        // ── 500+ Server errors ───────────────────────────
        if (statusCode != null && statusCode >= 500) {
          return const ServerException(
            'Something went wrong on the server. Please try again later.',
            statusCode: 500,
          );
        }

        // ── Fallback ─────────────────────────────────────
        final message = data?['message']?.toString() ??
            'Server error ($statusCode).';
        return ServerException(message, statusCode: statusCode);

      case DioExceptionType.connectionTimeout:
        return const NetworkException(
          'Connection timed out. Please check your internet.',
        );

      case DioExceptionType.sendTimeout:
        return const NetworkException(
          'Request timed out while sending. Please try again.',
        );

      case DioExceptionType.receiveTimeout:
        return const NetworkException(
          'Server took too long to respond. Please try again.',
        );

      case DioExceptionType.connectionError:
        return const NetworkException(
          'Unable to connect. Please check your internet connection.',
        );

      case DioExceptionType.badCertificate:
        return const NetworkException(
          'Security certificate error. Please contact support.',
        );

      case DioExceptionType.cancel:
        return const UnknownException('Request was cancelled.');

      default:
        return const UnknownException(
          'An unexpected error occurred. Please try again.',
        );
    }
  }

  // ─── Debug logging (debug builds only) ───────────────────────────────────
  void _logError(String method, DioException e) {
    if (!kDebugMode) return;
    debugPrint('┌─── AuthApi.$method ERROR ───────────────────');
    debugPrint('│ Type       : ${e.type.name}');
    debugPrint('│ Status     : ${e.response?.statusCode}');
    debugPrint('│ Data       : ${e.response?.data}');
    debugPrint('│ Message    : ${e.message}');
    debugPrint('└─────────────────────────────────────────────');
  }

  void _logUnknown(String method, Object e) {
    if (!kDebugMode) return;
    debugPrint('┌─── AuthApi.$method UNKNOWN ERROR ───────────');
    debugPrint('│ Error: $e');
    debugPrint('└─────────────────────────────────────────────');
  }
}