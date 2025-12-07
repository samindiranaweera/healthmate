//main.dart


import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:healthmate/features/health_records/provider/health_provider.dart';
import 'package:healthmate/features/health_records/ui/screens/main_app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final helper = HealthProvider();
  await helper.initForAppStart();
  helper.dispose();

  runApp(const HealthMateAppWrapper());
}

class HealthMateAppWrapper extends StatelessWidget {
  const HealthMateAppWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HealthProvider(),
      child: const HealthMateApp(),
    );
  }
}
