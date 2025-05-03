import 'package:firebase_core/firebase_core.dart';

// Template environment configuration
final Map<String, dynamic> templateEnvConfig = {
  'appName': '',
  'androidPackageName': '',
  'iosBundleId': '',
  'googleMapsApiKey': '', // Load from .env file
  'adMobAppId': '', // Load from .env file
  'apiBaseUrl': '',
  'firebaseConfig': {
    'android': const FirebaseOptions(
      apiKey: '', // Load from .env file
      appId: '', // Load from .env file
      messagingSenderId: '', // Load from .env file
      projectId: '', // Load from .env file
      storageBucket: '', // Load from .env file
    ),
    'ios': const FirebaseOptions(
      apiKey: '', // Load from .env file
      appId: '', // Load from .env file
      messagingSenderId: '', // Load from .env file
      projectId: '', // Load from .env file
      storageBucket: '', // Load from .env file
      iosClientId: '', // Load from .env file
      iosBundleId: '',
    ),
  },
}; 