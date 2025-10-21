import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bahias_descarga_system/providers/bahia_provider.dart';
import 'package:bahias_descarga_system/providers/reserva_provider.dart';
import 'package:bahias_descarga_system/providers/auth_provider.dart';
import 'package:bahias_descarga_system/models/bahia_model.dart';
import 'package:bahias_descarga_system/widgets/custom_appbar.dart';
import 'package:bahias_descarga_system/utils/constants.dart';

class ReservationScreen extends StatefulWidget {
  const ReservationScreen({super.key});

  @override
  _ReservationScreenState createState() => _ReservationScreenState();
}

class _ReservationScreenState extends State<ReservationScreen> {
  final _formKey = GlobalKey<FormState>();
  DateTime? _fechaInicio;
  DateTime? _fechaFin;
  late Bahia _bahia;
  bool _isLoading = false;
  bool _disponible = true;
  String _mensajeDisponibilidad = '';

  // Controladores de texto
  final TextEditingController _vehiculoPlacaController =
      TextEditingController();
  final TextEditingController _conductorNombreController =
      TextEditingController();
  final TextEditingController _conductorTelefonoController =
      TextEditingController();
  final TextEditingController _conductorDocumentoController =
      TextEditingController();
  final TextEditingController _mercanciaTipoController =
      TextEditingController();
  final TextEditingController _mercanciaPesoController =
      TextEditingController();
  final TextEditingController _mercanciaDescripcionController =
      TextEditingController();
  final TextEditingController _observacionesController =
      TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _bahia = ModalRoute.of(context)!.settings.arguments as Bahia;
  }

  // ==== Selección de fecha y hora ====
  Future<void> _selectDateTime(BuildContext context, bool isStartDate) async {
    final DateTime fallback = DateTime.now();
    final DateTime initial =
        isStartDate ? (_fechaInicio ?? fallback) : (_fechaFin ?? fallback);

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate == null) return;

    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
    );

    if (pickedTime == null) return;

    final newDateTime = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );

    setState(() {
      if (isStartDate) {
        _fechaInicio = newDateTime;
        if (_fechaFin == null ||
            _fechaFin!.isBefore(_fechaInicio!) ||
            _fechaFin!.isAtSameMomentAs(_fechaInicio!)) {
          _fechaFin = _fechaInicio!.add(const Duration(hours: 1));
        }
      } else {
        _fechaFin = newDateTime;
      }
    });

    if (_fechaInicio != null && _fechaFin != null) {
      await _verificarDisponibilidadConFechas();
    }
  }

  // ==== Verificación de disponibilidad ====
  Future<void> _verificarDisponibilidadConFechas() async {
    try {
      final bahiaProvider = Provider.of<BahiaProvider>(context, listen: false);
      final resultadoBasico =
          await bahiaProvider.verificarDisponibilidad(_bahia.id);

      if (!resultadoBasico['disponible']) {
        setState(() {
          _disponible = false;
          _mensajeDisponibilidad =
              resultadoBasico['mensaje'] ?? 'Bahía no disponible';
        });
        return;
      }

      setState(() {
        _disponible = true;
        _mensajeDisponibilidad =
            'Bahía disponible para las fechas seleccionadas';
      });
    } catch (e) {
      setState(() {
        _disponible = false;
        _mensajeDisponibilidad = 'Error al verificar disponibilidad: $e';
      });
    }
  }

  // ==== Envío del formulario ====
  void _submitReservation() async {
    if (_fechaInicio == null || _fechaFin == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Debe seleccionar las fechas de inicio y fin')),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      if (!_disponible) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_mensajeDisponibilidad)),
        );
        return;
      }

      if (_fechaFin!.isBefore(_fechaInicio!) ||
          _fechaFin!.isAtSameMomentAs(_fechaInicio!)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content:
                  Text('La fecha de fin debe ser posterior a la de inicio')),
        );
        return;
      }

      if (_fechaInicio!.isBefore(DateTime.now())) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('No se pueden crear reservas en el pasado')),
        );
        return;
      }

      setState(() => _isLoading = true);

      try {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final reservaProvider =
            Provider.of<ReservaProvider>(context, listen: false);
        final bahiaProvider =
            Provider.of<BahiaProvider>(context, listen: false);

        final usuario = authProvider.usuario;
        if (usuario == null) throw Exception('Usuario no autenticado');

        await reservaProvider.crearReserva(
          _bahia.id,
          _bahia.numero,
          usuario.id,
          usuario.nombre,
          _fechaInicio!,
          _fechaFin!,
          vehiculoPlaca: _vehiculoPlacaController.text,
          conductorNombre: _conductorNombreController.text,
          conductorTelefono: _conductorTelefonoController.text,
          conductorDocumento: _conductorDocumentoController.text,
          mercanciaTipo: _mercanciaTipoController.text,
          mercanciaPeso: double.tryParse(_mercanciaPesoController.text) ?? 0.0,
          mercanciaDescripcion: _mercanciaDescripcionController.text,
          observaciones: _observacionesController.text,
        );

        await bahiaProvider.cargarBahias();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reserva realizada con éxito')),
        );

        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al realizar la reserva: $e')),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _vehiculoPlacaController.dispose();
    _conductorNombreController.dispose();
    _conductorTelefonoController.dispose();
    _conductorDocumentoController.dispose();
    _mercanciaTipoController.dispose();
    _mercanciaPesoController.dispose();
    _mercanciaDescripcionController.dispose();
    _observacionesController.dispose();
    super.dispose();
  }

  // ==== UI ====
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Reservar Bahía ${_bahia.numero}',
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingLarge),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // 🧾 Información de la bahía
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Información de la bahía',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: AppDimensions.paddingMedium),
                      Text('Número: ${_bahia.numero}'),
                      Text('Tipo: ${_bahia.nombreTipo}'),
                      Text('Estado: ${_bahia.nombreEstado}'),
                      Text(
                        'Disponibilidad: ${_disponible ? 'Disponible' : 'No disponible'}',
                        style: TextStyle(
                          color: _disponible ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (_mensajeDisponibilidad.isNotEmpty)
                        Text(
                          _mensajeDisponibilidad,
                          style: TextStyle(
                            color: _disponible ? Colors.green : Colors.red,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppDimensions.paddingLarge),

              // 📅 Fechas de reserva
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Fechas de reserva',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: AppDimensions.paddingMedium),
                      ListTile(
                        title: const Text('Fecha y hora de inicio'),
                        subtitle: Text(_fechaInicio != null
                            ? _fechaInicio!.toString().substring(0, 16)
                            : 'No seleccionada'),
                        trailing: const Icon(Icons.calendar_today),
                        onTap: () => _selectDateTime(context, true),
                      ),
                      ListTile(
                        title: const Text('Fecha y hora de fin'),
                        subtitle: Text(_fechaFin != null
                            ? _fechaFin!.toString().substring(0, 16)
                            : 'No seleccionada'),
                        trailing: const Icon(Icons.calendar_today),
                        onTap: () => _selectDateTime(context, false),
                      ),
                      const Divider(),
                      if (_fechaInicio != null && _fechaFin != null)
                        ListTile(
                          title: const Text('Duración total'),
                          subtitle: Text(
                            '${_fechaFin!.difference(_fechaInicio!).inHours} horas '
                            '${_fechaFin!.difference(_fechaInicio!).inMinutes.remainder(60)} minutos',
                          ),
                        )
                      else
                        const ListTile(
                          title: Text('Duración total'),
                          subtitle: Text(
                              'Seleccione fecha de inicio y fin para calcular'),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppDimensions.paddingLarge),

              // 🚛 Datos del vehículo y conductor
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Datos del vehículo y conductor',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _vehiculoPlacaController,
                        decoration: const InputDecoration(
                            labelText: 'Placa del vehículo'),
                        validator: (value) => value == null || value.isEmpty
                            ? 'Ingrese la placa'
                            : null,
                      ),
                      TextFormField(
                        controller: _conductorNombreController,
                        decoration: const InputDecoration(
                            labelText: 'Nombre del conductor'),
                        validator: (value) => value == null || value.isEmpty
                            ? 'Ingrese el nombre del conductor'
                            : null,
                      ),
                      TextFormField(
                        controller: _conductorTelefonoController,
                        decoration: const InputDecoration(
                            labelText: 'Teléfono del conductor'),
                        keyboardType: TextInputType.phone,
                      ),
                      TextFormField(
                        controller: _conductorDocumentoController,
                        decoration: const InputDecoration(
                            labelText: 'Documento del conductor'),
                        keyboardType: TextInputType.number,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppDimensions.paddingLarge),

              // 📦 Datos de la mercancía
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Datos de la mercancía',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _mercanciaTipoController,
                        decoration: const InputDecoration(
                            labelText: 'Tipo de mercancía'),
                        validator: (value) => value == null || value.isEmpty
                            ? 'Ingrese el tipo de mercancía'
                            : null,
                      ),
                      TextFormField(
                        controller: _mercanciaPesoController,
                        decoration:
                            const InputDecoration(labelText: 'Peso (kg)'),
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                      ),
                      TextFormField(
                        controller: _mercanciaDescripcionController,
                        decoration: const InputDecoration(
                            labelText: 'Descripción de la carga'),
                        maxLines: 2,
                      ),
                      TextFormField(
                        controller: _observacionesController,
                        decoration: const InputDecoration(
                            labelText: 'Observaciones adicionales'),
                        maxLines: 2,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppDimensions.paddingLarge),

              // ✅ Botón de confirmación
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed:
                      _isLoading || !_disponible ? null : _submitReservation,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _disponible ? Colors.blue : Colors.grey,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : const Text(
                          'Confirmar Reserva',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
