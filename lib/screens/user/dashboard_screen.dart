import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bahias_descarga_system/providers/bahia_provider.dart';
import 'package:bahias_descarga_system/providers/reserva_provider.dart';
import 'package:bahias_descarga_system/providers/mantenimiento.dart';
import 'package:bahias_descarga_system/providers/auth_provider.dart';
import 'package:bahias_descarga_system/widgets/custom_appbar.dart';
import 'package:bahias_descarga_system/utils/constants.dart';
import 'package:bahias_descarga_system/utils/responsive.dart';
import 'package:bahias_descarga_system/models/bahia_model.dart';
import 'package:intl/intl.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  TipoBahia? _filtroTipo;
  EstadoBahia? _filtroEstado;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _statsScrollController = ScrollController();
  int _loadedBahias = 20;
  Map<String, dynamic> _estadisticas = {};
  bool _cargandoEstadisticas = false;

  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  @override
  void initState() {
    super.initState();
    _cargarDatosIniciales();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _statsScrollController.dispose();
    super.dispose();
  }

  // ========== MÉTODOS DE CARGA Y ACTUALIZACIÓN ==========

  Future<void> _cargarDatosIniciales() async {
    final bahiaProvider = Provider.of<BahiaProvider>(context, listen: false);
    final reservaProvider =
        Provider.of<ReservaProvider>(context, listen: false);

    await bahiaProvider.cargarBahias();
    await reservaProvider.cargarReservas();
    await _cargarEstadisticas();
  }

  Future<void> _cargarEstadisticas() async {
    if (_cargandoEstadisticas) return;

    setState(() => _cargandoEstadisticas = true);

    try {
      final reservaProvider =
          Provider.of<ReservaProvider>(context, listen: false);
      final estadisticas = await reservaProvider.obtenerIndicadoresDashboard();
      setState(() => _estadisticas = estadisticas);
    } catch (e) {
      print('Error cargando estadísticas: $e');
    } finally {
      setState(() => _cargandoEstadisticas = false);
    }
  }

  // ========== HELPERS DE UI ==========

  void _mostrarSnackBar(String mensaje, Color backgroundColor) {
    _scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: backgroundColor,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _mostrarDialogoCargando(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => WillPopScope(
        onWillPop: () async => false,
        child: const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  // ========== VALIDACIÓN DE PERMISOS ==========

  Future<bool> _validarPermisosMantenimiento(BuildContext context) async {
    // ✅ TODOS LOS USUARIOS TIENEN PERMISO PARA GESTIONAR MANTENIMIENTOS
    // Si necesitas agregar validación de permisos en el futuro, descomenta:
    /*
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    if (authProvider.usuario?.esAdministrador != true) {
      _mostrarSnackBar(
        'No tiene permisos para gestionar mantenimientos',
        Colors.orange
      );
      return false;
    }
    */

    return true;
  }

  // ========== BUILD ==========

  @override
  Widget build(BuildContext context) {
    final bahiaProvider = Provider.of<BahiaProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    final bahias = bahiaProvider.bahias;

    final totalBahias = bahias.length;
    final bahiasLibres =
        bahias.where((b) => b.estado == EstadoBahia.libre).length;
    final bahiasOcupadas =
        bahias.where((b) => b.estado == EstadoBahia.enUso).length;
    final bahiasReservadas =
        bahias.where((b) => b.estado == EstadoBahia.reservada).length;
    final bahiasMantenimiento =
        bahias.where((b) => b.estado == EstadoBahia.mantenimiento).length;

    return ScaffoldMessenger(
      key: _scaffoldMessengerKey,
      child: Scaffold(
        appBar: CustomAppBar(
          title: AppStrings.dashboard,
          showBackButton: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              onPressed: () {
                _cargarDatosIniciales();
                _mostrarSnackBar('Datos actualizados', Colors.blue);
              },
            ),
            IconButton(
              icon: const Icon(Icons.calendar_view_week, color: Colors.white),
              tooltip: 'Ver Disponibilidad',
              onPressed: () => _verDisponibilidadGeneral(context),
            ),
            IconButton(
              icon: const Icon(Icons.build_circle, color: Colors.white),
              tooltip: 'Ver Mantenimientos',
              onPressed: () => _verTodosLosMantenimientos(context),
            ),
            // ✅ BOTÓN DE ADMIN COMENTADO - Descomentar si necesitas validar permisos
            /*
            if (authProvider.usuario?.esAdministrador ?? false)
              IconButton(
                icon: const Icon(Icons.admin_panel_settings, color: Colors.white),
                onPressed: () => Navigator.pushNamed(context, '/admin'),
              ),
            */
          ],
        ),
        body: RefreshIndicator(
          onRefresh: _cargarDatosIniciales,
          child: Column(
            children: [
              _buildResponsiveStatsRow(
                totalBahias,
                bahiasLibres,
                bahiasOcupadas,
                bahiasReservadas,
                bahiasMantenimiento,
              ),
              _buildMobileSearchFilters(bahiaProvider),
              Expanded(
                child: _buildBahiasGrid(bahiaProvider, bahias),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ========== WIDGETS DE ESTADÍSTICAS ==========

  Widget _buildResponsiveStatsRow(
      int total, int libres, int ocupadas, int reservadas, int mantenimiento) {
    final reservasHoy = _estadisticas['reservas_hoy'] ?? 0;
    final reservasSemana = _estadisticas['reservas_semana'] ?? 0;
    final incidenciasAbiertas = _estadisticas['incidencias_abiertas'] ?? 0;

    if (Responsive.isMobile(context)) {
      return SizedBox(
        height: 120,
        child: ListView(
          controller: _statsScrollController,
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.all(16),
          children: [
            _buildStatCard('Total', total, Icons.local_parking, Colors.blue),
            _buildStatCard('Libres', libres, Icons.check_circle, Colors.green),
            _buildStatCard(
                'Ocupadas', ocupadas, Icons.do_not_disturb, Colors.red),
            _buildStatCard(
                'Reservas Hoy', reservasHoy, Icons.today, Colors.purple),
            _buildStatCard('Incidencias', incidenciasAbiertas, Icons.warning,
                Colors.orange),
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
            _buildStatCard(
                'Reservas Hoy', reservasHoy, Icons.today, Colors.purple),
            _buildStatCard('Reservas Semana', reservasSemana,
                Icons.calendar_today, Colors.indigo),
            _buildStatCard('Incidencias', incidenciasAbiertas, Icons.warning,
                Colors.orange),
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
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ========== WIDGETS DE FILTROS Y BÚSQUEDA ==========

  Widget _buildMobileSearchFilters(BahiaProvider bahiaProvider) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              labelText: 'Buscar bahía...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        bahiaProvider.limpiarBusqueda();
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onChanged: (value) => bahiaProvider.buscarBahias(value),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<EstadoBahia?>(
            value: _filtroEstado,
            decoration: InputDecoration(
              labelText: 'Filtrar por estado',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
            ),
            items: [
              const DropdownMenuItem<EstadoBahia?>(
                value: null,
                child: Text('Todos los estados'),
              ),
              DropdownMenuItem<EstadoBahia?>(
                value: EstadoBahia.libre,
                child: Text(_getEstadoBahiaText(EstadoBahia.libre)),
              ),
              DropdownMenuItem<EstadoBahia?>(
                value: EstadoBahia.enUso,
                child: Text(_getEstadoBahiaText(EstadoBahia.enUso)),
              ),
              DropdownMenuItem<EstadoBahia?>(
                value: EstadoBahia.reservada,
                child: Text(_getEstadoBahiaText(EstadoBahia.reservada)),
              ),
              DropdownMenuItem<EstadoBahia?>(
                value: EstadoBahia.mantenimiento,
                child: Text(_getEstadoBahiaText(EstadoBahia.mantenimiento)),
              ),
            ],
            onChanged: (value) => setState(() => _filtroEstado = value),
          ),
        ],
      ),
    );
  }

  // ========== WIDGETS DE GRID DE BAHÍAS ==========

  Widget _buildBahiasGrid(BahiaProvider bahiaProvider, List<Bahia> bahias) {
    List<Bahia> bahiasFiltradas = bahias;
    if (_filtroTipo != null) {
      bahiasFiltradas =
          bahiasFiltradas.where((b) => b.tipo == _filtroTipo).toList();
    }
    if (_filtroEstado != null) {
      bahiasFiltradas =
          bahiasFiltradas.where((b) => b.estado == _filtroEstado).toList();
    }

    final displayedBahias = _loadedBahias < bahiasFiltradas.length
        ? bahiasFiltradas.sublist(0, _loadedBahias)
        : bahiasFiltradas;

    if (bahiasFiltradas.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.local_parking, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No hay bahías disponibles',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Intenta cambiar los filtros',
              style: TextStyle(color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (scrollNotification) {
        if (scrollNotification is ScrollEndNotification &&
            scrollNotification.metrics.extentAfter == 0 &&
            _loadedBahias < bahiasFiltradas.length) {
          setState(() => _loadedBahias += 20);
        }
        return false;
      },
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: Responsive.isDesktop(context)
              ? 5
              : Responsive.isTablet(context)
                  ? 3
                  : 2,
          childAspectRatio: 0.9,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        padding: const EdgeInsets.all(16),
        itemCount: displayedBahias.length +
            (_loadedBahias < bahiasFiltradas.length ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == displayedBahias.length) {
            return const Center(child: CircularProgressIndicator());
          }
          final bahia = displayedBahias[index];
          return _buildBahiaCard(bahia, bahiaProvider);
        },
      ),
    );
  }

  Widget _buildBahiaCard(Bahia bahia, BahiaProvider bahiaProvider) {
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
              Text(
                'Bahía ${bahia.numero}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              Text(
                bahia.nombreTipo,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              Text(
                bahia.nombreEstado,
                style: TextStyle(
                  fontSize: 12,
                  color: bahia.colorEstado,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              if (bahia.estado == EstadoBahia.reservada ||
                  bahia.estado == EstadoBahia.enUso) ...[
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(6),
                    border:
                        Border.all(color: bahia.colorEstado.withOpacity(0.3)),
                  ),
                  child: Column(
                    children: [
                      if (bahia.reservadaPor != null) ...[
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.person,
                                size: 12, color: Colors.grey[700]),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                bahia.reservadaPor!,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[800],
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                          ],
                        ),
                      ],
                      if (bahia.horaInicioReserva != null) ...[
                        const SizedBox(height: 2),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.access_time,
                                size: 10, color: Colors.grey[600]),
                            const SizedBox(width: 2),
                            Text(
                              'Inicio: ${DateFormat('HH:mm').format(bahia.horaInicioReserva!)}',
                              style: TextStyle(
                                  fontSize: 9, color: Colors.grey[700]),
                            ),
                          ],
                        ),
                      ],
                      if (bahia.horaFinReserva != null) ...[
                        const SizedBox(height: 2),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.event, size: 10, color: Colors.red[400]),
                            const SizedBox(width: 2),
                            Text(
                              'Fin: ${DateFormat('HH:mm').format(bahia.horaFinReserva!)}',
                              style: TextStyle(
                                fontSize: 9,
                                color: Colors.red[700],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                      if (bahia.vehiculoPlaca != null &&
                          bahia.vehiculoPlaca != 'PENDIENTE') ...[
                        const SizedBox(height: 2),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.local_shipping,
                                size: 10, color: Colors.grey[600]),
                            const SizedBox(width: 2),
                            Text(
                              bahia.vehiculoPlaca!,
                              style: TextStyle(
                                fontSize: 9,
                                color: Colors.grey[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ========== DIÁLOGOS DE INFORMACIÓN ==========

  void _verDisponibilidadGeneral(BuildContext context) async {
    _mostrarDialogoCargando(context);

    try {
      final reservaProvider =
          Provider.of<ReservaProvider>(context, listen: false);
      final reservasActivas =
          await reservaProvider.obtenerReservasActivasBackend();

      if (!mounted) return;
      Navigator.pop(context);

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.calendar_view_week, color: Colors.blue),
              SizedBox(width: 8),
              Text('Disponibilidad de Bahías'),
            ],
          ),
          content: Container(
            width: double.maxFinite,
            constraints: const BoxConstraints(maxHeight: 400),
            child: reservasActivas.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.event_available,
                            size: 64, color: Colors.green),
                        SizedBox(height: 16),
                        Text('No hay reservas activas',
                            style: TextStyle(fontSize: 16)),
                      ],
                    ),
                  )
                : SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Reservas Activas: ${reservasActivas.length}',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 10),
                        ...reservasActivas.map((reserva) {
                          final bahiaProvider = Provider.of<BahiaProvider>(
                              context,
                              listen: false);
                          final bahia = bahiaProvider.bahias.firstWhere(
                            (b) => b.id == reserva.bahiaId,
                            orElse: () => null as dynamic,
                          );
                          final numeroBahia = bahia?.numero ?? 'N/A';

                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            child: ListTile(
                              leading: const Icon(Icons.calendar_today,
                                  color: Colors.blue),
                              title: Text('Bahía $numeroBahia'),
                              subtitle: Text(
                                'Inicio: ${DateFormat('dd/MM HH:mm').format(reserva.fechaHoraInicio)}\n'
                                'Fin: ${DateFormat('dd/MM HH:mm').format(reserva.fechaHoraFin)}\n'
                                'Usuario: ${reserva.usuarioNombre ?? "Sin nombre"}',
                              ),
                              trailing: const Chip(
                                label: Text('Activa',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 10)),
                                backgroundColor: Colors.green,
                              ),
                            ),
                          );
                        }),
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
      if (!mounted) return;
      Navigator.pop(context);
      _mostrarSnackBar('Error al cargar disponibilidad: $e', Colors.red);
    }
  }

  void _verTodosLosMantenimientos(BuildContext context) async {
    _mostrarDialogoCargando(context);

    try {
      final mantenimientoProvider =
          Provider.of<MantenimientoProvider>(context, listen: false);
      final mantenimientos =
          await mantenimientoProvider.obtenerTodosLosMantenimientos();

      if (!mounted) return;
      Navigator.pop(context);

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.build_circle, color: Colors.orange),
              SizedBox(width: 8),
              Text('Mantenimientos del Sistema'),
            ],
          ),
          content: Container(
            width: double.maxFinite,
            constraints: const BoxConstraints(maxHeight: 400),
            child: mantenimientos.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle, size: 64, color: Colors.green),
                        SizedBox(height: 16),
                        Text('No hay mantenimientos registrados',
                            style: TextStyle(fontSize: 16)),
                      ],
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: mantenimientos.length,
                    itemBuilder: (context, index) {
                      final mant = mantenimientos[index];
                      Color estadoColor;
                      IconData iconoEstado;

                      switch (mant['estado']) {
                        case 'programado':
                          estadoColor = Colors.blue;
                          iconoEstado = Icons.schedule;
                          break;
                        case 'en_progreso':
                          estadoColor = Colors.orange;
                          iconoEstado = Icons.build;
                          break;
                        case 'completado':
                          estadoColor = Colors.green;
                          iconoEstado = Icons.check_circle;
                          break;
                        case 'cancelado':
                          estadoColor = Colors.red;
                          iconoEstado = Icons.cancel;
                          break;
                        default:
                          estadoColor = Colors.grey;
                          iconoEstado = Icons.help;
                      }

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: ListTile(
                          leading: Icon(iconoEstado, color: estadoColor),
                          title:
                              Text('Bahía #${mant['bahia_numero'] ?? 'N/A'}'),
                          subtitle: Text(
                            '${mant['tipo_mantenimiento'] ?? 'N/A'}\n${mant['descripcion'] ?? 'Sin descripción'}',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: Chip(
                            label: Text(
                              (mant['estado'] ?? 'desconocido')
                                  .toString()
                                  .toUpperCase(),
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 10),
                            ),
                            backgroundColor: estadoColor,
                          ),
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
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      _mostrarSnackBar('Error al cargar mantenimientos: $e', Colors.red);
    }
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
              if (bahia.reservadaPor != null)
                _buildDetalleItem('Reservada por', bahia.reservadaPor!),
              if (bahia.horaInicioReserva != null)
                _buildDetalleItem(
                    'Inicio',
                    DateFormat('dd/MM/yyyy HH:mm')
                        .format(bahia.horaInicioReserva!)),
              if (bahia.horaFinReserva != null)
                _buildDetalleItem(
                    'Fin',
                    DateFormat('dd/MM/yyyy HH:mm')
                        .format(bahia.horaFinReserva!)),
              if (bahia.vehiculoPlaca != null)
                _buildDetalleItem('Vehículo', bahia.vehiculoPlaca!),
              if (bahia.conductorNombre != null)
                _buildDetalleItem('Conductor', bahia.conductorNombre!),
              if (bahia.observaciones != null)
                _buildDetalleItem('Observaciones', bahia.observaciones!),
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

  Widget _buildDetalleItem(String titulo, String valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$titulo: ',
              style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(valor)),
        ],
      ),
    );
  }

  // ========== MENÚ DE OPCIONES DE BAHÍA ==========

  void _mostrarOpcionesBahia(
      BuildContext context, Bahia bahia, BahiaProvider bahiaProvider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 16,
              left: 16,
              right: 16,
              top: 8,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
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
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: bahia.colorEstado.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Estado: ${bahia.nombreEstado}',
                      style: TextStyle(
                          fontSize: 16,
                          color: bahia.colorEstado,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ..._buildOpcionesPorEstado(context, bahia, bahiaProvider),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 8),
                  _buildBotonOpcion(
                    'Ver Detalles Completos',
                    Icons.info_outline,
                    Colors.blueGrey,
                    () {
                      Navigator.pop(sheetContext);
                      _mostrarDetallesCompletosBahia(context, bahia);
                    },
                  ),
                  const SizedBox(height: 8),
                  _buildBotonOpcion(
                    'Cerrar',
                    Icons.close,
                    Colors.grey[600]!,
                    () => Navigator.pop(sheetContext),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildOpcionesPorEstado(
      BuildContext context, Bahia bahia, BahiaProvider bahiaProvider) {
    switch (bahia.estado) {
      case EstadoBahia.libre:
        return _buildOpcionesLibre(context, bahia, bahiaProvider);
      case EstadoBahia.reservada:
        return _buildOpcionesReservada(context, bahia, bahiaProvider);
      case EstadoBahia.enUso:
        return _buildOpcionesEnUso(context, bahia, bahiaProvider);
      case EstadoBahia.mantenimiento:
        return _buildOpcionesMantenimiento(context, bahia, bahiaProvider);
      default:
        return [];
    }
  }

  List<Widget> _buildOpcionesLibre(
      BuildContext context, Bahia bahia, BahiaProvider bahiaProvider) {
    return [
      _buildBotonOpcion(
        'Reservar Bahía',
        Icons.calendar_today,
        Colors.blue,
        () => _reservarBahia(context, bahia),
      ),
      const SizedBox(height: 8),
      _buildBotonOpcion(
        'Poner en Uso Inmediato',
        Icons.local_shipping,
        Colors.orange,
        () {
          Navigator.pop(context); // Cerrar bottom sheet
          _ponerEnUsoInmediato(context, bahia, bahiaProvider);
        },
      ),
      const SizedBox(height: 8),
      _buildBotonOpcion(
        'Poner en Mantenimiento',
        Icons.build,
        Colors.blueGrey,
        () {
          Navigator.pop(context); // Cerrar bottom sheet
          _ponerEnMantenimientoCompleto(context, bahia, bahiaProvider);
        },
      ),
    ];
  }

  List<Widget> _buildOpcionesReservada(
      BuildContext context, Bahia bahia, BahiaProvider bahiaProvider) {
    return [
      _buildBotonOpcion(
        'Iniciar Uso',
        Icons.play_arrow,
        Colors.blue,
        () {
          Navigator.pop(context);
          _iniciarUsoDesdeReserva(context, bahia, bahiaProvider);
        },
      ),
      const SizedBox(height: 8),
      _buildBotonOpcion(
        'Cancelar Reserva',
        Icons.cancel,
        Colors.red,
        () {
          Navigator.pop(context);
          _cancelarReservaBahia(context, bahia, bahiaProvider);
        },
      ),
      const SizedBox(height: 8),
      _buildBotonOpcion(
        'Forzar Liberación',
        Icons.lock_open,
        Colors.orange,
        () {
          Navigator.pop(context);
          _forzarLiberacionBahia(context, bahia, bahiaProvider);
        },
      ),
    ];
  }

  List<Widget> _buildOpcionesEnUso(
      BuildContext context, Bahia bahia, BahiaProvider bahiaProvider) {
    return [
      _buildBotonOpcion(
        'Completar y Liberar',
        Icons.check_circle,
        Colors.green,
        () {
          Navigator.pop(context);
          _completarYLiberar(context, bahia, bahiaProvider);
        },
      ),
      const SizedBox(height: 8),
      _buildBotonOpcion(
        'Forzar Liberación',
        Icons.lock_open,
        Colors.orange,
        () {
          Navigator.pop(context);
          _forzarLiberacionBahia(context, bahia, bahiaProvider);
        },
      ),
    ];
  }

  List<Widget> _buildOpcionesMantenimiento(
      BuildContext context, Bahia bahia, BahiaProvider bahiaProvider) {
    return [
      _buildBotonOpcion(
        'Iniciar Mantenimiento',
        Icons.play_arrow,
        Colors.blue,
        () {
          Navigator.pop(context);
          _iniciarMantenimiento(context, bahia, bahiaProvider);
        },
      ),
      const SizedBox(height: 8),
      _buildBotonOpcion(
        'Completar Mantenimiento',
        Icons.check_circle,
        Colors.green,
        () {
          Navigator.pop(context);
          _completarMantenimiento(context, bahia, bahiaProvider);
        },
      ),
      const SizedBox(height: 8),
      _buildBotonOpcion(
        'Cancelar Mantenimiento',
        Icons.cancel,
        Colors.red,
        () {
          Navigator.pop(context);
          _cancelarMantenimiento(context, bahia, bahiaProvider);
        },
      ),
    ];
  }

  Widget _buildBotonOpcion(
      String texto, IconData icono, Color color, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icono, size: 22),
            const SizedBox(width: 10),
            Text(
              texto,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ========== ACCIONES DE BAHÍAS ==========

  void _reservarBahia(BuildContext context, Bahia bahia) {
    Navigator.pop(context);
    Navigator.pushNamed(context, '/reservation', arguments: bahia);
  }

  void _ponerEnUsoInmediato(BuildContext parentContext, Bahia bahia,
      BahiaProvider bahiaProvider) async {
    String vehiculoPlaca = '';
    String conductorNombre = '';
    String mercanciaTipo = '';

    final resultado = await showDialog<bool>(
      context: parentContext,
      builder: (dialogContext) => AlertDialog(
        title: Text('🚚 Poner en Uso - Bahía ${bahia.numero}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Complete los datos del vehículo:',
                style: TextStyle(fontSize: 13),
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Placa del vehículo *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.directions_car),
                ),
                onChanged: (value) => vehiculoPlaca = value.trim(),
                textCapitalization: TextCapitalization.characters,
              ),
              const SizedBox(height: 12),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Nombre del conductor *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                onChanged: (value) => conductorNombre = value.trim(),
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 12),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Tipo de mercancía *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.inventory_2),
                ),
                onChanged: (value) => mercanciaTipo = value.trim(),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (vehiculoPlaca.isEmpty ||
                  conductorNombre.isEmpty ||
                  mercanciaTipo.isEmpty) {
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  const SnackBar(
                    content: Text('❌ Todos los campos son obligatorios'),
                    backgroundColor: Colors.orange,
                  ),
                );
              } else {
                Navigator.pop(dialogContext, true);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('Poner en Uso'),
          ),
        ],
      ),
    );

    if (resultado != true) return;

    try {
      showDialog(
        context: parentContext,
        barrierDismissible: false,
        builder: (loadingContext) => const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: Colors.white),
              SizedBox(height: 16),
              Text(
                'Poniendo bahía en uso...',
                style: TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );

      await bahiaProvider.ponerEnUsoMejorado(
          bahia.id, vehiculoPlaca, conductorNombre, mercanciaTipo);

      if (parentContext.mounted) {
        Navigator.pop(parentContext);
        _mostrarSnackBar('✅ Bahía puesta en uso correctamente', Colors.green);
      }
    } catch (e) {
      if (parentContext.mounted) {
        Navigator.pop(parentContext);
        _mostrarSnackBar('❌ Error: ${e.toString()}', Colors.red);
      }
    }
  }

  void _iniciarUsoDesdeReserva(
      BuildContext context, Bahia bahia, BahiaProvider bahiaProvider) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('🚀 Iniciar Uso'),
        content: Text('La Bahía ${bahia.numero} está reservada.\n\n'
            '¿Desea cambiar su estado a "En Uso"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('Sí, iniciar uso'),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (loadingContext) => const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: Colors.white),
              SizedBox(height: 16),
              Text(
                'Cambiando estado a En Uso...',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      );

      await bahiaProvider.iniciarUsoDesdeBahiaReservada(bahia.id);

      if (context.mounted) {
        Navigator.pop(context);
        _mostrarSnackBar('✅ Bahía puesta en uso correctamente', Colors.green);
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        _mostrarSnackBar('❌ Error: ${e.toString()}', Colors.red);
      }
    }
  }

  void _ponerEnMantenimientoCompleto(
      BuildContext context, Bahia bahia, BahiaProvider bahiaProvider) async {
    String? tipoSeleccionado;
    String descripcion = '';
    String? tecnicoResponsable;
    String? costoStr;
    DateTime fechaInicio = DateTime.now().add(Duration(minutes: 5));
    DateTime fechaFinProgramada = DateTime.now().add(Duration(hours: 4));

    final resultado = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogState, setDialogState) => AlertDialog(
          title: Text('🔧 Poner en Mantenimiento - Bahía ${bahia.numero}'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Tipo de Mantenimiento *',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Seleccione tipo',
                  ),
                  value: tipoSeleccionado,
                  items: const [
                    DropdownMenuItem(
                        value: 'preventivo', child: Text('Preventivo')),
                    DropdownMenuItem(
                        value: 'correctivo', child: Text('Correctivo')),
                  ],
                  onChanged: (value) {
                    setDialogState(() {
                      tipoSeleccionado = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                const Text('Descripción *',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                TextField(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Describa el mantenimiento',
                  ),
                  maxLines: 3,
                  onChanged: (value) => descripcion = value.trim(),
                ),
                const SizedBox(height: 16),
                const Text('Técnico Responsable',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                TextField(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Nombre del técnico (opcional)',
                  ),
                  onChanged: (value) => tecnicoResponsable = value.trim(),
                ),
                const SizedBox(height: 16),
                const Text('Costo Estimado (opcional)',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                TextField(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Ej: 1500.00',
                    prefixText: '\$',
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) => costoStr = value.trim(),
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
                if (tipoSeleccionado == null) {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    const SnackBar(
                        content: Text(
                            '❌ Debe seleccionar un tipo de mantenimiento')),
                  );
                  return;
                }

                if (descripcion.isEmpty) {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    const SnackBar(
                        content: Text('❌ Debe ingresar una descripción')),
                  );
                  return;
                }

                Navigator.pop(dialogContext, true);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blueGrey),
              child: const Text('Programar Mantenimiento'),
            ),
          ],
        ),
      ),
    );

    if (resultado != true) return;

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (loadingContext) => const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: Colors.white),
              SizedBox(height: 16),
              Text(
                'Programando mantenimiento...',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      );

      double? costo;
      if (costoStr != null && costoStr!.isNotEmpty) {
        costo = double.tryParse(costoStr!);
      }

      final mantenimientoProvider =
          Provider.of<MantenimientoProvider>(context, listen: false);

      await mantenimientoProvider.crearMantenimiento(
        bahia.id,
        tipoSeleccionado!,
        descripcion,
        fechaInicio,
        fechaFinProgramada,
        tecnicoResponsable: tecnicoResponsable,
        costo: costo,
        observaciones: 'Mantenimiento programado desde Dashboard',
      );

      await bahiaProvider.cargarBahias();

      if (context.mounted) {
        Navigator.pop(context);
        _mostrarSnackBar(
            '✅ Mantenimiento programado correctamente', Colors.green);
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        _mostrarSnackBar('❌ Error: ${e.toString()}', Colors.red);
      }
    }
  }

  void _completarYLiberar(
      BuildContext context, Bahia bahia, BahiaProvider bahiaProvider) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('✅ Completar Uso'),
        content: Text(
            '¿Confirma que desea completar el uso de la Bahía ${bahia.numero}?\n\n'
            'La bahía quedará libre inmediatamente.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Sí, completar'),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: Colors.white),
              SizedBox(height: 16),
              Text(
                'Completando uso y liberando...',
                style: TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );

      bool exitoso = false;
      try {
        await bahiaProvider.liberarBahiaMejorado(bahia.id);
        exitoso = true;
      } catch (e) {
        print('⚠️ Método mejorado falló: $e');
        try {
          await bahiaProvider.forzarLiberacionCompleta(bahia.id);
          exitoso = true;
        } catch (e2) {
          print('❌ Forzar liberación también falló: $e2');
        }
      }

      if (context.mounted) {
        Navigator.pop(context);

        if (exitoso) {
          _mostrarSnackBar('✅ Bahía liberada correctamente', Colors.green);
        } else {
          _mostrarSnackBar(
              '⚠️ No se pudo liberar automáticamente. Intente forzar liberación.',
              Colors.orange);
        }
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        _mostrarSnackBar('❌ Error: ${e.toString()}', Colors.red);
      }
    }
  }

  void _iniciarMantenimiento(
      BuildContext context, Bahia bahia, BahiaProvider bahiaProvider) async {
    if (!mounted) return;

    // ✅ Validar permisos
    if (!await _validarPermisosMantenimiento(context)) return;

    _mostrarDialogoCargando(context);

    try {
      final mantenimientoProvider =
          Provider.of<MantenimientoProvider>(context, listen: false);

      await mantenimientoProvider.iniciarMantenimiento(bahia.id);
      await bahiaProvider.cargarBahias();
      await _cargarEstadisticas();

      if (!mounted) return;
      Navigator.of(context).pop();

      _mostrarSnackBar('✓ Mantenimiento iniciado', Colors.blue);
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop();
      _mostrarSnackBar('Error: ${e.toString()}', Colors.red);
    }
  }

  void _completarMantenimiento(
      BuildContext context, Bahia bahia, BahiaProvider bahiaProvider) async {
    // ✅ Validar permisos primero
    if (!await _validarPermisosMantenimiento(context)) return;

    final observacionesController = TextEditingController();

    final resultado = await showDialog<Map<String, dynamic>?>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Completar Mantenimiento'),
        content: TextField(
          controller: observacionesController,
          decoration: const InputDecoration(
            labelText: 'Observaciones (opcional)',
            hintText: 'Ingrese observaciones del trabajo realizado',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            onPressed: () {
              Navigator.pop(dialogContext, {
                'confirmar': true,
                'observaciones': observacionesController.text.trim()
              });
            },
            child: const Text('Completar'),
          ),
        ],
      ),
    );

    if (resultado == null || resultado['confirmar'] != true) return;
    if (!mounted) return;

    _mostrarDialogoCargando(context);

    try {
      final mantenimientoProvider =
          Provider.of<MantenimientoProvider>(context, listen: false);

      await mantenimientoProvider.completarMantenimiento(
        bahia.id,
        observaciones: resultado['observaciones'].isEmpty
            ? null
            : resultado['observaciones'],
      );

      await bahiaProvider.cargarBahias();
      await _cargarEstadisticas();

      if (!mounted) return;
      Navigator.of(context).pop();

      _mostrarSnackBar('Mantenimiento completado exitosamente', Colors.green);
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop();
      _mostrarSnackBar('Error: $e', Colors.red);
    }
  }

  void _cancelarMantenimiento(
      BuildContext context, Bahia bahia, BahiaProvider bahiaProvider) async {
    // ✅ Validar permisos primero
    if (!await _validarPermisosMantenimiento(context)) return;

    final motivoController = TextEditingController();

    final resultado = await showDialog<Map<String, dynamic>?>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.red),
            SizedBox(width: 8),
            Text('Cancelar Mantenimiento'),
          ],
        ),
        content: TextField(
          controller: motivoController,
          decoration: const InputDecoration(
            labelText: 'Motivo de cancelación *',
            hintText: 'Ingrese el motivo',
            border: OutlineInputBorder(),
          ),
          maxLines: 2,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              if (motivoController.text.trim().isEmpty) {
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  const SnackBar(
                    content: Text('Debe ingresar un motivo de cancelación'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }
              Navigator.pop(dialogContext,
                  {'confirmar': true, 'motivo': motivoController.text.trim()});
            },
            child: const Text('Confirmar Cancelación'),
          ),
        ],
      ),
    );

    if (resultado == null || resultado['confirmar'] != true) return;
    if (!mounted) return;

    _mostrarDialogoCargando(context);

    try {
      final mantenimientoProvider =
          Provider.of<MantenimientoProvider>(context, listen: false);

      await mantenimientoProvider.cancelarMantenimiento(
          bahia.id, resultado['motivo']);

      await bahiaProvider.cargarBahias();
      await _cargarEstadisticas();

      if (!mounted) return;
      Navigator.of(context).pop();

      _mostrarSnackBar('Mantenimiento cancelado', Colors.orange);
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop();
      _mostrarSnackBar('Error: $e', Colors.red);
    }
  }

  Future<void> _forzarLiberacionBahia(
      BuildContext context, Bahia bahia, BahiaProvider bahiaProvider) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('⚠️ Forzar Liberación'),
        content: Text(
            '¿Está seguro de forzar la liberación de la Bahía ${bahia.numero}?\n\n'
            'Estado actual: ${bahia.nombreEstado}\n\n'
            'Esta acción:\n'
            '• Completará cualquier reserva activa\n'
            '• Cambiará el estado a "Libre"\n'
            '• No se puede deshacer'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange),
            child: const Text('Sí, forzar'),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: Colors.white),
              SizedBox(height: 16),
              Text(
                'Forzando liberación completa...',
                style: TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );

      await bahiaProvider.forzarLiberacionCompleta(bahia.id);

      if (context.mounted) {
        Navigator.pop(context);
        _mostrarSnackBar('✅ Bahía liberada correctamente', Colors.green);
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        _mostrarSnackBar('❌ Error: ${e.toString()}', Colors.red);
      }
    }
  }

  void _cancelarReservaBahia(
      BuildContext context, Bahia bahia, BahiaProvider bahiaProvider) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.red),
            SizedBox(width: 8),
            Text('Cancelar Reserva'),
          ],
        ),
        content: Text(
          '¿Está seguro de cancelar la reserva de la Bahía ${bahia.numero}?\n\nEsta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Sí, Cancelar Reserva'),
          ),
        ],
      ),
    );

    if (confirmar != true) return;
    if (!mounted) return;

    _mostrarDialogoCargando(context);

    try {
      final reservaProvider =
          Provider.of<ReservaProvider>(context, listen: false);

      // 🔹 VALIDACIÓN: Obtener reservas activas primero
      final reservasActivas =
          await reservaProvider.obtenerReservasActivasBackend();

      // Buscar la reserva activa para esta bahía
      final reservasEncontradas =
          reservasActivas.where((r) => r.bahiaId == bahia.id).toList();

      if (!mounted) return;
      Navigator.of(context).pop(); // Cerrar loading

      if (reservasEncontradas.isEmpty) {
        _mostrarSnackBar(
          'Esta bahía no tiene una reserva activa para cancelar',
          Colors.orange,
        );
        // Recargar para sincronizar estado
        await bahiaProvider.cargarBahias();
        return;
      }

      // Confirmar nuevamente con información de la reserva
      final confirmarFinal = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Confirmar Cancelación'),
          content: Text(
            'Reserva encontrada:\n'
            'Usuario: ${reservasEncontradas.first.usuarioNombre ?? "Desconocido"}\n'
            'Inicio: ${DateFormat('dd/MM HH:mm').format(reservasEncontradas.first.fechaHoraInicio)}\n\n'
            '¿Confirma la cancelación?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('No'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Sí, Cancelar'),
            ),
          ],
        ),
      );

      if (confirmarFinal != true) return;
      if (!mounted) return;

      _mostrarDialogoCargando(context);

      await reservaProvider.cancelarReserva(reservasEncontradas.first.id);
      await bahiaProvider.cargarBahias();
      await _cargarEstadisticas();

      if (!mounted) return;
      Navigator.of(context).pop();

      _mostrarSnackBar('✓ Reserva cancelada exitosamente', Colors.orange);
    } catch (e) {
      if (!mounted) return;
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }

      // 🔹 MEJORAR MENSAJE DE ERROR
      String mensajeError = e.toString();
      if (mensajeError.contains('No hay reserva activa')) {
        mensajeError = 'La bahía no tiene una reserva activa para cancelar';
      } else if (mensajeError.contains('permisos')) {
        mensajeError = 'No tiene permisos para cancelar esta reserva';
      }

      _mostrarSnackBar('Error: $mensajeError', Colors.red);

      // Recargar datos para sincronizar
      await bahiaProvider.cargarBahias();
    }
  }

  // ========== UTILIDADES ==========

  String _getEstadoBahiaText(EstadoBahia estado) {
    switch (estado) {
      case EstadoBahia.libre:
        return 'Libre';
      case EstadoBahia.reservada:
        return 'Reservada';
      case EstadoBahia.enUso:
        return 'En uso';
      case EstadoBahia.mantenimiento:
        return 'Mantenimiento';
      default:
        return 'Desconocido';
    }
  }
}
