import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/district.dart';
import '../models/alert.dart';

class ApiService {
  static const String baseUrl = 'https://api.poweralert.gh';
  
  final http.Client _httpClient;

  ApiService({http.Client? httpClient}) : _httpClient = httpClient ?? http.Client();

  // District endpoints
  Future<List<District>> getAllDistricts() async {
    try {
      final response = await _httpClient.get(
        Uri.parse('$baseUrl/districts'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => District.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load districts');
      }
    } catch (e) {
      throw Exception('Error fetching districts: $e');
    }
  }

  Future<District?> getDistrict(String id) async {
    try {
      final response = await _httpClient.get(
        Uri.parse('$baseUrl/districts/$id'),
      );

      if (response.statusCode == 200) {
        return District.fromJson(jsonDecode(response.body));
      }
      return null;
    } catch (e) {
      throw Exception('Error fetching district: $e');
    }
  }

  // Alert endpoints
  Future<List<Alert>> getUserAlerts(String userId) async {
    try {
      final response = await _httpClient.get(
        Uri.parse('$baseUrl/alerts?userId=$userId'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Alert.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load alerts');
      }
    } catch (e) {
      throw Exception('Error fetching alerts: $e');
    }
  }

  Future<List<Alert>> getDistrictAlerts(String districtId) async {
    try {
      final response = await _httpClient.get(
        Uri.parse('$baseUrl/districts/$districtId/alerts'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Alert.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load district alerts');
      }
    } catch (e) {
      throw Exception('Error fetching district alerts: $e');
    }
  }

  // Auth endpoints
  Future<Map<String, dynamic>> verifyPhone(String phoneNumber) async {
    try {
      final response = await _httpClient.post(
        Uri.parse('$baseUrl/auth/verify-phone'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phoneNumber': phoneNumber}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to verify phone');
      }
    } catch (e) {
      throw Exception('Error verifying phone: $e');
    }
  }

  Future<Map<String, dynamic>> verifyOTP(String phoneNumber, String otp) async {
    try {
      final response = await _httpClient.post(
        Uri.parse('$baseUrl/auth/verify-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'phoneNumber': phoneNumber,
          'otp': otp,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to verify OTP');
      }
    } catch (e) {
      throw Exception('Error verifying OTP: $e');
    }
  }
}
