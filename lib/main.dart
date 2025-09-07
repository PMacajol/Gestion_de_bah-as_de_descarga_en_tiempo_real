import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bahias_descarga_system/providers/auth_provider.dart';
import 'package:bahias_descarga_system/providers/bahia_provider.dart';
import 'package:bahias_descarga_system/providers/reserva_provider.dart';
import 'package:bahias_descarga_system/screens/auth/login_screen.dart';
import 'package:bahias_descarga_system/screens/auth/register_screen.dart';
import 'package:bahias_descarga_system/screens/user/dashboard_screen.dart';
import 'package:bahias_descarga_system/screens/user/reservation_screen.dart';
import 'package:bahias_descarga_system/screens/user/profile_screen.dart';
import 'package:bahias_descarga_system/screens/reports/usage_report_screen.dart';
import 'package:bahias_descarga_system/screens/admin/admin_dashboard.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => BahiaProvider()),
        ChangeNotifierProvider(create: (_) => ReservaProvider()),
      ],
      child: MaterialApp(
        title: 'Sistema de Bahías de Descarga',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        initialRoute: '/login',
        routes: {
          '/login': (context) => LoginScreen(), // Sin const
          '/register': (context) => RegisterScreen(), // Sin const
          '/dashboard': (context) => DashboardScreen(), // Sin const
          '/reservation': (context) => ReservationScreen(), // Sin const
          '/profile': (context) => ProfileScreen(), // Sin const
          '/reports': (context) => UsageReportScreen(), // Sin const
          '/admin': (context) => AdminDashboard(),
        },
      ),
    );
  }
}
