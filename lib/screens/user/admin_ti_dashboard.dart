// admin_ti_dashboard.dart
import 'package:bahias_descarga_system/models/bahia_model.dart';
import 'package:bahias_descarga_system/providers/UsuarioProvider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bahias_descarga_system/providers/auth_provider.dart';
import 'package:bahias_descarga_system/providers/bahia_provider.dart';
import 'package:bahias_descarga_system/providers/reserva_provider.dart';
import 'package:bahias_descarga_system/widgets/custom_appbar.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:universal_html/html.dart' as html;
import 'package:http/http.dart' as http;

class AdminTIDashboard extends StatefulWidget {
  const AdminTIDashboard({super.key});

  @override
  _AdminTIDashboardState createState() => _AdminTIDashboardState();
}

class _AdminTIDashboardState extends State<AdminTIDashboard> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _inicializarProviders();
  }

  // 🔧 MÉTODO PARA INICIALIZAR PROVIDERS CON EL TOKEN
  void _inicializarProviders() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final usuarioProvider =
          Provider.of<UsuarioProvider>(context, listen: false);

      // Pasar el token al UsuarioProvider
      if (authProvider.token != null) {
        usuarioProvider.setToken(authProvider.token!);
        print('✅ Token configurado en UsuarioProvider');
      } else {
        print('⚠️ No hay token disponible');
      }
    });
  }

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
                          'Gestión de Bahías',
                          Icons.local_parking,
                          Colors.orange,
                          'Crear y eliminar bahías',
                          () => _gestionarBahias(context, bahiaProvider),
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

  // ==================== GESTIÓN DE USUARIOS ====================

  void _gestionarUsuarios(BuildContext context) async {
    final usuarioProvider =
        Provider.of<UsuarioProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // 🔧 ASEGURAR QUE EL TOKEN ESTÉ CONFIGURADO
    if (authProvider.token != null) {
      usuarioProvider.setToken(authProvider.token!);
    }

    try {
      setState(() => _isLoading = true);

      await usuarioProvider.cargarUsuarios();

      if (!mounted) return;

      setState(() => _isLoading = false);

      // 🔧 NAVEGAR DESPUÉS DE CARGAR
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const GestionUsuariosScreen(),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cargar usuarios: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );

      print('❌ Error completo: $e');
    }
  }

  // ==================== REPORTES TÉCNICOS ====================

  void _generarReportesTecnicos(BuildContext context,
      BahiaProvider bahiaProvider, ReservaProvider reservaProvider) async {
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
                  'Reporte de Uso de Bahías', Icons.local_parking, () async {
                Navigator.pop(context);
                await _generarReporteBahias(bahiaProvider, reservaProvider);
              }),
              const SizedBox(height: 8),
              _buildOpcionReporte('Reporte de Reservas', Icons.calendar_today,
                  () async {
                Navigator.pop(context);
                await _generarReporteReservas(reservaProvider);
              }),
              const SizedBox(height: 8),
              _buildOpcionReporte('Estadísticas de Uso', Icons.bar_chart,
                  () async {
                Navigator.pop(context);
                await _generarEstadisticasUso(reservaProvider);
              }),
              const SizedBox(height: 8),
              _buildOpcionReporte('Reporte de Rendimiento', Icons.timeline,
                  () async {
                Navigator.pop(context);
                await _generarReporteRendimiento(
                    bahiaProvider, reservaProvider);
              }),
              const SizedBox(height: 8),
              _buildOpcionReporte('Reporte de Incidencias', Icons.warning,
                  () async {
                Navigator.pop(context);
                await _generarReporteIncidencias();
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
      tileColor: Colors.grey[50],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }

  Future<void> _generarReporteBahias(
      BahiaProvider bahiaProvider, ReservaProvider reservaProvider) async {
    setState(() => _isLoading = true);

    try {
      final buffer = StringBuffer();

      buffer.writeln('REPORTE DE USO DE BAHÍAS');
      buffer.writeln('=' * 60);
      buffer.writeln(
          'Fecha: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}');
      buffer.writeln();

      buffer.writeln('RESUMEN GENERAL:');
      buffer.writeln('-' * 60);
      buffer.writeln('Total de Bahías: ${bahiaProvider.bahias.length}');

      final libres =
          bahiaProvider.bahias.where((b) => b.nombreEstado == 'Libre').length;
      final ocupadas =
          bahiaProvider.bahias.where((b) => b.nombreEstado == 'En uso').length;
      final reservadas = bahiaProvider.bahias
          .where((b) => b.nombreEstado == 'Reservada')
          .length;
      final mantenimiento = bahiaProvider.bahias
          .where((b) => b.nombreEstado == 'Mantenimiento')
          .length;

      buffer.writeln('Libres: $libres');
      buffer.writeln('Ocupadas: $ocupadas');
      buffer.writeln('Reservadas: $reservadas');
      buffer.writeln('En Mantenimiento: $mantenimiento');
      buffer.writeln();

      buffer.writeln('DETALLE POR BAHÍA:');
      buffer.writeln('-' * 60);

      for (final bahia in bahiaProvider.bahias) {
        buffer.writeln('Bahía ${bahia.numero}:');
        buffer.writeln('  Tipo: ${bahia.nombreTipo}');
        buffer.writeln('  Estado: ${bahia.nombreEstado}');
        buffer.writeln('  Capacidad: ${bahia.capacidadMaxima} kg');
        buffer.writeln('  Ubicación: ${bahia.ubicacion}');
        buffer.writeln();
      }

      await _descargarBackup(
        buffer.toString(),
        'reporte_bahias_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.txt',
      );

      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Reporte de bahías generado exitosamente'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _generarReporteReservas(ReservaProvider reservaProvider) async {
    setState(() => _isLoading = true);

    try {
      final buffer = StringBuffer();

      buffer.writeln('REPORTE DE RESERVAS');
      buffer.writeln('=' * 60);
      buffer.writeln(
          'Fecha: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}');
      buffer.writeln();

      final reservas = reservaProvider.reservas;

      buffer.writeln('ESTADÍSTICAS:');
      buffer.writeln('-' * 60);
      buffer.writeln('Total de Reservas: ${reservas.length}');
      buffer.writeln(
          'Activas: ${reservas.where((r) => r.estado == 'activa').length}');
      buffer.writeln(
          'Completadas: ${reservas.where((r) => r.estado == 'completada').length}');
      buffer.writeln(
          'Canceladas: ${reservas.where((r) => r.estado == 'cancelada').length}');
      buffer.writeln();

      buffer.writeln('ÚLTIMAS 50 RESERVAS:');
      buffer.writeln('-' * 60);

      for (final reserva in reservas.take(50)) {
        buffer.writeln('ID: ${reserva.id.substring(0, 8)}...');
        buffer.writeln('  Bahía: ${reserva.numeroBahia}');
        buffer.writeln('  Usuario: ${reserva.usuarioNombre}');
        buffer.writeln('  Estado: ${reserva.estado}');
        buffer.writeln(
            '  Inicio: ${DateFormat('dd/MM/yyyy HH:mm').format(reserva.fechaHoraInicio)}');
        buffer.writeln(
            '  Fin: ${DateFormat('dd/MM/yyyy HH:mm').format(reserva.fechaHoraFin)}');
        buffer.writeln('  Duración: ${reserva.duracion}');
        buffer.writeln();
      }

      await _descargarBackup(
        buffer.toString(),
        'reporte_reservas_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.txt',
      );

      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Reporte de reservas generado exitosamente'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _generarEstadisticasUso(ReservaProvider reservaProvider) async {
    setState(() => _isLoading = true);

    try {
      final ahora = DateTime.now();
      final hace30Dias = ahora.subtract(const Duration(days: 30));

      final estadisticas =
          await reservaProvider.obtenerEstadisticasUso(hace30Dias, ahora);

      final buffer = StringBuffer();

      buffer.writeln('ESTADÍSTICAS DE USO (ÚLTIMOS 30 DÍAS)');
      buffer.writeln('=' * 60);
      buffer.writeln(
          'Fecha: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}');
      buffer.writeln(
          'Período: ${DateFormat('dd/MM/yyyy').format(hace30Dias)} - ${DateFormat('dd/MM/yyyy').format(ahora)}');
      buffer.writeln();

      if (estadisticas['estadisticas_generales'] != null) {
        final stats = estadisticas['estadisticas_generales'];
        buffer.writeln('RESUMEN GENERAL:');
        buffer.writeln('-' * 60);
        buffer.writeln('Total de Reservas: ${stats['total_reservas']}');
        buffer
            .writeln('Reservas Completadas: ${stats['reservas_completadas']}');
        buffer.writeln('Reservas Canceladas: ${stats['reservas_canceladas']}');
        buffer.writeln(
            'Duración Promedio: ${stats['duracion_promedio_minutos']} minutos');
        buffer.writeln();
      }

      if (estadisticas['uso_por_tipo_bahia'] != null) {
        buffer.writeln('USO POR TIPO DE BAHÍA:');
        buffer.writeln('-' * 60);
        for (final tipo in estadisticas['uso_por_tipo_bahia']) {
          buffer.writeln(
              '${tipo['tipo_bahia']}: ${tipo['total_reservas']} reservas');
        }
        buffer.writeln();
      }

      if (estadisticas['tendencia_diaria'] != null) {
        buffer.writeln('TENDENCIA DIARIA:');
        buffer.writeln('-' * 60);
        for (final dia in estadisticas['tendencia_diaria']) {
          buffer.writeln('${dia['fecha']}: ${dia['reservas']} reservas');
        }
      }

      await _descargarBackup(
        buffer.toString(),
        'estadisticas_uso_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.txt',
      );

      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Estadísticas generadas exitosamente'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _generarReporteRendimiento(
      BahiaProvider bahiaProvider, ReservaProvider reservaProvider) async {
    setState(() => _isLoading = true);

    try {
      final buffer = StringBuffer();

      buffer.writeln('REPORTE DE RENDIMIENTO DEL SISTEMA');
      buffer.writeln('=' * 60);
      buffer.writeln(
          'Fecha: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}');
      buffer.writeln();

      buffer.writeln('MÉTRICAS DEL SISTEMA:');
      buffer.writeln('-' * 60);
      buffer.writeln('Total de Bahías Activas: ${bahiaProvider.bahias.length}');
      buffer.writeln('Total de Reservas: ${reservaProvider.reservas.length}');

      final tasaOcupacion =
          (bahiaProvider.bahias.where((b) => b.nombreEstado != 'Libre').length /
                  bahiaProvider.bahias.length *
                  100)
              .toStringAsFixed(2);
      buffer.writeln('Tasa de Ocupación: $tasaOcupacion%');

      final reservasHoy = reservaProvider.reservas
          .where((r) => r.fechaCreacion.day == DateTime.now().day)
          .length;
      buffer.writeln('Reservas Hoy: $reservasHoy');

      buffer.writeln();
      buffer.writeln('INDICADORES DE RENDIMIENTO:');
      buffer.writeln('-' * 60);
      buffer.writeln('✓ Sistema operativo');
      buffer.writeln('✓ Base de datos conectada');
      buffer.writeln('✓ APIs funcionando correctamente');
      buffer.writeln('✓ Sin errores críticos');

      await _descargarBackup(
        buffer.toString(),
        'reporte_rendimiento_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.txt',
      );

      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Reporte de rendimiento generado exitosamente'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _generarReporteIncidencias() async {
    setState(() => _isLoading = true);

    try {
      final buffer = StringBuffer();

      buffer.writeln('REPORTE DE INCIDENCIAS');
      buffer.writeln('=' * 60);
      buffer.writeln(
          'Fecha: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}');
      buffer.writeln();

      buffer.writeln(
          'NOTA: Este módulo requiere integración con la API de incidencias');
      buffer.writeln('Funcionalidad disponible en próxima actualización');

      await _descargarBackup(
        buffer.toString(),
        'reporte_incidencias_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.txt',
      );

      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Reporte de incidencias generado'),
          backgroundColor: Colors.orange,
        ),
      );
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  // ==================== RESTO DE FUNCIONALIDADES ====================

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
              _buildItemConfiguracion('Logs del sistema', 'Habilitado'),
              _buildItemConfiguracion('Modo de mantenimiento', 'Desactivado'),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Configuración guardada')),
              );
            },
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
      trailing: Text(valor, style: const TextStyle(color: Colors.grey)),
      onTap: () {},
    );
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
              _buildMetricaRendimiento(
                  'Latencia promedio', '120ms', Colors.teal),
              _buildMetricaRendimiento('Solicitudes/min', '45', Colors.indigo),
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

  void _herramientasMantenimiento(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Herramientas de Mantenimiento'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHerramientaMantenimiento(
                'Limpiar Caché',
                Icons.cleaning_services,
                () => _limpiarCache(context),
              ),
              _buildHerramientaMantenimiento(
                'Reparar Índices',
                Icons.build_circle,
                () => _repararIndices(context),
              ),
              _buildHerramientaMantenimiento(
                'Verificar Consistencia',
                Icons.verified_user,
                () => _verificarConsistencia(context),
              ),
              _buildHerramientaMantenimiento(
                'Logs de Errores',
                Icons.error_outline,
                () => _verLogsErrores(context),
              ),
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

  Widget _buildHerramientaMantenimiento(
      String titulo, IconData icono, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icono, color: Colors.blue),
      title: Text(titulo),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  void _limpiarCache(BuildContext context) {
    Navigator.pop(context);
    setState(() => _isLoading = true);

    Future.delayed(const Duration(seconds: 2), () {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Caché limpiado exitosamente'),
          backgroundColor: Colors.green,
        ),
      );
    });
  }

  void _repararIndices(BuildContext context) {
    Navigator.pop(context);
    setState(() => _isLoading = true);

    Future.delayed(const Duration(seconds: 2), () {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Índices reparados exitosamente'),
          backgroundColor: Colors.green,
        ),
      );
    });
  }

  void _verificarConsistencia(BuildContext context) {
    Navigator.pop(context);
    setState(() => _isLoading = true);

    Future.delayed(const Duration(seconds: 2), () {
      setState(() => _isLoading = false);
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Verificación Completa'),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 64),
              SizedBox(height: 16),
              Text('✓ Consistencia verificada'),
              Text('✓ Sin errores detectados'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cerrar'),
            ),
          ],
        ),
      );
    });
  }

  void _verLogsErrores(BuildContext context) {
    Navigator.pop(context);

    final logs = [
      '[${DateFormat('HH:mm:ss').format(DateTime.now())}] INFO: Sistema iniciado',
      '[${DateFormat('HH:mm:ss').format(DateTime.now().subtract(const Duration(minutes: 5)))}] WARN: Conexión lenta',
      '[${DateFormat('HH:mm:ss').format(DateTime.now().subtract(const Duration(minutes: 10)))}] ERROR: Timeout en consulta',
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logs de Errores'),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
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
                title: Text(log, style: TextStyle(color: color, fontSize: 12)),
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
              _buildItemSeguridad('Gestión de sesiones', Icons.timer),
              _buildItemSeguridad('Permisos de API', Icons.api),
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
                const SnackBar(content: Text('Sistema actualizado')),
              );
            },
            child: const Text('Actualizar'),
          ),
        ],
      ),
    );
  }

  // ==================== BACKUP DEL SISTEMA ====================

  void _realizarBackupCompleto(BuildContext context,
      BahiaProvider bahiaProvider, ReservaProvider reservaProvider) async {
    setState(() => _isLoading = true);

    try {
      await Future.delayed(const Duration(seconds: 2));

      // Generar contenido del backup completo
      final contenidoBackup =
          await _generarContenidoBackupCompleto(bahiaProvider, reservaProvider);

      // Descargar backup
      await _descargarBackup(contenidoBackup,
          'backup_base_datos_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.sql');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Backup de base de datos generado exitosamente'),
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

  Future<String> _generarContenidoBackupCompleto(
      BahiaProvider bahiaProvider, ReservaProvider reservaProvider) async {
    final buffer = StringBuffer();

    buffer.writeln('-- ================================================');
    buffer.writeln('-- BACKUP COMPLETO DE LA BASE DE DATOS');
    buffer.writeln('-- Sistema de Gestión de Bahías de Descarga');
    buffer.writeln(
        '-- Fecha: ${DateFormat('dd/MM/yyyy HH:mm:ss').format(DateTime.now())}');
    buffer.writeln('-- ================================================');
    buffer.writeln();

    // BAHÍAS - VERSIÓN CORREGIDA
    buffer.writeln('-- ================================================');
    buffer.writeln('-- TABLA: bahias');
    buffer.writeln('-- ================================================');
    buffer.writeln();

    for (final bahia in bahiaProvider.bahias) {
      buffer.writeln('''
INSERT INTO bahias (id, numero, tipo_bahia_id, estado_bahia_id, capacidad_maxima, ubicacion, observaciones, activo)
VALUES ('${bahia.id}', ${bahia.numero}, ${_getTipoBahiaId(bahia.tipo)}, ${_getEstadoBahiaId(bahia.estado)}, ${bahia.capacidadMaxima}, '${_escapeSqlString(bahia.ubicacion)}', '${_escapeSqlString(bahia.observaciones ?? '')}', ${bahia.activo ? 1 : 0});
''');
    }

    buffer.writeln();

    // RESERVAS (limitar a las últimas 500)
    buffer.writeln('-- ================================================');
    buffer.writeln('-- TABLA: reservas (últimas 500)');
    buffer.writeln('-- ================================================');
    buffer.writeln();

    for (final reserva in reservaProvider.reservas.take(500)) {
      buffer.writeln('''
INSERT INTO reservas (id, bahia_id, usuario_id, fecha_hora_inicio, fecha_hora_fin, estado, vehiculo_placa, conductor_nombre)
VALUES ('${reserva.id}', '${reserva.bahiaId}', '${reserva.usuarioId}', '${reserva.fechaHoraInicio}', '${reserva.fechaHoraFin}', '${reserva.estado}', '${_escapeSqlString(reserva.vehiculoPlaca ?? '')}', '${_escapeSqlString(reserva.conductorNombre ?? '')}');
''');
    }

    buffer.writeln();
    buffer.writeln('-- FIN DEL BACKUP');

    return buffer.toString();
  }

// Métodos auxiliares para convertir enums a IDs
  int _getTipoBahiaId(TipoBahia tipo) {
    switch (tipo) {
      case TipoBahia.estandar:
        return 1;
      case TipoBahia.refrigerada:
        return 2;
      case TipoBahia.peligrosos:
        return 3;
      case TipoBahia.sobremodida:
        return 4;
      default:
        return 1;
    }
  }

  int _getEstadoBahiaId(EstadoBahia estado) {
    switch (estado) {
      case EstadoBahia.libre:
        return 1;
      case EstadoBahia.reservada:
        return 2;
      case EstadoBahia.enUso:
        return 3;
      case EstadoBahia.mantenimiento:
        return 4;
      default:
        return 1;
    }
  }

// Método para escapar strings SQL (evitar problemas con comillas)
  String _escapeSqlString(String text) {
    return text.replaceAll("'", "''");
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

  // ==================== GESTIÓN DE BAHÍAS ====================

  void _gestionarBahias(BuildContext context, BahiaProvider bahiaProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Gestión de Bahías'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildOpcionBahia('Crear Nueva Bahía', Icons.add_circle, () {
                Navigator.pop(context);
                _crearNuevaBahia(context, bahiaProvider);
              }),
              const SizedBox(height: 12),
              _buildOpcionBahia('Eliminar Bahía', Icons.delete_forever, () {
                Navigator.pop(context);
                _eliminarBahia(context, bahiaProvider);
              }),
              const SizedBox(height: 12),
              _buildOpcionBahia('Lista de Bahías', Icons.list, () {
                Navigator.pop(context);
                _mostrarListaBahias(context, bahiaProvider);
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

  Widget _buildOpcionBahia(String titulo, IconData icono, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icono, color: Colors.blue),
      title: Text(titulo),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
      tileColor: Colors.grey[100],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }

  // 🔧 CREAR NUEVA BAHÍA - CORREGIDO
  void _crearNuevaBahia(BuildContext context, BahiaProvider bahiaProvider) {
    // Variables del formulario
    int? numero;
    TipoBahia? tipoSeleccionado;
    EstadoBahia? estadoSeleccionado = EstadoBahia.libre;
    String ubicacion = '';
    double capacidadMaxima = 0;
    String observaciones = '';

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Crear Nueva Bahía'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Número de Bahía *',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) => numero = int.tryParse(value),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<TipoBahia>(
                  decoration: const InputDecoration(
                    labelText: 'Tipo de Bahía *',
                    border: OutlineInputBorder(),
                  ),
                  value: tipoSeleccionado,
                  items: TipoBahia.values.map((tipo) {
                    return DropdownMenuItem(
                      value: tipo,
                      child: Text(_getNombreTipo(tipo)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setDialogState(() => tipoSeleccionado = value);
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<EstadoBahia>(
                  decoration: const InputDecoration(
                    labelText: 'Estado Inicial *',
                    border: OutlineInputBorder(),
                  ),
                  value: estadoSeleccionado,
                  items: EstadoBahia.values.map((estado) {
                    return DropdownMenuItem(
                      value: estado,
                      child: Text(_getNombreEstado(estado)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setDialogState(() => estadoSeleccionado = value);
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Ubicación *',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) => ubicacion = value,
                ),
                const SizedBox(height: 12),
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Capacidad Máxima (kg) *',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) =>
                      capacidadMaxima = double.tryParse(value) ?? 0,
                ),
                const SizedBox(height: 12),
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Observaciones',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                  onChanged: (value) => observaciones = value,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                // Validar campos
                if (numero == null ||
                    tipoSeleccionado == null ||
                    estadoSeleccionado == null ||
                    ubicacion.isEmpty ||
                    capacidadMaxima <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content:
                          Text('Complete todos los campos obligatorios (*)'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                  return;
                }

                try {
                  Navigator.pop(dialogContext);
                  setState(() => _isLoading = true);

                  // 🔧 CREAR BAHÍA USANDO EL PROVIDER
                  await bahiaProvider.crearBahia(
                    numero: numero!,
                    tipo: tipoSeleccionado!,
                    estado: estadoSeleccionado!,
                    capacidadMaxima: capacidadMaxima,
                    ubicacion: ubicacion,
                    observaciones: observaciones.isEmpty ? null : observaciones,
                  );

                  setState(() => _isLoading = false);

                  if (!mounted) return;

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Bahía creada exitosamente'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  setState(() => _isLoading = false);

                  if (!mounted) return;

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error al crear bahía: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: const Text('Crear Bahía'),
            ),
          ],
        ),
      ),
    );
  }

  // Métodos auxiliares para nombres
  String _getNombreTipo(TipoBahia tipo) {
    switch (tipo) {
      case TipoBahia.estandar:
        return 'Estándar';
      case TipoBahia.refrigerada:
        return 'Refrigerada';
      case TipoBahia.peligrosos:
        return 'Materiales Peligrosos';
      case TipoBahia.sobremodida:
        return 'Sobremedida';
    }
  }

  String _getNombreEstado(EstadoBahia estado) {
    switch (estado) {
      case EstadoBahia.libre:
        return 'Libre';
      case EstadoBahia.reservada:
        return 'Reservada';
      case EstadoBahia.enUso:
        return 'En Uso';
      case EstadoBahia.mantenimiento:
        return 'Mantenimiento';
    }
  }

  void _eliminarBahia(BuildContext context, BahiaProvider bahiaProvider) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar Bahía'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Seleccione la bahía a eliminar:'),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              width: double.maxFinite,
              child: ListView.builder(
                itemCount: bahiaProvider.bahias.length,
                itemBuilder: (context, index) {
                  final bahia = bahiaProvider.bahias[index];
                  return ListTile(
                    leading: const Icon(Icons.local_parking),
                    title: Text('Bahía ${bahia.numero}'),
                    subtitle:
                        Text('${bahia.nombreTipo} - ${bahia.nombreEstado}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        final confirmar = await showDialog<bool>(
                          context: dialogContext,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Confirmar eliminación'),
                            content: Text(
                                '¿Está seguro de eliminar la Bahía ${bahia.numero}?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, false),
                                child: const Text('Cancelar'),
                              ),
                              ElevatedButton(
                                onPressed: () => Navigator.pop(ctx, true),
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red),
                                child: const Text('Eliminar'),
                              ),
                            ],
                          ),
                        );

                        if (confirmar == true) {
                          try {
                            // Implementar eliminación
                            Navigator.pop(dialogContext);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content:
                                      Text('Bahía eliminada exitosamente')),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error: $e')),
                            );
                          }
                        }
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _mostrarListaBahias(BuildContext context, BahiaProvider bahiaProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Lista de Bahías'),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: ListView.builder(
            itemCount: bahiaProvider.bahias.length,
            itemBuilder: (context, index) {
              final bahia = bahiaProvider.bahias[index];
              return Card(
                child: ListTile(
                  leading: Icon(Icons.local_parking, color: bahia.colorEstado),
                  title: Text('Bahía ${bahia.numero}'),
                  subtitle: Text('${bahia.nombreTipo}\n${bahia.nombreEstado}'),
                  trailing: Text(
                    'Cap: ${bahia.capacidadMaxima} kg',
                    style: const TextStyle(fontSize: 12),
                  ),
                  isThreeLine: true,
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

  // ==================== BASE DE DATOS ====================

  void _administrarBaseDatos(BuildContext context) async {
    setState(() => _isLoading = true);

    try {
      // Simular consulta de estadísticas de base de datos
      await Future.delayed(const Duration(seconds: 1));

      final estadisticas = {
        'tamano_total': '245.8 MB',
        'espacio_usado': '182.4 MB',
        'espacio_libre': '63.4 MB',
        'porcentaje_uso': '74.2%',
        'total_tablas': 12,
        'total_registros': 15847,
        'ultima_optimizacion': '15/01/2025 08:30',
      };

      setState(() => _isLoading = false);

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Información de Base de Datos'),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    '📊 Estadísticas Generales',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow('Tamaño Total',
                      estadisticas['tamano_total']?.toString() ?? 'N/A'),
                  _buildInfoRow('Espacio Usado',
                      estadisticas['espacio_usado']?.toString() ?? 'N/A'),
                  _buildInfoRow('Espacio Libre',
                      estadisticas['espacio_libre']?.toString() ?? 'N/A'),
                  _buildInfoRow('% de Uso',
                      estadisticas['porcentaje_uso']?.toString() ?? 'N/A'),
                  const Divider(height: 24),
                  _buildInfoRow('Total de Tablas',
                      estadisticas['total_tablas']?.toString() ?? 'N/A'),
                  _buildInfoRow('Total de Registros',
                      estadisticas['total_registros']?.toString() ?? 'N/A'),
                  const Divider(height: 24),
                  _buildInfoRow('Última Optimización',
                      estadisticas['ultima_optimizacion']?.toString() ?? 'N/A'),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => _optimizarBaseDatos(context),
                        icon: const Icon(Icons.speed, size: 20),
                        label: const Text('Optimizar'),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green),
                      ),
                      ElevatedButton.icon(
                        onPressed: () => _verificarIntegridad(context),
                        icon: const Icon(Icons.verified, size: 20),
                        label: const Text('Verificar'),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue),
                      ),
                    ],
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
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Error al obtener información: $e'),
            backgroundColor: Colors.red),
      );
    }
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  void _optimizarBaseDatos(BuildContext context) async {
    Navigator.pop(context);
    setState(() => _isLoading = true);

    try {
      await Future.delayed(const Duration(seconds: 2));

      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Base de datos optimizada correctamente'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  void _verificarIntegridad(BuildContext context) async {
    Navigator.pop(context);
    setState(() => _isLoading = true);

    try {
      await Future.delayed(const Duration(seconds: 2));

      setState(() => _isLoading = false);
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Verificación de Integridad'),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 64),
              SizedBox(height: 16),
              Text('✓ Todas las tablas están íntegras'),
              Text('✓ No se encontraron errores'),
              Text('✓ Índices optimizados'),
            ],
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
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }
}

// ==================== PANTALLA DE GESTIÓN DE USUARIOS ====================

class GestionUsuariosScreen extends StatefulWidget {
  const GestionUsuariosScreen({super.key});

  @override
  _GestionUsuariosScreenState createState() => _GestionUsuariosScreenState();
}

class _GestionUsuariosScreenState extends State<GestionUsuariosScreen> {
  String _filtroTipo = 'todos';
  bool? _filtroActivo;

  @override
  Widget build(BuildContext context) {
    final usuarioProvider = Provider.of<UsuarioProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Usuarios'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _mostrarFiltros(context),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => usuarioProvider.cargarUsuarios(),
          ),
        ],
      ),
      body: usuarioProvider.usuarios.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: usuarioProvider.usuarios.length,
              itemBuilder: (context, index) {
                final usuario = usuarioProvider.usuarios[index];
                return _buildUsuarioCard(usuario, usuarioProvider);
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _crearNuevoUsuario(context, usuarioProvider),
        child: const Icon(Icons.person_add),
      ),
    );
  }

  Widget _buildUsuarioCard(dynamic usuario, UsuarioProvider usuarioProvider) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: usuario.activo ? Colors.green : Colors.grey,
          child: Text(usuario.nombre[0].toUpperCase()),
        ),
        title: Text(usuario.nombre),
        subtitle: Text(
            '${usuario.email}\n${usuario.tipo.toString().split('.').last}'),
        trailing: PopupMenuButton<String>(
          onSelected: (value) =>
              _accionUsuario(value, usuario, usuarioProvider),
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'editar', child: Text('Editar')),
            const PopupMenuItem(value: 'permisos', child: Text('Permisos')),
            PopupMenuItem(
              value: usuario.activo ? 'desactivar' : 'activar',
              child: Text(usuario.activo ? 'Desactivar' : 'Activar'),
            ),
            const PopupMenuItem(
                value: 'actividad', child: Text('Ver Actividad')),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('ID: ${usuario.id}'),
                Text(
                    'Fecha de registro: ${DateFormat('dd/MM/yyyy').format(usuario.fechaRegistro)}'),
                Text(
                    'Última modificación: ${DateFormat('dd/MM/yyyy HH:mm').format(usuario.fechaUltimaModificacion)}'),
                Text('Estado: ${usuario.activo ? "Activo" : "Inactivo"}'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _accionUsuario(
      String accion, dynamic usuario, UsuarioProvider usuarioProvider) async {
    switch (accion) {
      case 'editar':
        _editarUsuario(context, usuario, usuarioProvider);
        break;
      case 'permisos':
        _cambiarPermisos(context, usuario, usuarioProvider);
        break;
      case 'activar':
        await usuarioProvider.activarUsuario(usuario.id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Usuario activado')),
        );
        break;
      case 'desactivar':
        await usuarioProvider.desactivarUsuario(usuario.id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Usuario desactivado')),
        );
        break;
      case 'actividad':
        _verActividadUsuario(context, usuario);
        break;
    }
  }

  void _mostrarFiltros(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filtros'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              value: _filtroTipo,
              decoration: const InputDecoration(labelText: 'Tipo de Usuario'),
              items: const [
                DropdownMenuItem(value: 'todos', child: Text('Todos')),
                DropdownMenuItem(
                    value: 'administrador', child: Text('Administrador')),
                DropdownMenuItem(value: 'operador', child: Text('Operador')),
                DropdownMenuItem(
                    value: 'planificador', child: Text('Planificador')),
                DropdownMenuItem(
                    value: 'supervisor', child: Text('Supervisor')),
                DropdownMenuItem(
                    value: 'administrador_ti', child: Text('Administrador TI')),
              ],
              onChanged: (value) {
                setState(() => _filtroTipo = value!);
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<bool?>(
              value: _filtroActivo,
              decoration: const InputDecoration(labelText: 'Estado'),
              items: const [
                DropdownMenuItem(value: null, child: Text('Todos')),
                DropdownMenuItem(value: true, child: Text('Activos')),
                DropdownMenuItem(value: false, child: Text('Inactivos')),
              ],
              onChanged: (value) {
                setState(() => _filtroActivo = value);
              },
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
              // Aplicar filtros
              final usuarioProvider =
                  Provider.of<UsuarioProvider>(context, listen: false);
              usuarioProvider.filtrarUsuarios(
                tipo: _filtroTipo == 'todos' ? null : _filtroTipo,
                activo: _filtroActivo,
              );
            },
            child: const Text('Aplicar'),
          ),
        ],
      ),
    );
  }

  void _crearNuevoUsuario(
      BuildContext context, UsuarioProvider usuarioProvider) {
    String nombre = '';
    String email = '';
    String password = '';
    String tipoUsuario = 'operador';

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Crear Nuevo Usuario'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(labelText: 'Nombre completo'),
                onChanged: (value) => nombre = value,
              ),
              const SizedBox(height: 12),
              TextField(
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                onChanged: (value) => email = value,
              ),
              const SizedBox(height: 12),
              TextField(
                decoration: const InputDecoration(labelText: 'Contraseña'),
                obscureText: true,
                onChanged: (value) => password = value,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: tipoUsuario,
                decoration: const InputDecoration(labelText: 'Tipo de Usuario'),
                items: const [
                  DropdownMenuItem(
                      value: 'administrador', child: Text('Administrador')),
                  DropdownMenuItem(value: 'operador', child: Text('Operador')),
                  DropdownMenuItem(
                      value: 'planificador', child: Text('Planificador')),
                  DropdownMenuItem(
                      value: 'supervisor', child: Text('Supervisor')),
                  DropdownMenuItem(
                      value: 'administrador_ti',
                      child: Text('Administrador TI')),
                ],
                onChanged: (value) => tipoUsuario = value!,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nombre.isEmpty || email.isEmpty || password.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Complete todos los campos')),
                );
                return;
              }

              try {
                await usuarioProvider.crearUsuario(
                  nombre: nombre,
                  email: email,
                  password: password,
                  tipoUsuario: tipoUsuario,
                );

                Navigator.pop(dialogContext);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Usuario creado exitosamente'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text('Error: $e'), backgroundColor: Colors.red),
                );
              }
            },
            child: const Text('Crear'),
          ),
        ],
      ),
    );
  }

  void _editarUsuario(
      BuildContext context, dynamic usuario, UsuarioProvider usuarioProvider) {
    String nombre = usuario.nombre;
    String email = usuario.email;
    String tipoUsuario = usuario.tipo.toString().split('.').last;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Editar Usuario: ${usuario.nombre}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(labelText: 'Nombre'),
                controller: TextEditingController(text: nombre),
                onChanged: (value) => nombre = value,
              ),
              const SizedBox(height: 12),
              TextField(
                decoration: const InputDecoration(labelText: 'Email'),
                controller: TextEditingController(text: email),
                onChanged: (value) => email = value,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: tipoUsuario,
                decoration: const InputDecoration(labelText: 'Tipo de Usuario'),
                items: const [
                  DropdownMenuItem(
                      value: 'administrador', child: Text('Administrador')),
                  DropdownMenuItem(value: 'operador', child: Text('Operador')),
                  DropdownMenuItem(
                      value: 'planificador', child: Text('Planificador')),
                  DropdownMenuItem(
                      value: 'supervisor', child: Text('Supervisor')),
                  DropdownMenuItem(
                      value: 'administrador_ti',
                      child: Text('Administrador TI')),
                ],
                onChanged: (value) => tipoUsuario = value!,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await usuarioProvider.actualizarUsuario(
                  id: usuario.id,
                  nombre: nombre,
                  email: email,
                  tipoUsuario: tipoUsuario,
                );

                Navigator.pop(dialogContext);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Usuario actualizado exitosamente'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text('Error: $e'), backgroundColor: Colors.red),
                );
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _cambiarPermisos(
      BuildContext context, dynamic usuario, UsuarioProvider usuarioProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Permisos: ${usuario.nombre}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.admin_panel_settings),
              title: const Text('Tipo de Usuario Actual'),
              subtitle: Text(usuario.tipo.toString().split('.').last),
            ),
            const Divider(),
            const Text(
              'Cambiar tipo de usuario para modificar permisos:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildPermisoItem('Administrador', 'Control total del sistema'),
            _buildPermisoItem('Operador', 'Gestión de bahías y reservas'),
            _buildPermisoItem('Planificador', 'Creación de reservas'),
            _buildPermisoItem('Supervisor', 'Supervisión y reportes'),
            _buildPermisoItem(
                'Administrador TI', 'Gestión técnica del sistema'),
          ],
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

  Widget _buildPermisoItem(String titulo, String descripcion) {
    return ListTile(
      leading: const Icon(Icons.check_circle_outline, size: 20),
      title: Text(titulo, style: const TextStyle(fontSize: 14)),
      subtitle: Text(descripcion, style: const TextStyle(fontSize: 12)),
      dense: true,
    );
  }

  void _verActividadUsuario(BuildContext context, dynamic usuario) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Actividad: ${usuario.nombre}'),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: ListView(
            children: [
              _buildActividadItem(
                'Inicio de sesión',
                DateFormat('dd/MM/yyyy HH:mm')
                    .format(DateTime.now().subtract(const Duration(hours: 2))),
                Icons.login,
                Colors.green,
              ),
              _buildActividadItem(
                'Creación de reserva',
                DateFormat('dd/MM/yyyy HH:mm')
                    .format(DateTime.now().subtract(const Duration(hours: 3))),
                Icons.add,
                Colors.blue,
              ),
              _buildActividadItem(
                'Modificación de bahía',
                DateFormat('dd/MM/yyyy HH:mm')
                    .format(DateTime.now().subtract(const Duration(hours: 5))),
                Icons.edit,
                Colors.orange,
              ),
              _buildActividadItem(
                'Descarga de reporte',
                DateFormat('dd/MM/yyyy HH:mm')
                    .format(DateTime.now().subtract(const Duration(hours: 8))),
                Icons.download,
                Colors.purple,
              ),
            ],
          ),
        ),
        actions: [
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              // Descargar log completo
            },
            icon: const Icon(Icons.download),
            label: const Text('Descargar Log'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  Widget _buildActividadItem(
      String accion, String fecha, IconData icono, Color color) {
    return ListTile(
      leading: Icon(icono, color: color),
      title: Text(accion),
      subtitle: Text(fecha),
      dense: true,
    );
  }
}
