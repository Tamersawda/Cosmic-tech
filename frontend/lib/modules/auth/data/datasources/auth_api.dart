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
    required String name,  // ← backend field
    required String email,
    required String password,
    required String role,  // ← backend field
  }) async {
    try {
      final response = await _dio.post(
        ApiConstansts.registrationUrl,
        data: {
          'name': name,   // ← matches backend
          'email':    email,
          'password': password,
          'role': role,   // ← matches backend
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
  Future<void> logout() async {
    try {
      await _dio.post(ApiConstansts.logoutUrl);
    } on DioException catch (e) {
      _logError('logout', e);
      if (e.type == DioExceptionType.badResponse) {
        throw _handleError(e);
      }
    } catch (e) {
      _logUnknown('logout', e);
    }
  }

  // ─── Parse response → UserModel ───────────────────────────────────────────
  UserModel _parseUser(dynamic data) {
    if (data == null) {
      throw const ParseException('Server returned empty response.');
    }
    if (data is! Map<String, dynamic>) {
      throw const ParseException('Unexpected response format.');
    }
    try {
      return UserModel.fromJson(data); // fromJson handles the data wrapper
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

        String extractMessage(String defaultMsg) {
          if (data is Map) {
            return data['message']?.toString() ?? defaultMsg;
          }
          return data?.toString() ?? defaultMsg;
        }

        if (statusCode == 400) {
          return ServerException(
            extractMessage('Bad request. Please check your input.'),
            statusCode: 400,
          );
        }
        if (statusCode == 401) {
          return UnauthorisedException(
            extractMessage('Session expired. Please log in again.'),
          );
        }
        if (statusCode == 403) {
          return ServerException(
            extractMessage('You do not have permission.'),
            statusCode: 403,
          );
        }
        if (statusCode == 404) {
          return ServerException(
            extractMessage('Resource not found.'),
            statusCode: 404,
          );
        }
        if (statusCode == 409) {
          return ServerException(
            extractMessage('An account with this email already exists.'),
            statusCode: 409,
          );
        }
        if (statusCode == 422) {
          if (data is Map && data['errors'] != null) {
            final errors = data['errors'] as Map;
            if (errors.isNotEmpty) {
              return ServerException(
                errors.values.first[0].toString(),
                statusCode: 422,
              );
            }
          }
          return ServerException(
            extractMessage('Validation failed.'),
            statusCode: 422,
          );
        }
        if (statusCode == 429) {
          return const ServerException(
            'Too many attempts. Please wait and try again.',
            statusCode: 429,
          );
        }
        if (statusCode != null && statusCode >= 500) {
          return const ServerException(
            'Something went wrong on the server. Please try again later.',
            statusCode: 500,
          );
        }
        return ServerException(
          extractMessage('Server error ($statusCode).'),
          statusCode: statusCode,
        );

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

  // ─── Debug logging ────────────────────────────────────────────────────────
  void _logError(String method, DioException e) {
    if (!kDebugMode) return;
    debugPrint('┌─── AuthApi.$method ERROR ───────────────────');
    debugPrint('│ Type   : ${e.type.name}');
    debugPrint('│ Status : ${e.response?.statusCode}');
    debugPrint('│ Data   : ${e.response?.data}');
    debugPrint('│ Message: ${e.message}');
    debugPrint('└─────────────────────────────────────────────');
  }

  void _logUnknown(String method, Object e) {
    if (!kDebugMode) return;
    debugPrint('┌─── AuthApi.$method UNKNOWN ERROR ───────────');
    debugPrint('│ Error: $e');
    debugPrint('└─────────────────────────────────────────────');
  }
}