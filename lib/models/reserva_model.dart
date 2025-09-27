import 'package:intl/intl.dart';

class Reserva {
  final String id;
  final String bahiaId;
  final int numeroBahia;
  final String usuarioId;
  final String usuarioNombre;
  final DateTime fechaHoraInicio;
  final DateTime fechaHoraFin;
  final DateTime fechaCreacion;
  final String estado; // activa, completada, cancelada
  final String? vehiculoPlaca;
  final String? conductorNombre;
  final String? mercanciaTipo;
  final String? observaciones;

  Reserva({
    required this.id,
    required this.bahiaId,
    required this.numeroBahia,
    required this.usuarioId,
    required this.usuarioNombre,
    required this.fechaHoraInicio,
    required this.fechaHoraFin,
    required this.fechaCreacion,
    required this.estado,
    this.vehiculoPlaca,
    this.conductorNombre,
    this.mercanciaTipo,
    this.observaciones,
  });

  String get duracion {
    final diferencia = fechaHoraFin.difference(fechaHoraInicio);
    return '${diferencia.inHours}h ${diferencia.inMinutes.remainder(60)}m';
  }

  String get fechaInicioFormateada {
    return DateFormat('dd/MM/yyyy HH:mm').format(fechaHoraInicio);
  }

  // En reserva_model.dart
  Reserva copyWith({
    String? estado,
    String? observaciones,
  }) {
    return Reserva(
      id: id,
      bahiaId: bahiaId,
      numeroBahia: numeroBahia,
      usuarioId: usuarioId,
      usuarioNombre: usuarioNombre,
      fechaHoraInicio: fechaHoraInicio,
      fechaHoraFin: fechaHoraFin,
      fechaCreacion: fechaCreacion,
      estado: estado ?? this.estado,
      vehiculoPlaca: vehiculoPlaca,
      conductorNombre: conductorNombre,
      mercanciaTipo: mercanciaTipo,
      observaciones: observaciones ?? this.observaciones,
    );
  }

  String get fechaFinFormateada {
    return DateFormat('dd/MM/yyyy HH:mm').format(fechaHoraFin);
  }

  String get fechaCreacionFormateada {
    return DateFormat('dd/MM/yyyy HH:mm').format(fechaCreacion);
  }

  bool get estaActiva => estado == 'activa';
  bool get estaCompletada => estado == 'completada';
  bool get estaCancelada => estado == 'cancelada';
}
