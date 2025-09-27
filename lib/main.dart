import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart'; // Añade esta importación
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

// Importar los nuevos dashboards
import 'package:bahias_descarga_system/screens/user/planificador_dashboard.dart';
import 'package:bahias_descarga_system/screens/user/supervisor_dashboard.dart';
import 'package:bahias_descarga_system/screens/user/admin_ti_dashboard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar el formato de fechas para español
  await initializeDateFormatting('es_ES', null);

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
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/dashboard': (context) => const DashboardScreen(),
          '/reservation': (context) => const ReservationScreen(),
          '/profile': (context) => const ProfileScreen(),
          '/reports': (context) => const UsageReportScreen(),
          '/admin': (context) => const AdminDashboard(),
          '/planificador': (context) => const PlanificadorDashboard(),
          '/supervisor': (context) => const SupervisorDashboard(),
          '/admin-ti': (context) => const AdminTIDashboard(),
        },
      ),
    );
  }
}
