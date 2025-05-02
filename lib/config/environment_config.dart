
enum Environment {
  dev,
  staging,
  prod,
}

class EnvironmentConfig {
  static Environment _environment = Environment.dev;
  static final Map<String, dynamic> _configMap = {};

  // Initialize environment configuration
  static void init({required Environment env, required Map<String, dynamic> config}) {
    _environment = env;
    _configMap.addAll(config);
  }

  // Get current environment
  static Environment get environment => _environment;

  // Get environment name
  static String get envName => _environment.toString().split('.').last;

  // Check if in development
  static bool get isDev => _environment == Environment.dev;

  // Check if in staging
  static bool get isStaging => _environment == Environment.staging;

  // Check if in production
  static bool get isProd => _environment == Environment.prod;

  // Get app name based on environment
  static String get appName {
    return _configMap['appName'] ?? 'Madwell';
  }

  // Get application ID for Android based on environment
  static String get androidPackageName {
    return _configMap['androidPackageName'] ?? 'app.madwell.pro.customer';
  }

  // Get bundle ID for iOS based on environment
  static String get iosBundleId {
    return _configMap['iosBundleId'] ?? 'app.madwell.pro.customer';
  }

  // Get Google Maps API Key
  static String get googleMapsApiKey {
    return _configMap['googleMapsApiKey'] ?? '';
  }

  // Get AdMob App ID
  static String get adMobAppId {
    return _configMap['adMobAppId'] ?? '';
  }

  // Get Firebase options
  static Map<String, dynamic> get firebaseOptions {
    return _configMap['firebaseOptions'] ?? {};
  }

  // Get API base URL
  static String get apiBaseUrl {
    return _configMap['apiBaseUrl'] ?? '';
  }

  // Generic method to get any config value
  static T getValue<T>(String key, {T? defaultValue}) {
    if (_configMap.containsKey(key)) {
      return _configMap[key] as T;
    }
    if (defaultValue != null) {
      return defaultValue;
    }
    throw Exception('Key $key not found in environment config');
  }
} 