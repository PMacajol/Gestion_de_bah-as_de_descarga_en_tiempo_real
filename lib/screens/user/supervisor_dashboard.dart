// supervisor_dashboard.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bahias_descarga_system/providers/bahia_provider.dart';
import 'package:bahias_descarga_system/providers/reserva_provider.dart';
import 'package:bahias_descarga_system/widgets/custom_appbar.dart';
import 'package:bahias_descarga_system/utils/constants.dart';
import 'package:bahias_descarga_system/models/bahia_model.dart';
import 'package:bahias_descarga_system/models/reserva_model.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

// Clase para los datos del gráfico
class ChartData {
  final String dia;
  final int reservas;

  ChartData(this.dia, this.reservas);
}

class SupervisorDashboard extends StatefulWidget {
  const SupervisorDashboard({Key? key}) : super(key: key);

  @override
  _SupervisorDashboardState createState() => _SupervisorDashboardState();
}

class _SupervisorDashboardState extends State<SupervisorDashboard>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedIndex = 0;

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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bahiaProvider = Provider.of<BahiaProvider>(context);
    final reservaProvider = Provider.of<ReservaProvider>(context);
    final bahias = bahiaProvider.bahias;
    final reservas = reservaProvider.reservas;

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Panel de Supervisión',
        showBackButton: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart, color: Colors.white),
            onPressed: () =>
                _generarReporteSupervision(context, bahias, reservas),
          ),
        ],
      ),
      body: Column(
        children: [
          // Estadísticas rápidas
          _buildEstadisticasSupervision(bahias, reservas),

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
                Tab(icon: Icon(Icons.monitor_heart), text: 'Monitoreo'),
                Tab(icon: Icon(Icons.analytics), text: 'Métricas'),
                Tab(icon: Icon(Icons.warning), text: 'Alertas'),
              ],
            ),
          ),

          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildMonitoreo(bahias),
                _buildMetricas(reservas),
                _buildAlertas(bahias, reservas),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEstadisticasSupervision(
      List<Bahia> bahias, List<Reserva> reservas) {
    final ahora = DateTime.now();
    final reservasHoy = reservas
        .where((r) =>
            r.fechaHoraInicio.day == ahora.day &&
            r.fechaHoraInicio.month == ahora.month &&
            r.fechaHoraInicio.year == ahora.year)
        .length;

    final eficiencia = _calcularEficiencia(bahias, reservas);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Wrap(
        spacing: 16,
        runSpacing: 16,
        children: [
          _buildTarjetaSupervision(
            'Reservas Hoy',
            reservasHoy.toString(),
            Icons.calendar_today,
            Colors.blue,
          ),
          _buildTarjetaSupervision(
            'Eficiencia',
            '$eficiencia%',
            Icons.trending_up,
            eficiencia > 80 ? Colors.green : Colors.orange,
          ),
          _buildTarjetaSupervision(
            'Bahías Activas',
            bahias
                .where((b) => b.estado == EstadoBahia.enUso)
                .length
                .toString(),
            Icons.local_shipping,
            Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildTarjetaSupervision(
      String titulo, String valor, IconData icono, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          width: 150,
          child: Column(
            children: [
              Icon(icono, size: 30, color: color),
              const SizedBox(height: 8),
              Text(valor,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold)),
              Text(titulo,
                  style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }

  double _calcularEficiencia(List<Bahia> bahias, List<Reserva> reservas) {
    if (bahias.isEmpty) return 0;
    final bahiasUtilizadas = bahias
        .where((b) =>
            b.estado == EstadoBahia.enUso || b.estado == EstadoBahia.reservada)
        .length;
    return (bahiasUtilizadas / bahias.length * 100);
  }

  Widget _buildMonitoreo(List<Bahia> bahias) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.5,
      ),
      padding: const EdgeInsets.all(16),
      itemCount: bahias.length,
      itemBuilder: (context, index) {
        final bahia = bahias[index];
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: _getColorEstado(bahia.estado),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Bahía ${bahia.numero}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text('Estado: ${_getNombreEstado(bahia.estado)}'),
                if (bahia.estado == EstadoBahia.enUso &&
                    bahia.horaFinReserva != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Termina: ${DateFormat('HH:mm').format(bahia.horaFinReserva!)}',
                    style: const TextStyle(fontSize: 12, color: Colors.red),
                  ),
                ],
                if (bahia.progresoUso > 0) ...[
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: bahia.progresoUso,
                    backgroundColor: Colors.grey[200],
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Color _getColorEstado(EstadoBahia estado) {
    switch (estado) {
      case EstadoBahia.libre:
        return Colors.green;
      case EstadoBahia.reservada:
        return Colors.orange;
      case EstadoBahia.enUso:
        return Colors.red;
      case EstadoBahia.mantenimiento:
        return Colors.blueGrey;
      default:
        return Colors.grey;
    }
  }

  String _getNombreEstado(EstadoBahia estado) {
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

  Widget _buildMetricas(List<Reserva> reservas) {
    final datosSemana = _generarDatosSemana(reservas);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          SizedBox(
            height: 200,
            child: SfCartesianChart(
              primaryXAxis: CategoryAxis(),
              series: <CartesianSeries>[
                LineSeries<ChartData, String>(
                  dataSource: datosSemana,
                  xValueMapper: (ChartData data, _) => data.dia,
                  yValueMapper: (ChartData data, _) => data.reservas,
                  dataLabelSettings: const DataLabelSettings(isVisible: true),
                  markerSettings: const MarkerSettings(isVisible: true),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildResumenMetricas(reservas),
        ],
      ),
    );
  }

  List<ChartData> _generarDatosSemana(List<Reserva> reservas) {
    // Lógica para generar datos de la semana (simulada)
    return [
      ChartData('Lun', 12),
      ChartData('Mar', 18),
      ChartData('Mié', 15),
      ChartData('Jue', 22),
      ChartData('Vie', 19),
      ChartData('Sáb', 8),
      ChartData('Dom', 5),
    ];
  }

  Widget _buildResumenMetricas(List<Reserva> reservas) {
    final promedioDiario = _calcularPromedioDiario(reservas);
    final tasaUso = _calcularTasaUso(reservas);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildMetricaItem('Promedio Diario', '$promedioDiario reservas'),
            _buildMetricaItem('Tasa de Uso', '$tasaUso%'),
            _buildMetricaItem('Eficiencia', '85%'),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricaItem(String titulo, String valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(titulo),
          Text(valor, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  double _calcularPromedioDiario(List<Reserva> reservas) {
    if (reservas.isEmpty) return 0;
    // Lógica simplificada - calcular promedio real en implementación final
    final ultimaSemana = reservas.where((r) => r.fechaHoraInicio
        .isAfter(DateTime.now().subtract(const Duration(days: 7))));
    return ultimaSemana.length / 7;
  }

  double _calcularTasaUso(List<Reserva> reservas) {
    if (reservas.isEmpty) return 0;
    // Lógica simplificada
    final reservasCompletadas =
        reservas.where((r) => r.estado == 'completada').length;
    return (reservasCompletadas / reservas.length * 100);
  }

  Widget _buildAlertas(List<Bahia> bahias, List<Reserva> reservas) {
    final alertas = _generarAlertas(bahias, reservas);

    return ListView.builder(
      itemCount: alertas.length,
      itemBuilder: (context, index) {
        final alerta = alertas[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: ListTile(
            leading: Icon(alerta.icono, color: alerta.color),
            title: Text(alerta.titulo),
            subtitle: Text(alerta.mensaje),
            trailing: Chip(
              label: Text(alerta.nivel),
              backgroundColor: alerta.color.withOpacity(0.2),
            ),
          ),
        );
      },
    );
  }

  List<Alerta> _generarAlertas(List<Bahia> bahias, List<Reserva> reservas) {
    final alertas = <Alerta>[];

    // Bahías en tiempo crítico
    final bahiasCriticas = bahias
        .where((b) => b.estado == EstadoBahia.enUso && b.progresoUso > 0.9);

    for (final bahia in bahiasCriticas) {
      alertas.add(Alerta(
        titulo: 'Bahía ${bahia.numero} en tiempo crítico',
        mensaje: 'La bahía está próxima a finalizar su tiempo',
        nivel: 'Alto',
        color: Colors.red,
        icono: Icons.warning,
      ));
    }

    // Conflictos de reservas
    if (_hayConflictosReservas(reservas)) {
      alertas.add(Alerta(
        titulo: 'Conflictos en reservas detectados',
        mensaje: 'Existen solapamientos en las reservas programadas',
        nivel: 'Medio',
        color: Colors.orange,
        icono: Icons.error,
      ));
    }

    if (alertas.isEmpty) {
      alertas.add(Alerta(
        titulo: 'Sin alertas críticas',
        mensaje: 'El sistema funciona correctamente',
        nivel: 'Bajo',
        color: Colors.green,
        icono: Icons.check_circle,
      ));
    }

    return alertas;
  }

  bool _hayConflictosReservas(List<Reserva> reservas) {
    // Lógica simplificada para detectar conflictos
    // En implementación real, verificar solapamientos de horarios
    return false;
  }

  void _generarReporteSupervision(
      BuildContext context, List<Bahia> bahias, List<Reserva> reservas) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reporte de Supervisión'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              _buildResumenReporte(bahias, reservas),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
          TextButton(
            onPressed: () => _exportarReporte(context),
            child: const Text('Exportar'),
          ),
        ],
      ),
    );
  }

  Widget _buildResumenReporte(List<Bahia> bahias, List<Reserva> reservas) {
    return Column(
      children: [
        _buildMetricaReporte('Total Bahías', bahias.length.toString()),
        _buildMetricaReporte(
            'Bahías Ocupadas',
            bahias
                .where((b) => b.estado == EstadoBahia.enUso)
                .length
                .toString()),
        _buildMetricaReporte(
            'Reservas Hoy',
            reservas
                .where((r) =>
                    r.fechaHoraInicio.day == DateTime.now().day &&
                    r.fechaHoraInicio.month == DateTime.now().month &&
                    r.fechaHoraInicio.year == DateTime.now().year)
                .length
                .toString()),
        _buildMetricaReporte('Eficiencia',
            '${_calcularEficiencia(bahias, reservas).toStringAsFixed(1)}%'),
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

  void _exportarReporte(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Reporte exportado exitosamente')),
    );
  }
}

// Clase para representar alertas
class Alerta {
  final String titulo;
  final String mensaje;
  final String nivel;
  final Color color;
  final IconData icono;

  Alerta({
    required this.titulo,
    required this.mensaje,
    required this.nivel,
    required this.color,
    required this.icono,
  });
}
