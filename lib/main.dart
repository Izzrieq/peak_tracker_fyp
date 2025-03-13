import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/dashboard_screen.dart'; // Make sure to import DashboardScreen
import 'screens/error_screen.dart';

void main() {
  runApp(PeakTrackerApp());
}

class PeakTrackerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: "/login",
      routes: {
        "/login": (context) => LoginScreen(),
        "/signup": (context) => SignupScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == "/dashboard") {
          final arguments = settings.arguments;

          if (arguments is Map<String, dynamic>) {
            final String username = arguments["username"];
            final double currentWeight = arguments["currentWeight"];
            final double targetWeight = arguments["targetWeight"];

            return MaterialPageRoute(
              builder:
                  (context) => DashboardScreen(
                    username: username,
                    currentWeight: currentWeight,
                    targetWeight: targetWeight,
                  ),
            );
          } else {
            // Handle missing or incorrect arguments
            return MaterialPageRoute(builder: (context) => ErrorScreen());
          }
        }
        return null;
      },
    );
  }
}
