import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart' as dotenv; 
import 'package:madwell/config/environment_config.dart';
import 'package:madwell/config/template_env_config.dart';
import 'package:path_provider/path_provider.dart';

class EnvReader {
  // Initialize the environment
  static Future<void> initialize() async {
    // Determine which environment to use based on a compile-time flag or default to dev
    const String envName = String.fromEnvironment('ENV', defaultValue: 'dev');
    
    debugPrint('Initializing environment: $envName');
    
    try {
      // Try to load .env file if it exists
      final bool envLoaded = await _loadEnvFile(envName);
      
      if (!envLoaded) {
        debugPrint('Failed to load environment files. Using template config.');
      }
    
       EnvironmentConfig.init(env: Environment.dev, config: _mergeWithEnvFile(templateEnvConfig));
          
    } catch (e) {
      debugPrint('Error initializing environment: $e');
      EnvironmentConfig.init(env: Environment.dev, config: templateEnvConfig); 
    }
    
    debugPrint('Application running in ${EnvironmentConfig.envName} environment');
  }
  
  // Load environment file based on environment name
  static Future<bool> _loadEnvFile(String envName) async { 
    
    try { 
      await dotenv.dotenv.load(fileName: '.env.$envName'); 
      return true;
    } catch (e) {
      debugPrint('Could not load .env.$envName file: $e');
      // If specific environment file doesn't exist, try loading the default one
      try { 
        await dotenv.dotenv.load(fileName: '.env'); 
        return true;
      } catch (e) {
        debugPrint('Could not load .env file: $e');
        return false;
      }
    }
  }
  
  // Merge hardcoded config with values from .env file if they exist
  static Map<String, dynamic> _mergeWithEnvFile(Map<String, dynamic> config) {
    final Map<String, dynamic> result = Map.from(config);
    
    debugPrint('Env values loaded: ${dotenv.dotenv.env.keys.join(', ')}');
    
    // Replace values with those from .env file if they exist
    if (dotenv.dotenv.env.isNotEmpty) {
      // API Keys
      if (dotenv.dotenv.env.containsKey('GOOGLE_MAPS_API_KEY')) {
        result['googleMapsApiKey'] = dotenv.dotenv.env['GOOGLE_MAPS_API_KEY'];
      }
      
      if (dotenv.dotenv.env.containsKey('ADMOB_APP_ID')) {
        result['adMobAppId'] = dotenv.dotenv.env['ADMOB_APP_ID'];
      }
      
      // App Configuration
      if (dotenv.dotenv.env.containsKey('APP_NAME')) {
        result['appName'] = dotenv.dotenv.env['APP_NAME'];
      }
      
      if (dotenv.dotenv.env.containsKey('ANDROID_PACKAGE_NAME')) {
        result['androidPackageName'] = dotenv.dotenv.env['ANDROID_PACKAGE_NAME'];
      }
      
      if (dotenv.dotenv.env.containsKey('IOS_BUNDLE_ID')) {
        result['iosBundleId'] = dotenv.dotenv.env['IOS_BUNDLE_ID'];
      }
      
      if (dotenv.dotenv.env.containsKey('API_BASE_URL')) {
        result['apiBaseUrl'] = dotenv.dotenv.env['API_BASE_URL'];
        debugPrint('Setting apiBaseUrl from .env: ${result['apiBaseUrl']}');
      }
      
      // Firebase Configuration
      if (result.containsKey('firebaseConfig')) {
        final Map<String, dynamic> firebaseConfig = Map.from(result['firebaseConfig'] as Map<String, dynamic>);
        
        // Android Firebase Config
        if (firebaseConfig.containsKey('android') && 
            dotenv.dotenv.env.containsKey('FIREBASE_ANDROID_API_KEY') &&
            dotenv.dotenv.env.containsKey('FIREBASE_ANDROID_APP_ID') &&
            dotenv.dotenv.env.containsKey('FIREBASE_ANDROID_PROJECT_ID') &&
            dotenv.dotenv.env.containsKey('FIREBASE_ANDROID_STORAGE_BUCKET') &&
            dotenv.dotenv.env.containsKey('FIREBASE_MESSAGING_SENDER_ID')) {
          
          firebaseConfig['android'] = FirebaseOptions(
            apiKey: dotenv.dotenv.env['FIREBASE_ANDROID_API_KEY']!,
            appId: dotenv.dotenv.env['FIREBASE_ANDROID_APP_ID']!,
            messagingSenderId: dotenv.dotenv.env['FIREBASE_MESSAGING_SENDER_ID']!,
            projectId: dotenv.dotenv.env['FIREBASE_ANDROID_PROJECT_ID']!,
            storageBucket: dotenv.dotenv.env['FIREBASE_ANDROID_STORAGE_BUCKET'],
          );
        }
        
        // iOS Firebase Config
        if (firebaseConfig.containsKey('ios') && 
            dotenv.dotenv.env.containsKey('FIREBASE_IOS_API_KEY') &&
            dotenv.dotenv.env.containsKey('FIREBASE_IOS_APP_ID') &&
            dotenv.dotenv.env.containsKey('FIREBASE_IOS_PROJECT_ID') &&
            dotenv.dotenv.env.containsKey('FIREBASE_IOS_STORAGE_BUCKET') &&
            dotenv.dotenv.env.containsKey('FIREBASE_IOS_CLIENT_ID') &&
            dotenv.dotenv.env.containsKey('FIREBASE_IOS_BUNDLE_ID') &&
            dotenv.dotenv.env.containsKey('FIREBASE_MESSAGING_SENDER_ID')) {
          
          firebaseConfig['ios'] = FirebaseOptions(
            apiKey: dotenv.dotenv.env['FIREBASE_IOS_API_KEY']!,
            appId: dotenv.dotenv.env['FIREBASE_IOS_APP_ID']!,
            messagingSenderId: dotenv.dotenv.env['FIREBASE_MESSAGING_SENDER_ID']!,
            projectId: dotenv.dotenv.env['FIREBASE_IOS_PROJECT_ID']!,
            storageBucket: dotenv.dotenv.env['FIREBASE_IOS_STORAGE_BUCKET'],
            iosClientId: dotenv.dotenv.env['FIREBASE_IOS_CLIENT_ID'],
            iosBundleId: dotenv.dotenv.env['FIREBASE_IOS_BUNDLE_ID'],
          );
        }
        
        result['firebaseConfig'] = firebaseConfig;
      }
    }
    
    return result;
  }
} 