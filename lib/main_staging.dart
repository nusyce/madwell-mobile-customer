import 'package:flutter/material.dart';
import 'package:madwell/app/app.dart';
import 'package:madwell/config/env_reader.dart';
import 'package:madwell/config/platform_env_bridge.dart';
import 'package:flutter/services.dart';

void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set the environment variable
  const String.fromEnvironment('ENV', defaultValue: 'staging');
  
  // Initialize environment configuration
  await EnvReader.initialize();
  
  // Initialize platform-specific environment variables
  await PlatformEnvBridge.initPlatformEnv();

  // Initialize app
  initApp();
} 