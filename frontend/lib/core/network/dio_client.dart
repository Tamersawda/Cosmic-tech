import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:frontend/core/constants/api_constansts.dart';
import 'package:frontend/core/errors/app_exceptions.dart';
import 'package:frontend/core/storage/shared_pref_service.dart';

class DioClient {
  DioClient._() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstansts.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.addAll([
      _AuthInterceptor(),
      if (kDebugMode) _LogInterceptor(),
    ]);
  }

  static final DioClient instance = DioClient._();
  late final Dio _dio;

  Dio get client => _dio;
}

// ─── Auth Interceptor ────────────────────────────────────────────────────────

class _AuthInterceptor extends Interceptor {
  final _prefs = SharedPrefService.instance;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = _prefs.getToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final appEx = _toAppException(err);
    handler.next(err.copyWith(message: appEx.message));
  }

  AppException _toAppException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const NetworkException('Connection timed out.');

      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final data = e.response?.data;
        if (statusCode == 401) return const UnauthorisedException();
        if (statusCode == 422) {
          if (data is Map) {
            final errors = data['errors'];
            final message = errors != null
                ? (errors as Map).values.first[0]
                : data['message'] ?? 'Validation failed.';
            return ServerException(message.toString(), statusCode: statusCode);
          }
          return ServerException(data?.toString() ?? 'Validation failed.', statusCode: statusCode);
        }
        
        final message = data is Map
            ? (data['message']?.toString() ?? 'Server error ($statusCode).')
            : data?.toString() ?? 'Server error ($statusCode).';
            
        return ServerException(message, statusCode: statusCode);

      case DioExceptionType.connectionError:
        return const NetworkException();

      case DioExceptionType.cancel:
        return const UnknownException('Request was cancelled.');

      default:
        return const UnknownException();
    }
  }
}

// ─── Log Interceptor (debug only) ────────────────────────────────────────────

class _LogInterceptor extends Interceptor {
  static final _divider = '─' * 50;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    debugPrint('\n$_divider');
    debugPrint('➡️  ${options.method.toUpperCase()}  ${options.uri}');
    if (options.data != null) debugPrint('📦 Body     : ${options.data}');
    if (options.queryParameters.isNotEmpty) {
      debugPrint('🔎 Params   : ${options.queryParameters}');
    }
    debugPrint(_divider);
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    debugPrint('\n$_divider');
    debugPrint('✅ ${response.statusCode}  ${response.realUri}');
    debugPrint('📨 Response : ${response.data}');
    debugPrint(_divider);
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    debugPrint('\n$_divider');
    debugPrint('❌ ERROR     : ${err.type.name}');
    debugPrint('💬 Message  : ${err.message}');
    debugPrint('🐛 Underlying: ${err.error}');
    if (err.response != null) {
      debugPrint('📨 Body     : ${err.response?.data}');
    }
    debugPrint(_divider);
    handler.next(err);
  }
}