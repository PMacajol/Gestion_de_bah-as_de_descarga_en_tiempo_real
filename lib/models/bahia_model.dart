import 'package:flutter/material.dart';

enum EstadoBahia { libre, reservada, enUso, mantenimiento }

enum TipoBahia { estandar, refrigerada, peligrosos, sobremedida, prioritaria }

class Bahia {
  final String id;
  final int numero;
  final TipoBahia tipo;
  EstadoBahia estado;
  String? reservadaPor;
  String? reservadaPorId;
  DateTime? horaInicioReserva;
  DateTime? horaFinReserva;
  String? vehiculoPlaca;
  String? conductorNombre;
  String? mercanciaTipo;
  String? observaciones;
  final DateTime fechaCreacion;
  DateTime? fechaUltimaModificacion;

  Bahia({
    required this.id,
    required this.numero,
    required this.tipo,
    required this.estado,
    this.reservadaPor,
    this.reservadaPorId,
    this.horaInicioReserva,
    this.horaFinReserva,
    this.vehiculoPlaca,
    this.conductorNombre,
    this.mercanciaTipo,
    this.observaciones,
    required this.fechaCreacion,
    this.fechaUltimaModificacion,
  });

  String get nombreTipo {
    switch (tipo) {
      case TipoBahia.estandar:
        return 'Estándar';
      case TipoBahia.refrigerada:
        return 'Refrigerada';
      case TipoBahia.peligrosos:
        return 'Peligrosos';
      case TipoBahia.sobremedida:
        return 'Sobremédida';
      case TipoBahia.prioritaria:
        return 'Prioritaria';
    }
  }

  String get nombreEstado {
    switch (estado) {
      case EstadoBahia.libre:
        return 'Libre';
      case EstadoBahia.reservada:
        return 'Reservada';
      case EstadoBahia.enUso:
        return 'En uso';
      case EstadoBahia.mantenimiento:
        return 'Mantenimiento';
    }
  }

  Color get colorEstado {
    switch (estado) {
      case EstadoBahia.libre:
        return Colors.green;
      case EstadoBahia.reservada:
        return Colors.orange;
      case EstadoBahia.enUso:
        return Colors.red;
      case EstadoBahia.mantenimiento:
        return Colors.blue;
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

  bool get puedeReservar => estado == EstadoBahia.libre;
  bool get enUso => estado == EstadoBahia.enUso;
  bool get enMantenimiento => estado == EstadoBahia.mantenimiento;

  double get progresoUso {
    if (estado != EstadoBahia.enUso || horaInicioReserva == null) return 0;

    final ahora = DateTime.now();
    final inicio = horaInicioReserva!;
    final fin = horaFinReserva ?? ahora.add(const Duration(hours: 1));

    if (ahora.isAfter(fin)) return 1;

    final total = fin.difference(inicio).inMinutes;
    final transcurrido = ahora.difference(inicio).inMinutes;

    return transcurrido / total;
  }
}
