//main_app.dart


import 'package:flutter/material.dart';
import 'package:healthmate/features/health_records/ui/screens/dashboard_screen.dart';
import 'package:healthmate/features/health_records/ui/screens/add_record_screen.dart';
import 'package:healthmate/features/health_records/ui/screens/records_list_screen.dart';
import 'package:healthmate/features/health_records/ui/screens/settings_screen.dart';
import 'package:healthmate/utils/constants.dart';

class HealthMateApp extends StatelessWidget {
  const HealthMateApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HealthMate',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.blue)
            .copyWith(secondary: AppColors.water),
        appBarTheme: const AppBarTheme(
          elevation: 1,
          iconTheme: IconThemeData(color: Colors.black),
          titleTextStyle:
          TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (_) => const DashboardScreen(),
        '/add': (_) => const AddRecordScreen(),
        '/list': (_) => const RecordsListScreen(),
        '/settings': (_) => const SettingsScreen(),
      },
    );
  }
}
