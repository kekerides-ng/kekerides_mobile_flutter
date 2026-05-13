// lib/utils/api_debugger.dart
import 'package:dio/dio.dart';
import 'constants.dart';
import 'package:flutter/foundation.dart';

class ApiDebugger {
  static Future<Map<String, dynamic>> testConnection() async {
    final results = <String, dynamic>{
      'internet': false,
      'apiRoot': false,
      'apiEndpoint': false,
      'errors': [],
    };

    final dio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 10), // Increased to 10 seconds
      receiveTimeout: const Duration(seconds: 10),
      validateStatus: (status) {
        // Accept all status codes for testing
        return true;
      },
    ));

    print('\n🔍 ========== API CONNECTION TEST ==========\n');
    print('🔗 Testing URL: ${Constants.baseUrl}');

    try {
      // Test 1: Basic internet connectivity (with better error handling)
      print('\n🌐 Test 1: Internet connectivity...');
      try {
        final response = await dio.get(
          'https://www.google.com', // More reliable than jsonplaceholder
          options: Options(
            receiveTimeout: const Duration(seconds: 5),
          ),
        );
        results['internet'] = response.statusCode == 200 || response.statusCode == 301 || response.statusCode == 302;
        print('✅ Internet working: ${response.statusCode}');
      } catch (e) {
        results['errors'].add('Internet test failed: $e');
        print('❌ No internet connection: $e');
        print('💡 Check your device internet connection');
      }

      // Test 2: API root accessibility
      print('\n🔗 Test 2: API root accessibility...');
      try {
        // Try to access the root (without /api/v1)
        final rootUrl = Constants.baseUrl.replaceAll('/api/v1', '').replaceAll('/api', '');
        print('Testing root URL: $rootUrl');

        final response = await dio.get(
          rootUrl,
          options: Options(
            headers: {
              'User-Agent': 'KekeApp/1.0',
            },
          ),
        );

        print('Response status: ${response.statusCode}');
        print('Response headers: ${response.headers}');

        results['apiRoot'] = ((response.statusCode ?? 500) < 500); // Accept any non-5xx
        if (response.statusCode == 417) {
          print('⚠️  Server returned 417 (Expectation Failed)');
          print('💡 This might be due to missing headers or CORS');
        }
      } catch (e) {
        results['errors'].add('API root test failed: $e');
        print('⚠️  API root not accessible: $e');
      }

      // Test 3: Specific API endpoint
      print('\n🔗 Test 3: API endpoint test...');
      try {
        // Try common endpoints with different methods
        final endpoints = [
          {'path': 'health', 'method': 'GET'},
          {'path': '', 'method': 'GET'},
          {'path': 'auth/status', 'method': 'GET'},
          {'path': 'auth/test', 'method': 'GET'},
        ];

        bool endpointFound = false;

        for (var endpoint in endpoints) {
          try {
            print('Trying endpoint: ${endpoint['path']}');
            Response response;

            if (endpoint['method'] == 'GET') {
              response = await dio.get(
                '${Constants.baseUrl}${endpoint['path']}',
                options: Options(
                  headers: {
                    'Accept': 'application/json',
                    'Content-Type': 'application/json',
                  },
                ),
              );
            } else {
              continue;
            }

            print('Response status for ${endpoint['path']}: ${response.statusCode}');

            if (response.statusCode == 200 || response.statusCode == 201) {
              results['apiEndpoint'] = true;
              endpointFound = true;
              print('✅ API endpoint working (${endpoint['path']}): ${response.statusCode}');
              if (response.data != null) {
                print('Response data: ${response.data}');
              }
              break;
            } else if (response.statusCode == 404) {
              print('❌ Endpoint not found (404): ${endpoint['path']}');
            } else {
              print('⚠️  Endpoint responded with ${response.statusCode}: ${endpoint['path']}');
            }
          } catch (e) {
            print('❌ Endpoint error for ${endpoint['path']}: $e');
          }

          // Wait a bit between requests
          await Future.delayed(const Duration(milliseconds: 500));
        }

        if (!endpointFound) {
          // Try a simple POST to test if it's a method issue
          try {
            print('Trying simple POST to auth/register...');
            final response = await dio.post(
              '${Constants.baseUrl}auth/register',
              data: {
                'test': 'test',
              },
              options: Options(
                headers: {
                  'Accept': 'application/json',
                  'Content-Type': 'application/json',
                },
              ),
            );
            print('POST response: ${response.statusCode}');
            if (response.statusCode != null && response.statusCode! < 500) {
              results['apiEndpoint'] = true;
              endpointFound = true;
            }
          } catch (e) {
            print('POST test also failed: $e');
          }
        }

        if (!endpointFound) {
          results['errors'].add('All API endpoints failed');
          print('❌ No API endpoints responded successfully');
        }
      } catch (e) {
        results['errors'].add('Endpoint test failed: $e');
        print('❌ Endpoint test error: $e');
      }

    } catch (e) {
      results['errors'].add('General test error: $e');
      print('❌ General error: $e');
    }

    print('\n📊 ========== TEST RESULTS ==========');
    print('🌐 Internet: ${results['internet'] ? '✅' : '❌'}');
    print('🔗 API Root: ${results['apiRoot'] ? '✅' : '❌'}');
    print('🔌 API Endpoint: ${results['apiEndpoint'] ? '✅' : '❌'}');

    if (results['errors'].isNotEmpty) {
      print('\n❌ Errors:');
      for (var error in results['errors']) {
        if (error.toString().length > 200) {
          print('   • ${error.toString().substring(0, 200)}...');
        } else {
          print('   • $error');
        }
      }
    }

    print('\n🔍 ========== DEBUG INFO ==========');
    print('Base URL: ${Constants.baseUrl}');
    print('Is Render.com: ${Constants.baseUrl.contains('render.com')}');

    return results;
  }

  static void checkConstants() {
    print('\n🔧 ========== CONSTANTS CHECK ==========');
    print('Base URL: ${Constants.baseUrl}');

    // Check for common issues
    if (Constants.baseUrl.isEmpty) {
      print('❌ ERROR: baseUrl is empty!');
    } else if (Constants.baseUrl.contains('YOUR_ACTUAL_API_URL_HERE')) {
      print('❌ ERROR: You need to replace the placeholder URL!');
    } else if (!Constants.baseUrl.startsWith('http')) {
      print('❌ ERROR: baseUrl should start with http:// or https://');
    } else if (Constants.baseUrl.contains('render.com')) {
      print('✅ Using Render.com hosting');
      print('💡 Note: Free Render.com instances spin down when inactive');
      print('💡 First request may take 30-60 seconds to wake up');
    }
  }

  static Future<void> testWithCurlCommand() async {
    print('\n💻 ========== CURL COMMAND TO TEST ==========');
    print('''
Run this in your terminal to test the API manually:

curl -X GET "https://kekerides-backend.onrender.com/api/v1/health" \\
  -H "Content-Type: application/json" \\
  -H "Accept: application/json" \\
  -H "User-Agent: KekeApp/1.0" \\
  --max-time 30 \\
  --verbose

Or test with a simple browser visit:
https://kekerides-backend.onrender.com/api/v1/health
''');
  }
}