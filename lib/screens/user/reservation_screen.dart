import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bahias_descarga_system/providers/bahia_provider.dart';
import 'package:bahias_descarga_system/providers/reserva_provider.dart';
import 'package:bahias_descarga_system/models/bahia_model.dart';
import 'package:bahias_descarga_system/widgets/custom_appbar.dart';
import 'package:bahias_descarga_system/utils/constants.dart';

class ReservationScreen extends StatefulWidget {
  const ReservationScreen({Key? key}) : super(key: key);

  @override
  _ReservationScreenState createState() => _ReservationScreenState();
}

class _ReservationScreenState extends State<ReservationScreen> {
  final _formKey = GlobalKey<FormState>();
  late DateTime _fechaInicio;
  late DateTime _fechaFin;
  late Bahia _bahia;
  bool _isLoading = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _bahia = ModalRoute.of(context)!.settings.arguments as Bahia;
    _fechaInicio = DateTime.now();
    _fechaFin = DateTime.now().add(const Duration(hours: 1));
  }

  Future<void> _selectDateTime(BuildContext context, bool isStartDate) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: isStartDate ? _fechaInicio : _fechaFin,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: isStartDate
            ? TimeOfDay.fromDateTime(_fechaInicio)
            : TimeOfDay.fromDateTime(_fechaFin),
      );

      if (pickedTime != null) {
        setState(() {
          final newDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );

          if (isStartDate) {
            _fechaInicio = newDateTime;
            if (_fechaFin.isBefore(_fechaInicio)) {
              _fechaFin = _fechaInicio.add(const Duration(hours: 1));
            }
          } else {
            _fechaFin = newDateTime;
          }
        });
      }
    }
  }

  void _submitReservation() async {
    if (_formKey.currentState!.validate()) {
      if (_fechaFin.isBefore(_fechaInicio)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content:
                  Text('La fecha de fin debe ser posterior a la de inicio')),
        );
        return;
      }

      setState(() => _isLoading = true);

      try {
        final bahiaProvider =
            Provider.of<BahiaProvider>(context, listen: false);
        final reservaProvider =
            Provider.of<ReservaProvider>(context, listen: false);

        // Simular ID de usuario (en una app real vendría del provider de autenticación)
        final usuarioId = 'user_123';
        final usuarioNombre = 'Usuario Actual';

        await bahiaProvider.reservarBahia(
          _bahia.id,
          usuarioNombre,
          usuarioId, // ← Ahora se envía bien
          _fechaInicio,
          _fechaFin,
        );

        await reservaProvider.crearReserva(
          _bahia.id,
          _bahia.numero,
          usuarioId,
          usuarioNombre,
          _fechaInicio,
          _fechaFin,
        );

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
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Información de la bahía',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.paddingMedium),
                      Row(
                        children: [
                          const Text('Número: ',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          Text('${_bahia.numero}'),
                        ],
                      ),
                      const SizedBox(height: AppDimensions.paddingSmall),
                      Row(
                        children: [
                          const Text('Tipo: ',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          Text(_bahia.nombreTipo),
                        ],
                      ),
                      const SizedBox(height: AppDimensions.paddingSmall),
                      Row(
                        children: [
                          const Text('Estado: ',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          Text(_bahia.nombreEstado),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppDimensions.paddingLarge),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Detalles de la reserva',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.paddingMedium),
                      ListTile(
                        title: const Text('Fecha y hora de inicio'),
                        subtitle:
                            Text('${_fechaInicio.toString().substring(0, 16)}'),
                        trailing: const Icon(Icons.calendar_today),
                        onTap: () => _selectDateTime(context, true),
                      ),
                      ListTile(
                        title: const Text('Fecha y hora de fin'),
                        subtitle:
                            Text('${_fechaFin.toString().substring(0, 16)}'),
                        trailing: const Icon(Icons.calendar_today),
                        onTap: () => _selectDateTime(context, false),
                      ),
                      const SizedBox(height: AppDimensions.paddingMedium),
                      if (_fechaInicio != null && _fechaFin != null) ...[
                        const Divider(),
                        ListTile(
                          title: const Text('Duración total'),
                          subtitle: Text(
                              '${_fechaFin.difference(_fechaInicio).inHours} horas '
                              '${_fechaFin.difference(_fechaInicio).inMinutes.remainder(60)} minutos'),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppDimensions.paddingLarge),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitReservation,
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : const Text('Confirmar Reserva'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
