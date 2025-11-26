import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Response, MultipartFile;
import 'package:http/http.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';


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
          response = await post(uri, headers: requestHeaders, body: jsonEncode(body));
          break;
        case 'GET':
          response = await get(uri, headers: requestHeaders);
          break;
        case 'PUT':
          response = await put(uri, headers: requestHeaders, body: jsonEncode(body));
          break;
        case 'DELETE':
          response = await delete(uri, headers: requestHeaders);
          break;
        case 'PATCH': // Add the PATCH case
          response = await patch(uri, headers: requestHeaders, body: jsonEncode(body));
          break;
        default:
          throw Exception('Unsupported HTTP method: $method');
      }

      // Handle the response
      return _handleResponse(response, isLogin);
    } catch (e) {
      debugPrint('Error: $e');
      return NetworkResponse(isSuccess: false, errorMessage: e.toString());
    }
  }

  // Handles response from the HTTP request and returns a NetworkResponse
  Future<NetworkResponse> _handleResponse(Response response, bool isLogin) async {
    try {
      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

      // Check if the response status is successful
      if (response.statusCode == 200 || response.statusCode == 201) {
        return NetworkResponse(
          isSuccess: true,
          jsonResponse: jsonResponse,
          statusCode: response.statusCode,
        );
      }

      // If status code is 401, it might be related to login, handle accordingly
      if (response.statusCode == 401 || response.statusCode == 403 && !isLogin) {
        // if (await SecureStorageService().containsKey(AppConstants.refreshToken) ||
        //     await SecureStorageService().containsKey(AppConstants.accessToken)) {
        //   await SecureStorageService().delete(AppConstants.accessToken);
        //   await SecureStorageService().delete(AppConstants.refreshToken);
        // }
        // Get.offAll(() => const SignInPage());
        return NetworkResponse(
          isSuccess: false,
          statusCode: response.statusCode,
          jsonResponse: jsonResponse,
        );
      }

      // Handle unsuccessful responses
      return NetworkResponse(
        isSuccess: false,
        statusCode: response.statusCode,
        jsonResponse: jsonResponse,
      );
    } catch (e) {
      return NetworkResponse(
        isSuccess: false,
        errorMessage: 'Error parsing response: ${e.toString()}',
      );
    }
  }

  // POST Request
  Future<NetworkResponse> postRequest(
      String url, {
        Map<String, dynamic>? body,
        bool isLogin = false,
        Map<String, String>? headers,
      }) async {
    return _request('POST', url, body: body, isLogin: isLogin, headers: headers);
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
    return _request('DELETE', url, body: body, isLogin: isLogin, headers: headers);
  }

  // PATCH Request
  Future<NetworkResponse> patchRequest(
      String url, {
        Map<String, dynamic>? body,
        bool isLogin = false,
        Map<String, String>? headers,
      }) async {
    return _request('PATCH', url, body: body, isLogin: isLogin, headers: headers);
  }

  // ===================== NEW MULTIPART METHODS =====================

  // Helper method to convert dynamic values to string fields
  // This handles nested objects by JSON encoding them
  Map<String, String> _convertToStringFields(Map<String, dynamic> body) {
    final Map<String, String> fields = <String, String>{};

    for (final MapEntry<String, dynamic> entry in body.entries) {
      final dynamic value = entry.value;

      // If value is a Map, List, or any complex object, encode it as JSON
      if (value is Map || value is List) {
        fields[entry.key] = jsonEncode(value);
      } else if (value == null) {
        // Skip null values or convert to 'null' string if needed
        // fields[entry.key] = 'null';
        continue;
      } else {
        // For simple types (String, int, bool, etc.), convert to string
        fields[entry.key] = value.toString();
      }
    }

    return fields;
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
      final MultipartRequest request = MultipartRequest(method.toUpperCase(), uri);

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

          // Get the mime type of the file
          final String? mimeType = lookupMimeType(file.path);
          final List<String>? mimeTypeParts = mimeType?.split('/');

          // Add the file as a MultipartFile
          request.files.add(
            await MultipartFile.fromPath(
              fieldName,
              file.path,
              contentType: mimeType != null
                  ? MediaType(mimeTypeParts?[0] ?? 'application', mimeTypeParts?[1] ?? 'octet-stream')
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
    } catch (e) {
      debugPrint('Multipart Error: $e');
      return NetworkResponse(isSuccess: false, errorMessage: e.toString());
    }
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
    // Convert body to fields using the helper method
    // This will JSON encode any nested Maps or Lists
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