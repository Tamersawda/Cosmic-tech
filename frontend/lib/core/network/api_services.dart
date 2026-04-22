import 'package:dio/dio.dart';
import 'package:frontend/core/errors/app_exceptions.dart';
import 'package:frontend/core/network/dio_client.dart';

class ApiService {
  ApiService({Dio? dio}) : _dio = dio ?? DioClient.instance.client;

  final Dio _dio;

  // ─── GET ──────────────────────────────────────────────────────────────────
  Future<T> get<T>(
    String path, {
    Map<String, dynamic>? queryParams,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParams,
      );
      return _parse<T>(response.data, fromJson);
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (_) {
      throw const UnknownException();
    }
  }

  // ─── POST ─────────────────────────────────────────────────────────────────
  Future<T> post<T>(
    String path, {
    Map<String, dynamic>? data,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
      );
      return _parse<T>(response.data, fromJson);
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (_) {
      throw const UnknownException();
    }
  }

  // ─── PUT ──────────────────────────────────────────────────────────────────
  Future<T> put<T>(
    String path, {
    Map<String, dynamic>? data,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await _dio.put(
        path,
        data: data,
      );
      return _parse<T>(response.data, fromJson);
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (_) {
      throw const UnknownException();
    }
  }

  // ─── PATCH ────────────────────────────────────────────────────────────────
  Future<T> patch<T>(
    String path, {
    Map<String, dynamic>? data,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await _dio.patch(
        path,
        data: data,
      );
      return _parse<T>(response.data, fromJson);
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (_) {
      throw const UnknownException();
    }
  }

  // ─── DELETE ───────────────────────────────────────────────────────────────
  Future<T> delete<T>(
    String path, {
    Map<String, dynamic>? data,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await _dio.delete(
        path,
        data: data,
      );
      return _parse<T>(response.data, fromJson);
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (_) {
      throw const UnknownException();
    }
  }

  // ─── UPLOAD SINGLE FILE ───────────────────────────────────────────────────
  Future<T> uploadFile<T>(
    String path, {
    required String filePath,
    String fileField = 'file',
    Map<String, dynamic>? extraData,
    void Function(int sent, int total)? onProgress,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final formData = FormData.fromMap({
        ...?extraData,
        fileField: await MultipartFile.fromFile(filePath),
      });

      final response = await _dio.post(
        path,
        data: formData,
        options: Options(
          headers: {'Content-Type': 'multipart/form-data'},
        ),
        onSendProgress: onProgress,
      );
      return _parse<T>(response.data, fromJson);
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (_) {
      throw const UnknownException();
    }
  }

  // ─── UPLOAD MULTIPLE FILES ────────────────────────────────────────────────
  Future<T> uploadMultipleFiles<T>(
    String path, {
    required List<String> filePaths,
    String fileField = 'files',
    Map<String, dynamic>? extraData,
    void Function(int sent, int total)? onProgress,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final files = await Future.wait(
        filePaths.map((p) => MultipartFile.fromFile(p)),
      );

      final formData = FormData.fromMap({
        ...?extraData,
        fileField: files,
      });

      final response = await _dio.post(
        path,
        data: formData,
        options: Options(
          headers: {'Content-Type': 'multipart/form-data'},
        ),
        onSendProgress: onProgress,
      );
      return _parse<T>(response.data, fromJson);
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (_) {
      throw const UnknownException();
    }
  }

  // ─── DOWNLOAD FILE ────────────────────────────────────────────────────────
  Future<void> downloadFile(
    String path, {
    required String savePath,
    void Function(int received, int total)? onProgress,
  }) async {
    try {
      await _dio.download(
        path,
        savePath,
        onReceiveProgress: onProgress,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (_) {
      throw const UnknownException();
    }
  }

  // ─── Generic parser ───────────────────────────────────────────────────────
  T _parse<T>(dynamic data, T Function(dynamic)? fromJson) {
    if (fromJson != null) {
      try {
        return fromJson(data);
      } catch (_) {
        throw const ParseException();
      }
    }
    if (data is T) return data;
    throw const ParseException();
  }

  // ─── Error handler ────────────────────────────────────────────────────────
  AppException _handleError(DioException e) {
    switch (e.type) {
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        if (statusCode == 401) return const UnauthorisedException();
        if (statusCode == 403) {
          return const ServerException(
            'You do not have permission to perform this action.',
            statusCode: 403,
          );
        }
        if (statusCode == 404) {
          return const ServerException(
            'The requested resource was not found.',
            statusCode: 404,
          );
        }
        if (statusCode == 422) {
          final errors = e.response?.data?['errors'];
          final message = errors != null
              ? (errors as Map).values.first[0]
              : e.response?.data?['message'] ?? 'Validation failed.';
          return ServerException(message.toString(), statusCode: statusCode);
        }
        if (statusCode != null && statusCode >= 500) {
          return const ServerException(
            'Something went wrong on the server. Please try again later.',
            statusCode: 500,
          );
        }
        final message = e.response?.data?['message']?.toString() ??
            'Server error ($statusCode).';
        return ServerException(message, statusCode: statusCode);

      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const NetworkException('Connection timed out. Check your internet.');

      case DioExceptionType.connectionError:
        return const NetworkException('No internet connection.');

      case DioExceptionType.cancel:
        return const UnknownException('Request was cancelled.');

      default:
        return const UnknownException();
    }
  }
}