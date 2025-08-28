import 'package:flutter/foundation.dart';
import 'package:bahias_descarga_system/models/reserva_model.dart';

class ReservaProvider with ChangeNotifier {
  List<Reserva> _reservas = [];

  List<Reserva> get reservas => _reservas;

  ReservaProvider() {
    _inicializarReservas();
  }

  void _inicializarReservas() {
    // Crear reservas de ejemplo
    _reservas = List.generate(20, (index) {
      final numeroBahia = (index % 35) + 1;
      final ahora = DateTime.now();

      return Reserva(
        id: 'reserva_$index',
        bahiaId: 'bahia_$numeroBahia',
        numeroBahia: numeroBahia,
        usuarioId: 'usuario_${index % 5}',
        usuarioNombre: 'Usuario ${index % 5 + 1}',
        fechaHoraInicio: ahora.subtract(Duration(days: index % 7)),
        fechaHoraFin: ahora.add(Duration(hours: (index % 12) + 2)),
        fechaCreacion: ahora.subtract(Duration(days: index % 7)),
        estado: index % 3 == 0
            ? 'activa'
            : index % 3 == 1
                ? 'completada'
                : 'cancelada',
        vehiculoPlaca: index % 4 == 0 ? 'ABC${123 + index}' : null,
        conductorNombre: index % 4 == 0 ? 'Conductor ${index + 1}' : null,
        mercanciaTipo: index % 4 == 0
            ? ['Alimentos', 'Electrónicos', 'Químicos', 'Textiles'][index % 4]
            : null,
      );
    });
  }

  Future<void> crearReserva(
    String bahiaId,
    int numeroBahia,
    String usuarioId,
    String usuarioNombre,
    DateTime inicio,
    DateTime fin, {
    String? vehiculoPlaca,
    String? conductorNombre,
    String? mercanciaTipo,
    String? observaciones,
  }) async {
    await Future.delayed(const Duration(seconds: 1));

    final nuevaReserva = Reserva(
      id: 'reserva_${DateTime.now().millisecondsSinceEpoch}',
      bahiaId: bahiaId,
      numeroBahia: numeroBahia,
      usuarioId: usuarioId,
      usuarioNombre: usuarioNombre,
      fechaHoraInicio: inicio,
      fechaHoraFin: fin,
      fechaCreacion: DateTime.now(),
      estado: 'activa',
      vehiculoPlaca: vehiculoPlaca,
      conductorNombre: conductorNombre,
      mercanciaTipo: mercanciaTipo,
      observaciones: observaciones,
    );

    _reservas.add(nuevaReserva);
    notifyListeners();
  }

  Future<Map<String, dynamic>> obtenerEstadisticasUso(
      DateTime inicio, DateTime fin) async {
    await Future.delayed(const Duration(seconds: 1));

    // Simular datos de estadísticas
    return {
      'totalReservas': 150,
      'tasaUso': 75.5,
      'promedioHoras': 2.5,
      'usoPorTipo': [
        {'tipo': 'Estándar', 'count': 50},
        {'tipo': 'Refrigerada', 'count': 30},
        {'tipo': 'Peligrosos', 'count': 40},
        {'tipo': 'Sobremédida', 'count': 30},
      ],
      'tendenciaUso': [
        {'fecha': '2023-01-01', 'count': 10},
        {'fecha': '2023-01-02', 'count': 15},
        {'fecha': '2023-01-03', 'count': 12},
        {'fecha': '2023-01-04', 'count': 20},
        {'fecha': '2023-01-05', 'count': 18},
      ],
    };
  }

  List<Reserva> obtenerReservasPorUsuario(String usuarioId) {
    return _reservas
        .where((reserva) => reserva.usuarioId == usuarioId)
        .toList();
  }

  List<Reserva> obtenerReservasPorBahia(String bahiaId) {
    return _reservas.where((reserva) => reserva.bahiaId == bahiaId).toList();
  }

  List<Reserva> obtenerReservasActivas() {
    return _reservas.where((reserva) => reserva.estaActiva).toList();
  }

  Future<void> cancelarReserva(String reservaId) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final index = _reservas.indexWhere((reserva) => reserva.id == reservaId);
    if (index != -1) {
      _reservas[index] = Reserva(
        id: _reservas[index].id,
        bahiaId: _reservas[index].bahiaId,
        numeroBahia: _reservas[index].numeroBahia,
        usuarioId: _reservas[index].usuarioId,
        usuarioNombre: _reservas[index].usuarioNombre,
        fechaHoraInicio: _reservas[index].fechaHoraInicio,
        fechaHoraFin: _reservas[index].fechaHoraFin,
        fechaCreacion: _reservas[index].fechaCreacion,
        estado: 'cancelada',
        vehiculoPlaca: _reservas[index].vehiculoPlaca,
        conductorNombre: _reservas[index].conductorNombre,
        mercanciaTipo: _reservas[index].mercanciaTipo,
        observaciones: _reservas[index].observaciones,
      );
      notifyListeners();
    }
  }
}
