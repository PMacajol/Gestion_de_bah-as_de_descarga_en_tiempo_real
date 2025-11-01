import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bahias_descarga_system/providers/auth_provider.dart';
import 'package:bahias_descarga_system/models/usuario_model.dart';
import 'package:bahias_descarga_system/providers/bahia_provider.dart';
import 'package:bahias_descarga_system/providers/reserva_provider.dart';
import 'package:bahias_descarga_system/providers/mantenimiento.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController(text: 'admin@empresa.com');
  final _passwordController = TextEditingController(text: 'password123');
  bool _obscurePassword = true;
  bool _isLoading = false;

  // ✅ MÉTODO PRINCIPAL DE LOGIN UNIFICADO
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      print('🔄 Iniciando proceso de login...');

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final bahiaProvider = Provider.of<BahiaProvider>(context, listen: false);
      final reservaProvider =
          Provider.of<ReservaProvider>(context, listen: false);
      final mantenimientoProvider =
          Provider.of<MantenimientoProvider>(context, listen: false);

      // 1. Verificar conexión primero
      print('🔍 Verificando conexión con el servidor...');
      final conectado = await authProvider.verificarConexion();
      if (!conectado) {
        throw Exception(
            'No se puede conectar al servidor. Verifica que el backend esté ejecutándose.');
      }

      // 2. Realizar login
      final success = await authProvider.login(
        _emailController.text,
        _passwordController.text,
      );

      if (!success) {
        throw Exception('Login falló sin error específico');
      }

      // 3. Verificar que tenemos token
      if (authProvider.token == null) {
        throw Exception('No se recibió token del servidor');
      }

      print('🔑 Token obtenido: ${authProvider.token!.substring(0, 20)}...');

      // 4. CONFIGURAR TOKEN EN TODOS LOS PROVIDERS
      await _configureProviders(authProvider.token!);

      // 5. Verificar que el token es válido
      print('🔐 Verificando validez del token...');
      final tokenValido = await authProvider.verificarTokenValido();
      if (!tokenValido) {
        throw Exception('Token inválido o expirado');
      }

      // 6. Redirigir según el tipo de usuario
      final usuario = authProvider.usuario;
      if (usuario != null) {
        print('👤 Usuario autenticado: ${usuario.nombre} (${usuario.tipo})');

        String route;
        switch (usuario.tipo) {
          case TipoUsuario.administrador:
            route = '/admin';
            break;
          case TipoUsuario.administradorTI:
            route = '/admin-ti';
          case TipoUsuario.planificador:
            route = '/planificador';
            break;
          case TipoUsuario.supervisor:
            route = '/supervisor';
            break;

          case TipoUsuario.operador:
          default:
            route = '/dashboard';
        }

        print('🚀 Navegando a: $route');

        // Verificar que el widget aún está montado antes de navegar
        if (mounted) {
          Navigator.pushReplacementNamed(context, route);
        }
      } else {
        throw Exception('No se pudo obtener información del usuario');
      }
    } catch (e) {
      print('❌ Error en login: $e');

      // Solo mostrar error si el widget aún está montado
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      // Solo llamar setState si el widget aún está montado
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // ✅ MÉTODO MEJORADO PARA CONFIGURAR TOKEN EN TODOS LOS PROVIDERS
  Future<void> _configureProviders(String token) async {
    try {
      print('🔄 Configurando providers con token...');

      final bahiaProvider = Provider.of<BahiaProvider>(context, listen: false);
      final reservaProvider =
          Provider.of<ReservaProvider>(context, listen: false);
      final mantenimientoProvider =
          Provider.of<MantenimientoProvider>(context, listen: false);

      // Configurar token en todos los providers
      bahiaProvider.setToken(token);
      reservaProvider.setToken(token);
      mantenimientoProvider.setToken(token);

      print('✅ Token configurado en todos los providers');

      // Cargar datos iniciales en segundo plano (sin await para no bloquear)
      Future.microtask(() async {
        try {
          print('📥 Cargando datos iniciales en segundo plano...');

          await Future.wait([
            bahiaProvider.cargarBahias(),
            reservaProvider.cargarReservas(),
          ]).timeout(const Duration(seconds: 10));

          print('✅ Datos iniciales cargados exitosamente');
        } catch (e) {
          print('⚠️ Error cargando datos en segundo plano: $e');
          // No mostramos error al usuario porque esto es en segundo plano
        }
      });
    } catch (e) {
      print('❌ Error configurando providers: $e');
      throw Exception('Error al configurar la aplicación: $e');
    }
  }

  // ✅ MÉTODO PARA PROBAR CONEXIÓN (BOTÓN DEBUG)
  Future<void> _probarConexion() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    try {
      setState(() => _isLoading = true);

      print('🔍 Probando conexión...');
      final conectado = await authProvider.verificarConexion();

      if (conectado) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Conexión exitosa con el servidor'),
            backgroundColor: Colors.green,
          ),
        );
        print('✅ Servidor responde correctamente');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ No se puede conectar al servidor'),
            backgroundColor: Colors.red,
          ),
        );
        print('❌ Servidor no responde');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error probando conexión: $e'),
          backgroundColor: Colors.red,
        ),
      );
      print('❌ Error en prueba de conexión: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Fondo de pantalla
          Image.network(
            'https://thumbs.dreamstime.com/b/asombroso-exterior-de-un-almac%C3%A9n-moderno-con-bah%C3%ADas-carga-en-azul-y-blanco-la-hora-dorada-ia-generativa-385289866.jpg',
            fit: BoxFit.cover,
          ),

          // Overlay oscuro para contraste
          Container(color: Colors.black.withOpacity(0.5)),

          // Formulario centrado
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo redondeado
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.white,
                        backgroundImage: const NetworkImage(
                          'https://thumbs.dreamstime.com/b/personaje-masculino-alegre-est%C3%A1-saludando-con-su-mano-sobre-fondo-blanco-concepto-de-personas-que-expresan-sus-emociones-lenguaje-228376228.jpg',
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Nombre del sistema
                      const Text(
                        'Sistema de Bahías',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Email
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          labelStyle: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          prefixIcon: Icon(
                            Icons.email,
                            color: Colors.white,
                            size: 28,
                          ),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingrese su email';
                          }
                          if (!value.contains('@')) {
                            return 'Email inválido';
                          }
                          return null;
                        },
                        keyboardType: TextInputType.emailAddress,
                        style: const TextStyle(color: Colors.white),
                      ),

                      const SizedBox(height: 16),

                      // Password
                      TextFormField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: 'Contraseña',
                          labelStyle: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          prefixIcon: const Icon(
                            Icons.lock,
                            color: Colors.white,
                            size: 28,
                          ),
                          enabledBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Colors.white,
                              size: 28,
                            ),
                            onPressed: () {
                              setState(
                                  () => _obscurePassword = !_obscurePassword);
                            },
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingrese su contraseña';
                          }
                          if (value.length < 6) {
                            return 'La contraseña debe tener al menos 6 caracteres';
                          }
                          return null;
                        },
                        obscureText: _obscurePassword,
                        style: const TextStyle(color: Colors.white),
                      ),

                      const SizedBox(height: 16),

                      // Botón de login
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                  ),
                                )
                              : const Text(
                                  'Iniciar Sesión',
                                  style: TextStyle(fontSize: 16),
                                ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Botón de prueba de conexión (solo para debug)
                      if (!_isLoading) ...[
                        TextButton(
                          onPressed: _probarConexion,
                          child: const Text(
                            '🔧 Probar Conexión',
                            style: TextStyle(color: Colors.white70),
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],

                      // Registro
                      TextButton(
                        onPressed: _isLoading
                            ? null
                            : () {
                                Navigator.pushNamed(context, '/register');
                              },
                        child: const Text(
                          '¿No tienes cuenta? Regístrate aquí',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
