import 'package:madwell/app/app.dart';
import 'package:madwell/config/env_reader.dart';

void main() async {
  // Initialize environment configuration
  await EnvReader.initialize();

  // Initialize app
  initApp();
}
