// lib/services/api_exceptions.dart
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class ApiException implements Exception {
  final String message;
  final dynamic raw; // original response payload (Map, List, or String)

  ApiException(this.message, {this.raw});

  @override
  String toString() => 'ApiException: $message';

  factory ApiException.fromDioError(DioException dioError) {
    try {
      debugPrint('DioException type: ${dioError.type}');
      final response = dioError.response;
      final data = response?.data;

      final extracted = _extractMessageFromResponseData(data);
      if (extracted != null && extracted.isNotEmpty) {
        return ApiException(extracted, raw: data);
      }

      if (response != null) {
        final statusMessage = response.statusMessage;
        final statusCode = response.statusCode;
        final msg = statusMessage != null && statusMessage.isNotEmpty
            ? '$statusMessage ($statusCode)'
            : 'Request failed (${statusCode ?? "unknown status"})';
        return ApiException(msg, raw: data);
      }

      switch (dioError.type) {
        case DioExceptionType.connectionTimeout:
          return ApiException('Connection timeout — please try again', raw: dioError);
        case DioExceptionType.receiveTimeout:
          return ApiException('Receive timeout — please try again', raw: dioError);
        case DioExceptionType.sendTimeout:
          return ApiException('Send timeout — please try again', raw: dioError);
        case DioExceptionType.cancel:
          return ApiException('Request cancelled', raw: dioError);
        case DioExceptionType.badCertificate:
          return ApiException('Bad certificate', raw: dioError);
        case DioExceptionType.connectionError:
          return ApiException('Unable to connect — check your internet', raw: dioError);
        case DioExceptionType.unknown:
        default:
          final fallback = dioError.message ?? 'Unknown network error';
          return ApiException(fallback, raw: dioError);
      }
    } catch (e, st) {
      debugPrint('Error parsing DioException: $e\n$st');
      return ApiException('Something went wrong', raw: dioError);
    }
  }

  static String? _extractMessageFromResponseData(dynamic data) {
    if (data == null) return null;

    // If it's a plain string, possibly JSON encoded or HTML
    if (data is String) {
      final trimmed = data.trim();
      if (trimmed.startsWith('{') || trimmed.startsWith('[')) {
        try {
          final decoded = jsonDecode(trimmed);
          return _extractMessageFromResponseData(decoded);
        } catch (_) {
          return _stripHtmlIfNeeded(trimmed);
        }
      }
      return _stripHtmlIfNeeded(trimmed);
    }

    // Map/dictionary: look for common message keys
    if (data is Map) {
      const keys = ['message', 'error', 'errors', 'detail', 'details', 'msg', 'description'];
      for (final k in keys) {
        if (data.containsKey(k)) {
          final v = data[k];
          final result = _normalizeMessageValue(v);
          if (result != null && result.isNotEmpty) return result;
        }
      }

      // Recurse into values to find nested messages
      for (final value in data.values) {
        final nested = _extractMessageFromResponseData(value);
        if (nested != null && nested.isNotEmpty) return nested;
      }
      return null;
    }

    // List: join messages (recursively)
    if (data is List) {
      final flattened = data.map((e) => _extractMessageFromResponseData(e)).whereType<String>().toList();
      if (flattened.isNotEmpty) return flattened.join('; ');
      return null;
    }

    // Fallback toString
    return data.toString();
  }

  static String? _normalizeMessageValue(dynamic v) {
    if (v == null) return null;
    if (v is String) return v;
    if (v is List) {
      final parts = <String>[];
      for (final item in v) {
        final msg = _normalizeMessageValue(item);
        if (msg != null && msg.isNotEmpty) parts.add(msg);
      }
      return parts.join('; ');
    }
    if (v is Map) {
      return _extractMessageFromResponseData(v);
    }
    return v.toString();
  }

  static String _stripHtmlIfNeeded(String s) {
    if (s.contains('<') && s.contains('>')) {
      final stripped = s.replaceAll(RegExp(r'<[^>]*>'), ' ').replaceAll(RegExp(r'\s+'), ' ').trim();
      return stripped.isNotEmpty ? stripped : s;
    }
    return s;
  }
}
