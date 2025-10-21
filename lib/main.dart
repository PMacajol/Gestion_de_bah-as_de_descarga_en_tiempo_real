import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';

// Providers
import 'package:bahias_descarga_system/providers/auth_provider.dart';
import 'package:bahias_descarga_system/providers/reserva_provider.dart';
import 'package:bahias_descarga_system/providers/mantenimiento.dart';
import 'package:bahias_descarga_system/providers/bahia_provider.dart';
// Screens
import 'package:bahias_descarga_system/screens/auth/login_screen.dart';
import 'package:bahias_descarga_system/screens/auth/register_screen.dart';
import 'package:bahias_descarga_system/screens/user/dashboard_screen.dart';
import 'package:bahias_descarga_system/screens/user/reservation_screen.dart';
import 'package:bahias_descarga_system/screens/user/profile_screen.dart';
import 'package:bahias_descarga_system/screens/reports/usage_report_screen.dart';
import 'package:bahias_descarga_system/screens/admin/admin_dashboard.dart';

// Otros dashboards
import 'package:bahias_descarga_system/screens/user/planificador_dashboard.dart';
import 'package:bahias_descarga_system/screens/user/supervisor_dashboard.dart';
import 'package:bahias_descarga_system/screens/user/admin_ti_dashboard.dart';

// Models
import 'package:bahias_descarga_system/models/usuario_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es_ES', null);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => BahiaProvider()),
        ChangeNotifierProvider(create: (_) => ReservaProvider()),
        ChangeNotifierProvider(create: (_) => MantenimientoProvider()),
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
        home: const AuthWrapper(),
        routes: {
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/dashboard': (context) => const DashboardScreen(),
          '/reservation': (context) => const ReservationScreen(),
          '/profile': (context) => const ProfileScreen(),
          '/reports': (context) => const UsageReportScreen(),
          '/admin': (context) => const AdminDashboard(), // ✅ Corregido
          '/planificador': (context) => const PlanificadorDashboard(),
          '/supervisor': (context) => const SupervisorDashboard(),
          '/admin-ti': (context) => const AdminTIDashboard(),
        },
      ),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  _AuthWrapperState createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final isLoggedIn = await authProvider.tryAutoLogin();

        if (isLoggedIn && authProvider.token != null) {
          await _configureProviders(authProvider.token!);
        }

        setState(() => _isLoading = false);
      });
    } catch (e) {
      print('Error inicializando app: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _configureProviders(String token) async {
    final bahiaProvider = Provider.of<BahiaProvider>(context, listen: false);
    final reservaProvider =
        Provider.of<ReservaProvider>(context, listen: false);
    final mantenimientoProvider =
        Provider.of<MantenimientoProvider>(context, listen: false);

    bahiaProvider.setToken(token);
    reservaProvider.setToken(token);
    mantenimientoProvider.setToken(token);

    Future.microtask(() async {
      try {
        await bahiaProvider.cargarBahias();
        await reservaProvider.cargarReservas();
      } catch (e) {
        print('Error cargando datos iniciales: $e');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Inicializando aplicación...'),
            ],
          ),
        ),
      );
    }

    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (authProvider.autenticado) {
          final usuario = authProvider.usuario;
          if (usuario != null) {
            switch (usuario.tipo) {
              case TipoUsuario.administrador:
              case TipoUsuario.administradorTI:
                return const AdminDashboard(); // ✅ Corregido
              case TipoUsuario.planificador:
                return const PlanificadorDashboard();
              case TipoUsuario.supervisor:
                return const SupervisorDashboard();
              case TipoUsuario.operador:
              default:
                return const DashboardScreen();
            }
          }
          return const DashboardScreen();
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}
