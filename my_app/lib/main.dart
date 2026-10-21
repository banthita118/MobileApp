import 'package:flutter/material.dart';
import 'services/api_service.dart';
import 'theme/app_theme.dart';
import 'screens/login_screen.dart';
import 'screens/main_navigation_shell.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ServiceDeskApp());
}

class ServiceDeskApp extends StatefulWidget {
  const ServiceDeskApp({super.key});

  @override
  State<ServiceDeskApp> createState() => _ServiceDeskAppState();
}

class _ServiceDeskAppState extends State<ServiceDeskApp> {
  final _apiService = ApiService();

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _apiService,
      builder: (context, _) {
        return MaterialApp(
          title: 'IT Service Desk',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.light,
          home: _apiService.isLoggedIn
              ? const MainNavigationShell()
              : const LoginScreen(),
        );
      },
    );
  }
}
