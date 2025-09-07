import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bahias_descarga_system/providers/bahia_provider.dart';
import 'package:bahias_descarga_system/providers/reserva_provider.dart';
import 'package:bahias_descarga_system/providers/auth_provider.dart';
import 'package:bahias_descarga_system/widgets/custom_appbar.dart';
import 'package:bahias_descarga_system/utils/constants.dart';
import 'package:bahias_descarga_system/utils/responsive.dart';
import 'package:bahias_descarga_system/models/bahia_model.dart';
import 'package:bahias_descarga_system/models/reserva_model.dart';
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

  @override
  void initState() {
    super.initState();
    final bahiaProvider = Provider.of<BahiaProvider>(context, listen: false);
    bahiaProvider.limpiarBusqueda();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _statsScrollController.dispose();
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
        title: AppStrings.dashboard,
        showBackButton: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.white),
            onPressed: () => _mostrarNotificaciones(context),
          ),
          if (authProvider.usuario?.esAdministrador ?? false)
            IconButton(
              icon: const Icon(Icons.admin_panel_settings, color: Colors.white),
              onPressed: () => Navigator.pushNamed(context, '/admin'),
            ),
        ],
      ),
      body: Column(
        children: [
          // Tarjetas de estadísticas con scroll horizontal en móvil
          _buildResponsiveStatsRow(totalBahias, bahiasLibres, bahiasOcupadas,
              bahiasReservadas, bahiasMantenimiento),

          // Barra de búsqueda y filtros optimizada para móvil
          _buildMobileSearchFilters(bahiaProvider),

          // Lista de bahías con lazy loading
          Expanded(
            child: _buildBahiasGrid(bahiaProvider, bahias),
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
          controller: _statsScrollController,
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
          runSpacing: 16, // ✅ corregido
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

  Widget _buildMobileSearchFilters(BahiaProvider bahiaProvider) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Barra de búsqueda
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
            onChanged: (value) {
              bahiaProvider.buscarBahias(value);
            },
          ),
          const SizedBox(height: 12),

          // Selector de filtros para móvil
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
            onChanged: (value) {
              setState(() {
                _filtroEstado = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBahiasGrid(BahiaProvider bahiaProvider, List<Bahia> bahias) {
    // Aplicar filtros
    List<Bahia> bahiasFiltradas = bahias;
    if (_filtroTipo != null) {
      bahiasFiltradas =
          bahiasFiltradas.where((b) => b.tipo == _filtroTipo).toList();
    }
    if (_filtroEstado != null) {
      bahiasFiltradas =
          bahiasFiltradas.where((b) => b.estado == _filtroEstado).toList();
    }

    // Lazy loading para móviles
    final displayedBahias = _loadedBahias < bahiasFiltradas.length
        ? bahiasFiltradas.sublist(0, _loadedBahias)
        : bahiasFiltradas;

    return NotificationListener<ScrollNotification>(
      onNotification: (scrollNotification) {
        if (scrollNotification is ScrollEndNotification &&
            scrollNotification.metrics.extentAfter == 0 &&
            _loadedBahias < bahiasFiltradas.length) {
          setState(() {
            _loadedBahias += 20;
          });
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
                style: const TextStyle(fontSize: 12, color: Colors.grey),
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
                  style: const TextStyle(fontSize: 10, color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // === MÉTODOS DE GESTIÓN DE BAHÍAS ===

  void _reservarBahia(BuildContext context, Bahia bahia) {
    Navigator.pop(context);
    Navigator.pushNamed(context, '/reservation', arguments: bahia);
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

  void _mostrarDetallesCompletosBahia(BuildContext context, Bahia bahia) {
    Navigator.pop(context);
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

  void _mostrarOpcionesBahia(
      BuildContext context, Bahia bahia, BahiaProvider bahiaProvider) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final esAdministrador = authProvider.usuario?.esAdministrador ?? false;

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
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                // OPCIONES PARA USUARIOS NORMALES
                if (bahia.estado == EstadoBahia.libre) ...[
                  _buildBotonOpcion(
                    'Reservar Bahía',
                    Icons.calendar_today,
                    Colors.blue,
                    () => _reservarBahia(context, bahia),
                  ),
                ],

                // OPCIONES SOLO PARA ADMINISTRADORES

                if (bahia.estado == EstadoBahia.libre) ...[
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

  String _getTipoBahiaText(TipoBahia tipo) {
    switch (tipo) {
      case TipoBahia.estandar:
        return 'Estándar';
      case TipoBahia.refrigerada:
        return 'Refrigerada';
      case TipoBahia.peligrosos:
        return 'Peligrosos';
      case TipoBahia.sobremedida:
        return 'Sobremédida';
      default:
        return 'Desconocido';
    }
  }

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
