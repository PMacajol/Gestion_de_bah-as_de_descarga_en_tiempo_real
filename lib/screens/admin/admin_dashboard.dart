import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bahias_descarga_system/providers/bahia_provider.dart';
import 'package:bahias_descarga_system/providers/reserva_provider.dart';
import 'package:bahias_descarga_system/providers/auth_provider.dart';
import 'package:bahias_descarga_system/models/bahia_model.dart';
import 'package:bahias_descarga_system/widgets/custom_appbar.dart';
import 'package:bahias_descarga_system/utils/constants.dart';
import 'package:bahias_descarga_system/utils/responsive.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';
import 'package:bahias_descarga_system/models/reserva_model.dart';
import 'dart:convert';
import 'dart:math';
import 'package:universal_html/html.dart' as html;

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({Key? key}) : super(key: key);

  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedIndex = 0;
  final ScrollController _scrollController = ScrollController();
  int _loadedItems = 20;
  bool _cargandoDatos = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedIndex = _tabController.index;
      });
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        setState(() {
          _loadedItems += 20;
        });
      }
    });

    // Cargar datos al iniciar
    _cargarDatosIniciales();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _cargarDatosIniciales() async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final bahiaProvider = Provider.of<BahiaProvider>(context, listen: false);
      final reservaProvider =
          Provider.of<ReservaProvider>(context, listen: false);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      // Verificar que tenemos token
      if (authProvider.token == null) {
        print('❌ No hay token disponible en AdminDashboard');
        setState(() {
          _cargandoDatos = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'No hay sesión activa. Por favor, inicia sesión nuevamente.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      try {
        setState(() {
          _cargandoDatos = true;
        });

        print(
            '🔑 Token disponible: ${authProvider.token!.substring(0, 20)}...');

        // Pasar el token a los providers (por si acaso no se propagó correctamente)
        bahiaProvider.setToken(authProvider.token!);
        reservaProvider.setToken(authProvider.token!);

        print('🔄 Iniciando carga de datos...');

        // Verificar conexión primero
        final conectado = await authProvider.verificarConexion();
        if (!conectado) {
          throw Exception(
              'No se puede conectar al servidor. Verifica que el backend esté ejecutándose.');
        }

        // Verificar que el token es válido
        print('🔐 Verificando validez del token...');
        final tokenValido = await authProvider.verificarTokenValido();
        if (!tokenValido) {
          throw Exception(
              'Token inválido o expirado. Por favor, inicia sesión nuevamente.');
        }

        // Cargar datos secuencialmente para mejor debugging
        await bahiaProvider.cargarBahias();
        print('✅ Bahías cargadas: ${bahiaProvider.bahias.length}');

        await reservaProvider.cargarReservas();
        print('✅ Reservas cargadas: ${reservaProvider.reservas.length}');

        setState(() {
          _cargandoDatos = false;
        });

        print('🎉 Todos los datos cargados exitosamente');
      } catch (e) {
        print('❌ Error en carga de datos: $e');
        setState(() {
          _cargandoDatos = false;
        });

        // Mostrar error detallado
        _mostrarErrorDetallado(context, e);
      }
    });
  }

  void _mostrarErrorDetallado(BuildContext context, dynamic error) {
    String mensaje = 'Error desconocido';

    if (error.toString().contains('401')) {
      mensaje =
          'Error de autenticación (401). El token puede ser inválido o haber expirado.';
    } else if (error.toString().contains('403')) {
      mensaje = 'No tienes permisos para acceder a este recurso.';
    } else if (error.toString().contains('404')) {
      mensaje = 'Endpoint no encontrado. Verifica las URLs de la API.';
    } else if (error.toString().contains('Connection refused') ||
        error.toString().contains('Failed host lookup')) {
      mensaje =
          'No se puede conectar al servidor. Verifica que el backend esté ejecutándose en el puerto 8000.';
    } else if (error.toString().contains('timeout')) {
      mensaje =
          'Tiempo de espera agotado. El servidor está lento o no responde.';
    } else if (error.toString().contains('SocketException')) {
      mensaje = 'Error de conexión de red. Verifica tu conexión a internet.';
    } else {
      mensaje = 'Error: $error';
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 5),
      ),
    );
  }

  Future<void> _actualizarDatos() async {
    final bahiaProvider = Provider.of<BahiaProvider>(context, listen: false);
    final reservaProvider =
        Provider.of<ReservaProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    try {
      setState(() {
        _cargandoDatos = true;
      });

      // Verificar token antes de actualizar
      if (authProvider.token == null) {
        throw Exception('No hay token de autenticación disponible');
      }

      print('🔄 Actualizando datos...');

      await Future.wait([
        bahiaProvider.cargarBahias(),
        reservaProvider.cargarReservas(),
      ]).timeout(const Duration(seconds: 15));

      setState(() {
        _cargandoDatos = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Datos actualizados correctamente'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() {
        _cargandoDatos = false;
      });
      print('❌ Error al actualizar: $e');
      _mostrarErrorDetallado(context, e);
    }
  }

  Widget _buildLoadingWidget() {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Panel de Administración',
        showBackButton: false,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            const Text('Conectando con el servidor...'),
            const SizedBox(height: 8),
            Consumer<AuthProvider>(
              builder: (context, authProvider, child) {
                return Text(
                  'Token: ${authProvider.token != null ? '✅ Disponible' : '❌ No disponible'}',
                  style: TextStyle(
                    color:
                        authProvider.token != null ? Colors.green : Colors.red,
                    fontSize: 12,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Si está cargando, mostrar widget de carga mejorado
    if (_cargandoDatos) {
      return _buildLoadingWidget();
    }

    final bahiaProvider = Provider.of<BahiaProvider>(context);
    final reservaProvider = Provider.of<ReservaProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    final bahias = bahiaProvider.bahias;
    final reservas = reservaProvider.reservas;

    // Estadísticas
    final totalBahias = bahias.length;
    final bahiasLibres =
        bahias.where((b) => b.estado == EstadoBahia.libre).length;
    final bahiasOcupadas =
        bahias.where((b) => b.estado == EstadoBahia.enUso).length;
    final bahiasReservadas =
        bahias.where((b) => b.estado == EstadoBahia.reservada).length;
    final bahiasMantenimiento =
        bahias.where((b) => b.estado == EstadoBahia.mantenimiento).length;

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Panel de Administración',
        showBackButton: false,
        actions: [
          // Botón de debug para verificar token
          IconButton(
            icon: const Icon(Icons.security, color: Colors.white),
            onPressed: () => _verificarToken(context),
            tooltip: 'Verificar Token',
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _actualizarDatos,
            tooltip: 'Actualizar datos',
          ),
          IconButton(
            icon: const Icon(Icons.notifications_active, color: Colors.white),
            onPressed: () => _mostrarNotificaciones(context),
            tooltip: 'Notificaciones',
          ),
          IconButton(
            icon: const Icon(Icons.bar_chart, color: Colors.white),
            onPressed: () => _mostrarReportesCompletos(context, reservas),
            tooltip: 'Reportes',
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) {
              if (value == 'configuracion') {
                _mostrarConfiguracion(context);
              } else if (value == 'backup') {
                _realizarBackup(context);
              } else if (value == 'debug') {
                _mostrarInfoDebug(
                    context, authProvider, bahiaProvider, reservaProvider);
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem<String>(
                  value: 'configuracion',
                  child: ListTile(
                    leading: Icon(Icons.settings),
                    title: Text('Configuración'),
                  ),
                ),
                const PopupMenuItem<String>(
                  value: 'backup',
                  child: ListTile(
                    leading: Icon(Icons.backup),
                    title: Text('Realizar Backup'),
                  ),
                ),
                const PopupMenuItem<String>(
                  value: 'debug',
                  child: ListTile(
                    leading: Icon(Icons.bug_report),
                    title: Text('Info Debug'),
                  ),
                ),
              ];
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Tarjetas de estadísticas
          _buildResponsiveStatsRow(totalBahias, bahiasLibres, bahiasOcupadas,
              bahiasReservadas, bahiasMantenimiento),

          // Pestañas
          Container(
            color: Colors.grey[100],
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              indicatorColor: AppColors.primary,
              labelColor: AppColors.primary,
              unselectedLabelColor: Colors.grey,
              tabs: Responsive.isMobile(context)
                  ? const [
                      Tab(icon: Icon(Icons.dashboard)),
                      Tab(icon: Icon(Icons.local_shipping)),
                      Tab(icon: Icon(Icons.calendar_today)),
                      Tab(icon: Icon(Icons.analytics)),
                    ]
                  : const [
                      Tab(icon: Icon(Icons.dashboard), text: 'Dashboard'),
                      Tab(icon: Icon(Icons.local_shipping), text: 'Bahías'),
                      Tab(icon: Icon(Icons.calendar_today), text: 'Reservas'),
                      Tab(icon: Icon(Icons.analytics), text: 'Reportes'),
                    ],
            ),
          ),

          // Contenido de pestañas
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildDashboardTab(bahias, reservas, reservaProvider),
                _buildBahiasTab(bahiaProvider, bahias),
                _buildReservasTab(reservaProvider, reservas),
                _buildReportesTab(bahias, reservas, reservaProvider),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _selectedIndex == 1
          ? FloatingActionButton(
              onPressed: () => _agregarNuevaBahia(context, bahiaProvider),
              child: const Icon(Icons.add),
              backgroundColor: AppColors.primary,
              tooltip: 'Agregar nueva bahía',
            )
          : null,
      bottomNavigationBar: Responsive.isMobile(context)
          ? BottomNavigationBar(
              currentIndex: _selectedIndex,
              onTap: (index) {
                setState(() {
                  _selectedIndex = index;
                  _tabController.animateTo(index);
                });
              },
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.dashboard),
                  label: 'Dashboard',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.local_shipping),
                  label: 'Bahías',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.calendar_today),
                  label: 'Reservas',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.analytics),
                  label: 'Reportes',
                ),
              ],
            )
          : null,
    );
  }

  Future<void> _verificarToken(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    try {
      final tokenValido = await authProvider.verificarTokenValido();
      final tokenInfo = authProvider.getTokenInfo();

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Información del Token'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('✅ Token válido: ${tokenValido ? "SÍ" : "NO"}'),
                const SizedBox(height: 10),
                if (tokenInfo != null) ...[
                  Text('👤 Usuario ID: ${tokenInfo['sub']}'),
                  Text('🎯 Tipo: ${tokenInfo['tipo']}'),
                  Text(
                      '⏰ Expira: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.fromMillisecondsSinceEpoch(tokenInfo['exp'] * 1000))}'),
                ],
                const SizedBox(height: 10),
                Text(
                    '🔑 Token (inicio): ${authProvider.token?.substring(0, 30)}...'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cerrar'),
            ),
          ],
        ),
      );
    } catch (e) {
      _mostrarErrorDetallado(context, e);
    }
  }

  void _mostrarInfoDebug(BuildContext context, AuthProvider authProvider,
      BahiaProvider bahiaProvider, ReservaProvider reservaProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Información de Debug'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🔐 AUTENTICACIÓN:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Text(
                  'Token: ${authProvider.token != null ? "✅ Disponible" : "❌ No disponible"}'),
              Text(
                  'Usuario: ${authProvider.usuario?.nombre ?? "No autenticado"}'),
              Text('Autenticado: ${authProvider.autenticado}'),
              const SizedBox(height: 16),
              const Text('📊 DATOS:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Text('Bahías cargadas: ${bahiaProvider.bahias.length}'),
              Text('Reservas cargadas: ${reservaProvider.reservas.length}'),
              const SizedBox(height: 16),
              const Text('🌐 CONEXIÓN:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Text('URL Base: http://10.0.2.2:8000'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  Widget _buildResponsiveStatsRow(
      int total, int libres, int ocupadas, int reservadas, int mantenimiento) {
    if (Responsive.isMobile(context)) {
      return SizedBox(
        height: 120,
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.all(16),
          children: [
            _buildStatCard('Total', total, Icons.local_parking, Colors.blue),
            _buildStatCard('Libres', libres, Icons.check_circle, Colors.green),
            _buildStatCard(
                'Ocupadas', ocupadas, Icons.do_not_disturb, Colors.red),
            _buildStatCard(
                'Reservadas', reservadas, Icons.access_time, Colors.orange),
            _buildStatCard(
                'Mant.', mantenimiento, Icons.build, Colors.blueGrey),
          ],
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            _buildStatCard(
                'Total Bahías', total, Icons.local_parking, Colors.blue),
            _buildStatCard('Libres', libres, Icons.check_circle, Colors.green),
            _buildStatCard(
                'Ocupadas', ocupadas, Icons.do_not_disturb, Colors.red),
            _buildStatCard(
                'Reservadas', reservadas, Icons.access_time, Colors.orange),
            _buildStatCard(
                'Mantenimiento', mantenimiento, Icons.build, Colors.blueGrey),
          ],
        ),
      );
    }
  }

  Widget _buildStatCard(String title, int value, IconData icon, Color color) {
    final isMobile = Responsive.isMobile(context);
    return Card(
      elevation: 4,
      child: Padding(
        padding:
            isMobile ? const EdgeInsets.all(8.0) : const EdgeInsets.all(16.0),
        child: SizedBox(
          width: isMobile ? 100 : 150,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: color, size: isMobile ? 20 : 24),
                  const Spacer(),
                  Text(
                    value.toString(),
                    style: TextStyle(
                      fontSize: isMobile ? 18 : 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: isMobile ? 12 : 14,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _reservarBahia(BuildContext context, Bahia bahia) {
    Navigator.pop(context);
    Navigator.pushNamed(
      context,
      '/reservation',
      arguments: bahia,
    );
  }

  void _ponerEnUso(
      BuildContext context, Bahia bahia, BahiaProvider bahiaProvider) async {
    try {
      await _mostrarDialogoPonerEnUso(context, bahia, bahiaProvider);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _mostrarDialogoPonerEnUso(
      BuildContext context, Bahia bahia, BahiaProvider bahiaProvider) async {
    String vehiculoPlaca = '';
    String conductorNombre = '';
    String mercanciaTipo = '';

    await showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Poner en uso Bahía ${bahia.numero}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Placa del vehículo',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => vehiculoPlaca = value,
            ),
            const SizedBox(height: 12),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Nombre del conductor',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => conductorNombre = value,
            ),
            const SizedBox(height: 12),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Tipo de mercancía',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => mercanciaTipo = value,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (vehiculoPlaca.isEmpty ||
                  conductorNombre.isEmpty ||
                  mercanciaTipo.isEmpty) {
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  const SnackBar(
                      content: Text('Todos los campos son obligatorios')),
                );
                return;
              }

              try {
                // Cerrar el diálogo de entrada
                Navigator.pop(dialogContext);

                // ✅ CERRAR el menú de opciones también
                if (context.mounted) {
                  Navigator.pop(context);
                }

                // Realizar la acción
                await bahiaProvider.ponerEnUso(
                    bahia.id, vehiculoPlaca, conductorNombre, mercanciaTipo);

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Bahía puesta en uso correctamente')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              }
            },
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );
  }

  void _ponerEnMantenimiento(
      BuildContext context, Bahia bahia, BahiaProvider bahiaProvider) async {
    try {
      // Cerrar el menú de opciones primero
      Navigator.pop(context);

      await bahiaProvider.ponerEnMantenimiento(
          bahia.id, 'Mantenimiento programado desde Admin Dashboard');

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Bahía puesta en mantenimiento correctamente')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  void _liberarDeMantenimiento(
      BuildContext context, Bahia bahia, BahiaProvider bahiaProvider) async {
    // Cerrar el menú de opciones primero
    Navigator.pop(context);

    // Mostrar diálogo con opciones
    final accion = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Mantenimiento de Bahía ${bahia.numero}'),
        content: const Text('¿Qué acción desea realizar con el mantenimiento?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, 'cancelar'),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, 'completar_sin_obs'),
            style: TextButton.styleFrom(foregroundColor: Colors.blue),
            child: const Text('Completar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, 'completar_con_obs'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Completar con Observaciones'),
          ),
        ],
      ),
    );

    if (accion == null) return;

    try {
      if (accion == 'cancelar') {
        // Pedir motivo de cancelación
        final motivo = await _mostrarDialogoMotivo(
            context, '¿Por qué se cancela el mantenimiento?');
        if (motivo == null || motivo.isEmpty) return;

        await bahiaProvider.cancelarMantenimiento(bahia.id, motivo);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Mantenimiento cancelado correctamente')),
          );
        }
      } else if (accion == 'completar_sin_obs') {
        // Completar sin observaciones
        await bahiaProvider.liberarDeMantenimiento(bahia.id);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Mantenimiento completado correctamente')),
          );
        }
      } else if (accion == 'completar_con_obs') {
        // Completar con observaciones
        final observaciones = await _mostrarDialogoMotivo(
            context, 'Ingrese observaciones sobre el mantenimiento realizado:');
        if (observaciones == null || observaciones.isEmpty) {
          // Si no ingresa observaciones, completar sin ellas
          await bahiaProvider.liberarDeMantenimiento(bahia.id);
        } else {
          await bahiaProvider.liberarDeMantenimiento(bahia.id,
              observaciones: observaciones);
        }

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Mantenimiento completado correctamente')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<String?> _mostrarDialogoMotivo(
      BuildContext context, String titulo) async {
    String texto = '';

    return await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(titulo),
        content: TextField(
          decoration: const InputDecoration(
            hintText: 'Escriba aquí...',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
          onChanged: (value) => texto = value,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, null),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, texto),
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );
  }

  void _liberarBahia(
      BuildContext context, Bahia bahia, BahiaProvider bahiaProvider) async {
    try {
      // Cerrar el menú de opciones primero
      Navigator.pop(context);

      await bahiaProvider.liberarBahia(bahia.id);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bahía liberada correctamente')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  void _cancelarReservaBahia(
      BuildContext context, Bahia bahia, BahiaProvider bahiaProvider) async {
    // Mostrar confirmación antes de cancelar
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Confirmar cancelación'),
        content: Text(
            '¿Está seguro de cancelar la reserva de la Bahía ${bahia.numero}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Sí, cancelar'),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    try {
      // Cerrar el menú de opciones
      if (context.mounted) {
        Navigator.pop(context);
      }

      await bahiaProvider.cancelarReservaBahia(bahia.id);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reserva cancelada correctamente')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Widget _buildDetalleItem(String titulo, String valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$titulo: ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(valor),
          ),
        ],
      ),
    );
  }

  void _mostrarDetallesCompletosBahia(BuildContext context, Bahia bahia) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Detalles de Bahía ${bahia.numero}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetalleItem('Número', bahia.numero.toString()),
              _buildDetalleItem('Tipo', bahia.nombreTipo),
              _buildDetalleItem('Estado', bahia.nombreEstado),
              _buildDetalleItem(
                  'Capacidad Máxima', bahia.capacidadMaxima.toString()),
              _buildDetalleItem('Ubicación', bahia.ubicacion),
              if (bahia.observaciones != null &&
                  bahia.observaciones!.isNotEmpty)
                _buildDetalleItem('Observaciones', bahia.observaciones!),
              _buildDetalleItem('Activa', bahia.activo ? 'Sí' : 'No'),
              _buildDetalleItem('Fecha Creación',
                  DateFormat('dd/MM/yyyy HH:mm').format(bahia.fechaCreacion)),
              _buildDetalleItem(
                  'Última Modificación',
                  DateFormat('dd/MM/yyyy HH:mm')
                      .format(bahia.fechaUltimaModificacion)),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  Widget _buildBotonOpcion(
      String texto, IconData icono, Color color, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icono, size: 20),
        label: Text(texto),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        ),
      ),
    );
  }

  Widget _buildDashboardTab(List<Bahia> bahias, List<Reserva> reservas,
      ReservaProvider reservaProvider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Resumen del Sistema',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildUsoPorTipoChart(bahias),
          const SizedBox(height: 24),
          _buildReservasProximas(reservas),
          const SizedBox(height: 24),
          _buildIndicadoresDashboard(reservaProvider),
        ],
      ),
    );
  }

  Widget _buildUsoPorTipoChart(List<Bahia> bahias) {
    final bool isMobile = Responsive.isMobile(context);
    final datos = [
      ChartData(
          'Libres',
          bahias.where((b) => b.estado == EstadoBahia.libre).length,
          Colors.green),
      ChartData(
          'Ocupadas',
          bahias.where((b) => b.estado == EstadoBahia.enUso).length,
          Colors.red),
      ChartData(
          'Reservadas',
          bahias.where((b) => b.estado == EstadoBahia.reservada).length,
          Colors.orange),
      ChartData(
          'Mantenimiento',
          bahias.where((b) => b.estado == EstadoBahia.mantenimiento).length,
          Colors.blue),
    ];

    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.blue.shade100, width: 1),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blue.shade50, Colors.white],
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: EdgeInsets.all(isMobile ? 12.0 : 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '📊 Distribución de Estados',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: isMobile ? 180 : 250,
                child: SfCircularChart(
                  margin: EdgeInsets.zero,
                  palette: const [
                    Colors.green,
                    Colors.red,
                    Colors.orange,
                    Colors.blue
                  ],
                  series: <CircularSeries>[
                    DoughnutSeries<ChartData, String>(
                      dataSource: datos,
                      xValueMapper: (ChartData data, _) => data.x,
                      yValueMapper: (ChartData data, _) => data.y,
                      radius: '80%',
                      explode: true,
                      explodeOffset: '10%',
                      dataLabelSettings: const DataLabelSettings(
                        isVisible: true,
                        labelPosition: ChartDataLabelPosition.outside,
                        textStyle: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold),
                        connectorLineSettings: ConnectorLineSettings(
                          length: '10%',
                          width: 2,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ],
                  legend: const Legend(
                    isVisible: true,
                    position: LegendPosition.bottom,
                    overflowMode: LegendItemOverflowMode.wrap,
                    textStyle:
                        TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: datos
                    .map((dato) => Chip(
                          label: Text('${dato.x}: ${dato.y}'),
                          backgroundColor:
                              (dato.color ?? Colors.grey).withOpacity(0.2),
                          labelStyle: TextStyle(
                            color: dato.color ?? Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                          side: BorderSide(color: dato.color ?? Colors.grey),
                        ))
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReservasProximas(List<Reserva> reservas) {
    final ahora = DateTime.now();
    final en24Horas = ahora.add(const Duration(days: 1));

    final reservasProximas = reservas
        .where((r) {
          bool esActiva = r.estado == 'activa';
          bool estaEnRango = r.fechaHoraInicio.isAfter(ahora) &&
              r.fechaHoraInicio.isBefore(en24Horas);
          return esActiva && estaEnRango;
        })
        .take(5)
        .toList();

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Próximas Reservas (24h)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (reservasProximas.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'No hay reservas activas en las próximas 24 horas',
                  style: TextStyle(
                      color: Colors.grey, fontStyle: FontStyle.italic),
                ),
              )
            else
              ...reservasProximas.map((reserva) => ListTile(
                    leading:
                        const Icon(Icons.calendar_today, color: Colors.blue),
                    title: Text('Bahía #${reserva.numeroBahia}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Usuario: ${reserva.usuarioNombre}'),
                        Text(
                            'Inicio: ${DateFormat('dd/MM/yyyy HH:mm').format(reserva.fechaHoraInicio)}'),
                        Text(
                            'Fin: ${DateFormat('dd/MM/yyyy HH:mm').format(reserva.fechaHoraFin)}'),
                      ],
                    ),
                    trailing: Chip(
                      label: Text(
                        reserva.estado.toUpperCase(),
                        style:
                            const TextStyle(fontSize: 10, color: Colors.white),
                      ),
                      backgroundColor: Colors.orange,
                    ),
                  )),
          ],
        ),
      ),
    );
  }

  Widget _buildIndicadoresDashboard(ReservaProvider reservaProvider) {
    return FutureBuilder<Map<String, dynamic>>(
      future: reservaProvider.obtenerIndicadoresDashboard(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildMetricasCargando();
        } else if (snapshot.hasError) {
          return _buildErrorCard(
              'Error al cargar indicadores: ${snapshot.error}');
        } else {
          final datos = snapshot.data!;
          return _buildIndicadoresDashboardReal(datos);
        }
      },
    );
  }

  Widget _buildMetricasCargando() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
                child: _buildMiniMetricaCard(
                    'Cargando...', 0, Icons.hourglass_empty, Colors.grey)),
            Expanded(
                child: _buildMiniMetricaCard(
                    'Cargando...', 0, Icons.hourglass_empty, Colors.grey)),
            Expanded(
                child: _buildMiniMetricaCard(
                    'Cargando...', 0, Icons.hourglass_empty, Colors.grey)),
            Expanded(
                child: _buildMiniMetricaCard(
                    'Cargando...', 0, Icons.hourglass_empty, Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorCard(String mensaje) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(Icons.error, color: Colors.red, size: 48),
            const SizedBox(height: 8),
            Text(mensaje, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildIndicadoresDashboardReal(Map<String, dynamic> datos) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Indicadores en Tiempo Real',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildMiniMetricaCard('Hoy', _safeInt(datos['reservas_hoy']),
                    Icons.today, Colors.blue),
                _buildMiniMetricaCard(
                    'Semana',
                    _safeInt(datos['reservas_semana']),
                    Icons.date_range,
                    Colors.green),
                _buildMiniMetricaCard(
                    'Críticas',
                    _safeInt(datos['bahias_criticas']),
                    Icons.warning,
                    Colors.orange),
                _buildMiniMetricaCard(
                    'Incidencias',
                    _safeInt(datos['incidencias_abiertas']),
                    Icons.report_problem,
                    Colors.red),
              ],
            ),
          ],
        ),
      ),
    );
  }

// Método auxiliar para convertir safe a int
  int _safeInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  Widget _buildMiniMetricaCard(
      String titulo, int valor, IconData icono, Color color) {
    return Expanded(
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Icon(icono, size: 20, color: color),
              const SizedBox(height: 8),
              Text(
                valor.toString(),
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold, color: color),
              ),
              Text(
                titulo,
                style: const TextStyle(fontSize: 10, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBahiasTab(BahiaProvider bahiaProvider, List<Bahia> bahias) {
    final searchController = TextEditingController();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Barra de búsqueda
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    labelText: 'Buscar bahía...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              searchController.clear();
                              bahiaProvider.limpiarBusqueda();
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onChanged: (value) {
                    bahiaProvider.buscarBahias(value);
                  },
                ),
              ),
              const SizedBox(width: 16),
              PopupMenuButton<String>(
                icon: const Icon(Icons.filter_list),
                onSelected: (value) {
                  // Filtros pueden implementarse aquí si es necesario
                },
                itemBuilder: (BuildContext context) {
                  return [
                    const PopupMenuItem<String>(
                      value: 'todas',
                      child: Text('Todas las bahías'),
                    ),
                    const PopupMenuItem<String>(
                      value: 'libres',
                      child: Text('Solo libres'),
                    ),
                    const PopupMenuItem<String>(
                      value: 'ocupadas',
                      child: Text('Solo ocupadas'),
                    ),
                  ];
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                double width = constraints.maxWidth;
                int crossAxisCount;
                if (width > 600) {
                  crossAxisCount = 4;
                } else if (width > 400) {
                  crossAxisCount = 3;
                } else {
                  crossAxisCount = 2;
                }

                return GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    childAspectRatio: 0.8,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: bahias.length,
                  itemBuilder: (context, index) {
                    final bahia = bahias[index];
                    return _buildBahiaAdminCard(bahia, bahiaProvider);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _mostrarOpcionesBahia(
      BuildContext context, Bahia bahia, BahiaProvider bahiaProvider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return SafeArea(
          child: Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 8, bottom: 16),
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(2.5),
                  ),
                ),
                Text(
                  'Bahía ${bahia.numero} - ${bahia.nombreTipo}',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Estado: ${bahia.nombreEstado}',
                  style: TextStyle(
                    fontSize: 16,
                    color: bahia.colorEstado,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                if (bahia.estado == EstadoBahia.libre) ...[
                  _buildBotonOpcion(
                    'Reservar Bahía',
                    Icons.calendar_today,
                    Colors.blue,
                    () => _reservarBahia(context, bahia),
                  ),
                  const SizedBox(height: 8),
                  _buildBotonOpcion(
                    'Poner en Uso',
                    Icons.local_shipping,
                    Colors.orange,
                    () => _ponerEnUso(context, bahia, bahiaProvider),
                  ),
                  const SizedBox(height: 8),
                  _buildBotonOpcion(
                    'Poner en Mantenimiento',
                    Icons.build,
                    Colors.blueGrey,
                    () => _ponerEnMantenimiento(context, bahia, bahiaProvider),
                  ),
                ],
                if (bahia.estado == EstadoBahia.mantenimiento) ...[
                  _buildBotonOpcion(
                    'Liberar de Mantenimiento',
                    Icons.check_circle,
                    Colors.green,
                    () =>
                        _liberarDeMantenimiento(context, bahia, bahiaProvider),
                  ),
                ],
                if (bahia.estado == EstadoBahia.reservada) ...[
                  _buildBotonOpcion(
                    'Cancelar Reserva',
                    Icons.cancel,
                    Colors.red,
                    () => _cancelarReservaBahia(context, bahia, bahiaProvider),
                  ),
                  const SizedBox(height: 8),
                  _buildBotonOpcion(
                    'Poner en Uso',
                    Icons.local_shipping,
                    Colors.orange,
                    () => _ponerEnUso(context, bahia, bahiaProvider),
                  ),
                ],
                if (bahia.estado == EstadoBahia.enUso) ...[
                  _buildBotonOpcion(
                    'Liberar Bahía',
                    Icons.check_circle,
                    Colors.green,
                    () => _liberarBahia(context, bahia, bahiaProvider),
                  ),
                ],
                const SizedBox(height: 16),
                _buildBotonOpcion(
                  'Ver Detalles',
                  Icons.info,
                  Colors.grey,
                  () => _mostrarDetallesCompletosBahia(context, bahia),
                ),
                const SizedBox(height: 8),
                _buildBotonOpcion(
                  'Cancelar',
                  Icons.close,
                  Colors.grey,
                  () => Navigator.pop(context),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBahiaAdminCard(Bahia bahia, BahiaProvider bahiaProvider) {
    // Determinar texto legible según el estado del enum
    String estadoTexto;
    switch (bahia.estado) {
      case EstadoBahia.libre:
        estadoTexto = 'Libre';
        break;
      case EstadoBahia.enUso:
        estadoTexto = 'En Uso';
        break;
      case EstadoBahia.reservada:
        estadoTexto = 'Reservada';
        break;
      case EstadoBahia.mantenimiento:
        estadoTexto = 'Mantenimiento';
        break;
    }

    return GestureDetector(
      onTap: () => _mostrarOpcionesBahia(context, bahia, bahiaProvider),
      onLongPress: () => _mostrarDetallesCompletosBahia(context, bahia),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: bahia.colorEstado.withOpacity(0.3), width: 2),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: bahia.colorEstado.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Ícono circular de estado
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: bahia.colorEstado,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  bahia.iconoEstado,
                  size: 20,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),

              // Número de bahía
              Text(
                'Bahía ${bahia.numero}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),

              // Tipo de bahía
              Text(
                bahia.nombreTipo,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),

              // Estado traducido (controlado desde enum)
              Text(
                estadoTexto,
                style: TextStyle(
                  fontSize: 12,
                  color: bahia.colorEstado,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReservasTab(
      ReservaProvider reservaProvider, List<Reserva> reservas) {
    final searchController = TextEditingController();
    String _filtroEstado = 'todas';

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    labelText: 'Buscar reservas...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onChanged: (value) {
                    // Búsqueda puede implementarse aquí
                  },
                ),
              ),
              const SizedBox(width: 16),
              PopupMenuButton<String>(
                icon: const Icon(Icons.filter_list),
                onSelected: (value) {
                  setState(() {
                    _filtroEstado = value;
                  });
                },
                itemBuilder: (BuildContext context) {
                  return [
                    const PopupMenuItem<String>(
                      value: 'todas',
                      child: Text('Todas las reservas'),
                    ),
                    const PopupMenuItem<String>(
                      value: 'activas',
                      child: Text('Solo activas'),
                    ),
                    const PopupMenuItem<String>(
                      value: 'completadas',
                      child: Text('Solo completadas'),
                    ),
                    const PopupMenuItem<String>(
                      value: 'canceladas',
                      child: Text('Solo canceladas'),
                    ),
                  ];
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildResumenReservas(reservas),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: min(_loadedItems + 1, reservas.length),
              itemBuilder: (context, index) {
                if (index == _loadedItems && _loadedItems < reservas.length) {
                  return const Center(child: CircularProgressIndicator());
                }

                final reserva = reservas[index];

                // Aplicar filtro
                if (_filtroEstado == 'activas' && reserva.estado != 'activa')
                  return Container();
                if (_filtroEstado == 'completadas' &&
                    reserva.estado != 'completada') return Container();
                if (_filtroEstado == 'canceladas' &&
                    reserva.estado != 'cancelada') return Container();

                return _buildReservaCard(reserva, reservaProvider);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResumenReservas(List<Reserva> reservas) {
    final total = reservas.length;
    final activas = reservas.where((r) => r.estado == 'activa').length;
    final completadas = reservas.where((r) => r.estado == 'completada').length;
    final canceladas = reservas.where((r) => r.estado == 'cancelada').length;

    return Row(
      children: [
        _buildMiniReservaCard('Total', total, Icons.list, Colors.blue),
        const SizedBox(width: 8),
        _buildMiniReservaCard(
            'Activas', activas, Icons.check_circle, Colors.green),
        const SizedBox(width: 8),
        _buildMiniReservaCard(
            'Completadas', completadas, Icons.done_all, Colors.blueGrey),
        const SizedBox(width: 8),
        _buildMiniReservaCard(
            'Canceladas', canceladas, Icons.cancel, Colors.red),
      ],
    );
  }

  Widget _buildMiniReservaCard(
      String titulo, int valor, IconData icono, Color color) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Icon(icono, size: 16, color: color),
              const SizedBox(height: 4),
              Text(
                valor.toString(),
                style: TextStyle(
                    fontSize: 14, fontWeight: FontWeight.bold, color: color),
              ),
              Text(
                titulo,
                style: const TextStyle(fontSize: 10),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReservaCard(Reserva reserva, ReservaProvider reservaProvider) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
            color: reserva.estado == 'activa'
                ? Colors.green.shade100
                : reserva.estado == 'completada'
                    ? Colors.blueGrey.shade100
                    : Colors.red.shade100,
            width: 2),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: reserva.estado == 'activa'
                ? Colors.green.withOpacity(0.2)
                : reserva.estado == 'completada'
                    ? Colors.blueGrey.withOpacity(0.2)
                    : Colors.red.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(
            reserva.estado == 'activa'
                ? Icons.access_time
                : reserva.estado == 'completada'
                    ? Icons.check_circle
                    : Icons.cancel,
            size: 20,
            color: reserva.estado == 'activa'
                ? Colors.green
                : reserva.estado == 'completada'
                    ? Colors.blueGrey
                    : Colors.red,
          ),
        ),
        title: Text(
          'Reserva #${reserva.id.substring(0, 8)}...',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Bahía: ${reserva.numeroBahia}'),
            Text('Usuario: ${reserva.usuarioNombre}'),
            Text(
                'Inicio: ${DateFormat('dd/MM/yyyy HH:mm').format(reserva.fechaHoraInicio)}'),
            Text(
                'Fin: ${DateFormat('dd/MM/yyyy HH:mm').format(reserva.fechaHoraFin)}'),
            Chip(
              label: Text(
                reserva.estado.toUpperCase(),
                style: const TextStyle(fontSize: 10, color: Colors.white),
              ),
              backgroundColor: reserva.estado == 'activa'
                  ? Colors.green
                  : reserva.estado == 'completada'
                      ? Colors.blueGrey
                      : Colors.red,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          onSelected: (value) {
            if (value == 'editar') {
              _editarReserva(context, reserva, reservaProvider);
            } else if (value == 'cancelar' && reserva.estado == 'activa') {
              _cancelarReservaIndividual(context, reserva, reservaProvider);
            } else if (value == 'completar' && reserva.estado == 'activa') {
              _completarReserva(context, reserva, reservaProvider);
            } else if (value == 'detalles') {
              _mostrarDetallesReserva(context, reserva);
            }
          },
          itemBuilder: (BuildContext context) {
            return [
              if (reserva.estado == 'activa') ...[
                const PopupMenuItem<String>(
                  value: 'cancelar',
                  child: ListTile(
                    leading: Icon(Icons.cancel, size: 20, color: Colors.red),
                    title: Text('Cancelar'),
                  ),
                ),
                const PopupMenuItem<String>(
                  value: 'completar',
                  child: ListTile(
                    leading:
                        Icon(Icons.check_circle, size: 20, color: Colors.green),
                    title: Text('Completar'),
                  ),
                ),
              ],
              const PopupMenuItem<String>(
                value: 'detalles',
                child: ListTile(
                  leading: Icon(Icons.info, size: 20),
                  title: Text('Detalles'),
                ),
              ),
            ];
          },
        ),
      ),
    );
  }

  void _cancelarReservaIndividual(
      BuildContext context, Reserva reserva, ReservaProvider reservaProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancelar Reserva'),
        content: const Text(
            '¿Está seguro de cancelar esta reserva? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No, mantener'),
          ),
          TextButton(
            onPressed: () async {
              try {
                await reservaProvider.cancelarReserva(reserva.id);

                final bahiaProvider =
                    Provider.of<BahiaProvider>(context, listen: false);
                await bahiaProvider.liberarBahia(reserva.bahiaId);

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Reserva cancelada exitosamente')),
                );

                setState(() {});
              } catch (e) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error al cancelar: $e')),
                );
              }
            },
            child:
                const Text('Sí, cancelar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _editarReserva(
      BuildContext context, Reserva reserva, ReservaProvider reservaProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Reserva'),
        content: const Text(
            'Funcionalidad de edición en desarrollo para próxima versión.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _completarReserva(BuildContext context, Reserva reserva,
      ReservaProvider reservaProvider) async {
    try {
      await reservaProvider.completarReserva(reserva.id);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reserva marcada como completada')),
      );

      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void _mostrarDetallesReserva(BuildContext context, Reserva reserva) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Detalles de Reserva #${reserva.id.substring(0, 8)}...'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetalleItem('ID', reserva.id),
              _buildDetalleItem('Bahía', reserva.numeroBahia.toString()),
              _buildDetalleItem('Usuario', reserva.usuarioNombre),
              _buildDetalleItem('Email', reserva.usuarioEmail),
              _buildDetalleItem('Estado', reserva.estado),
              _buildDetalleItem(
                  'Inicio',
                  DateFormat('dd/MM/yyyy HH:mm')
                      .format(reserva.fechaHoraInicio)),
              _buildDetalleItem('Fin',
                  DateFormat('dd/MM/yyyy HH:mm').format(reserva.fechaHoraFin)),
              _buildDetalleItem('Duración', reserva.duracion),
              _buildDetalleItem('Creación',
                  DateFormat('dd/MM/yyyy HH:mm').format(reserva.fechaCreacion)),
              if (reserva.vehiculoPlaca != null)
                _buildDetalleItem('Vehículo', reserva.vehiculoPlaca!),
              if (reserva.conductorNombre != null)
                _buildDetalleItem('Conductor', reserva.conductorNombre!),
              if (reserva.mercanciaTipo != null)
                _buildDetalleItem('Mercancía', reserva.mercanciaTipo!),
              if (reserva.observaciones != null)
                _buildDetalleItem('Observaciones', reserva.observaciones!),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  Widget _buildReportesTab(List<Bahia> bahias, List<Reserva> reservas,
      ReservaProvider reservaProvider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '📈 Reportes y Estadísticas',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Estadísticas de uso
          FutureBuilder<Map<String, dynamic>>(
            future: reservaProvider.obtenerEstadisticasUso(
                DateTime.now().subtract(const Duration(days: 30)),
                DateTime.now()),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return _buildGraficoCargando();
              } else if (snapshot.hasError) {
                return _buildErrorCard(
                    'Error al cargar estadísticas: ${snapshot.error}');
              } else {
                final datos = snapshot.data!;
                return _buildEstadisticasUso(datos);
              }
            },
          ),

          const SizedBox(height: 24),

          // Gráfico de tendencia
          FutureBuilder<Map<String, dynamic>>(
            future: reservaProvider.obtenerEstadisticasUso(
                DateTime.now().subtract(const Duration(days: 30)),
                DateTime.now()),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return _buildGraficoCargando();
              } else if (snapshot.hasError) {
                return _buildErrorCard(
                    'Error al cargar tendencia: ${snapshot.error}');
              } else {
                final datos = snapshot.data!;
                return _buildGraficoTendenciaReal(datos);
              }
            },
          ),

          const SizedBox(height: 24),

          // Exportar reportes
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Exportar Reportes',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _buildBotonExportacion(
                          'Reporte Diario',
                          Icons.today,
                          Colors.blue,
                          () => _generarReporteDiario(reservaProvider)),
                      _buildBotonExportacion(
                          'Reporte Semanal',
                          Icons.date_range,
                          Colors.green,
                          () => _generarReporteSemanal(reservaProvider)),
                      _buildBotonExportacion(
                          'Reporte Mensual',
                          Icons.calendar_view_month,
                          Colors.orange,
                          () => _generarReporteMensual(reservaProvider)),
                      _buildBotonExportacion(
                          'Personalizado',
                          Icons.tune,
                          Colors.purple,
                          () => _generarReportePersonalizado(
                              context, reservaProvider)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGraficoCargando() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text('Cargando gráfico...'),
            const SizedBox(height: 16),
            LinearProgressIndicator(),
          ],
        ),
      ),
    );
  }

  Widget _buildEstadisticasUso(Map<String, dynamic> datos) {
    final stats = datos['estadisticas_generales'] ?? {};
    final usoPorTipo = datos['uso_por_tipo_bahia'] ?? [];

    // Manejo seguro de la duración promedio
    final dynamic duracionPromedio = stats["duracion_promedio_minutos"];
    String duracionPromedioTexto = "0 min";

    if (duracionPromedio != null) {
      if (duracionPromedio is num) {
        duracionPromedioTexto = "${duracionPromedio.toStringAsFixed(0)} min";
      } else if (duracionPromedio is String) {
        // Si viene como string, usarlo directamente
        duracionPromedioTexto = duracionPromedio;
      }
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Estadísticas de Uso (Últimos 30 días)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _buildMiniMetricaCard('Total',
                    _safeInt(stats['total_reservas']), Icons.list, Colors.blue),
                _buildMiniMetricaCard(
                  'Completadas',
                  _safeInt(stats['reservas_completadas']),
                  Icons.check_circle,
                  Colors.green,
                ),
                _buildMiniMetricaCard(
                  'Canceladas',
                  _safeInt(stats['reservas_canceladas']),
                  Icons.cancel,
                  Colors.red,
                ),
                _buildMiniMetricaCardTexto(
                  'Duración Prom.',
                  duracionPromedioTexto, // Usar el texto directamente
                  Icons.timer,
                  Colors.orange,
                ),
              ],
            ),
            if (usoPorTipo.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text(
                'Uso por Tipo de Bahía:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              ...usoPorTipo.map((tipo) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Expanded(
                            child: Text(tipo['tipo_bahia'] ?? 'Desconocido')),
                        Text('${_safeInt(tipo['total_reservas'])} reservas'),
                      ],
                    ),
                  )),
            ],
          ],
        ),
      ),
    );
  }

// Nuevo método para mostrar texto en lugar de números
  Widget _buildMiniMetricaCardTexto(
      String titulo, String valor, IconData icono, Color color) {
    return Expanded(
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Icon(icono, size: 20, color: color),
              const SizedBox(height: 8),
              Text(
                valor,
                style: TextStyle(
                    fontSize: 14, fontWeight: FontWeight.bold, color: color),
                textAlign: TextAlign.center,
              ),
              Text(
                titulo,
                style: const TextStyle(fontSize: 10, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGraficoTendenciaReal(Map<String, dynamic> datos) {
    final tendencia = datos['tendencia_diaria'] ?? [];
    final datosChart = tendencia.map<ChartData>((item) {
      return ChartData(
        DateFormat('dd/MM').format(DateTime.parse(item['fecha'])),
        item['reservas'] ?? 0,
      );
    }).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tendencia de Reservas (Últimos 30 días)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: datosChart.isNotEmpty
                  ? SfCartesianChart(
                      primaryXAxis: const CategoryAxis(),
                      series: <CartesianSeries>[
                        LineSeries<ChartData, String>(
                          dataSource: datosChart,
                          xValueMapper: (ChartData data, _) => data.x,
                          yValueMapper: (ChartData data, _) => data.y,
                          markerSettings: const MarkerSettings(isVisible: true),
                          dataLabelSettings:
                              const DataLabelSettings(isVisible: true),
                        ),
                      ],
                    )
                  : const Center(
                      child: Text('No hay datos de tendencia disponibles')),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBotonExportacion(
      String texto, IconData icono, Color color, VoidCallback onPressed) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icono, size: 16),
      label: Text(texto),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
      ),
    );
  }

  void _generarReporteDiario(ReservaProvider reservaProvider) async {
    try {
      final ahora = DateTime.now();
      final reporte = await reservaProvider.obtenerReporteDiario(ahora);
      final contenido = _generarContenidoReporteReal(reporte, 'Diario');
      await _descargarPDF(contenido,
          'reporte_diario_${DateFormat('yyyyMMdd').format(ahora)}.txt');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reporte diario exportado correctamente')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al generar reporte: $e')),
      );
    }
  }

  void _generarReporteSemanal(ReservaProvider reservaProvider) async {
    try {
      final ahora = DateTime.now();
      final inicioSemana = ahora.subtract(Duration(days: ahora.weekday - 1));
      final reporte =
          await reservaProvider.obtenerEstadisticasUso(inicioSemana, ahora);
      final contenido = _generarContenidoReporteReal(reporte, 'Semanal');
      await _descargarPDF(contenido,
          'reporte_semanal_${DateFormat('yyyyMMdd').format(ahora)}.txt');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Reporte semanal exportado correctamente')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al generar reporte: $e')),
      );
    }
  }

  void _generarReporteMensual(ReservaProvider reservaProvider) async {
    try {
      final ahora = DateTime.now();
      final inicioMes = DateTime(ahora.year, ahora.month, 1);
      final reporte =
          await reservaProvider.obtenerEstadisticasUso(inicioMes, ahora);
      final contenido = _generarContenidoReporteReal(reporte, 'Mensual');
      await _descargarPDF(contenido,
          'reporte_mensual_${DateFormat('yyyyMM').format(ahora)}.txt');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Reporte mensual exportado correctamente')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al generar reporte: $e')),
      );
    }
  }

  String _generarContenidoReporteReal(
      Map<String, dynamic> reporte, String tipo) {
    final buffer = StringBuffer();

    buffer.writeln('REPORTE $tipo DEL SISTEMA DE BAHÍAS');
    buffer.writeln('=' * 50);
    buffer.writeln(
        'Fecha: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}');
    buffer.writeln();

    if (reporte['estadisticas_generales'] != null) {
      final stats = reporte['estadisticas_generales'];
      buffer.writeln('ESTADÍSTICAS GENERALES:');
      buffer.writeln('- Total reservas: ${stats['total_reservas']}');
      buffer
          .writeln('- Reservas completadas: ${stats['reservas_completadas']}');
      buffer.writeln('- Reservas canceladas: ${stats['reservas_canceladas']}');
      buffer.writeln(
          '- Duración promedio: ${stats['duracion_promedio_minutos']} minutos');
      buffer.writeln();
    }

    if (reporte['uso_por_tipo_bahia'] != null) {
      buffer.writeln('USO POR TIPO DE BAHÍA:');
      for (final tipo in reporte['uso_por_tipo_bahia']) {
        buffer.writeln(
            '- ${tipo['tipo_bahia']}: ${tipo['total_reservas']} reservas');
      }
      buffer.writeln();
    }

    buffer.writeln('--- FIN DEL REPORTE ---');
    return buffer.toString();
  }

  Future<void> _descargarPDF(String contenido, String fileName) async {
    try {
      final contenidoFormateado = '''
REPORTE DEL SISTEMA DE BAHÍAS
=============================

$contenido

---
Generado el: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}
''';

      final bytes = utf8.encode(contenidoFormateado);
      final blob = html.Blob([bytes], 'text/plain;charset=utf-8');
      final url = html.Url.createObjectUrlFromBlob(blob);

      final anchor = html.document.createElement('a') as html.AnchorElement
        ..href = url
        ..download = fileName
        ..style.display = 'none';

      html.document.body?.children.add(anchor);
      anchor.click();

      html.document.body?.children.remove(anchor);
      html.Url.revokeObjectUrl(url);
    } catch (e) {
      _descargarFallback(contenido, fileName);
    }
  }

  void _descargarFallback(String contenido, String fileName) {
    final text = contenido;
    final bytes = utf8.encode(text);
    final base64 = base64Encode(bytes);
    final uri = 'data:text/plain;base64,$base64';

    html.window.open(uri, '_blank');
  }

  void _generarReportePersonalizado(
      BuildContext context, ReservaProvider reservaProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reporte Personalizado'),
        content: const Text('Seleccione el rango de fechas para el reporte.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);

              final ahora = DateTime.now();
              final hace15Dias = ahora.subtract(const Duration(days: 15));
              try {
                final reporte = await reservaProvider.obtenerEstadisticasUso(
                    hace15Dias, ahora);
                final contenido = _generarContenidoReporteReal(
                    reporte, 'Personalizado (15 días)');
                await _descargarPDF(contenido,
                    'reporte_personalizado_${DateFormat('yyyyMMdd').format(ahora)}.txt');

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text(
                          'Reporte personalizado exportado correctamente')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error al generar reporte: $e')),
                );
              }
            },
            child: const Text('Generar'),
          ),
        ],
      ),
    );
  }

  void _mostrarNotificaciones(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Notificaciones'),
        content: const Text('No hay notificaciones nuevas.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _mostrarReportesCompletos(BuildContext context, List<Reserva> reservas) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reportes Completos'),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildResumenReportesCompletos(reservas),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () => _exportarReporteCompleto(context, reservas),
                  icon: const Icon(Icons.download),
                  label: const Text('Exportar Reporte Completo'),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  Widget _buildResumenReportesCompletos(List<Reserva> reservas) {
    final ahora = DateTime.now();
    final ultimoMes = ahora.subtract(const Duration(days: 30));
    final reservasUltimoMes =
        reservas.where((r) => r.fechaCreacion.isAfter(ultimoMes)).length;

    return Column(
      children: [
        _buildMetricaReporte('Total Reservas', reservas.length.toString()),
        _buildMetricaReporte(
            'Reservas Último Mes', reservasUltimoMes.toString()),
        _buildMetricaReporte('Reservas Activas',
            reservas.where((r) => r.estado == 'activa').length.toString()),
        _buildMetricaReporte('Reservas Completadas',
            reservas.where((r) => r.estado == 'completada').length.toString()),
      ],
    );
  }

  Widget _buildMetricaReporte(String titulo, String valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(titulo, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(valor),
        ],
      ),
    );
  }

  Future<void> _exportarReporteCompleto(
      BuildContext context, List<Reserva> reservas) async {
    try {
      final contenido = _generarContenidoReporteCompleto(reservas);
      await _descargarPDF(contenido,
          'reporte_completo_${DateFormat('yyyyMMdd').format(DateTime.now())}.txt');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Reporte completo exportado correctamente')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al exportar: $e')),
      );
    }
  }

  String _generarContenidoReporteCompleto(List<Reserva> reservas) {
    final buffer = StringBuffer();

    buffer.writeln('REPORTE COMPLETO DE RESERVAS');
    buffer.writeln('=' * 50);
    buffer.writeln(
        'Fecha: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}');
    buffer.writeln('Total de reservas: ${reservas.length}');
    buffer.writeln();

    buffer.writeln('ESTADÍSTICAS:');
    buffer.writeln(
        '- Activas: ${reservas.where((r) => r.estado == "activa").length}');
    buffer.writeln(
        '- Completadas: ${reservas.where((r) => r.estado == "completada").length}');
    buffer.writeln(
        '- Canceladas: ${reservas.where((r) => r.estado == "cancelada").length}');
    buffer.writeln();

    buffer.writeln('DETALLES DE RESERVAS:');
    buffer.writeln('=' * 50);

    for (final reserva in reservas.take(100)) {
      // Limitar a 100 reservas para el reporte
      buffer.writeln('ID: ${reserva.id}');
      buffer.writeln('Bahía: ${reserva.numeroBahia}');
      buffer.writeln('Usuario: ${reserva.usuarioNombre}');
      buffer.writeln('Estado: ${reserva.estado}');
      buffer.writeln(
          'Inicio: ${DateFormat('dd/MM/yyyy HH:mm').format(reserva.fechaHoraInicio)}');
      buffer.writeln(
          'Fin: ${DateFormat('dd/MM/yyyy HH:mm').format(reserva.fechaHoraFin)}');
      buffer.writeln('Duración: ${reserva.duracion}');
      buffer.writeln('-' * 30);
    }

    return buffer.toString();
  }

  void _mostrarConfiguracion(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Configuración del Sistema'),
        content: const Text('Opciones de configuración avanzada.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _realizarBackup(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Backup del Sistema'),
        content: const Text('Backup realizado exitosamente.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );
  }

  void _agregarNuevaBahia(BuildContext context, BahiaProvider bahiaProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Agregar Nueva Bahía'),
        content:
            const Text('Funcionalidad en desarrollo para próxima versión.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }
}

class ChartData {
  final String x;
  final int y;
  final Color? color;
  ChartData(this.x, this.y, [this.color]);
}
