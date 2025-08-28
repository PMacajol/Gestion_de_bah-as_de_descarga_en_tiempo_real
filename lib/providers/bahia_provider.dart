import 'package:flutter/foundation.dart';
import 'package:bahias_descarga_system/models/bahia_model.dart';

class BahiaProvider with ChangeNotifier {
  List<Bahia> _bahias = [];
  List<Bahia> _bahiasFiltradas = [];
  String _terminoBusqueda = '';

  List<Bahia> get bahias =>
      _terminoBusqueda.isEmpty ? _bahias : _bahiasFiltradas;

  BahiaProvider() {
    _inicializarBahias();
  }

  Future<void> ponerEnUso(String id, String vehiculoPlaca,
      String conductorNombre, String mercanciaTipo) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final index = _bahias.indexWhere((bahia) => bahia.id == id);
    if (index != -1) {
      final bahia = _bahias[index];

      if (bahia.estado == EstadoBahia.mantenimiento) {
        throw Exception('No se puede usar una bahía en mantenimiento');
      }

      _bahias[index].estado = EstadoBahia.enUso;
      _bahias[index].vehiculoPlaca = vehiculoPlaca;
      _bahias[index].conductorNombre = conductorNombre;
      _bahias[index].mercanciaTipo = mercanciaTipo;
      _bahias[index].horaInicioReserva = DateTime.now();
      _bahias[index].horaFinReserva =
          DateTime.now().add(const Duration(hours: 2));
      _bahias[index].fechaUltimaModificacion = DateTime.now();

      if (_terminoBusqueda.isNotEmpty) {
        buscarBahias(_terminoBusqueda);
      } else {
        notifyListeners();
      }
    }
  }

  void _inicializarBahias() {
    _bahias = List.generate(35, (index) {
      final numero = index + 1;
      final tipoIndex = index % TipoBahia.values.length;
      final estadoIndex = index % EstadoBahia.values.length;

      return Bahia(
        id: 'bahia_$numero',
        numero: numero,
        tipo: TipoBahia.values[tipoIndex],
        estado: EstadoBahia.values[estadoIndex],
        reservadaPor: estadoIndex != 0 ? 'Usuario ${index % 5 + 1}' : null,
        reservadaPorId: estadoIndex != 0 ? 'user_${index % 5}' : null,
        horaInicioReserva: estadoIndex != 0
            ? DateTime.now().subtract(Duration(hours: index % 6))
            : null,
        horaFinReserva: estadoIndex != 0
            ? DateTime.now().add(Duration(hours: (index % 6) + 2))
            : null,
        vehiculoPlaca:
            estadoIndex == 2 ? 'ABC${123 + index}' : null, // Solo en uso
        conductorNombre:
            estadoIndex == 2 ? 'Conductor ${index + 1}' : null, // Solo en uso
        mercanciaTipo: estadoIndex == 2
            ? ['Alimentos', 'Electrónicos', 'Químicos', 'Textiles'][index % 4]
            : null,
        observaciones: estadoIndex == 3
            ? 'En mantenimiento programado'
            : null, // Solo en mantenimiento
        fechaCreacion: DateTime.now().subtract(Duration(days: 365 - index)),
        fechaUltimaModificacion: DateTime.now(),
      );
    });
    _bahiasFiltradas = _bahias;
  }

  // ✅ MÉTODO DE BÚSQUEDA
  void buscarBahias(String termino) {
    _terminoBusqueda = termino.toLowerCase();

    if (_terminoBusqueda.isEmpty) {
      _bahiasFiltradas = _bahias;
    } else {
      _bahiasFiltradas = _bahias.where((bahia) {
        return bahia.numero.toString().contains(_terminoBusqueda) ||
            bahia.nombreTipo.toLowerCase().contains(_terminoBusqueda) ||
            bahia.nombreEstado.toLowerCase().contains(_terminoBusqueda) ||
            (bahia.reservadaPor != null &&
                bahia.reservadaPor!.toLowerCase().contains(_terminoBusqueda));
      }).toList();
    }
    notifyListeners();
  }

  // ✅ LIMPIAR BÚSQUEDA
  void limpiarBusqueda() {
    _terminoBusqueda = '';
    _bahiasFiltradas = _bahias;
    notifyListeners();
  }

  List<Bahia> obtenerBahiasPorTipo(TipoBahia tipo) {
    return _bahias.where((bahia) => bahia.tipo == tipo).toList();
  }

  List<Bahia> obtenerBahiasPorEstado(EstadoBahia estado) {
    return _bahias.where((bahia) => bahia.estado == estado).toList();
  }

  Bahia obtenerBahiaPorId(String id) {
    return _bahias.firstWhere((bahia) => bahia.id == id);
  }

  // ✅ ACTUALIZAR ESTADO CON BÚSQUEDA
  Future<void> actualizarEstadoBahia(String id, EstadoBahia nuevoEstado) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final index = _bahias.indexWhere((bahia) => bahia.id == id);
    if (index != -1) {
      _bahias[index].estado = nuevoEstado;
      _bahias[index].fechaUltimaModificacion = DateTime.now();

      // Actualizar también la lista filtrada si hay búsqueda activa
      if (_terminoBusqueda.isNotEmpty) {
        buscarBahias(_terminoBusqueda);
      } else {
        notifyListeners();
      }
    }
  }

  // ✅ RESERVAR BAHÍA CON BÚSQUEDA
  Future<void> reservarBahia(String id, String usuarioNombre, String usuarioId,
      DateTime inicio, DateTime fin) async {
    await Future.delayed(const Duration(seconds: 1));

    final index = _bahias.indexWhere((bahia) => bahia.id == id);
    if (index != -1) {
      final bahia = _bahias[index];

      if (bahia.estado == EstadoBahia.mantenimiento) {
        throw Exception('No se puede reservar una bahía en mantenimiento');
      }

      if (bahia.estado != EstadoBahia.libre) {
        throw Exception('La bahía no está disponible para reserva');
      }

      _bahias[index].estado = EstadoBahia.reservada;
      _bahias[index].reservadaPor = usuarioNombre;
      _bahias[index].reservadaPorId = usuarioId;
      _bahias[index].horaInicioReserva = inicio;
      _bahias[index].horaFinReserva = fin;
      _bahias[index].fechaUltimaModificacion = DateTime.now();

      // Actualizar búsqueda si está activa
      if (_terminoBusqueda.isNotEmpty) {
        buscarBahias(_terminoBusqueda);
      } else {
        notifyListeners();
      }
    }
  }

  // ✅ LIBERAR BAHÍA CON BÚSQUEDA
  Future<void> liberarBahia(String id) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final index = _bahias.indexWhere((bahia) => bahia.id == id);
    if (index != -1) {
      _bahias[index].estado = EstadoBahia.libre;
      _bahias[index].reservadaPor = null;
      _bahias[index].reservadaPorId = null;
      _bahias[index].horaInicioReserva = null;
      _bahias[index].horaFinReserva = null;
      _bahias[index].vehiculoPlaca = null;
      _bahias[index].conductorNombre = null;
      _bahias[index].mercanciaTipo = null;
      _bahias[index].fechaUltimaModificacion = DateTime.now();

      // Actualizar búsqueda si está activa
      if (_terminoBusqueda.isNotEmpty) {
        buscarBahias(_terminoBusqueda);
      } else {
        notifyListeners();
      }
    }
  }

  // ✅ PONER EN MANTENIMIENTO CON BÚSQUEDA
  Future<void> ponerEnMantenimiento(String id, String observaciones) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final index = _bahias.indexWhere((bahia) => bahia.id == id);
    if (index != -1) {
      final bahia = _bahias[index];

      if (bahia.estado != EstadoBahia.libre) {
        throw Exception('Solo se puede poner en mantenimiento una bahía libre');
      }

      _bahias[index].estado = EstadoBahia.mantenimiento;
      _bahias[index].observaciones = observaciones;
      _bahias[index].fechaUltimaModificacion = DateTime.now();

      // Actualizar búsqueda si está activa
      if (_terminoBusqueda.isNotEmpty) {
        buscarBahias(_terminoBusqueda);
      } else {
        notifyListeners();
      }
    }
  }

  // ✅ LIBERAR DE MANTENIMIENTO CON BÚSQUEDA
  Future<void> liberarDeMantenimiento(String id) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final index = _bahias.indexWhere((bahia) => bahia.id == id);
    if (index != -1) {
      final bahia = _bahias[index];

      if (bahia.estado != EstadoBahia.mantenimiento) {
        throw Exception('Solo se puede liberar una bahía en mantenimiento');
      }

      _bahias[index].estado = EstadoBahia.libre;
      _bahias[index].observaciones = null;
      _bahias[index].fechaUltimaModificacion = DateTime.now();

      // Actualizar búsqueda si está activa
      if (_terminoBusqueda.isNotEmpty) {
        buscarBahias(_terminoBusqueda);
      } else {
        notifyListeners();
      }
    }
  }

  Future<void> agregarBahia(int numero, TipoBahia tipo) async {
    await Future.delayed(const Duration(seconds: 1));

    final nuevaBahia = Bahia(
      id: 'bahia_${_bahias.length + 1}',
      numero: numero,
      tipo: tipo,
      estado: EstadoBahia.libre,
      fechaCreacion: DateTime.now(),
      fechaUltimaModificacion: DateTime.now(),
    );

    _bahias.add(nuevaBahia);

    // Actualizar búsqueda si está activa
    if (_terminoBusqueda.isNotEmpty) {
      buscarBahias(_terminoBusqueda);
    } else {
      notifyListeners();
    }
  }

  Future<void> eliminarBahia(String id) async {
    await Future.delayed(const Duration(seconds: 1));
    _bahias.removeWhere((bahia) => bahia.id == id);

    // Actualizar búsqueda si está activa
    if (_terminoBusqueda.isNotEmpty) {
      buscarBahias(_terminoBusqueda);
    } else {
      notifyListeners();
    }
  }
}
