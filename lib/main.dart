import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/listing_provider.dart';
import 'providers/settings_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/verify_email_screen.dart';
import 'screens/home/home_shell.dart';
import 'services/auth_service.dart';
import 'services/firestore_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const KigaliDirectoryApp());
}

class KigaliDirectoryApp extends StatelessWidget {
  const KigaliDirectoryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthService>(create: (_) => AuthService()),
        Provider<FirestoreService>(create: (_) => FirestoreService()),
        ChangeNotifierProvider<AuthProvider>(
          create: (context) => AuthProvider(
            authService: context.read<AuthService>(),
            firestoreService: context.read<FirestoreService>(),
          ),
        ),
        ChangeNotifierProxyProvider<AuthProvider, ListingProvider>(
          create: (context) => ListingProvider(
            firestoreService: context.read<FirestoreService>(),
          ),
          update: (context, authProvider, listingProvider) {
            listingProvider ??= ListingProvider(
              firestoreService: context.read<FirestoreService>(),
            );
            listingProvider.setCurrentUser(authProvider.user?.uid);
            return listingProvider;
          },
        ),
        ChangeNotifierProvider<SettingsProvider>(
          create: (_) => SettingsProvider(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Kigali Directory',
        theme: AppTheme.darkTheme,
        home: const AppGate(),
      ),
    );
  }
}

class AppGate extends StatelessWidget {
  const AppGate({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    if (authProvider.isLoading && authProvider.user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (authProvider.user == null) {
      return const LoginScreen();
    }

    if (!authProvider.isEmailVerified) {
      return const VerifyEmailScreen();
    }

    return const HomeShell();
  }
}
