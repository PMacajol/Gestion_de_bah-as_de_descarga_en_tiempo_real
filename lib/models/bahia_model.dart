import 'package:flutter/material.dart';

enum TipoBahia {
  estandar,
  refrigerada,
  peligrosos,
  sobremodida,
}

enum EstadoBahia {
  libre,
  reservada,
  enUso,
  mantenimiento,
}

class Bahia {
  final String id;
  final int numero;
  final TipoBahia tipo;
  final EstadoBahia estado;
  final String nombreTipo;
  final String nombreEstado;
  final String? reservadaPor;
  final String? reservadaPorId;
  final DateTime? horaInicioReserva;
  final DateTime? horaFinReserva;
  final String? vehiculoPlaca;
  final String? conductorNombre;
  final String? mercanciaTipo;
  final String? observaciones;
  final int capacidadMaxima;
  final String ubicacion;
  final bool activo;
  final DateTime fechaCreacion;
  final DateTime fechaUltimaModificacion;

  Bahia({
    required this.id,
    required this.numero,
    required this.tipo,
    required this.estado,
    required this.nombreTipo,
    required this.nombreEstado,
    this.reservadaPor,
    this.reservadaPorId,
    this.horaInicioReserva,
    this.horaFinReserva,
    this.vehiculoPlaca,
    this.conductorNombre,
    this.mercanciaTipo,
    this.observaciones,
    required this.capacidadMaxima,
    required this.ubicacion,
    required this.activo,
    required this.fechaCreacion,
    required this.fechaUltimaModificacion,
  });

  // 🔹 fromJson seguro y flexible
  factory Bahia.fromJson(Map<String, dynamic> json) {
    // Asegurar tipos correctos
    final dynamic capacidad = json['capacidad_maxima'];
    final int capacidadInt = capacidad is int
        ? capacidad
        : (capacidad is double ? capacidad.toInt() : 1);

    final dynamic numeroVal = json['numero'];
    final int numeroInt = numeroVal is int
        ? numeroVal
        : (numeroVal is double
            ? numeroVal.toInt()
            : int.tryParse('$numeroVal') ?? 0);

    final String fechaCreacionStr = json['fecha_creacion']?.toString() ?? '';
    final String fechaModStr =
        json['fecha_ultima_modificacion']?.toString() ?? '';

    return Bahia(
      id: json['id']?.toString() ?? '',
      numero: numeroInt,
      tipo: _parseTipoBahia(json['tipo_bahia_nombre']?.toString() ??
          json['tipo_bahia_id']?.toString() ??
          'estandar'),
      estado: _parseEstadoBahia(json['estado_bahia_codigo']?.toString() ??
          json['estado_bahia_id']?.toString() ??
          'libre'),
      nombreTipo: json['tipo_bahia_nombre']?.toString() ?? 'Estándar',
      nombreEstado: json['estado_bahia_nombre']?.toString() ?? 'Libre',
      capacidadMaxima: capacidadInt,
      ubicacion: json['ubicacion']?.toString() ?? 'No especificada',
      activo: json['activo'] == true || json['activo'] == 1,
      fechaCreacion: _parseFecha(fechaCreacionStr),
      fechaUltimaModificacion: _parseFecha(fechaModStr),
      observaciones: json['observaciones']?.toString(),
      reservadaPor: json['reservada_por']?.toString(),
      reservadaPorId: json['reservada_por_id']?.toString(),
      horaInicioReserva: _parseFecha(json['hora_inicio_reserva']),
      horaFinReserva: _parseFecha(json['hora_fin_reserva']),
      vehiculoPlaca: json['vehiculo_placa']?.toString(),
      conductorNombre: json['conductor_nombre']?.toString(),
      mercanciaTipo: json['mercancia_tipo']?.toString(),
    );
  }

  // 🔹 Parsers auxiliares robustos
  static TipoBahia _parseTipoBahia(String tipo) {
    switch (tipo.toLowerCase()) {
      case 'refrigerada':
      case '2':
        return TipoBahia.refrigerada;
      case 'peligrosos':
      case '3':
        return TipoBahia.peligrosos;
      case 'sobremodida':
      case '4':
        return TipoBahia.sobremodida;
      case 'estandar':
      case '1':
      default:
        return TipoBahia.estandar;
    }
  }

  static EstadoBahia _parseEstadoBahia(String estado) {
    switch (estado.toLowerCase()) {
      case 'reservada':
      case '2':
        return EstadoBahia.reservada;
      case 'en_uso':
      case '3':
        return EstadoBahia.enUso;
      case 'mantenimiento':
      case '4':
        return EstadoBahia.mantenimiento;
      case 'libre':
      case '1':
      default:
        return EstadoBahia.libre;
    }
  }

  static DateTime _parseFecha(dynamic fecha) {
    if (fecha == null) return DateTime.now();
    try {
      return DateTime.parse(fecha.toString());
    } catch (_) {
      return DateTime.now();
    }
  }

  // 🔹 Propiedades visuales
  Color get colorEstado {
    switch (estado) {
      case EstadoBahia.libre:
        return Colors.green;
      case EstadoBahia.reservada:
        return Colors.orange;
      case EstadoBahia.enUso:
        return Colors.red;
      case EstadoBahia.mantenimiento:
        return Colors.blueGrey;
    }
  }

  IconData get iconoEstado {
    switch (estado) {
      case EstadoBahia.libre:
        return Icons.check_circle;
      case EstadoBahia.reservada:
        return Icons.access_time;
      case EstadoBahia.enUso:
        return Icons.local_shipping;
      case EstadoBahia.mantenimiento:
        return Icons.build;
    }
  }

  // 🔹 Progreso del uso (por tiempo de reserva)
  double get progresoUso {
    if (horaInicioReserva == null || horaFinReserva == null) return 0.0;
    final ahora = DateTime.now();
    final total = horaFinReserva!.difference(horaInicioReserva!).inMinutes;
    final transcurrido = ahora.difference(horaInicioReserva!).inMinutes;

    if (transcurrido <= 0) return 0.0;
    if (transcurrido >= total) return 1.0;

    return transcurrido / total;
  }

  // 🔹 Estados rápidos
  bool get estaDisponible => estado == EstadoBahia.libre;
  bool get estaOcupada => estado == EstadoBahia.enUso;
  bool get estaReservada => estado == EstadoBahia.reservada;
  bool get estaEnMantenimiento => estado == EstadoBahia.mantenimiento;
}
