import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bahias_descarga_system/providers/auth_provider.dart';
import 'package:bahias_descarga_system/models/usuario_model.dart';
import 'package:bahias_descarga_system/utils/constants.dart';
import 'package:bahias_descarga_system/utils/validators.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController(text: 'admin@empresa.com');
  final _passwordController = TextEditingController(text: 'password123');
  bool _obscurePassword = true;
  bool _isLoading = false;

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        await authProvider.login(
          _emailController.text,
          _passwordController.text,
        );

        // Redirigir según el tipo de usuario
        final usuario = authProvider.usuario;
        if (usuario != null) {
          switch (usuario.tipo) {
            case TipoUsuario.administrador:
              Navigator.pushReplacementNamed(context, '/admin');
              break;
            case TipoUsuario.operador:
              Navigator.pushReplacementNamed(context, '/dashboard');
              break;
            case TipoUsuario.planificador:
              Navigator.pushReplacementNamed(context, '/planificador');
              break;
            case TipoUsuario.supervisor:
              Navigator.pushReplacementNamed(context, '/supervisor');
              break;
            case TipoUsuario.administradorTI:
              Navigator.pushReplacementNamed(context, '/admin-ti');
              break;
            default:
              Navigator.pushReplacementNamed(context, '/dashboard');
          }
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      } finally {
        setState(() => _isLoading = false);
      }
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
                        backgroundImage: NetworkImage(
                          'https://thumbs.dreamstime.com/b/personaje-masculino-alegre-est%C3%A1-saludando-con-su-mano-sobre-fondo-blanco-concepto-de-personas-que-expresan-sus-emociones-lenguaje-228376228.jpg',
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Nombre del sistema
                      Text(
                        'Sistema de Bahías',
                        style: const TextStyle(
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

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _submit,
                          child: _isLoading
                              ? const CircularProgressIndicator()
                              : const Text('Iniciar Sesión'),
                        ),
                      ),

                      const SizedBox(height: 16),

                      TextButton(
                        onPressed: () {
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
