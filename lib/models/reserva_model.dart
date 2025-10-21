import 'package:flutter/material.dart';

class Reserva {
  final String id;
  final String bahiaId;
  final int numeroBahia;
  final String usuarioId;
  final String usuarioNombre;
  final String usuarioEmail;
  final DateTime fechaHoraInicio;
  final DateTime fechaHoraFin;
  final DateTime fechaCreacion;
  final String estado;
  final String? vehiculoPlaca;
  final String? conductorNombre;
  final String? conductorTelefono;
  final String? conductorDocumento;
  final String? mercanciaTipo;
  final double? mercanciaPeso;
  final String? mercanciaDescripcion;
  final String? observaciones;
  final DateTime? fechaCancelacion;
  final DateTime? fechaCompletacion;
  final String? canceladoPor;
  final String? motivoCancelacion;

  Reserva({
    required this.id,
    required this.bahiaId,
    required this.numeroBahia,
    required this.usuarioId,
    required this.usuarioNombre,
    required this.usuarioEmail,
    required this.fechaHoraInicio,
    required this.fechaHoraFin,
    required this.fechaCreacion,
    required this.estado,
    this.vehiculoPlaca,
    this.conductorNombre,
    this.conductorTelefono,
    this.conductorDocumento,
    this.mercanciaTipo,
    this.mercanciaPeso,
    this.mercanciaDescripcion,
    this.observaciones,
    this.fechaCancelacion,
    this.fechaCompletacion,
    this.canceladoPor,
    this.motivoCancelacion,
  });

  // ✅ fromJson robusto y tolerante a formatos mixtos
  factory Reserva.fromJson(Map<String, dynamic> json) {
    // Convertir número de bahía correctamente
    final dynamic numeroBahia = json['numero_bahia'];
    final int numeroBahiaInt = numeroBahia is int
        ? numeroBahia
        : (numeroBahia is double
            ? numeroBahia.toInt()
            : int.tryParse('${numeroBahia ?? 0}') ?? 0);

    // Convertir peso de mercancía correctamente
    final dynamic mercanciaPeso = json['mercancia_peso'];
    final double? mercanciaPesoDouble = mercanciaPeso != null
        ? (mercanciaPeso is double
            ? mercanciaPeso
            : (mercanciaPeso is int
                ? mercanciaPeso.toDouble()
                : double.tryParse(mercanciaPeso.toString())))
        : null;

    return Reserva(
      id: json['id']?.toString() ?? '',
      bahiaId: json['bahia_id']?.toString() ?? '',
      numeroBahia: numeroBahiaInt,
      usuarioId: json['usuario_id']?.toString() ?? '',
      usuarioNombre:
          json['usuario_nombre']?.toString() ?? 'Usuario desconocido',
      usuarioEmail: json['usuario_email']?.toString() ?? '',
      fechaHoraInicio: _parseFecha(json['fecha_hora_inicio']),
      fechaHoraFin: _parseFecha(json['fecha_hora_fin']),
      fechaCreacion: _parseFecha(json['fecha_creacion']),
      estado: json['estado']?.toString().toLowerCase() ?? 'activa',
      vehiculoPlaca: json['vehiculo_placa']?.toString(),
      conductorNombre: json['conductor_nombre']?.toString(),
      conductorTelefono: json['conductor_telefono']?.toString(),
      conductorDocumento: json['conductor_documento']?.toString(),
      mercanciaTipo: json['mercancia_tipo']?.toString(),
      mercanciaPeso: mercanciaPesoDouble,
      mercanciaDescripcion: json['mercancia_descripcion']?.toString(),
      observaciones: json['observaciones']?.toString(),
      fechaCancelacion: _parseFechaNullable(json['fecha_cancelacion']),
      fechaCompletacion: _parseFechaNullable(json['fecha_completacion']),
      canceladoPor: json['cancelado_por']?.toString(),
      motivoCancelacion: json['motivo_cancelacion']?.toString(),
    );
  }

  // 🔹 Funciones auxiliares de parseo seguras
  static DateTime _parseFecha(dynamic valor) {
    try {
      return DateTime.parse(valor?.toString() ?? DateTime.now().toString());
    } catch (_) {
      return DateTime.now();
    }
  }

  static DateTime? _parseFechaNullable(dynamic valor) {
    if (valor == null) return null;
    try {
      return DateTime.parse(valor.toString());
    } catch (_) {
      return null;
    }
  }

  // 🔹 Método copyWith para modificar instancias
  Reserva copyWith({
    String? id,
    String? bahiaId,
    int? numeroBahia,
    String? usuarioId,
    String? usuarioNombre,
    String? usuarioEmail,
    DateTime? fechaHoraInicio,
    DateTime? fechaHoraFin,
    DateTime? fechaCreacion,
    String? estado,
    String? vehiculoPlaca,
    String? conductorNombre,
    String? conductorTelefono,
    String? conductorDocumento,
    String? mercanciaTipo,
    double? mercanciaPeso,
    String? mercanciaDescripcion,
    String? observaciones,
    DateTime? fechaCancelacion,
    DateTime? fechaCompletacion,
    String? canceladoPor,
    String? motivoCancelacion,
  }) {
    return Reserva(
      id: id ?? this.id,
      bahiaId: bahiaId ?? this.bahiaId,
      numeroBahia: numeroBahia ?? this.numeroBahia,
      usuarioId: usuarioId ?? this.usuarioId,
      usuarioNombre: usuarioNombre ?? this.usuarioNombre,
      usuarioEmail: usuarioEmail ?? this.usuarioEmail,
      fechaHoraInicio: fechaHoraInicio ?? this.fechaHoraInicio,
      fechaHoraFin: fechaHoraFin ?? this.fechaHoraFin,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      estado: estado ?? this.estado,
      vehiculoPlaca: vehiculoPlaca ?? this.vehiculoPlaca,
      conductorNombre: conductorNombre ?? this.conductorNombre,
      conductorTelefono: conductorTelefono ?? this.conductorTelefono,
      conductorDocumento: conductorDocumento ?? this.conductorDocumento,
      mercanciaTipo: mercanciaTipo ?? this.mercanciaTipo,
      mercanciaPeso: mercanciaPeso ?? this.mercanciaPeso,
      mercanciaDescripcion: mercanciaDescripcion ?? this.mercanciaDescripcion,
      observaciones: observaciones ?? this.observaciones,
      fechaCancelacion: fechaCancelacion ?? this.fechaCancelacion,
      fechaCompletacion: fechaCompletacion ?? this.fechaCompletacion,
      canceladoPor: canceladoPor ?? this.canceladoPor,
      motivoCancelacion: motivoCancelacion ?? this.motivoCancelacion,
    );
  }

  // 🔹 Propiedades computadas
  bool get estaActiva => estado == 'activa';
  bool get estaCompletada => estado == 'completada';
  bool get estaCancelada => estado == 'cancelada';

  bool get estaEnCurso {
    final ahora = DateTime.now();
    return estaActiva &&
        fechaHoraInicio.isBefore(ahora) &&
        fechaHoraFin.isAfter(ahora);
  }

  bool get estaPendiente {
    final ahora = DateTime.now();
    return estaActiva && fechaHoraInicio.isAfter(ahora);
  }

  bool get estaVencida {
    final ahora = DateTime.now();
    return estaActiva && fechaHoraFin.isBefore(ahora);
  }

  // 🔹 Cálculo de duración legible
  String get duracion {
    final diferencia = fechaHoraFin.difference(fechaHoraInicio);
    final horas = diferencia.inHours;
    final minutos = diferencia.inMinutes.remainder(60);

    if (horas > 0) {
      return '${horas}h ${minutos}m';
    } else {
      return '${minutos}m';
    }
  }

  // 🔹 Estado visual para la UI
  String get estadoDisplay {
    if (estaCancelada) return 'Cancelada';
    if (estaCompletada) return 'Completada';
    if (estaEnCurso) return 'En Curso';
    if (estaPendiente) return 'Pendiente';
    if (estaVencida) return 'Vencida';
    return 'Desconocido';
  }

  Color get colorEstado {
    if (estaCancelada) return Colors.red;
    if (estaCompletada) return Colors.green;
    if (estaEnCurso) return Colors.blue;
    if (estaPendiente) return Colors.orange;
    if (estaVencida) return Colors.purple;
    return Colors.grey;
  }
}
