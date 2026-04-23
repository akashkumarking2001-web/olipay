import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'providers/app_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/language_selection_screen.dart';
import 'screens/home_screen.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Initialize Firebase with error handling
    await Firebase.initializeApp();
    
    // Initialize Background Notification Service
    NotificationService.init();
    
  } catch (e) {
    debugPrint("Initialization Error: $e");
    // Even if Firebase fails, we let the app run to show an error or retry
  }
  
  runApp(const OliPayApp());
}

class OliPayApp extends StatelessWidget {
  const OliPayApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppProvider()),
      ],
      child: MaterialApp(
        title: 'OliPay Soundbox',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF4285F4),
            primary: const Color(0xFF4285F4),
            secondary: const Color(0xFF34A853),
          ),
          fontFamily: 'Inter',
        ),
        home: const SplashScreen(),
        routes: {
          '/home': (context) => const HomeScreen(),
          '/languages': (context) => const LanguageSelectionScreen(),
        },
      ),
    );
  }
}
