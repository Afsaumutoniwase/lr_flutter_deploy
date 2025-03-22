// ignore_for_file: avoid_print

import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import '../models/hydroponic_data.dart';

class ApiService {
  final String baseUrl = "https://hydroponic-ph-prediction.onrender.com";

  // Timeout duration for all requests
  final Duration timeout = Duration(seconds: 30);

  Future<double> predictPH(HydroponicInput data) async {
    final url = Uri.parse("$baseUrl/predict");

    try {
      print("Making API request to: $url"); // Debug log
      print("Request body: ${jsonEncode(data.toJson())}"); // Debug log

      // Instead of directly using HTTP with a timeout, use a more resilient approach
      final response = await http
          .post(
            url,
            headers: {"Content-Type": "application/json"},
            body: jsonEncode(data.toJson()),
          )
          .timeout(timeout);

      print("Response status code: ${response.statusCode}"); // Debug log
      print("Response body: ${response.body}"); // Debug log

      if (response.statusCode == 200) {
        try {
          final jsonResponse = jsonDecode(response.body);

          // Check for both possible response formats
          if (jsonResponse.containsKey("Predicted pH")) {
            return jsonResponse["Predicted pH"].toDouble();
          }
          // Add this condition to handle the actual response format
          else if (jsonResponse.containsKey("predicted_pH")) {
            return jsonResponse["predicted_pH"].toDouble();
          } else {
            throw Exception(
              'Invalid response format: Missing pH field. Available fields: ${jsonResponse.keys.join(", ")}',
            );
          }
        } on FormatException {
          throw Exception(
            'Invalid response format: Could not parse JSON response',
          );
        }
      } else if (response.statusCode >= 500) {
        throw Exception(
          'Server error (${response.statusCode}): The server is experiencing issues',
        );
      } else if (response.statusCode == 404) {
        throw Exception(
          'API endpoint not found: The server may have been updated',
        );
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        throw Exception(
          'Authentication error: Not authorized to access this service',
        );
      } else {
        throw Exception(
          'Failed with status ${response.statusCode}: ${response.body}',
        );
      }
    } on SocketException catch (e) {
      print("Socket exception: $e"); // Debug log
      throw Exception('Network error: Please check your internet connection');
    } on TimeoutException catch (e) {
      print("Timeout exception: $e"); // Debug log
      throw Exception('Connection timed out. The server may be unresponsive.');
    } on FormatException catch (e) {
      print("Format exception: $e"); // Debug log
      throw Exception('Invalid response format. Please try again later.');
    } catch (e) {
      print("General exception: $e"); // Debug log
      throw Exception('Error: $e');
    }
  }

  // Improved checkConnectivity method with a more specific endpoint test
  Future<bool> checkConnectivity() async {
    try {
      // First check if the device has internet
      try {
        final result = await InternetAddress.lookup('google.com');
        if (result.isEmpty || result[0].rawAddress.isEmpty) {
          return false;
        }
      } on SocketException catch (_) {
        return false;
      }

      // Then check if the API server is reachable
      try {
        final response = await http
            .get(Uri.parse("$baseUrl/docs"))
            .timeout(Duration(seconds: 5));
        return response.statusCode >= 200 && response.statusCode < 300;
      } catch (_) {
        return false;
      }
    } catch (e) {
      print("Connectivity check failed: $e");
      return false;
    }
  }
}
