import 'package:flutter/material.dart';
import 'package:madwell/config/environment_config.dart';
import 'package:package_info_plus/package_info_plus.dart';

class EnvDisplayWidget extends StatelessWidget {
  const EnvDisplayWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _getEnvColor().withAlpha(25),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: _getEnvColor()),
        ),
        child: FutureBuilder<PackageInfo>(
          future: PackageInfo.fromPlatform(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const CircularProgressIndicator();
            }

            final packageInfo = snapshot.data!;
            
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Environment: ${EnvironmentConfig.envName.toUpperCase()}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _getEnvColor(),
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                _buildInfoRow('App Name', EnvironmentConfig.appName),
                _buildInfoRow('Package Name', packageInfo.packageName),
                _buildInfoRow('Version', '${packageInfo.version}+${packageInfo.buildNumber}'),
                _buildInfoRow('API URL', EnvironmentConfig.apiBaseUrl),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.normal),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Color _getEnvColor() {
    if (EnvironmentConfig.isDev) {
      return Colors.blue;
    } else if (EnvironmentConfig.isStaging) {
      return Colors.orange;
    } else {
      return Colors.green;
    }
  }
} 