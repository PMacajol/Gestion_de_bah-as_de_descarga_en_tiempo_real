// screens/planificador/planificador_dashboard.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bahias_descarga_system/providers/bahia_provider.dart';
import 'package:bahias_descarga_system/providers/reserva_provider.dart';
import 'package:bahias_descarga_system/widgets/custom_appbar.dart';
import 'package:bahias_descarga_system/utils/constants.dart';
import 'package:bahias_descarga_system/models/bahia_model.dart';
import 'package:bahias_descarga_system/models/reserva_model.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class PlanificadorDashboard extends StatefulWidget {
  const PlanificadorDashboard({super.key});

  @override
  _PlanificadorDashboardState createState() => _PlanificadorDashboardState();
}

class _PlanificadorDashboardState extends State<PlanificadorDashboard>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedIndex = 0;
  DateTime _fechaSeleccionada = DateTime.now();
  CalendarView _calendarView = CalendarView.day;
  final CalendarController _calendarController = CalendarController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedIndex = _tabController.index;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _calendarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reservaProvider = Provider.of<ReservaProvider>(context);
    final bahiaProvider = Provider.of<BahiaProvider>(context);
    final reservas = reservaProvider.reservas;
    final bahias = bahiaProvider.bahias;

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Panel de Planificación',
        showBackButton: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.today, color: Colors.white),
            onPressed: () => _irAHoy(),
          ),
          IconButton(
            icon: const Icon(Icons.bar_chart, color: Colors.white),
            onPressed: () => _mostrarReportesPlanificacion(context, reservas),
          ),
          if (_selectedIndex == 0)
            PopupMenuButton<CalendarView>(
              icon: const Icon(Icons.view_week, color: Colors.white),
              onSelected: (view) {
                setState(() {
                  _calendarView = view;
                  _calendarController.view = view;
                });
              },
              itemBuilder: (BuildContext context) => [
                const PopupMenuItem(
                  value: CalendarView.day,
                  child: Text('Vista Diaria'),
                ),
                const PopupMenuItem(
                  value: CalendarView.week,
                  child: Text('Vista Semanal'),
                ),
                const PopupMenuItem(
                  value: CalendarView.month,
                  child: Text('Vista Mensual'),
                ),
              ],
            ),
        ],
      ),
      body: Column(
        children: [
          // Selector de fecha mejorado
          _buildSelectorFechaMejorado(),

          // Pestañas
          Container(
            color: Colors.grey[100],
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              indicatorColor: AppColors.primary,
              labelColor: AppColors.primary,
              unselectedLabelColor: Colors.grey,
              tabs: const [
                Tab(icon: Icon(Icons.calendar_today), text: 'Calendario'),
                Tab(icon: Icon(Icons.list), text: 'Reservas'),
                Tab(icon: Icon(Icons.analytics), text: 'Disponibilidad'),
              ],
            ),
          ),

          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildCalendarioDinamico(reservas),
                _buildListaReservasMejorada(
                    reservas, reservaProvider, bahiaProvider),
                _buildDisponibilidadMejorada(bahias, reservas),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _selectedIndex == 1
          ? FloatingActionButton(
              onPressed: () {
                final bahiaProvider =
                    Provider.of<BahiaProvider>(context, listen: false);
                final bahias = bahiaProvider.bahias;
                _crearReserva(context, bahias);
              },
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildSelectorFechaMejorado() {
    return Card(
      margin: const EdgeInsets.all(12),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blue.shade50, Colors.white],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.calendar_today, color: Colors.white),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _formatearFecha(_fechaSeleccionada),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    Text(
                      '${_contarReservasDelDia(Provider.of<ReservaProvider>(context).reservas, _fechaSeleccionada)} reservas programadas',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_back_ios, size: 16),
                    ),
                    onPressed: () => _cambiarFecha(-1),
                  ),
                  IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_forward_ios, size: 16),
                    ),
                    onPressed: () => _cambiarFecha(1),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCalendarioDinamico(List<Reserva> reservas) {
    return Column(
      children: [
        // Selector de vista rápida
        _buildSelectorVistaCalendario(),

        // Calendario interactivo
        Expanded(
          child: Card(
            margin: const EdgeInsets.all(12),
            elevation: 4,
            child: SfCalendar(
              controller: _calendarController,
              view: _calendarView,
              initialDisplayDate: _fechaSeleccionada,
              initialSelectedDate: _fechaSeleccionada,
              dataSource:
                  _ReservaDataSource(_convertirReservasAEventos(reservas)),
              onTap: (CalendarTapDetails details) {
                if (details.targetElement == CalendarElement.calendarCell) {
                  setState(() {
                    _fechaSeleccionada = details.date!;
                  });
                }
              },
              onViewChanged: (ViewChangedDetails details) {
                // Actualizar la fecha seleccionada cuando cambia la vista
                if (_calendarView == CalendarView.month) {
                  setState(() {
                    _fechaSeleccionada =
                        details.visibleDates[details.visibleDates.length ~/ 2];
                  });
                }
              },
              monthViewSettings: const MonthViewSettings(
                showAgenda: true,
                agendaStyle: AgendaStyle(
                  backgroundColor: Colors.white,
                  appointmentTextStyle: TextStyle(fontSize: 12),
                ),
              ),
              appointmentBuilder: (context, details) {
                final reserva = details.appointments.first as _ReservaEvento;
                return Container(
                  decoration: BoxDecoration(
                    color: _obtenerColorEstado(reserva.estado),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Center(
                    child: Text(
                      'Bahía ${reserva.numeroBahia}\n${reserva.usuarioNombre}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                );
              },
            ),
          ),
        ),

        // Resumen rápido del día
        _buildResumenDia(reservas),
      ],
    );
  }

  Widget _buildSelectorVistaCalendario() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildBotonVista('Día', CalendarView.day, Icons.view_day),
          _buildBotonVista('Semana', CalendarView.week, Icons.view_week),
          _buildBotonVista(
              'Mes', CalendarView.month, Icons.calendar_view_month),
        ],
      ),
    );
  }

  Widget _buildBotonVista(String texto, CalendarView vista, IconData icono) {
    final bool estaSeleccionado = _calendarView == vista;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: ElevatedButton.icon(
        onPressed: () {
          setState(() {
            _calendarView = vista;
            _calendarController.view = vista;
          });
        },
        icon: Icon(icono, size: 16),
        label: Text(texto),
        style: ElevatedButton.styleFrom(
          backgroundColor:
              estaSeleccionado ? AppColors.primary : Colors.grey[300],
          foregroundColor: estaSeleccionado ? Colors.white : Colors.grey[700],
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
      ),
    );
  }

  Widget _buildResumenDia(List<Reserva> reservas) {
    final reservasDelDia = reservas.where((reserva) {
      final fechaReserva = DateTime(
        reserva.fechaHoraInicio.year,
        reserva.fechaHoraInicio.month,
        reserva.fechaHoraInicio.day,
      );
      final fechaSeleccionada = DateTime(
        _fechaSeleccionada.year,
        _fechaSeleccionada.month,
        _fechaSeleccionada.day,
      );
      return fechaReserva == fechaSeleccionada;
    }).toList();

    return Card(
      margin: const EdgeInsets.all(12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            const Icon(Icons.info, color: Colors.blue),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Resumen del ${DateFormat('dd/MM').format(_fechaSeleccionada)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    '${reservasDelDia.length} reservas programadas',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Chip(
              label: Text(
                reservasDelDia.isEmpty ? 'Libre' : 'Ocupado',
                style: const TextStyle(fontSize: 10, color: Colors.white),
              ),
              backgroundColor:
                  reservasDelDia.isEmpty ? Colors.green : Colors.orange,
            ),
          ],
        ),
      ),
    );
  }

  List<_ReservaEvento> _convertirReservasAEventos(List<Reserva> reservas) {
    return reservas
        .map((reserva) => _ReservaEvento(
              reserva.id,
              reserva.numeroBahia,
              reserva.usuarioNombre,
              reserva.fechaHoraInicio,
              reserva.fechaHoraFin,
              reserva.estado,
            ))
        .toList();
  }

  Color _obtenerColorEstado(String estado) {
    switch (estado) {
      case 'activa':
        return Colors.green;
      case 'completada':
        return Colors.blue;
      case 'cancelada':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget _buildListaReservasMejorada(List<Reserva> reservas,
      ReservaProvider reservaProvider, BahiaProvider bahiaProvider) {
    final reservasDelDia = reservas.where((reserva) {
      final fechaReserva = DateTime(
        reserva.fechaHoraInicio.year,
        reserva.fechaHoraInicio.month,
        reserva.fechaHoraInicio.day,
      );
      final fechaSeleccionada = DateTime(
        _fechaSeleccionada.year,
        _fechaSeleccionada.month,
        _fechaSeleccionada.day,
      );
      return fechaReserva == fechaSeleccionada;
    }).toList();

    // Ordenar por hora de inicio
    reservasDelDia
        .sort((a, b) => a.fechaHoraInicio.compareTo(b.fechaHoraInicio));

    if (reservasDelDia.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            const Text(
              'No hay reservas para este día',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () => _crearReserva(context, bahiaProvider.bahias),
              icon: const Icon(Icons.add),
              label: const Text('Crear Primera Reserva'),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Header con estadísticas
        _buildHeaderReservas(reservasDelDia),

        // Lista de reservas
        Expanded(
          child: ListView.builder(
            itemCount: reservasDelDia.length,
            itemBuilder: (context, index) {
              final reserva = reservasDelDia[index];
              return _buildTarjetaReservaMejorada(
                  reserva, reservaProvider, bahiaProvider);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderReservas(List<Reserva> reservasDelDia) {
    final reservasActivas =
        reservasDelDia.where((r) => r.estado == 'activa').length;
    final reservasCompletadas =
        reservasDelDia.where((r) => r.estado == 'completada').length;

    return Card(
      margin: const EdgeInsets.all(12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildEstadisticaReserva(
                'Total', reservasDelDia.length, Icons.list),
            _buildEstadisticaReserva(
                'Activas', reservasActivas, Icons.access_time),
            _buildEstadisticaReserva(
                'Completadas', reservasCompletadas, Icons.check_circle),
          ],
        ),
      ),
    );
  }

  Widget _buildEstadisticaReserva(String titulo, int valor, IconData icono) {
    return Column(
      children: [
        Icon(icono, color: Colors.blue, size: 20),
        const SizedBox(height: 4),
        Text(
          valor.toString(),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        Text(
          titulo,
          style: const TextStyle(fontSize: 10, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildTarjetaReservaMejorada(Reserva reserva,
      ReservaProvider reservaProvider, BahiaProvider bahiaProvider) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(
              color: _obtenerColorEstado(reserva.estado),
              width: 6,
            ),
          ),
        ),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: _obtenerColorEstado(reserva.estado),
            child: Text(
              reserva.numeroBahia.toString(),
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          title: Text(
            'Bahía ${reserva.numeroBahia}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Usuario: ${reserva.usuarioNombre}'),
              Text(
                  '${_formatearHora(reserva.fechaHoraInicio)} - ${_formatearHora(reserva.fechaHoraFin)}'),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.access_time, size: 12, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    reserva.duracion,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
          trailing: PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) => _manejarOpcionReserva(
                value, reserva, reservaProvider, bahiaProvider),
            itemBuilder: (BuildContext context) => [
              PopupMenuItem(
                value: 'editar',
                child: Row(
                  children: const [
                    Icon(Icons.edit, size: 16),
                    SizedBox(width: 8),
                    Text('Editar'),
                  ],
                ),
              ),
              if (reserva.estado == 'activa')
                PopupMenuItem(
                  value: 'cancelar',
                  child: Row(
                    children: const [
                      Icon(Icons.cancel, size: 16, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Cancelar'),
                    ],
                  ),
                ),
              PopupMenuItem(
                value: 'detalles',
                child: Row(
                  children: const [
                    Icon(Icons.info, size: 16),
                    SizedBox(width: 8),
                    Text('Detalles'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _manejarOpcionReserva(String opcion, Reserva reserva,
      ReservaProvider reservaProvider, BahiaProvider bahiaProvider) {
    switch (opcion) {
      case 'editar':
        _editarReserva(context, reserva);
        break;
      case 'cancelar':
        _cancelarReserva(context, reserva, reservaProvider, bahiaProvider);
        break;
      case 'detalles':
        _mostrarDetallesReserva(context, reserva);
        break;
    }
  }

  Widget _buildDisponibilidadMejorada(
      List<Bahia> bahias, List<Reserva> reservas) {
    final bahiasLibres =
        bahias.where((b) => b.estado == EstadoBahia.libre).length;
    final porcentajeDisponibilidad =
        (bahiasLibres / bahias.length * 100).round();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tarjeta de disponibilidad general
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircularProgressIndicator(
                    value: porcentajeDisponibilidad / 100,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      porcentajeDisponibilidad > 50
                          ? Colors.green
                          : porcentajeDisponibilidad > 20
                              ? Colors.orange
                              : Colors.red,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$porcentajeDisponibilidad% Disponible',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text('$bahiasLibres de ${bahias.length} bahías libres'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Lista de bahías con estado
          Expanded(
            child: ListView(
              children: [
                const Text(
                  'Estado de Bahías',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...bahias.map((bahia) => _buildTarjetaBahia(bahia)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTarjetaBahia(Bahia bahia) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: bahia.colorEstado,
            shape: BoxShape.circle,
          ),
        ),
        title: Text('Bahía ${bahia.numero} - ${bahia.nombreTipo}'),
        subtitle: Text(bahia.nombreEstado),
        trailing: bahia.estado == EstadoBahia.libre
            ? const Icon(Icons.check_circle, color: Colors.green)
            : const Icon(Icons.do_not_disturb, color: Colors.red),
      ),
    );
  }

  String _formatearFecha(DateTime fecha) {
    try {
      return DateFormat('EEEE, d MMMM y', 'es_ES').format(fecha);
    } catch (e) {
      return '${fecha.day}/${fecha.month}/${fecha.year}';
    }
  }

  void _cambiarFecha(int dias) {
    setState(() {
      _fechaSeleccionada = _fechaSeleccionada.add(Duration(days: dias));
      _calendarController.displayDate = _fechaSeleccionada;
      _calendarController.selectedDate = _fechaSeleccionada;
    });
  }

  void _irAHoy() {
    setState(() {
      _fechaSeleccionada = DateTime.now();
      _calendarController.displayDate = _fechaSeleccionada;
      _calendarController.selectedDate = _fechaSeleccionada;
    });
  }

  int _contarReservasDelDia(List<Reserva> reservas, DateTime fecha) {
    return reservas.where((reserva) {
      return reserva.fechaHoraInicio.year == fecha.year &&
          reserva.fechaHoraInicio.month == fecha.month &&
          reserva.fechaHoraInicio.day == fecha.day;
    }).length;
  }

  String _formatearHora(DateTime fecha) {
    try {
      return DateFormat('HH:mm').format(fecha);
    } catch (e) {
      return '${fecha.hour}:${fecha.minute.toString().padLeft(2, '0')}';
    }
  }

  void _crearReserva(BuildContext context, List<Bahia> bahias) {
    final bahiasDisponibles =
        bahias.where((b) => b.estado == EstadoBahia.libre).toList();

    if (bahiasDisponibles.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('No hay bahías disponibles'),
          content:
              const Text('Todas las bahías están ocupadas o en mantenimiento.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Aceptar'),
            ),
          ],
        ),
      );
      return;
    }

    // CORRECCIÓN: Mostrar diálogo para seleccionar bahía
    _mostrarSelectorBahia(context, bahiasDisponibles);
  }

  void _mostrarSelectorBahia(
      BuildContext context, List<Bahia> bahiasDisponibles) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Seleccionar Bahía'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: bahiasDisponibles.length,
            itemBuilder: (context, index) {
              final bahia = bahiasDisponibles[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.blue,
                  child: Text(
                    bahia.numero.toString(),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                title: Text('Bahía ${bahia.numero}'),
                subtitle: Text(bahia.nombreTipo),
                onTap: () {
                  Navigator.pop(context); // Cerrar el diálogo de selección
                  _navegarAPantallaReserva(context, bahia);
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
  }

  void _navegarAPantallaReserva(BuildContext context, Bahia bahia) {
    // CORRECCIÓN: Navegar correctamente a la pantalla de reserva
    Navigator.pushNamed(
      context,
      '/reservation',
      arguments: bahia, // Pasar la bahía seleccionada como argumento
    ).then((_) {
      // Actualizar la UI cuando regrese de la pantalla de reserva
      if (mounted) {
        setState(() {});
      }
    });
  }

  void _editarReserva(BuildContext context, Reserva reserva) {
    // Primero necesitamos obtener la bahía asociada a esta reserva
    final bahiaProvider = Provider.of<BahiaProvider>(context, listen: false);
    final bahias = bahiaProvider.bahias;

    final bahiaAsociada = bahias.firstWhere(
      (bahia) => bahia.numero == reserva.numeroBahia,
      orElse: () => bahias.first, // Fallback si no encuentra la bahía
    );

    // Navegar a la pantalla de reserva con la bahía y los datos de la reserva
    Navigator.pushNamed(
      context,
      '/reservation',
      arguments: bahiaAsociada, // Pasar la bahía para la edición
    ).then((_) {
      // Actualizar la UI cuando regrese
      if (mounted) {
        setState(() {});
      }
    });
  }

  void _cancelarReserva(BuildContext context, Reserva reserva,
      ReservaProvider reservaProvider, BahiaProvider bahiaProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancelar Reserva'),
        content: Text(
            '¿Está seguro de cancelar la reserva de la Bahía ${reserva.numeroBahia}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No, mantener'),
          ),
          TextButton(
            onPressed: () async {
              try {
                // Mostrar indicador de carga
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => const Center(
                    child: CircularProgressIndicator(),
                  ),
                );

                // CORRECCIÓN: Cancelar la reserva usando el provider
                await reservaProvider.cancelarReserva(reserva.id);

                // Liberar la bahía asociada
                await bahiaProvider
                    .liberarBahia(reserva.numeroBahia.toString());

                // Cerrar el diálogo de carga
                Navigator.pop(context);

                // Cerrar el diálogo de confirmación
                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Reserva cancelada exitosamente'),
                    backgroundColor: Colors.green,
                  ),
                );

                // Actualizar la UI
                if (mounted) {
                  setState(() {});
                }
              } catch (e) {
                // Cerrar el diálogo de carga si hay error
                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error al cancelar: $e'),
                    backgroundColor: Colors.red,
                  ),
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

  void _mostrarDetallesReserva(BuildContext context, Reserva reserva) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Detalles de Reserva - Bahía ${reserva.numeroBahia}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetalleItem('Usuario', reserva.usuarioNombre),
              _buildDetalleItem('Bahía', reserva.numeroBahia.toString()),
              _buildDetalleItem('Estado', reserva.estado),
              _buildDetalleItem(
                  'Inicio',
                  DateFormat('dd/MM/yyyy HH:mm')
                      .format(reserva.fechaHoraInicio)),
              _buildDetalleItem('Fin',
                  DateFormat('dd/MM/yyyy HH:mm').format(reserva.fechaHoraFin)),
              _buildDetalleItem('Duración', reserva.duracion),
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
          Expanded(child: Text(valor)),
        ],
      ),
    );
  }

  void _mostrarReportesPlanificacion(
      BuildContext context, List<Reserva> reservas) {
    // Implementar reportes de planificación
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reportes de Planificación'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildMetricaReporte(
                  'Total Reservas', reservas.length.toString()),
              _buildMetricaReporte(
                  'Reservas Activas',
                  reservas
                      .where((r) => r.estado == 'activa')
                      .length
                      .toString()),
              _buildMetricaReporte(
                  'Reservas del Mes',
                  reservas
                      .where((r) =>
                          r.fechaHoraInicio.month == DateTime.now().month)
                      .length
                      .toString()),
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

  Widget _buildMetricaReporte(String titulo, String valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(titulo, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(valor, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _ReservaEvento {
  _ReservaEvento(
    this.id,
    this.numeroBahia,
    this.usuarioNombre,
    this.fechaInicio,
    this.fechaFin,
    this.estado,
  );

  final String id;
  final int numeroBahia;
  final String usuarioNombre;
  final DateTime fechaInicio;
  final DateTime fechaFin;
  final String estado;
}

class _ReservaDataSource extends CalendarDataSource {
  _ReservaDataSource(List<_ReservaEvento> source) {
    appointments = source;
  }

  @override
  DateTime getStartTime(int index) {
    return appointments![index].fechaInicio;
  }

  @override
  DateTime getEndTime(int index) {
    return appointments![index].fechaFin;
  }

  @override
  String getSubject(int index) {
    return 'Bahía ${appointments![index].numeroBahia}';
  }

  @override
  String getNotes(int index) {
    return appointments![index].usuarioNombre;
  }
}
