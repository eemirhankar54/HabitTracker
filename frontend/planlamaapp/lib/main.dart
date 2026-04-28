// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart'; // EKLE
import 'providers/auth_provider.dart';
import 'providers/habit_provider.dart';
import 'app.dart';

void main() async {
  // async ekledik
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Firebase'i başlat (Zorunlu!)
  await Firebase.initializeApp();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()..checkAuth()),
        ChangeNotifierProvider(create: (_) => HabitProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

// BU FONKSİYONLARI main() DIŞINA VEYA HomeScreen'e almalısın.
// Şimdilik burada kalsın ama bir yerde çağırman lazım.
