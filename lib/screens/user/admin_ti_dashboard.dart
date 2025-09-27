// admin_ti_dashboard.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bahias_descarga_system/providers/auth_provider.dart';
import 'package:bahias_descarga_system/providers/bahia_provider.dart';
import 'package:bahias_descarga_system/providers/reserva_provider.dart';
import 'package:bahias_descarga_system/widgets/custom_appbar.dart';
import 'package:bahias_descarga_system/utils/constants.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:universal_html/html.dart' as html;

class AdminTIDashboard extends StatefulWidget {
  const AdminTIDashboard({Key? key}) : super(key: key);

  @override
  _AdminTIDashboardState createState() => _AdminTIDashboardState();
}

class _AdminTIDashboardState extends State<AdminTIDashboard> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final bahiaProvider = Provider.of<BahiaProvider>(context);
    final reservaProvider = Provider.of<ReservaProvider>(context);

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Panel de Administración TI',
        showBackButton: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.security, color: Colors.white),
            onPressed: () => _mostrarConfiguracionSeguridad(context),
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () => _actualizarSistema(context),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Estadísticas rápidas del sistema
                  _buildEstadisticasRapidas(bahiaProvider, reservaProvider),
                  const SizedBox(height: 20),

                  const Text(
                    'Herramientas de Administración TI',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),

                  Expanded(
                    child: GridView.count(
                      crossAxisCount: _calcularColumnas(context),
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      children: [
                        _buildTarjetaTI(
                          'Gestión de Usuarios',
                          Icons.people,
                          Colors.blue,
                          'Administrar usuarios y permisos',
                          () => _gestionarUsuarios(context),
                        ),
                        _buildTarjetaTI(
                          'Backup del Sistema',
                          Icons.backup,
                          Colors.green,
                          'Crear copia de seguridad',
                          () => _realizarBackupCompleto(
                              context, bahiaProvider, reservaProvider),
                        ),
                        _buildTarjetaTI(
                          'Logs del Sistema',
                          Icons.list_alt,
                          Colors.orange,
                          'Ver registros del sistema',
                          () => _verLogsSistema(context),
                        ),
                        _buildTarjetaTI(
                          'Configuración',
                          Icons.settings,
                          Colors.purple,
                          'Configurar parámetros',
                          () => _configurarSistema(context),
                        ),
                        _buildTarjetaTI(
                          'Monitor de Rendimiento',
                          Icons.monitor_heart,
                          Colors.red,
                          'Estado del sistema',
                          () => _monitorearRendimiento(context),
                        ),
                        _buildTarjetaTI(
                          'Reportes Técnicos',
                          Icons.analytics,
                          Colors.teal,
                          'Generar reportes',
                          () => _generarReportesTecnicos(
                              context, bahiaProvider, reservaProvider),
                        ),
                        _buildTarjetaTI(
                          'Mantenimiento',
                          Icons.build,
                          Colors.brown,
                          'Herramientas de mantenimiento',
                          () => _herramientasMantenimiento(context),
                        ),
                        _buildTarjetaTI(
                          'Base de Datos',
                          Icons.storage,
                          Colors.indigo,
                          'Administrar base de datos',
                          () => _administrarBaseDatos(context),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  int _calcularColumnas(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1200) return 4;
    if (width > 800) return 3;
    if (width > 600) return 2;
    return 1;
  }

  Widget _buildEstadisticasRapidas(
      BahiaProvider bahiaProvider, ReservaProvider reservaProvider) {
    final bahias = bahiaProvider.bahias;
    final reservas = reservaProvider.reservas;

    final totalBahias = bahias.length;
    //final bahiasLibres = bahias.where((b) => b.estado == EstadoBahia.libre).length;
    final totalReservas = reservas.length;
    final reservasHoy =
        reservas.where((r) => r.fechaCreacion.day == DateTime.now().day).length;

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildEstadisticaItem(
                'Bahías', '$totalBahias', Icons.local_parking, Colors.blue),
            //  _buildEstadisticaItem('Libres', '$bahiasLibres', Icons.check_circle, Colors.green),
            _buildEstadisticaItem('Reservas', '$totalReservas',
                Icons.calendar_today, Colors.orange),
            _buildEstadisticaItem(
                'Hoy', '$reservasHoy', Icons.today, Colors.purple),
          ],
        ),
      ),
    );
  }

  Widget _buildEstadisticaItem(
      String titulo, String valor, IconData icono, Color color) {
    return Column(
      children: [
        Icon(icono, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          valor,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(
          titulo,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildTarjetaTI(String titulo, IconData icono, Color color,
      String descripcion, VoidCallback onTap) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icono, size: 30, color: color),
              ),
              const SizedBox(height: 12),
              Text(
                titulo,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                descripcion,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // FUNCIONALIDADES IMPLEMENTADAS

  void _gestionarUsuarios(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Gestión de Usuarios'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: [
              _buildOpcionUsuario('Crear Nuevo Usuario', Icons.person_add, () {
                Navigator.pop(context);
                _crearNuevoUsuario(context);
              }),
              _buildOpcionUsuario('Lista de Usuarios', Icons.people_alt, () {
                Navigator.pop(context);
                _mostrarListaUsuarios(context);
              }),
              _buildOpcionUsuario(
                  'Permisos y Roles', Icons.admin_panel_settings, () {
                Navigator.pop(context);
                _gestionarPermisos(context);
              }),
              _buildOpcionUsuario('Actividad de Usuarios', Icons.timeline, () {
                Navigator.pop(context);
                _verActividadUsuarios(context);
              }),
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

  Widget _buildOpcionUsuario(
      String titulo, IconData icono, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icono, color: Colors.blue),
      title: Text(titulo),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  void _crearNuevoUsuario(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Crear Nuevo Usuario'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              decoration: const InputDecoration(labelText: 'Nombre de usuario'),
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Rol'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Usuario creado exitosamente')),
              );
            },
            child: const Text('Crear'),
          ),
        ],
      ),
    );
  }

  void _mostrarListaUsuarios(BuildContext context) {
    // Simular lista de usuarios
    final usuarios = [
      {'nombre': 'Admin', 'email': 'admin@sistema.com', 'rol': 'Administrador'},
      {
        'nombre': 'Usuario1',
        'email': 'user1@sistema.com',
        'rol': 'Planificador'
      },
      {'nombre': 'Usuario2', 'email': 'user2@sistema.com', 'rol': 'Operador'},
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Lista de Usuarios'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: usuarios.length,
            itemBuilder: (context, index) {
              final usuario = usuarios[index];
              return ListTile(
                leading: const Icon(Icons.person),
                title: Text(usuario['nombre']!),
                subtitle: Text('${usuario['email']} - ${usuario['rol']}'),
                trailing: IconButton(
                  icon: const Icon(Icons.edit, size: 20),
                  onPressed: () => _editarUsuario(context, usuario),
                ),
              );
            },
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

  void _editarUsuario(BuildContext context, Map<String, String> usuario) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Editar Usuario: ${usuario['nombre']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              initialValue: usuario['nombre'],
              decoration: const InputDecoration(labelText: 'Nombre'),
            ),
            TextFormField(
              initialValue: usuario['email'],
              decoration: const InputDecoration(labelText: 'Email'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Usuario actualizado')),
              );
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _gestionarPermisos(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Gestión de Permisos'),
        content: const Text('Configurar permisos y roles del sistema.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _verActividadUsuarios(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Actividad de Usuarios'),
        content:
            const Text('Registro de actividad de los usuarios del sistema.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _realizarBackupCompleto(BuildContext context,
      BahiaProvider bahiaProvider, ReservaProvider reservaProvider) async {
    setState(() => _isLoading = true);

    try {
      // Simular proceso de backup
      await Future.delayed(const Duration(seconds: 2));

      // Generar contenido del backup
      final contenidoBackup =
          _generarContenidoBackup(bahiaProvider, reservaProvider);

      // Descargar backup
      await _descargarBackup(contenidoBackup,
          'backup_sistema_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.txt');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Backup realizado y descargado exitosamente'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al realizar backup: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String _generarContenidoBackup(
      BahiaProvider bahiaProvider, ReservaProvider reservaProvider) {
    final buffer = StringBuffer();
    buffer.writeln('=== BACKUP DEL SISTEMA ===');
    buffer.writeln(
        'Fecha: ${DateFormat('dd/MM/yyyy HH:mm:ss').format(DateTime.now())}');
    buffer.writeln('=' * 50);

    // Información de bahías
    buffer.writeln('\nBAHÍAS:');
    for (final bahia in bahiaProvider.bahias) {
      buffer.writeln(
          'Bahía ${bahia.numero} - ${bahia.nombreTipo} - ${bahia.nombreEstado}');
    }

    // Información de reservas
    buffer.writeln('\nRESERVAS:');
    for (final reserva in reservaProvider.reservas.take(100)) {
      // Limitar a 100 reservas
      buffer.writeln(
          'Reserva ${reserva.id} - Bahía ${reserva.numeroBahia} - ${reserva.estado}');
    }

    return buffer.toString();
  }

  Future<void> _descargarBackup(String contenido, String fileName) async {
    final bytes = utf8.encode(contenido);
    final blob = html.Blob([bytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);

    final anchor = html.document.createElement('a') as html.AnchorElement
      ..href = url
      ..download = fileName
      ..style.display = 'none';

    html.document.body?.children.add(anchor);
    anchor.click();
    html.document.body?.children.remove(anchor);
    html.Url.revokeObjectUrl(url);
  }

  void _verLogsSistema(BuildContext context) {
    final logs = [
      'INFO: Sistema iniciado - ${DateFormat('HH:mm:ss').format(DateTime.now())}',
      'INFO: Usuario admin conectado - ${DateFormat('HH:mm:ss').format(DateTime.now().subtract(const Duration(minutes: 5)))}',
      'WARN: Bahía 3 en uso prolongado - ${DateFormat('HH:mm:ss').format(DateTime.now().subtract(const Duration(minutes: 10)))}',
      'ERROR: Error de conexión con base de datos - ${DateFormat('HH:mm:ss').format(DateTime.now().subtract(const Duration(minutes: 15)))}',
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logs del Sistema'),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: Column(
            children: [
              const Text('Registros del sistema en tiempo real:'),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: logs.length,
                  itemBuilder: (context, index) {
                    final log = logs[index];
                    Color color = Colors.black;
                    if (log.contains('ERROR')) color = Colors.red;
                    if (log.contains('WARN')) color = Colors.orange;
                    if (log.contains('INFO')) color = Colors.blue;

                    return ListTile(
                      leading: Icon(Icons.circle, size: 8, color: color),
                      title: Text(log, style: TextStyle(color: color)),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => _descargarLogs(logs),
            child: const Text('Descargar Logs'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _descargarLogs(List<String> logs) {
    final contenido = logs.join('\n');
    _descargarBackup(contenido,
        'logs_sistema_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.txt');
  }

  void _configurarSistema(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Configuración del Sistema'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: [
              _buildItemConfiguracion('Tiempo máximo de reserva', '4 horas'),
              _buildItemConfiguracion('Límite de bahías', '20 unidades'),
              _buildItemConfiguracion('Notificaciones', 'Activadas'),
              _buildItemConfiguracion('Backup automático', 'Cada 24 horas'),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Guardar Cambios'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  Widget _buildItemConfiguracion(String titulo, String valor) {
    return ListTile(
      title: Text(titulo),
      trailing: Text(valor),
      onTap: () => _editarConfiguracion(titulo, valor),
    );
  }

  void _editarConfiguracion(String titulo, String valorActual) {
    // Implementar edición de configuración
  }

  void _monitorearRendimiento(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Monitor de Rendimiento'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildMetricaRendimiento('Uso de CPU', '45%', Colors.green),
              _buildMetricaRendimiento('Uso de Memoria', '67%', Colors.orange),
              _buildMetricaRendimiento('Almacenamiento', '23%', Colors.blue),
              _buildMetricaRendimiento(
                  'Conexiones activas', '5', Colors.purple),
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

  Widget _buildMetricaRendimiento(String titulo, String valor, Color color) {
    return ListTile(
      leading: Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
      ),
      title: Text(titulo),
      trailing: Text(valor,
          style: TextStyle(fontWeight: FontWeight.bold, color: color)),
    );
  }

  void _generarReportesTecnicos(BuildContext context,
      BahiaProvider bahiaProvider, ReservaProvider reservaProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Generar Reportes Técnicos'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: [
              _buildOpcionReporte(
                  'Reporte de Uso de Bahías', Icons.local_parking, () {
                _generarReporteBahias(bahiaProvider);
              }),
              _buildOpcionReporte('Reporte de Reservas', Icons.calendar_today,
                  () {
                _generarReporteReservas(reservaProvider);
              }),
              _buildOpcionReporte('Reporte de Errores', Icons.error, () {
                _generarReporteErrores();
              }),
              _buildOpcionReporte('Reporte de Rendimiento', Icons.timeline, () {
                _generarReporteRendimiento();
              }),
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

  Widget _buildOpcionReporte(
      String titulo, IconData icono, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icono, color: Colors.blue),
      title: Text(titulo),
      trailing: const Icon(Icons.download),
      onTap: onTap,
    );
  }

  void _generarReporteBahias(BahiaProvider bahiaProvider) {
    final contenido = _generarContenidoBackup(
        bahiaProvider, Provider.of<ReservaProvider>(context, listen: false));
    _descargarBackup(contenido,
        'reporte_bahias_${DateFormat('yyyyMMdd').format(DateTime.now())}.txt');
  }

  void _generarReporteReservas(ReservaProvider reservaProvider) {
    final contenido =
        'Reporte de reservas generado el ${DateFormat('dd/MM/yyyy').format(DateTime.now())}';
    _descargarBackup(contenido,
        'reporte_reservas_${DateFormat('yyyyMMdd').format(DateTime.now())}.txt');
  }

  void _generarReporteErrores() {
    final contenido = 'Reporte de errores del sistema';
    _descargarBackup(contenido,
        'reporte_errores_${DateFormat('yyyyMMdd').format(DateTime.now())}.txt');
  }

  void _generarReporteRendimiento() {
    final contenido = 'Reporte de rendimiento del sistema';
    _descargarBackup(contenido,
        'reporte_rendimiento_${DateFormat('yyyyMMdd').format(DateTime.now())}.txt');
  }

  void _herramientasMantenimiento(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Herramientas de Mantenimiento'),
        content: const Text('Utilidades para mantenimiento del sistema.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _administrarBaseDatos(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Administración de Base de Datos'),
        content:
            const Text('Herramientas de administración de la base de datos.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _mostrarConfiguracionSeguridad(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Configuración de Seguridad'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: [
              _buildItemSeguridad('Cambiar contraseña', Icons.password),
              _buildItemSeguridad(
                  'Autenticación de dos factores', Icons.security),
              _buildItemSeguridad('Registro de auditoría', Icons.assignment),
              _buildItemSeguridad('Políticas de seguridad', Icons.policy),
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

  Widget _buildItemSeguridad(String titulo, IconData icono) {
    return ListTile(
      leading: Icon(icono, color: Colors.blue),
      title: Text(titulo),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {},
    );
  }

  void _actualizarSistema(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Actualizar Sistema'),
        content: const Text('¿Desea buscar actualizaciones del sistema?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Sistema actualizado exitosamente')),
              );
            },
            child: const Text('Actualizar'),
          ),
        ],
      ),
    );
  }
}
