import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/theme.dart';
import 'providers/auth_provider.dart';
import 'providers/ride_provider.dart';
import 'providers/locale_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/login_screen.dart';
import 'screens/otp_screen.dart';
import 'screens/home_screen.dart';
import 'screens/ride_request_screen.dart';
import 'screens/matching_screen.dart';
import 'screens/trip_active_screen.dart';
import 'screens/trip_summary_screen.dart';
import 'screens/rating_screen.dart';

void main() {
  runApp(const FairGoCustomerApp());
}

class FairGoCustomerApp extends StatelessWidget {
  const FairGoCustomerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => RideProvider()),
      ],
      child: Consumer<LocaleProvider>(
        builder: (context, localeProvider, _) {
          return MaterialApp(
            title: 'FAIRGO',
            debugShowCheckedModeBanner: false,
            theme: FairGoTheme.lightTheme,
            locale: localeProvider.locale,
            supportedLocales: const [
              Locale('th'),
              Locale('en'),
            ],
            initialRoute: '/',
            routes: {
              '/': (context) => const SplashScreen(),
              '/onboarding': (context) => const OnboardingScreen(),
              '/login': (context) => const LoginScreen(),
              '/otp': (context) => const OtpScreen(),
              '/home': (context) => const HomeScreen(),
              '/ride-request': (context) => const RideRequestScreen(),
              '/matching': (context) => const MatchingScreen(),
              '/trip-active': (context) => const TripActiveScreen(),
              '/trip-summary': (context) => const TripSummaryScreen(),
              '/rate-driver': (context) => const RatingScreen(),
            },
          );
        },
      ),
    );
  }
}
