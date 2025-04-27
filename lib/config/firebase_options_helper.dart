import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:e_demand/config/environment_config.dart';

class CustomFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError('Unsupported platform');
    }
    
    // Get the config based on the current platform
    final firebaseConfig = EnvironmentConfig.getValue<Map<String, dynamic>>('firebaseConfig', defaultValue: {});
    
    if (defaultTargetPlatform == TargetPlatform.android) {
      final androidConfig = firebaseConfig['android'];
      if (androidConfig == null) {
        throw Exception('Android Firebase configuration not found for the current environment');
      }
      return androidConfig as FirebaseOptions;
    }
    
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      final iosConfig = firebaseConfig['ios'];
      if (iosConfig == null) {
        throw Exception('iOS Firebase configuration not found for the current environment');
      }
      return iosConfig as FirebaseOptions;
    }
    
    throw UnsupportedError('Unsupported platform');
  }
} 