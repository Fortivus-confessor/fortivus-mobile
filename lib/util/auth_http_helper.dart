import 'dart:convert';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../services/auth_service.dart';

class AuthHttpHelper {
  static Future<http.Response> _makeRequest(
    Future<http.Response> Function(Map<String, String> headers) requestExecutor,
  ) async {
    final String? token = await AuthService().getAccessToken();

    if (token == null) {
      if (kDebugMode) {
        debugPrint('[AuthHttpHelper] ❌ Falha ao obter token. Sessão inválida.');
      }
      AuthService().reportAuthenticationError();
      return http.Response(
        json.encode({'error': 'Sessão inválida ou expirada.'}),
        401,
      );
    }

    final headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
      'X-Client-Timezone': DateTime.now().timeZoneName,
      'X-Client-Offset': DateTime.now().timeZoneOffset.inMinutes.toString(),
    };

    try {
      // 3. Executa requisição com timeout
      final response = await requestExecutor(headers).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          if (kDebugMode) {
            debugPrint('[AuthHttpHelper] ⏱️ Timeout na requisição HTTP');
          }
          return http.Response(
            json.encode({'error': 'Timeout na requisição'}),
            408,
          );
        },
      );

      // 4. Tratamento de erro 401
      if (response.statusCode == 401) {
        if (kDebugMode) {
          debugPrint('[AuthHttpHelper] 🚨 Recebido 401. Token revogado ou inválido no servidor.');
        }

        // Força logout
        await AuthService().logout();
        
        // Notifica erro de autenticação
        AuthService().reportAuthenticationError();
      }

      return response;
    } on TimeoutException {
      if (kDebugMode) {
        debugPrint('[AuthHttpHelper] ⏱️ TimeoutException capturado');
      }
      
      return http.Response(
        json.encode({'error': 'Timeout na requisição'}),
        408,
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[AuthHttpHelper] ❌ Erro na requisição HTTP: $e');
      }
      
      return http.Response(
        json.encode({'error': 'Erro na requisição: ${e.toString()}'}),
        500,
      );
    }
  }

  // ===== MÉTODOS PÚBLICOS =====

  /// GET request
  static Future<http.Response> get(
    Uri url, {
    Map<String, String>? headers,
  }) async {
    if (kDebugMode) {
      debugPrint('[AuthHttpHelper] 📤 GET: $url');
    }
    
    return _makeRequest(
      (authHeaders) => http.get(
        url,
        headers: {...authHeaders, ...?headers},
      ),
    );
  }

  /// POST request
  static Future<http.Response> post(
    Uri url, {
    Object? body,
    Map<String, String>? headers,
  }) async {
    if (kDebugMode) {
      debugPrint('[AuthHttpHelper] 📤 POST: $url');
    }

    // Codifica body se for Map
    Object? finalBody = body;
    if (body is Map) {
      finalBody = json.encode(body);
    }

    return _makeRequest(
      (authHeaders) => http.post(
        url,
        headers: {...authHeaders, ...?headers},
        body: finalBody,
      ),
    );
  }

  /// PUT request
  static Future<http.Response> put(
    Uri url, {
    Object? body,
    Map<String, String>? headers,
  }) async {
    if (kDebugMode) {
      debugPrint('[AuthHttpHelper] 📤 PUT: $url');
    }

    // Codifica body se for Map
    Object? finalBody = body;
    if (body is Map) {
      finalBody = json.encode(body);
    }

    return _makeRequest(
      (authHeaders) => http.put(
        url,
        headers: {...authHeaders, ...?headers},
        body: finalBody,
      ),
    );
  }

  /// DELETE request
  static Future<http.Response> delete(
    Uri url, {
    Object? body,
    Map<String, String>? headers,
  }) async {
    if (kDebugMode) {
      debugPrint('[AuthHttpHelper] 📤 DELETE: $url');
    }

    // Codifica body se for Map
    Object? finalBody = body;
    if (body is Map) {
      finalBody = json.encode(body);
    }

    return _makeRequest(
      (authHeaders) => http.delete(
        url,
        headers: {...authHeaders, ...?headers},
        body: finalBody,
      ),
    );
  }

  static Future<http.Response> patch(
    Uri url, {
    Object? body,
    Map<String, String>? headers,
  }) async {
    if (kDebugMode) {
      debugPrint('[AuthHttpHelper] 📤 PATCH: $url');
    }
    Object? finalBody = body;
    if (body is Map) {
      finalBody = json.encode(body);
    }

    return _makeRequest(
      (authHeaders) => http.patch(
        url,
        headers: {...authHeaders, ...?headers},
        body: finalBody,
      ),
    );
  }
}