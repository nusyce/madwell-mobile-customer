import 'package:e_demand/app/app.dart';
import 'package:e_demand/config/env_reader.dart';

void main() async {
  // Initialize environment configuration
  await EnvReader.initialize();
  
  // Initialize app
  initApp();
}
