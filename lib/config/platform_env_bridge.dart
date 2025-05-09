import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:madwell/config/environment_config.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart' as dotenv;

/// Class responsible for passing environment variables to native platforms
class PlatformEnvBridge {
  static const MethodChannel _iosEnvChannel = MethodChannel('app.madwell.pro.customer/environment');
  static const MethodChannel _androidEnvChannel = MethodChannel('app.madwell.pro.customer/android_environment');

  /// Initialize platform-specific environment variables
  static Future<void> initPlatformEnv() async {
    try {
      // Make sure dotenv is loaded before continuing
      final envFile = '.env.${const String.fromEnvironment('ENV', defaultValue: 'dev')}';
      try {
        await dotenv.dotenv.load(fileName: envFile);
      } catch (e) {
        debugPrint('Warning: Could not load env file: $e');
      }

      // Pass environment variables to native platforms
      if (Platform.isIOS) {
        await _initIOSEnvironment();
      } else if (Platform.isAndroid) {
        await _initAndroidEnvironment();
      }
    } catch (e) {
      debugPrint('Error initializing platform environment: $e');
    }
  }

  /// Initialize iOS-specific environment variables
  static Future<void> _initIOSEnvironment() async {
    try {
      final Map<String, dynamic> envVars = _getEnvironmentVariables();
      
      final bool? success = await _iosEnvChannel.invokeMethod<bool>('getEnvironmentVariables', envVars);
      debugPrint('iOS environment initialized: $success');
    } catch (e) {
      debugPrint('Error initializing iOS environment: $e');
    }
  }

  /// Initialize Android-specific environment variables
  static Future<void> _initAndroidEnvironment() async {
    try {
      final Map<String, dynamic> envVars = _getEnvironmentVariables();
      
      final bool? success = await _androidEnvChannel.invokeMethod<bool>('getEnvironmentVariables', envVars);
      debugPrint('Android environment initialized: $success');
    } catch (e) {
      debugPrint('Error initializing Android environment: $e');
    }
  }

  /// Helper method to get environment variables
  static Map<String, dynamic> _getEnvironmentVariables() {
    final env = dotenv.dotenv.env;
    
    final Map<String, dynamic> result = {
      // API Keys
      'GOOGLE_MAPS_API_KEY': env['GOOGLE_MAPS_API_KEY'] ?? '',
      'ADMOB_APP_ID': env['ADMOB_APP_ID'] ?? '',
      
      // App Configuration
      'APP_NAME': env['APP_NAME'] ?? 'Madwell',
      'ANDROID_PACKAGE_NAME': env['ANDROID_PACKAGE_NAME'] ?? 'app.madwell.pro.customer',
      'IOS_BUNDLE_ID': env['IOS_BUNDLE_ID'] ?? 'app.madwell.pro.customer',
      'API_BASE_URL': env['API_BASE_URL'] ?? '',
      
      // Firebase Configuration - Android
      'FIREBASE_ANDROID_API_KEY': env['FIREBASE_ANDROID_API_KEY'] ?? '',
      'FIREBASE_ANDROID_APP_ID': env['FIREBASE_ANDROID_APP_ID'] ?? '',
      'FIREBASE_ANDROID_PROJECT_ID': env['FIREBASE_ANDROID_PROJECT_ID'] ?? '',
      'FIREBASE_ANDROID_STORAGE_BUCKET': env['FIREBASE_ANDROID_STORAGE_BUCKET'] ?? '',
      'FIREBASE_MESSAGING_SENDER_ID': env['FIREBASE_MESSAGING_SENDER_ID'] ?? '',
      
      // Firebase Configuration - iOS
      'FIREBASE_IOS_API_KEY': env['FIREBASE_IOS_API_KEY'] ?? '',
      'FIREBASE_IOS_APP_ID': env['FIREBASE_IOS_APP_ID'] ?? '',
      'FIREBASE_IOS_PROJECT_ID': env['FIREBASE_IOS_PROJECT_ID'] ?? '',
      'FIREBASE_IOS_STORAGE_BUCKET': env['FIREBASE_IOS_STORAGE_BUCKET'] ?? '',
      'FIREBASE_IOS_CLIENT_ID': env['FIREBASE_IOS_CLIENT_ID'] ?? '',
    };
    
    return result;
  }
} 