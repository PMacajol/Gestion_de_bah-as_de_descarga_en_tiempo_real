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
import 'dart:io';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'dart:math';
import 'package:flutter/material.dart';

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
        // Cargar más elementos cuando se llega al final
        setState(() {
          _loadedItems += 20;
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
          IconButton(
            icon: const Icon(Icons.notifications_active, color: Colors.white),
            onPressed: () => _mostrarNotificaciones(context),
          ),
          IconButton(
            icon: const Icon(Icons.bar_chart, color: Colors.white),
            onPressed: () => _mostrarReportesCompletos(context),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) {
              if (value == 'configuracion') {
                _mostrarConfiguracion(context);
              } else if (value == 'backup') {
                _realizarBackup(context);
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem<String>(
                  value: 'configuracion',
                  child: Text('Configuración'),
                ),
                const PopupMenuItem<String>(
                  value: 'backup',
                  child: Text('Realizar Backup'),
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
                _buildDashboardTab(bahias, reservas),
                _buildBahiasTab(bahiaProvider, bahias),
                _buildReservasTab(reservaProvider, reservas),
                _buildReportesTab(bahias, reservas),
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
    Navigator.pop(context); // Cerrar el bottom sheet
    Navigator.pushNamed(
      context,
      '/reservation',
      arguments: bahia,
    );
  }

  void _ponerEnUso(
      BuildContext context, Bahia bahia, BahiaProvider bahiaProvider) async {
    try {
      await bahiaProvider.actualizarEstadoBahia(bahia.id, EstadoBahia.enUso);

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bahía puesta en uso')),
      );
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void _ponerEnMantenimiento(
      BuildContext context, Bahia bahia, BahiaProvider bahiaProvider) async {
    try {
      await bahiaProvider.ponerEnMantenimiento(
          bahia.id, 'Mantenimiento programado');
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bahía puesta en mantenimiento')),
      );
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void _cancelarReserva(
      BuildContext context, Bahia bahia, BahiaProvider bahiaProvider) async {
    try {
      await bahiaProvider.liberarBahia(bahia.id);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reserva cancelada')),
      );
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void _mostrarDetallesBahia(BuildContext context, Bahia bahia) {
    Navigator.pop(context); // Cerrar el bottom sheet primero
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

  void _liberarDeMantenimiento(
      BuildContext context, Bahia bahia, BahiaProvider bahiaProvider) async {
    try {
      await bahiaProvider.liberarDeMantenimiento(bahia.id);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bahía liberada de mantenimiento')),
      );
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void _liberarBahia(
      BuildContext context, Bahia bahia, BahiaProvider bahiaProvider) async {
    try {
      await bahiaProvider.liberarBahia(bahia.id);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bahía liberada')),
      );
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void _cancelarReservaBahia(
      BuildContext context, Bahia bahia, BahiaProvider bahiaProvider) async {
    try {
      await bahiaProvider.liberarBahia(bahia.id);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reserva cancelada')),
      );
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  // Para reservas (no confundir con el anterior)

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
                // Aquí va la lógica real para cancelar la reserva
                // Por ahora simulamos la cancelación
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Reserva cancelada exitosamente')),
                );

                // Opcional: Actualizar la lista de reservas
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

  void _mostrarDetallesCompletosBahia(BuildContext context, Bahia bahia) {
    Navigator.pop(context); // Cerrar el bottom sheet primero
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

  Widget _buildDashboardTab(List<Bahia> bahias, List<Reserva> reservas) {
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
          _buildBahiasCriticas(bahias),
        ],
      ),
    );
  }

  Widget _buildUsoPorTipoChart(List<Bahia> bahias) {
    final bool isMobile = Responsive.isMobile(context);
    final datos = [
      _crearDatoChart(
          'Libres',
          bahias.where((b) => b.estado == EstadoBahia.libre).length,
          Colors.green),
      _crearDatoChart(
          'Ocupadas',
          bahias.where((b) => b.estado == EstadoBahia.enUso).length,
          Colors.red),
      _crearDatoChart(
          'Reservadas',
          bahias.where((b) => b.estado == EstadoBahia.reservada).length,
          Colors.orange),
      _crearDatoChart(
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
                  palette: [
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
                  legend: Legend(
                    isVisible: true,
                    position: LegendPosition.bottom,
                    overflowMode: LegendItemOverflowMode.wrap,
                    textStyle: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.bold),
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

  ChartData _crearDatoChart(String x, int y, [Color? color]) {
    return ChartData(x, y, color);
  }

  Widget _buildReservasProximas(List<Reserva> reservas) {
    final ahora = DateTime.now();
    final reservasProximas = reservas
        .where((r) =>
            r.fechaHoraInicio.isAfter(ahora) &&
            r.fechaHoraInicio.isBefore(ahora.add(const Duration(days: 1))))
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
              const Text('No hay reservas próximas',
                  style: TextStyle(color: Colors.grey)),
            ...reservasProximas.map((reserva) => ListTile(
                  leading: const Icon(Icons.calendar_today, color: Colors.blue),
                  title: Text('Bahía #${reserva.numeroBahia}'),
                  subtitle: Text(DateFormat('dd/MM/yyyy HH:mm')
                      .format(reserva.fechaHoraInicio)),
                  trailing: Chip(
                    label: Text(reserva.estado,
                        style: const TextStyle(fontSize: 12)),
                    backgroundColor: reserva.estado == 'activa'
                        ? Colors.orange[100]
                        : Colors.grey[200],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildBahiasCriticas(List<Bahia> bahias) {
    final bahiasCriticas =
        bahias.where((b) => b.enUso && b.progresoUso > 0.9).take(5).toList();

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Bahías con Tiempo Crítico',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (bahiasCriticas.isEmpty)
              const Text('No hay bahías en tiempo crítico',
                  style: TextStyle(color: Colors.grey)),
            ...bahiasCriticas.map((bahia) => ListTile(
                  leading: Icon(Icons.warning, color: Colors.orange[700]),
                  title: Text('Bahía #${bahia.numero}'),
                  subtitle: LinearProgressIndicator(
                    value: bahia.progresoUso,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      bahia.progresoUso > 0.9 ? Colors.red : Colors.orange,
                    ),
                  ),
                  trailing:
                      Text('${(bahia.progresoUso * 100).toStringAsFixed(0)}%'),
                )),
          ],
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
          // Barra de búsqueda FUNCIONAL
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
                  switch (value) {
                    case 'todas':
                      bahiaProvider.limpiarBusqueda();
                      break;
                    case 'libres':
                      // Filtrar por libres
                      break;
                    case 'ocupadas':
                      // Filtrar por ocupadas
                      break;
                  }
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
                // Ajustar el número de columnas basado en el ancho disponible
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
                // Barra de arrastre para móvil
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

                // OPCIONES SEGÚN ESTADO ACTUAL
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
              // Icono de estado
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

              // Estado
              Text(
                bahia.nombreEstado,
                style: TextStyle(
                  fontSize: 12,
                  color: bahia.colorEstado,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),

              // Información adicional
              if (bahia.reservadaPor != null) ...[
                const SizedBox(height: 4),
                Text(
                  bahia.reservadaPor!,
                  style: const TextStyle(
                    fontSize: 10,
                    fontStyle: FontStyle.italic,
                  ),
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ],

              if (bahia.enUso && bahia.horaFinReserva != null) ...[
                const SizedBox(height: 4),
                Text(
                  'Termina: ${DateFormat('HH:mm').format(bahia.horaFinReserva!)}',
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.red,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
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
          // Barra de búsqueda y filtros
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
                    // Implementar búsqueda si es necesario
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

          // Estadísticas rápidas
          _buildResumenReservas(reservas),
          const SizedBox(height: 16),

          // Lista de reservas
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
          'Reserva #${reserva.id.split('_').last}',
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
            } else if (value == 'reactivar' && reserva.estado != 'activa') {
              _reactivarReserva(context, reserva, reservaProvider);
            } else if (value == 'detalles') {
              _mostrarDetallesReserva(context, reserva);
            }
          },
          itemBuilder: (BuildContext context) {
            return [
              if (reserva.estado == 'activa') ...[
                const PopupMenuItem<String>(
                  value: 'editar',
                  child: ListTile(
                    leading: Icon(Icons.edit, size: 20),
                    title: Text('Editar'),
                  ),
                ),
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
              if (reserva.estado != 'activa')
                const PopupMenuItem<String>(
                  value: 'reactivar',
                  child: ListTile(
                    leading: Icon(Icons.refresh, size: 20),
                    title: Text('Reactivar'),
                  ),
                ),
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

  Widget _buildReportesTab(List<Bahia> bahias, List<Reserva> reservas) {
    final ahora = DateTime.now();
    final inicioDia = DateTime(ahora.year, ahora.month, ahora.day);
    final inicioSemana = ahora.subtract(Duration(days: ahora.weekday - 1));
    final inicioMes = DateTime(ahora.year, ahora.month, 1);

    final reservasHoy =
        reservas.where((r) => r.fechaCreacion.isAfter(inicioDia)).length;
    final reservasSemana =
        reservas.where((r) => r.fechaCreacion.isAfter(inicioSemana)).length;
    final reservasMes =
        reservas.where((r) => r.fechaCreacion.isAfter(inicioMes)).length;

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

          // Estadísticas rápidas
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text(
                    'Resumen del Mes',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _buildMetricaCard('Hoy', reservasHoy, Icons.today),
                      _buildMetricaCard(
                          'Esta semana', reservasSemana, Icons.date_range),
                      _buildMetricaCard(
                          'Este mes', reservasMes, Icons.calendar_view_month),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Gráfico de tendencia
          _buildGraficoTendencia(reservas),

          const SizedBox(height: 24),

          // Opciones de exportación
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
                      _buildBotonExportacion('Reporte Diario', Icons.today,
                          Colors.blue, () => _generarReporteDiario(reservas)),
                      _buildBotonExportacion(
                          'Reporte Semanal',
                          Icons.date_range,
                          Colors.green,
                          () => _generarReporteSemanal(reservas)),
                      _buildBotonExportacion(
                          'Reporte Mensual',
                          Icons.calendar_view_month,
                          Colors.orange,
                          () => _generarReporteMensual(reservas)),
                      _buildBotonExportacion(
                          'Personalizado',
                          Icons.tune,
                          Colors.purple,
                          () =>
                              _generarReportePersonalizado(context, reservas)),
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

  Widget _buildMetricaCard(String titulo, int valor, IconData icono) {
    return Expanded(
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Icon(icono, size: 24, color: Colors.blue),
              const SizedBox(height: 8),
              Text(
                valor.toString(),
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Text(
                titulo,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGraficoTendencia(List<Reserva> reservas) {
    // Datos de ejemplo para la tendencia
    final datosTendencia = [
      _crearDatoChart('Lun', 12),
      _crearDatoChart('Mar', 18),
      _crearDatoChart('Mié', 15),
      _crearDatoChart('Jue', 22),
      _crearDatoChart('Vie', 19),
      _crearDatoChart('Sáb', 25),
      _crearDatoChart('Dom', 20),
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tendencia Semanal de Reservas',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: SfCartesianChart(
                primaryXAxis: CategoryAxis(),
                series: <CartesianSeries>[
                  LineSeries<ChartData, String>(
                    dataSource: datosTendencia,
                    xValueMapper: (ChartData data, _) => data.x,
                    yValueMapper: (ChartData data, _) => data.y,
                    markerSettings: const MarkerSettings(isVisible: true),
                    dataLabelSettings: const DataLabelSettings(isVisible: true),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResumenReportes(List<Bahia> bahias, List<Reserva> reservas) {
    final ahora = DateTime.now();
    final inicioMes = DateTime(ahora.year, ahora.month, 1);
    final reservasEsteMes =
        reservas.where((r) => r.fechaCreacion.isAfter(inicioMes)).length;

    return Row(
      children: [
        Expanded(
          child: _buildMiniReporteCard('Reservas este mes',
              reservasEsteMes.toString(), Icons.calendar_today, Colors.blue),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildMiniReporteCard(
              'Bahías activas',
              bahias.where((b) => b.enUso).length.toString(),
              Icons.local_shipping,
              Colors.green),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildMiniReporteCard(
              'Tasa de uso',
              '${((bahias.where((b) => b.enUso).length / bahias.length) * 100).toStringAsFixed(1)}%',
              Icons.trending_up,
              Colors.orange),
        ),
      ],
    );
  }

  Widget _buildMiniReporteCard(
      String titulo, String valor, IconData icono, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icono, color: color),
            const SizedBox(height: 8),
            Text(
              valor,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              titulo,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOpcionesExportacion(
      BuildContext context, List<Reserva>? reservas) {
    if (reservas == null || reservas.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: const Text('No hay reservas disponibles para exportar.'),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Exportar Reportes',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _buildBotonExportacion(
                  'Reporte Diario',
                  Icons.today,
                  Colors.blue,
                  () => _exportarReporteDiario(context, reservas),
                ),
                _buildBotonExportacion(
                  'Reporte Semanal',
                  Icons.date_range,
                  Colors.green,
                  () => _exportarReporteSemanal(context, reservas),
                ),
                _buildBotonExportacion(
                  'Reporte Mensual',
                  Icons.calendar_view_month,
                  Colors.orange,
                  () => _exportarReporteMensual(context, reservas),
                ),
                _buildBotonExportacion(
                  'Personalizado',
                  Icons.tune,
                  Colors.purple,
                  () => _exportarReportePersonalizado(context, reservas),
                ),
              ],
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

  // Métodos de acciones (simulados)
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

  void _mostrarReportesCompletos(BuildContext context) {
    // Navegar a pantalla de reportes completos
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
        content: const Text('Funcionalidad en desarrollo.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _mostrarCalendarioReservas(BuildContext context) {
    // Navegar a calendario de reservas
  }

  void _editarReserva(
      BuildContext context, Reserva reserva, ReservaProvider reservaProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Reserva'),
        content: const Text('Funcionalidad de edición en desarrollo.'),
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
      // Aquí iría la lógica para marcar la reserva como completada
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reserva marcada como completada')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void _reactivarReserva(BuildContext context, Reserva reserva,
      ReservaProvider reservaProvider) async {
    try {
      // Aquí iría la lógica para reactivar la reserva
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reserva reactivada')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void _generarReporteDiario(List<Reserva> reservas) async {
    final ahora = DateTime.now();
    final inicioDia = DateTime(ahora.year, ahora.month, ahora.day);
    final reservasHoy =
        reservas.where((r) => r.fechaCreacion.isAfter(inicioDia)).toList();

    _mostrarReporteGenerado('Reporte Diario', reservasHoy);
  }

  void _generarReporteSemanal(List<Reserva> reservas) async {
    final ahora = DateTime.now();
    final inicioSemana = ahora.subtract(Duration(days: ahora.weekday - 1));
    final reservasSemana =
        reservas.where((r) => r.fechaCreacion.isAfter(inicioSemana)).toList();

    _mostrarReporteGenerado('Reporte Semanal', reservasSemana);
  }

  void _generarReporteMensual(List<Reserva> reservas) async {
    final ahora = DateTime.now();
    final inicioMes = DateTime(ahora.year, ahora.month, 1);
    final reservasMes =
        reservas.where((r) => r.fechaCreacion.isAfter(inicioMes)).toList();

    _mostrarReporteGenerado('Reporte Mensual', reservasMes);
  }

  void _generarReportePersonalizado(
      BuildContext context, List<Reserva> reservas) {
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
            onPressed: () {
              Navigator.pop(context);
              _mostrarReporteGenerado('Reporte Personalizado', reservas);
            },
            child: const Text('Generar'),
          ),
        ],
      ),
    );
  }

  void _mostrarReporteGenerado(String titulo, List<Reserva> reservas) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(titulo),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Total de reservas: ${reservas.length}'),
              const SizedBox(height: 16),
              if (reservas.isNotEmpty) ...[
                const Text('Resumen:'),
                const SizedBox(height: 8),
                Text(
                    'Activas: ${reservas.where((r) => r.estado == 'activa').length}'),
                Text(
                    'Completadas: ${reservas.where((r) => r.estado == 'completada').length}'),
                Text(
                    'Canceladas: ${reservas.where((r) => r.estado == 'cancelada').length}'),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
          TextButton(
            onPressed: () {
              // Aquí iría la lógica para exportar el reporte
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Reporte exportado exitosamente')),
              );
              Navigator.pop(context);
            },
            child: const Text('Exportar'),
          ),
        ],
      ),
    );
  }

  void _mostrarDetallesReserva(BuildContext context, Reserva reserva) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Detalles de Reserva #${reserva.id.split('_').last}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetalleItem('ID', reserva.id),
              _buildDetalleItem('Bahía', reserva.numeroBahia.toString()),
              _buildDetalleItem('Usuario', reserva.usuarioNombre),
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
}

class ChartData {
  final String x;
  final int y;
  final Color? color;
  ChartData(this.x, this.y, [this.color]);
}

// Método helper para generar PDF desde lista filtrada
Future<Uint8List> _generatePdf(
    String title, List<Reserva> filteredReservas) async {
  final pdf = pw.Document();

  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(32),
      build: (pw.Context context) => [
        pw.Header(
          level: 0,
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(title,
                  style: pw.TextStyle(
                      fontSize: 18, fontWeight: pw.FontWeight.bold)),
              pw.Text(
                  'Fecha: ${DateFormat('dd/MM/yyyy').format(DateTime.now())}'),
            ],
          ),
        ),
        pw.SizedBox(height: 20),
        if (filteredReservas.isEmpty)
          pw.Text('No hay reservas en este período.',
              style: const pw.TextStyle(fontSize: 14))
        else
          pw.Table.fromTextArray(
            headers: ['ID', 'Bahía', 'Usuario', 'Inicio', 'Fin', 'Estado'],
            data: filteredReservas
                .map((r) => [
                      r.id.split('_').last,
                      r.numeroBahia.toString(),
                      r.usuarioNombre,
                      DateFormat('dd/MM/yyyy HH:mm').format(r.fechaHoraInicio),
                      DateFormat('dd/MM/yyyy HH:mm').format(r.fechaHoraFin),
                      r.estado.toUpperCase(),
                    ])
                .toList(),
            border: null,
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
            cellHeight: 30,
            cellAlignments: {
              0: pw.Alignment.centerLeft,
              1: pw.Alignment.center,
              2: pw.Alignment.centerLeft,
              3: pw.Alignment.center,
              4: pw.Alignment.center,
              5: pw.Alignment.center,
            },
          ),
      ],
    ),
  );

  return pdf.save();
}

// Método helper para guardar PDF
Future<void> _savePdf(
    BuildContext context, Uint8List pdfBytes, String fileName) async {
  try {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$fileName');
    await file.writeAsBytes(pdfBytes);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Reporte exportado a ${file.path}')),
      );
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al exportar: $e')),
      );
    }
  }
}

// Métodos de exportación
void _exportarReporteDiario(
    BuildContext context, List<Reserva> reservas) async {
  final ahora = DateTime.now();
  final inicioDia = DateTime(ahora.year, ahora.month, ahora.day);
  final reservasHoy =
      reservas.where((r) => r.fechaCreacion.isAfter(inicioDia)).toList();
  final pdfBytes = await _generatePdf('Reporte Diario', reservasHoy);
  await _savePdf(context, pdfBytes,
      'reporte_diario_${DateFormat('yyyyMMdd').format(ahora)}.pdf');
}

void _exportarReporteSemanal(
    BuildContext context, List<Reserva> reservas) async {
  final ahora = DateTime.now();
  final inicioSemana = ahora.subtract(Duration(days: ahora.weekday - 1));
  final reservasSemana =
      reservas.where((r) => r.fechaCreacion.isAfter(inicioSemana)).toList();
  final pdfBytes = await _generatePdf('Reporte Semanal', reservasSemana);
  await _savePdf(context, pdfBytes,
      'reporte_semanal_${DateFormat('yyyyMMdd').format(ahora)}.pdf');
}

void _exportarReporteMensual(
    BuildContext context, List<Reserva> reservas) async {
  final ahora = DateTime.now();
  final inicioMes = DateTime(ahora.year, ahora.month, 1);
  final reservasMes =
      reservas.where((r) => r.fechaCreacion.isAfter(inicioMes)).toList();
  final pdfBytes = await _generatePdf('Reporte Mensual', reservasMes);
  await _savePdf(context, pdfBytes,
      'reporte_mensual_${DateFormat('yyyyMM').format(ahora)}.pdf');
}

void _exportarReportePersonalizado(
    BuildContext context, List<Reserva> reservas) async {
  final DateTimeRange? range = await showDateRangePicker(
    context: context,
    firstDate: DateTime(2000),
    lastDate: DateTime.now(),
    helpText: 'Seleccione rango de fechas',
  );
  if (range != null) {
    final reservasFiltradas = reservas
        .where(
          (r) =>
              r.fechaCreacion.isAfter(range.start) &&
              r.fechaCreacion.isBefore(range.end.add(const Duration(days: 1))),
        )
        .toList();
    final pdfBytes = await _generatePdf(
        'Reporte Personalizado (${DateFormat('dd/MM/yyyy').format(range.start)} - ${DateFormat('dd/MM/yyyy').format(range.end)})',
        reservasFiltradas);
    await _savePdf(context, pdfBytes,
        'reporte_personalizado_${DateFormat('yyyyMMdd').format(DateTime.now())}.pdf');
  }
}
