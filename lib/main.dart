import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'core/app_theme.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/parking_repository.dart';
import 'data/repositories/favorite_repository.dart';
import 'services/notification_service.dart';
import 'presentation/screens/splash_screen.dart';

/// Entry point aplikasi Parking Finder
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Inisialisasi notifikasi
  final notificationService = NotificationService();
  await notificationService.initialize();
  await notificationService.scheduleDailyNotification();

  runApp(const ParkingFinderApp());
}

class ParkingFinderApp extends StatelessWidget {
  const ParkingFinderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthRepository()),
        ChangeNotifierProvider(create: (_) => ParkingRepository()),
        ChangeNotifierProvider(create: (_) => FavoriteRepository()),
      ],
      child: MaterialApp(
        title: 'Parking Finder',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const SplashScreen(),
      ),
    );
  }
}
