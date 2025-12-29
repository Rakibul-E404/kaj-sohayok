import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Response, MultipartFile;
import 'package:http/http.dart';
import 'package:kaz_bd/utilities/logger_util.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';

import '../controllers/svp_profile_screen_controller.dart';
import '../controllers/user_profile_screen_controller.dart';
import '../utilities/app_constants.dart';
import '../utilities/enum.dart';
import 'get_storage.dart' show GetStorageModel;
import 'network_response.dart';

class NetworkCaller {
  // Generic function to handle any HTTP request (GET, POST, PUT, DELETE)
  Future<NetworkResponse> _request(
    String method,
    String url, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    bool isLogin = false,
  }) async {
    final Uri uri = Uri.parse(url);
    final Map<String, String> requestHeaders = <String, String>{
      'Content-Type': 'application/json',
      ...?headers,
    };

    try {
      // Make the request using a single method instead of multiple ones.
      Response response;
      switch (method.toUpperCase()) {
        case 'POST':
          response =
              await post(uri, headers: requestHeaders, body: jsonEncode(body));
          break;
        case 'GET':
          response = await get(uri, headers: requestHeaders);
          break;
        case 'PUT':
          response =
              await put(uri, headers: requestHeaders, body: jsonEncode(body));
          break;
        case 'DELETE':
          response = await delete(uri, headers: requestHeaders);
          break;
        case 'PATCH':
          response =
              await patch(uri, headers: requestHeaders, body: jsonEncode(body));
          break;
        default:
          throw Exception('Unsupported HTTP method: $method');
      }

      // Handle the response
      return _handleResponse(response, isLogin);
    } on SocketException {
      debugPrint('No Internet Connection');
      return NetworkResponse(
        isSuccess: false,
        errorMessage: 'No internet connection. Please check your network.',
      );
    } on HttpException {
      debugPrint('HTTP Exception');
      return NetworkResponse(
        isSuccess: false,
        errorMessage: 'Server error occurred. Please try again later.',
      );
    } on FormatException {
      debugPrint('Invalid Response Format');
      return NetworkResponse(
        isSuccess: false,
        errorMessage: 'Invalid response from server.',
      );
    } catch (e) {
      debugPrint('Error: $e');
      return NetworkResponse(
        isSuccess: false,
        errorMessage: 'An unexpected error occurred: ${e.toString()}',
      );
    }
  }

  // Handles response from the HTTP request and returns a NetworkResponse
  Future<NetworkResponse> _handleResponse(
      Response response, bool isLogin) async {
    try {
      Map<String, dynamic>? jsonResponse;

      // Try to parse JSON response
      try {
        if (response.body.isNotEmpty) {
          jsonResponse = jsonDecode(response.body);
        }
      } catch (e) {
        debugPrint('Failed to parse JSON: $e');
        // If JSON parsing fails, return error
        return NetworkResponse(
          isSuccess: false,
          statusCode: response.statusCode,
          errorMessage: 'Invalid JSON response from server',
        );
      }

      // Handle successful responses (200, 201)
      if (response.statusCode == 200 || response.statusCode == 201) {
        return NetworkResponse(
          isSuccess: true,
          jsonResponse: jsonResponse,
          statusCode: response.statusCode,
        );
      }

      // Handle 401 Unauthorized - Token expired or invalid
      if (response.statusCode == 401 && !isLogin) {
        debugPrint('Unauthorized: Token expired or invalid');
        await _handleUnauthorized(message: 'Session Expired');
        return NetworkResponse(
          isSuccess: false,
          statusCode: response.statusCode,
          jsonResponse: jsonResponse,
          errorMessage: jsonResponse?['message'] ??
              'Session expired. Please login again.',
        );
      }

      // Handle custom 555 status code (if your backend uses this)
      if (response.statusCode == 555 && !isLogin) {
        final String? message = jsonResponse?['message']?.toString();
        LoggerUtils.error(message);
        if (message != null &&
            message.isNotEmpty &&
            message == "You are blocked by admin.") {
          await _handleUnauthorized(message: message);
          return NetworkResponse(
            isSuccess: false,
            statusCode: response.statusCode,
            jsonResponse: jsonResponse,
            errorMessage: 'Access denied. You do not have permission.',
          );
        }
      }

      // Handle 403 Forbidden - User doesn't have permission
      if (response.statusCode == 403 && !isLogin) {
        debugPrint('Forbidden: Access denied');
        return NetworkResponse(
          isSuccess: false,
          statusCode: response.statusCode,
          jsonResponse: jsonResponse,
          errorMessage: jsonResponse?['message'] ??
              'Access denied. You do not have permission.',
        );
      }

      // Handle 404 Not Found
      if (response.statusCode == 404) {
        debugPrint('Not Found: Resource not found');
        return NetworkResponse(
          isSuccess: false,
          statusCode: response.statusCode,
          jsonResponse: jsonResponse,
          errorMessage:
              jsonResponse?['message'] ?? 'Requested resource not found.',
        );
      }

      // Handle 500 Internal Server Error
      if (response.statusCode == 500) {
        debugPrint('Server Error: Internal server error');
        return NetworkResponse(
          isSuccess: false,
          statusCode: response.statusCode,
          jsonResponse: jsonResponse,
          errorMessage: 'Server error. Please try again later.',
        );
      }

      // Handle 503 Service Unavailable
      if (response.statusCode == 503) {
        debugPrint('Service Unavailable: Server is down');
        return NetworkResponse(
          isSuccess: false,
          statusCode: response.statusCode,
          jsonResponse: jsonResponse,
          errorMessage:
              'Service temporarily unavailable. Please try again later.',
        );
      }

      // Handle other unsuccessful responses
      return NetworkResponse(
        isSuccess: false,
        statusCode: response.statusCode,
        jsonResponse: jsonResponse,
        errorMessage: jsonResponse?['message'] ??
            'Request failed with status: ${response.statusCode}',
      );
    } catch (e) {
      debugPrint('Error handling response: $e');
      return NetworkResponse(
        isSuccess: false,
        errorMessage: 'Error processing response: ${e.toString()}',
      );
    }
  }

  // Handle unauthorized access (401) - Clear tokens and navigate to login
  Future<void> _handleUnauthorized({required String message}) async {
    try {
      final String? currentRole = await GetStorageModel().read(
        AppConstants.currentRole,
      );

      // Handle logout based on user role
      if (currentRole != null) {
        if (currentRole == UserRole.user.name) {
          // Check if controller is registered before using it
          if (Get.isRegistered<UserProfileScreenController>()) {
            Get.find<UserProfileScreenController>().handleLogOut();
          }
        } else if (currentRole == UserRole.provider.name) {
          // Check if controller is registered before using it
          if (Get.isRegistered<SvpProfileScreenController>()) {
            Get.find<SvpProfileScreenController>().handleLogOut();
          }
        }
      }

      // Show a snackbar to inform the user
      Get.snackbar(
        'Error',
        message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
        duration: const Duration(seconds: 3),
      );
    } catch (e) {
      debugPrint('Error handling unauthorized: $e');
    }
  }

  // POST Request
  Future<NetworkResponse> postRequest(
    String url, {
    Map<String, dynamic>? body,
    bool isLogin = false,
    Map<String, String>? headers,
  }) async {
    return _request('POST', url,
        body: body, isLogin: isLogin, headers: headers);
  }

  // GET Request
  Future<NetworkResponse> getRequest(
    String url, {
    Map<String, dynamic>? body,
    bool isLogin = false,
    Map<String, String>? headers,
  }) async {
    return _request('GET', url, body: body, isLogin: isLogin, headers: headers);
  }

  // PUT Request
  Future<NetworkResponse> putRequest(
    String url, {
    Map<String, dynamic>? body,
    bool isLogin = false,
    Map<String, String>? headers,
  }) async {
    return _request('PUT', url, body: body, isLogin: isLogin, headers: headers);
  }

  // DELETE Request
  Future<NetworkResponse> deleteRequest(
    String url, {
    Map<String, dynamic>? body,
    bool isLogin = false,
    Map<String, String>? headers,
  }) async {
    return _request('DELETE', url,
        body: body, isLogin: isLogin, headers: headers);
  }

  // PATCH Request
  Future<NetworkResponse> patchRequest(
    String url, {
    Map<String, dynamic>? body,
    bool isLogin = false,
    Map<String, String>? headers,
  }) async {
    return _request('PATCH', url,
        body: body, isLogin: isLogin, headers: headers);
  }

  // ===================== MULTIPART METHODS =====================

  // Helper method to convert dynamic values to string fields
  Map<String, String> _convertToStringFields(Map<String, dynamic> body) {
    final Map<String, String> fields = <String, String>{};

    for (final MapEntry<String, dynamic> entry in body.entries) {
      final dynamic value = entry.value;

      if (value is Map || value is List) {
        fields[entry.key] = jsonEncode(value);
      } else if (value == null) {
        continue;
      } else {
        fields[entry.key] = value.toString();
      }
    }

    return fields;
  }

  // Generic multipart request handler
  Future<NetworkResponse> _multipartRequest(
    String method,
    String url, {
    Map<String, String>? fields,
    Map<String, File>? files,
    Map<String, String>? headers,
    bool isLogin = false,
  }) async {
    try {
      final Uri uri = Uri.parse(url);
      final MultipartRequest request =
          MultipartRequest(method.toUpperCase(), uri);

      // Add headers
      if (headers != null) {
        request.headers.addAll(headers);
      }

      // Add fields
      if (fields != null) {
        request.fields.addAll(fields);
      }

      // Add files
      if (files != null) {
        for (final MapEntry<String, File> entry in files.entries) {
          final String fieldName = entry.key;
          final File file = entry.value;

          // Check if file exists
          if (!await file.exists()) {
            debugPrint('File not found: ${file.path}');
            return NetworkResponse(
              isSuccess: false,
              errorMessage: 'File not found: ${file.path}',
            );
          }

          // Get the mime type of the file
          final String? mimeType = lookupMimeType(file.path);
          final List<String>? mimeTypeParts = mimeType?.split('/');

          // Add the file as a MultipartFile
          request.files.add(
            await MultipartFile.fromPath(
              fieldName,
              file.path,
              contentType: mimeType != null
                  ? MediaType(mimeTypeParts?[0] ?? 'application',
                      mimeTypeParts?[1] ?? 'octet-stream')
                  : null,
            ),
          );
        }
      }

      // Send the request
      final StreamedResponse streamedResponse = await request.send();

      // Convert StreamedResponse to Response
      final Response response = await Response.fromStream(streamedResponse);

      // Handle the response using existing method
      return _handleResponse(response, isLogin);
    } on SocketException {
      debugPrint('Multipart: No Internet Connection');
      return NetworkResponse(
        isSuccess: false,
        errorMessage: 'No internet connection. Please check your network.',
      );
    } on HttpException {
      debugPrint('Multipart: HTTP Exception');
      return NetworkResponse(
        isSuccess: false,
        errorMessage: 'Server error occurred. Please try again later.',
      );
    } catch (e) {
      debugPrint('Multipart Error: $e');
      return NetworkResponse(
        isSuccess: false,
        errorMessage: 'Upload failed: ${e.toString()}',
      );
    }
  }

  // Multipart Request (for form data with files)
  Future<NetworkResponse> multipartRequest(
    String url, {
    String method = 'POST',
    Map<String, String>? fields,
    Map<String, File>? files,
    Map<String, String>? headers,
    bool isLogin = false,
  }) async {
    return _multipartRequest(
      method,
      url,
      fields: fields,
      files: files,
      headers: headers,
      isLogin: isLogin,
    );
  }

  // Multipart POST Request
  Future<NetworkResponse> multipartPostRequest(
    String url, {
    Map<String, String>? fields,
    Map<String, File>? files,
    Map<String, String>? headers,
    bool isLogin = false,
  }) async {
    return multipartRequest(
      url,
      method: 'POST',
      fields: fields,
      files: files,
      headers: headers,
      isLogin: isLogin,
    );
  }

  // Multipart PUT Request
  Future<NetworkResponse> multipartPutRequest(
    String url, {
    Map<String, String>? fields,
    Map<String, File>? files,
    Map<String, String>? headers,
    bool isLogin = false,
  }) async {
    return multipartRequest(
      url,
      method: 'PUT',
      fields: fields,
      files: files,
      headers: headers,
      isLogin: isLogin,
    );
  }

  // Multipart PATCH Request
  Future<NetworkResponse> multipartPatchRequest(
    String url, {
    Map<String, String>? fields,
    Map<String, File>? files,
    Map<String, String>? headers,
    bool isLogin = false,
  }) async {
    return multipartRequest(
      url,
      method: 'PATCH',
      fields: fields,
      files: files,
      headers: headers,
      isLogin: isLogin,
    );
  }

  // Enhanced method that accepts Map<String, dynamic> and handles nested objects
  Future<NetworkResponse> multipartRequest2(
    String url, {
    Map<String, dynamic>? body,
    Map<String, File>? files,
    Map<String, String>? headers,
    bool isLogin = false,
    String method = 'PATCH',
  }) async {
    Map<String, String>? fields;
    if (body != null) {
      fields = _convertToStringFields(body);
    }

    return multipartRequest(
      url,
      method: method,
      fields: fields,
      files: files,
      headers: headers,
      isLogin: isLogin,
    );
  }
}
