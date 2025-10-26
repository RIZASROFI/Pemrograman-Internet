import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'services/auth_service.dart';
import 'services/notification_service.dart';
import 'providers/sensor_provider.dart';
import 'firebase_options.dart'; // <- import ini

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, // <- gunakan ini
  );

  // Configure Firestore to disable persistence entirely to avoid IndexedDB issues on web
  FirebaseFirestore.instance.settings =
      const Settings(persistenceEnabled: false);

  await NotificationService().initialize();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => SensorProvider()),
      ],
      child: MaterialApp(
        title: 'Dashboard Kualitas Daging',
        theme: ThemeData(
          primarySwatch: Colors.green,
          primaryColor: Color(0xFF4CAF50),
          scaffoldBackgroundColor: Colors.white,
          appBarTheme: AppBarTheme(
            backgroundColor: Color(0xFF4CAF50),
            foregroundColor: Colors.white,
            elevation: 0,
          ),
        ),
        home: AuthWrapper(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, authService, child) {
        // Show Dashboard if logged in, otherwise show LoginScreen
        if (authService.user != null) {
          return DashboardScreen();
        }
        return LoginScreen();
      },
    );
  }
}
