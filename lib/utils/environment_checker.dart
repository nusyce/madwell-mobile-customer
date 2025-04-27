import 'dart:math' show min;
import 'package:e_demand/config/environment_config.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

class EnvironmentChecker {
  static Future<Map<String, String>> getEnvironmentInfo() async {
    final Map<String, String> info = {};
    
    // Get basic environment information
    info['Environment'] = EnvironmentConfig.envName;
    info['App Name'] = EnvironmentConfig.appName;
    info['API Base URL'] = EnvironmentConfig.apiBaseUrl;
    
    try {
      // Get package information
      final PackageInfo packageInfo = await PackageInfo.fromPlatform();
      info['Package Name'] = packageInfo.packageName;
      info['App Version'] = '${packageInfo.version}+${packageInfo.buildNumber}';
    } catch (e) {
      info['Package Info Error'] = e.toString();
    }
    
    // Add Firebase project details
    final firebaseConfig = EnvironmentConfig.firebaseOptions;
    if (firebaseConfig.containsKey('android')) {
      info['Firebase Project ID (Android)'] = 
          firebaseConfig['android'].projectId ?? 'Unknown';
    }
    
    if (firebaseConfig.containsKey('ios')) {
      info['Firebase Project ID (iOS)'] = 
          firebaseConfig['ios'].projectId ?? 'Unknown';
    }
    
    // Add Google Maps API key (first 8 chars for security)
    final googleMapsKey = EnvironmentConfig.googleMapsApiKey;
    if (googleMapsKey.isNotEmpty) {
      info['Google Maps API Key'] = '${googleMapsKey.substring(0, min(8, googleMapsKey.length))}...';
    } else {
      info['Google Maps API Key'] = 'Not configured';
    }
    
    return info;
  }
  
  // Show an info dialog with environment details
  static Future<void> showEnvironmentInfoDialog(BuildContext context) async {
    final info = await getEnvironmentInfo();
    
    if (context.mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Environment: ${EnvironmentConfig.envName.toUpperCase()}'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: info.entries.map((entry) => 
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.key,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(entry.value),
                      const Divider(),
                    ],
                  ),
                ),
              ).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }
} 