<p class="has-line-data" data-line-start="0" data-line-end="35">lib/<br>
├── models/<br>
│   ├── bahia_model.dart<br>
│   ├── reserva_model.dart<br>
│   └── usuario_model.dart<br>
├── providers/<br>
│   ├── auth_provider.dart<br>
│   ├── bahia_provider.dart<br>
│   └── reserva_provider.dart<br>
├── services/<br>
│   ├── auth_service.dart<br>
│   ├── database_service.dart<br>
│   └── report_service.dart<br>
├── utils/<br>
│   ├── constants.dart<br>
│   ├── responsive.dart<br>
│   └── validators.dart<br>
├── widgets/<br>
│   ├── bahia_card.dart<br>
│   ├── custom_appbar.dart<br>
│   └── responsive_layout.dart<br>
└── screens/<br>
├── auth/<br>
│   ├── login_screen.dart<br>
│   └── register_screen.dart<br>
├── admin/<br>
│   ├── admin_dashboard.dart<br>
│   └── user_management.dart<br>
├── user/<br>
│   ├── dashboard_screen.dart<br>
│   ├── reservation_screen.dart<br>
│   └── profile_screen.dart<br>
└── reports/<br>
├── usage_report_screen.dart<br>
└── availability_report_screen.dart</p>


# bahia_model.dart
DOCUMENTACIÓN DETALLADA DEL CÓDIGO: Clase Bahia en Flutter/Dart

Este código está escrito en Flutter (framework basado en Dart) y define la lógica de una entidad llamada "Bahia". 
Una bahía representa un espacio físico de carga/descarga o parqueo dentro de un sistema de logística o transporte. 
La clase incluye atributos que describen la bahía, su estado, tipo, reservas y utilidades para la interfaz gráfica 
(colores e íconos). A continuación, se explica paso a paso:

-------------------------------------------------
1. Importaciones
-------------------------------------------------
import 'package:flutter/material.dart';

- Esta línea importa la librería principal de Flutter llamada "material.dart".
- Contiene widgets, colores, íconos y componentes visuales necesarios para construir interfaces gráficas modernas.
- En este caso, se utiliza para devolver colores (Colors) e íconos (Icons) asociados a los estados de la bahía.

-------------------------------------------------
2. Enumeraciones de Estado y Tipo
-------------------------------------------------
enum EstadoBahia { libre, reservada, enUso, mantenimiento }

- Se define un "enum" (enumeración) llamado EstadoBahia.
- Una enumeración es una lista de valores predefinidos que representan opciones limitadas.
- En este caso, una bahía puede estar en uno de los siguientes estados:
  - libre → disponible para ser utilizada.
  - reservada → apartada para un usuario pero aún no en uso.
  - enUso → actualmente ocupada por un vehículo.
  - mantenimiento → no disponible porque se encuentra en reparación o revisión.

enum TipoBahia { estandar, refrigerada, peligrosos, sobremedida, prioritaria }

- Se define otro enum llamado TipoBahia.
- Representa los distintos tipos físicos o funcionales de bahías:
  - estandar → bahía normal.
  - refrigerada → con sistema de refrigeración, usada para mercancía sensible.
  - peligrosos → destinada a materiales peligrosos.
  - sobremedida → bahía para cargas de gran tamaño.
  - prioritaria → bahía especial, por ejemplo para entregas urgentes.

-------------------------------------------------
3. Clase Bahia
-------------------------------------------------
class Bahia {

- Aquí comienza la definición de la clase Bahia.
- Una clase es un modelo que agrupa atributos (datos) y métodos (funciones).
- Representa una bahía en el sistema.

-------------------------------------------------
4. Atributos de la clase
-------------------------------------------------
final String id;
- Identificador único de la bahía (no se puede cambiar, por eso es "final").

final int numero;
- Número asignado a la bahía (ejemplo: bahía 5, bahía 12).

final TipoBahia tipo;
- Tipo de bahía según la enumeración definida antes (estándar, refrigerada, etc.).

EstadoBahia estado;
- Estado actual de la bahía (libre, reservada, en uso, mantenimiento).

String? reservadaPor;
- Nombre del usuario que reservó la bahía (puede ser nulo si nadie la ha reservado).

String? reservadaPorId;
- ID del usuario que hizo la reserva (puede ser nulo).

DateTime? horaInicioReserva;
- Fecha y hora en que inició la reserva de la bahía (puede ser nulo).

DateTime? horaFinReserva;
- Fecha y hora en que termina la reserva de la bahía (puede ser nulo).

String? vehiculoPlaca;
- Placa del vehículo que está usando la bahía (puede ser nulo si está vacía).

String? conductorNombre;
- Nombre del conductor asociado a la bahía (puede ser nulo).

String? mercanciaTipo;
- Tipo de mercancía que se manipula en la bahía (puede ser nulo).

String? observaciones;
- Campo libre para comentarios adicionales (puede ser nulo).

final DateTime fechaCreacion;
- Fecha y hora exacta en que se creó este registro de bahía (no cambia).

DateTime? fechaUltimaModificacion;
- Última vez que se actualizó/modificó la información de la bahía (puede ser nulo).

-------------------------------------------------
5. Constructor
-------------------------------------------------
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

- El constructor sirve para crear instancias (objetos) de la clase Bahia.
- Algunos campos son obligatorios (required), por ejemplo: id, numero, tipo, estado y fechaCreacion.
- Otros son opcionales (pueden ser nulos), como reservadaPor o vehiculoPlaca.

-------------------------------------------------
6. Getters personalizados
-------------------------------------------------
Un "getter" es una función que devuelve un valor calculado a partir de los atributos de la clase.

String get nombreTipo { ... }
- Devuelve el nombre del tipo de bahía en formato de texto legible.
- Ejemplo: si tipo == TipoBahia.estandar, devuelve "Estándar".

String get nombreEstado { ... }
- Devuelve el estado de la bahía en formato texto.
- Ejemplo: si estado == EstadoBahia.reservada, devuelve "Reservada".

Color get colorEstado { ... }
- Devuelve un color visual asociado al estado de la bahía:
  - Libre → verde.
  - Reservada → naranja.
  - En uso → rojo.
  - Mantenimiento → azul.
- Esto sirve para mostrar gráficamente el estado en la interfaz de usuario.

IconData get iconoEstado { ... }
- Devuelve un ícono representativo del estado:
  - Libre → check_circle.
  - Reservada → reloj (access_time).
  - En uso → camión (local_shipping).
  - Mantenimiento → herramientas (build).
- Facilita la visualización rápida del estado.

-------------------------------------------------
7. Propiedades lógicas de conveniencia
-------------------------------------------------
bool get puedeReservar => estado == EstadoBahia.libre;
- Devuelve true si la bahía está libre y se puede reservar.

bool get enUso => estado == EstadoBahia.enUso;
- Devuelve true si actualmente la bahía está siendo usada.

bool get enMantenimiento => estado == EstadoBahia.mantenimiento;
- Devuelve true si la bahía está en mantenimiento.

-------------------------------------------------
8. Progreso de uso
-------------------------------------------------
double get progresoUso { ... }

- Calcula qué porcentaje del tiempo de uso ha transcurrido.
- Solo aplica cuando la bahía está en uso.
- Funcionamiento:
  1. Si el estado no es "enUso" o no existe hora de inicio, devuelve 0.
  2. Toma la hora actual del sistema (DateTime.now()).
  3. Usa horaInicioReserva como inicio y horaFinReserva como final (o 1 hora por defecto si no está definido).
  4. Calcula:
     total = diferencia en minutos entre fin e inicio.
     transcurrido = minutos desde inicio hasta ahora.
  5. Devuelve (transcurrido / total).
- Ejemplo: Si la reserva dura 60 minutos y han pasado 30, devuelve 0.5 (50%).

-------------------------------------------------
FIN DE DOCUMENTACIÓN













# reserva_model.dart
--------------------------------------------------------------------------------
DOCUMENTACIÓN DETALLADA DE CÓDIGO
Archivo: reserva_model.dart
Propósito: Definir el modelo de datos "Reserva", utilizado para representar 
y manipular información relacionada con reservas de bahías (espacios de carga,
descarga, estacionamiento, etc.).
--------------------------------------------------------------------------------

1. import 'package:intl/intl.dart';
   - Se importa la librería "intl", que es utilizada para dar formato a fechas
     y horas. Sin esta librería, no se podría mostrar de forma amigable las 
     fechas de inicio, fin o creación de la reserva.

--------------------------------------------------------------------------------
2. class Reserva {
   - Se define una clase llamada "Reserva".
   - Esta clase es el modelo que representa la información de una reserva.
   - Contendrá atributos (datos), un constructor (para crear objetos de tipo 
     reserva), y métodos/getters que procesan o devuelven información útil.

--------------------------------------------------------------------------------
3. Atributos principales (obligatorios y opcionales):

   final String id;
   - Identificador único de la reserva. Puede ser generado por la base de datos 
     o el sistema. Ejemplo: "R001".

   final String bahiaId;
   - Identificador de la bahía (espacio o lugar físico asignado).
     Ejemplo: "B05".

   final int numeroBahia;
   - Número de bahía asignada. Es un valor numérico que representa la ubicación.
     Ejemplo: 5.

   final String usuarioId;
   - Identificador del usuario que realizó la reserva.
     Ejemplo: "U123".

   final String usuarioNombre;
   - Nombre del usuario que realizó la reserva.
     Ejemplo: "Pedro Macajol".

   final DateTime fechaHoraInicio;
   - Fecha y hora en que inicia la reserva.
     Ejemplo: 2025-08-28 10:00.

   final DateTime fechaHoraFin;
   - Fecha y hora en que finaliza la reserva.
     Ejemplo: 2025-08-28 12:00.

   final DateTime fechaCreacion;
   - Momento exacto en que se creó la reserva en el sistema.
     Ejemplo: 2025-08-27 09:15.

   final String estado;
   - Estado actual de la reserva. Puede tomar valores como:
       * "activa"
       * "completada"
       * "cancelada"

   // Campos opcionales (pueden venir nulos):
   final String? vehiculoPlaca;
   - Número de placa del vehículo asignado a la bahía.
     Ejemplo: "P123ABC".

   final String? conductorNombre;
   - Nombre del conductor asignado al vehículo.
     Ejemplo: "Juan Pérez".

   final String? mercanciaTipo;
   - Tipo de mercancía a cargar o descargar.
     Ejemplo: "Electrónica".

   final String? observaciones;
   - Campo libre para anotar comentarios adicionales.
     Ejemplo: "Llegar 15 minutos antes".

--------------------------------------------------------------------------------
4. Constructor de la clase Reserva:

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

   - Este constructor obliga a que se definan los campos más importantes al 
     momento de crear una nueva reserva (por ejemplo: id, bahía, usuario, 
     fechas y estado).
   - Los campos opcionales (vehículo, conductor, mercancía, observaciones) 
     pueden omitirse si no se tienen datos.

   Ejemplo de creación de una reserva:
   var reserva = Reserva(
     id: "R001",
     bahiaId: "B05",
     numeroBahia: 5,
     usuarioId: "U123",
     usuarioNombre: "Pedro Macajol",
     fechaHoraInicio: DateTime(2025, 8, 28, 10, 0),
     fechaHoraFin: DateTime(2025, 8, 28, 12, 0),
     fechaCreacion: DateTime.now(),
     estado: "activa",
   );

--------------------------------------------------------------------------------
5. Getters (métodos que calculan o devuelven información lista para usar):

   String get duracion {
     final diferencia = fechaHoraFin.difference(fechaHoraInicio);
     return '${diferencia.inHours}h ${diferencia.inMinutes.remainder(60)}m';
   }
   - Calcula la duración de la reserva, restando la fecha de inicio a la fecha 
     de fin. Devuelve el resultado en formato "Xh Ym".
     Ejemplo: 2h 30m.

   String get fechaInicioFormateada {
     return DateFormat('dd/MM/yyyy HH:mm').format(fechaHoraInicio);
   }
   - Devuelve la fecha y hora de inicio en formato legible (día/mes/año hora:minuto).
     Ejemplo: "28/08/2025 10:00".

   String get fechaFinFormateada {
     return DateFormat('dd/MM/yyyy HH:mm').format(fechaHoraFin);
   }
   - Devuelve la fecha y hora de finalización en el mismo formato legible.
     Ejemplo: "28/08/2025 12:00".

   String get fechaCreacionFormateada {
     return DateFormat('dd/MM/yyyy HH:mm').format(fechaCreacion);
   }
   - Devuelve la fecha en la que se creó la reserva en formato legible.
     Ejemplo: "27/08/2025 09:15".

--------------------------------------------------------------------------------
6. Getters de estado (booleanos):

   bool get estaActiva => estado == 'activa';
   - Retorna "true" si la reserva está activa, de lo contrario "false".

   bool get estaCompletada => estado == 'completada';
   - Retorna "true" si la reserva ya fue completada.

   bool get estaCancelada => estado == 'cancelada';
   - Retorna "true" si la reserva fue cancelada.

--------------------------------------------------------------------------------
RESUMEN:
- Esta clase sirve como plantilla para crear, almacenar y manipular reservas.
- Facilita el manejo de fechas, duración y estado sin tener que calcularlos 
  manualmente en otras partes del código.
- Incluye validaciones simples a través de los getters, lo que hace más 
  fácil y seguro el trabajo de otros desarrolladores.























# usuario_model.dart
DOCUMENTACIÓN DEL CÓDIGO: CLASE USUARIO Y ENUMERADO TIPOUSUARIO
================================================================

Este archivo define un modelo de datos para representar a los usuarios del sistema.
Incluye un enumerado para distinguir los roles de usuario (administrador o usuario común)
y una clase que encapsula toda la información relevante del usuario.

----------------------------------------------------------------
1. ENUMERADO TipoUsuario
----------------------------------------------------------------
enum TipoUsuario { administrador, usuario }

- Un "enum" (enumerado) es un tipo de dato especial que permite definir un conjunto fijo
  de valores constantes.
- Aquí se usa para representar el tipo de rol que puede tener un usuario en el sistema.

Valores posibles:
- administrador -> Representa a un usuario con permisos y privilegios completos,
                   normalmente alguien con acceso a configuraciones avanzadas.
- usuario       -> Representa a un usuario común, con permisos limitados,
                   enfocado en el uso normal del sistema.

----------------------------------------------------------------
2. CLASE Usuario
----------------------------------------------------------------
class Usuario { ... }

La clase `Usuario` modela a una persona registrada en el sistema. 
Cada instancia de la clase representa a un usuario diferente, con su información
de identificación, contacto, rol y fecha de registro.

ATRIBUTOS:
----------
final String id;
- Identificador único del usuario.
- Se guarda como texto (`String`) ya que puede provenir de una base de datos,
  un sistema externo o un generador de identificadores.
- Es inmutable porque está declarado como `final`.

final String email;
- Correo electrónico del usuario.
- Usado para autenticar (iniciar sesión) y como dato de contacto.

final String nombre;
- Nombre completo del usuario.
- Se utiliza para mostrar en pantallas, reportes o listados.

final TipoUsuario tipo;
- Define el rol del usuario dentro del sistema.
- Solo puede ser uno de los valores definidos en el enumerado `TipoUsuario`
  (administrador o usuario).

final DateTime fechaRegistro;
- Almacena la fecha y hora exacta en que el usuario fue creado en el sistema.
- Se usa la clase `DateTime` de Dart para manipular y mostrar fechas.

CONSTRUCTOR:
------------
Usuario({
  required this.id,
  required this.email,
  required this.nombre,
  required this.tipo,
  required this.fechaRegistro,
});

- Es un constructor con parámetros nombrados y todos son obligatorios (`required`).
- Garantiza que cada vez que se cree un usuario se proporcione toda la información necesaria.
- Ejemplo de uso:
  var u = Usuario(
    id: "U123",
    email: "correo@ejemplo.com",
    nombre: "Pedro López",
    tipo: TipoUsuario.usuario,
    fechaRegistro: DateTime.now(),
  );

PROPIEDAD CALCULADA:
--------------------
bool get esAdministrador => tipo == TipoUsuario.administrador;

- Propiedad que devuelve un valor booleano (`true` o `false`).
- Sirve para verificar rápidamente si el usuario actual es un administrador.
- Retorna `true` si el atributo `tipo` es igual a `TipoUsuario.administrador`,
  en caso contrario retorna `false`.
- Ejemplo:
  if (usuario.esAdministrador) {
    print("Este usuario tiene privilegios de administrador");
  } else {
    print("Este usuario es normal");
  }

----------------------------------------------------------------
RESUMEN:
----------------------------------------------------------------
- `TipoUsuario` define los roles posibles (administrador, usuario).
- `Usuario` encapsula toda la información importante de cada usuario.
- El constructor obliga a siempre crear usuarios con datos completos.
- La propiedad `esAdministrador` permite verificar privilegios sin necesidad
  de escribir comparaciones manuales en el resto del código.








# auth_provider.dart
Este archivo define la clase "AuthProvider" que maneja la lógica de autenticación de usuarios 
en el sistema. Se apoya en el modelo "Usuario" y simula un backend con una lista de usuarios 
para pruebas.

────────────────────────────────────────────────────────────
1. Importaciones necesarias:
────────────────────────────────────────────────────────────
import 'package:flutter/foundation.dart';
    → Se importa la librería de Flutter "foundation" que provee la clase ChangeNotifier 
      (necesaria para el patrón Provider y notificar cambios a la UI).

import 'package:bahias_descarga_system/models/usuario_model.dart';
    → Se importa el modelo "Usuario" y la enumeración "TipoUsuario", que representan 
      la estructura de un usuario dentro del sistema.

────────────────────────────────────────────────────────────
2. Definición de la clase AuthProvider:
────────────────────────────────────────────────────────────
class AuthProvider with ChangeNotifier {
    → Se define la clase "AuthProvider" que implementa el mixin "ChangeNotifier".
      Esto permite que cuando cambien variables internas, se pueda notificar a 
      los widgets que dependen de esta clase.

────────────────────────────────────────────────────────────
3. Variables privadas de estado:
────────────────────────────────────────────────────────────
  Usuario? _usuario;
      → Guarda el usuario actualmente autenticado (puede ser null si no hay login activo).

  bool _autenticado = false;
      → Indica si actualmente hay un usuario autenticado en el sistema.

────────────────────────────────────────────────────────────
4. Getters públicos:
────────────────────────────────────────────────────────────
  Usuario? get usuario => _usuario;
      → Permite acceder al usuario autenticado desde fuera de la clase.

  bool get autenticado => _autenticado;
      → Permite saber si el usuario está autenticado (true o false).

────────────────────────────────────────────────────────────
5. Lista de usuarios simulados (mock):
────────────────────────────────────────────────────────────
  final List<Usuario> _usuariosSimulados = [
      → Lista interna que simula una base de datos de usuarios para pruebas.

    Usuario(
      id: '1',
      email: 'admin@empresa.com',
      nombre: 'Administrador Sistema',
      tipo: TipoUsuario.administrador,
      fechaRegistro: DateTime.now(),
    ),
        → Primer usuario: administrador del sistema.

    Usuario(
      id: '2',
      email: 'usuario@empresa.com',
      nombre: 'Juan Pérez',
      tipo: TipoUsuario.usuario,
      fechaRegistro: DateTime.now(),
    ),
        → Segundo usuario: un usuario normal del sistema.
  ];

────────────────────────────────────────────────────────────
6. Método login:
────────────────────────────────────────────────────────────
  Future<bool> login(String email, String password) async {
      → Recibe email y password e intenta autenticar al usuario.

    await Future.delayed(const Duration(seconds: 1));
        → Simula un pequeño tiempo de espera (como si fuese una petición al servidor).

    final usuario = _usuariosSimulados.firstWhere(
      (u) => u.email == email,
      orElse: () => throw Exception('Usuario no encontrado'),
    );
        → Busca en la lista simulada un usuario con el email indicado.
          Si no lo encuentra, lanza una excepción.

    if (password != 'password123') {
      throw Exception('Contraseña incorrecta');
    }
        → Valida la contraseña. En este caso está simulada con un texto fijo 
          "password123" (no hay encriptación aquí).

    _usuario = usuario;
    _autenticado = true;
    notifyListeners();
        → Si todo es correcto: guarda el usuario en la variable interna, 
          marca que está autenticado y notifica a la UI.

    return true;
  }

────────────────────────────────────────────────────────────
7. Método register:
────────────────────────────────────────────────────────────
  Future<bool> register(String email, String password, String nombre) async {
      → Permite registrar un nuevo usuario en la lista simulada.

    await Future.delayed(const Duration(seconds: 1));
        → Simula el tiempo de espera de una petición.

    if (_usuariosSimulados.any((u) => u.email == email)) {
      throw Exception('El usuario ya existe');
    }
        → Valida que no exista ya un usuario con ese mismo email.

    final nuevoUsuario = Usuario(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      email: email,
      nombre: nombre,
      tipo: TipoUsuario.usuario,
      fechaRegistro: DateTime.now(),
    );
        → Crea un nuevo usuario con un ID único (basado en timestamp) 
          y lo marca como tipo "usuario".

    _usuariosSimulados.add(nuevoUsuario);
    _usuario = nuevoUsuario;
    _autenticado = true;
    notifyListeners();
        → Lo agrega a la lista, lo guarda como usuario actual y marca la sesión activa.

    return true;
  }

────────────────────────────────────────────────────────────
8. Método logout:
────────────────────────────────────────────────────────────
  Future<void> logout() async {
      → Cierra la sesión del usuario actual.

    await Future.delayed(const Duration(milliseconds: 500));
        → Simula medio segundo de espera.

    _usuario = null;
    _autenticado = false;
    notifyListeners();
        → Limpia los datos del usuario y marca autenticación en false. 
          Además notifica a la UI para actualizar la vista.
  }
}

────────────────────────────────────────────────────────────
Resumen:
────────────────────────────────────────────────────────────
AuthProvider es el encargado de manejar todo el ciclo de autenticación en el sistema:
- Mantiene un usuario actual y un flag de autenticación.
- Tiene usuarios simulados (mock) para pruebas.
- Permite iniciar sesión con email + password.
- Permite registrar nuevos usuarios (simulados).
- Permite cerrar sesión.
- Notifica a la interfaz cuando hay cambios en el estado.










# bahia_provider.dart
DOCUMENTACIÓN DEL CÓDIGO: CLASE BahiaProvider
================================================================
Este archivo define la clase "BahiaProvider" que maneja la lógica de 
administración de bahías dentro del sistema. Esta clase utiliza el patrón 
ChangeNotifier para notificar a la interfaz de usuario cada vez que se 
realiza un cambio en los datos de las bahías.

Importa el modelo "Bahia" para poder manipular instancias de bahías.

────────────────────────────────────────────────────────────
1. Importaciones necesarias:
────────────────────────────────────────────────────────────
import 'package:flutter/foundation.dart';
    → Se importa "foundation.dart" de Flutter para usar ChangeNotifier, 
      que permite notificar cambios a la UI.

import 'package:bahias_descarga_system/models/bahia_model.dart';
    → Se importa el modelo Bahia para manipular objetos de tipo bahía
      (información de estado, tipo, reservaciones, vehículos, etc.).

────────────────────────────────────────────────────────────
2. Definición de la clase BahiaProvider:
────────────────────────────────────────────────────────────
class BahiaProvider with ChangeNotifier {
    → Clase que maneja todas las operaciones de las bahías, incluyendo:
      uso, reserva, mantenimiento, liberación y búsqueda.
    → Utiliza ChangeNotifier para actualizar automáticamente la UI cuando 
      cambia el estado de alguna bahía.

────────────────────────────────────────────────────────────
3. Variables privadas internas:
────────────────────────────────────────────────────────────
List<Bahia> _bahias = [];
    → Lista completa de todas las bahías del sistema.

List<Bahia> _bahiasFiltradas = [];
    → Lista de bahías filtradas según criterios de búsqueda.

String _terminoBusqueda = '';
    → Término actual de búsqueda, se usa para filtrar la lista de bahías.

────────────────────────────────────────────────────────────
4. Getters públicos:
────────────────────────────────────────────────────────────
List<Bahia> get bahias =>
    _terminoBusqueda.isEmpty ? _bahias : _bahiasFiltradas;
    → Devuelve la lista de bahías según si hay un término de búsqueda activo.
    → Si no hay búsqueda, retorna todas las bahías; si hay, retorna las filtradas.

────────────────────────────────────────────────────────────
5. Constructor:
────────────────────────────────────────────────────────────
BahiaProvider() {
    _inicializarBahias();
}
    → Al crear un BahiaProvider, se inicializa automáticamente la lista de bahías 
      simuladas con diferentes estados, tipos y datos ficticios.

────────────────────────────────────────────────────────────
6. Método ponerEnUso:
────────────────────────────────────────────────────────────
Future<void> ponerEnUso(String id, String vehiculoPlaca,
    String conductorNombre, String mercanciaTipo) async { ... }

- Cambia el estado de una bahía a "enUso".
- Asigna vehículo, conductor y tipo de mercancía.
- Establece hora de inicio y fin de reserva (por defecto 2 horas).
- Verifica que la bahía no esté en mantenimiento.
- Actualiza fecha de última modificación.
- Actualiza la lista filtrada si hay búsqueda activa, o notifica listeners.

────────────────────────────────────────────────────────────
7. Método _inicializarBahias:
────────────────────────────────────────────────────────────
void _inicializarBahias() { ... }

- Genera 35 bahías simuladas con diferentes combinaciones de tipo y estado.
- Para cada bahía se asignan datos ficticios:
  * Número de bahía
  * Tipo de bahía (estándar, refrigerada, peligrosa, etc.)
  * Estado (libre, reservada, en uso, mantenimiento)
  * ReservadaPor y reservadaPorId si la bahía no está libre
  * Vehículo, conductor y tipo de mercancía si la bahía está en uso
  * Observaciones si la bahía está en mantenimiento
  * Fecha de creación y última modificación

────────────────────────────────────────────────────────────
8. Método buscarBahias:
────────────────────────────────────────────────────────────
void buscarBahias(String termino) { ... }

- Permite filtrar la lista de bahías según número, tipo, estado o usuario que la reservó.
- Convierte el término a minúsculas para búsqueda insensible a mayúsculas.
- Actualiza la lista filtrada y notifica a la UI.

────────────────────────────────────────────────────────────
9. Método limpiarBusqueda:
────────────────────────────────────────────────────────────
void limpiarBusqueda() { ... }

- Resetea el término de búsqueda.
- Devuelve la lista filtrada a la lista completa de bahías.
- Notifica a la UI.

────────────────────────────────────────────────────────────
10. Métodos de filtrado:
────────────────────────────────────────────────────────────
List<Bahia> obtenerBahiasPorTipo(TipoBahia tipo) { ... }
    → Devuelve todas las bahías que coinciden con un tipo específico.

List<Bahia> obtenerBahiasPorEstado(EstadoBahia estado) { ... }
    → Devuelve todas las bahías que coinciden con un estado específico.

Bahia obtenerBahiaPorId(String id) { ... }
    → Devuelve la bahía que coincide con un ID específico.

────────────────────────────────────────────────────────────
11. Método actualizarEstadoBahia:
────────────────────────────────────────────────────────────
Future<void> actualizarEstadoBahia(String id, EstadoBahia nuevoEstado) { ... }

- Permite cambiar el estado de una bahía (libre, en uso, reservada, mantenimiento).
- Actualiza la fecha de última modificación.
- Actualiza la lista filtrada si hay búsqueda activa.

────────────────────────────────────────────────────────────
12. Método reservarBahia:
────────────────────────────────────────────────────────────
Future<void> reservarBahia(String id, String usuarioNombre, String usuarioId,
    DateTime inicio, DateTime fin) { ... }

- Permite reservar una bahía libre.
- Cambia estado a "reservada".
- Asigna usuario, hora de inicio y fin de reserva.
- Lanza excepción si la bahía está en mantenimiento o no está disponible.

────────────────────────────────────────────────────────────
13. Método liberarBahia:
────────────────────────────────────────────────────────────
Future<void> liberarBahia(String id) { ... }

- Cambia estado a "libre".
- Limpia todos los datos de reserva y uso de la bahía.
- Actualiza fecha de última modificación.

────────────────────────────────────────────────────────────
14. Métodos de mantenimiento:
────────────────────────────────────────────────────────────
Future<void> ponerEnMantenimiento(String id, String observaciones) { ... }
    → Cambia estado a "mantenimiento" solo si la bahía está libre.
    → Asigna observaciones y actualiza fecha de modificación.

Future<void> liberarDeMantenimiento(String id) { ... }
    → Libera una bahía en mantenimiento y la deja libre.
    → Limpia observaciones y actualiza fecha de modificación.

────────────────────────────────────────────────────────────
15. Métodos de gestión de bahías:
────────────────────────────────────────────────────────────
Future<void> agregarBahia(int numero, TipoBahia tipo) { ... }
    → Crea una nueva bahía con estado libre.
    → Asigna ID basado en la cantidad de bahías existentes.
    → Actualiza la UI o lista filtrada.

Future<void> eliminarBahia(String id) { ... }
    → Elimina una bahía por ID.
    → Actualiza la UI o lista filtrada.

────────────────────────────────────────────────────────────
RESUMEN:
────────────────────────────────────────────────────────────
- BahiaProvider maneja todas las operaciones sobre bahías: uso, reserva, 
  mantenimiento, agregación, eliminación y búsqueda.
- Utiliza listas internas: completas y filtradas según búsqueda.
- Emplea ChangeNotifier para notificar automáticamente la UI.
- Incluye validaciones de estado antes de realizar acciones.
- Simula tiempos de espera de red con Future.delayed para comportarse 
  como un servicio real.





















# reserva_provider.dart
DOCUMENTACIÓN DEL CÓDIGO: CLASE ReservaProvider
================================================================
Este archivo define la clase "ReservaProvider", responsable de manejar la
información y operaciones relacionadas con las reservas de bahías. La clase
usa el patrón ChangeNotifier para actualizar automáticamente la UI cuando
hay cambios en las reservas.

Importa el modelo "Reserva" para poder manipular instancias de reservas.

────────────────────────────────────────────────────────────
1. Importaciones necesarias:
────────────────────────────────────────────────────────────
import 'package:flutter/foundation.dart';
    → Se importa "foundation.dart" para usar ChangeNotifier, permitiendo
      notificar a la UI sobre cambios de estado.

import 'package:bahias_descarga_system/models/reserva_model.dart';
    → Se importa el modelo Reserva para manipular objetos de tipo reserva
      (información de usuario, bahía, fechas, estado, vehículo, etc.).

────────────────────────────────────────────────────────────
2. Definición de la clase ReservaProvider:
────────────────────────────────────────────────────────────
class ReservaProvider with ChangeNotifier {
    → Clase que gestiona todas las operaciones de reservas:
      creación, cancelación, consultas, estadísticas.
    → Utiliza ChangeNotifier para notificar automáticamente cambios a la UI.

────────────────────────────────────────────────────────────
3. Variables privadas internas:
────────────────────────────────────────────────────────────
List<Reserva> _reservas = [];
    → Lista interna que almacena todas las reservas del sistema.

────────────────────────────────────────────────────────────
4. Getters públicos:
────────────────────────────────────────────────────────────
List<Reserva> get reservas => _reservas;
    → Devuelve todas las reservas actualmente almacenadas.

────────────────────────────────────────────────────────────
5. Constructor:
────────────────────────────────────────────────────────────
ReservaProvider() {
    _inicializarReservas();
}
    → Al crear un ReservaProvider, se inicializa automáticamente la lista
      de reservas con datos de ejemplo.

────────────────────────────────────────────────────────────
6. Método _inicializarReservas:
────────────────────────────────────────────────────────────
void _inicializarReservas() { ... }

- Crea 20 reservas de ejemplo simulando diferentes bahías y usuarios.
- Para cada reserva se asignan:
  * ID único de reserva
  * ID de bahía y número de bahía
  * ID y nombre de usuario
  * Fecha y hora de inicio y fin de la reserva
  * Fecha de creación
  * Estado ('activa', 'completada', 'cancelada')
  * Vehículo, conductor y tipo de mercancía (solo algunas reservas)
- Se usa List.generate para crear las reservas automáticamente.

────────────────────────────────────────────────────────────
7. Método crearReserva:
────────────────────────────────────────────────────────────
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
}) async { ... }

- Permite crear una nueva reserva con información completa.
- Genera un ID único basado en timestamp.
- Añade la nueva reserva a la lista interna.
- Notifica a la UI mediante notifyListeners().
- Puede incluir información opcional de vehículo, conductor, tipo de mercancía y observaciones.

────────────────────────────────────────────────────────────
8. Método obtenerEstadisticasUso:
────────────────────────────────────────────────────────────
Future<Map<String, dynamic>> obtenerEstadisticasUso(
    DateTime inicio, DateTime fin) async { ... }

- Simula la obtención de estadísticas de uso de las reservas.
- Retorna un Map con datos como:
  * totalReservas: número total de reservas
  * tasaUso: porcentaje de uso
  * promedioHoras: duración promedio de las reservas
  * usoPorTipo: cantidad de reservas por tipo de bahía
  * tendenciaUso: cantidad de reservas por fecha
- Emplea Future.delayed para simular tiempo de respuesta de servidor.

────────────────────────────────────────────────────────────
9. Métodos de consulta:
────────────────────────────────────────────────────────────
List<Reserva> obtenerReservasPorUsuario(String usuarioId) { ... }
    → Devuelve todas las reservas asociadas a un usuario específico.

List<Reserva> obtenerReservasPorBahia(String bahiaId) { ... }
    → Devuelve todas las reservas asociadas a una bahía específica.

List<Reserva> obtenerReservasActivas() { ... }
    → Devuelve solo las reservas cuyo estado es 'activa'.

────────────────────────────────────────────────────────────
10. Método cancelarReserva:
────────────────────────────────────────────────────────────
Future<void> cancelarReserva(String reservaId) async { ... }

- Cambia el estado de una reserva a 'cancelada'.
- Mantiene el resto de información intacta (usuario, bahía, fechas, vehículo, etc.).
- Notifica a la UI mediante notifyListeners().

────────────────────────────────────────────────────────────
RESUMEN:
────────────────────────────────────────────────────────────
- ReservaProvider maneja todas las operaciones sobre reservas de bahías.
- Permite crear, consultar y cancelar reservas.
- Permite filtrar reservas por usuario, bahía o estado activo.
- Genera datos de ejemplo automáticamente al inicializarse.
- Proporciona estadísticas simuladas de uso de bahías.
- Notifica automáticamente a la interfaz de usuario cuando se realizan cambios.












# constants.dart
DOCUMENTACIÓN DEL CÓDIGO: CONSTANTES DE ESTILO, TEXTOS Y DIMENSIONES
================================================================
Este archivo define clases de constantes utilizadas en la aplicación para 
mantener consistencia en colores, textos y dimensiones de la UI. Se busca 
facilitar mantenimiento y cambios globales sin modificar cada widget.

────────────────────────────────────────────────────────────
1. Importaciones necesarias:
────────────────────────────────────────────────────────────
import 'package:flutter/material.dart';
    → Se importa el paquete Material para poder usar la clase Color
      y definir colores personalizados en la aplicación.

────────────────────────────────────────────────────────────
2. Clase AppColors:
────────────────────────────────────────────────────────────
class AppColors {
  static const primary = Color(0xFF0066CC);
      → Color principal de la app (azul intenso) usado en botones, 
        encabezados o elementos destacados.

  static const secondary = Color(0xFF66A3FF);
      → Color secundario (azul claro) usado para elementos de soporte 
        visual, fondos secundarios o iconos.

  static const accent = Color(0xFF00CC66);
      → Color de acento (verde) para destacar acciones o elementos 
        importantes.

  static const background = Color(0xFFF5F5F5);
      → Color de fondo general de la aplicación (gris muy claro) 
        usado en pantallas y contenedores.

  static const textDark = Color(0xFF333333);
      → Color para texto oscuro, legible sobre fondos claros.

  static const textLight = Color(0xFF666666);
      → Color para texto secundario o de menor énfasis, legible pero
        menos intenso.
}

────────────────────────────────────────────────────────────
3. Clase AppStrings:
────────────────────────────────────────────────────────────
class AppStrings {
  static const appName = 'Sistema de Bahías';
      → Nombre de la aplicación que se muestra en encabezados o título de ventana.

  static const login = 'Iniciar Sesión';
      → Texto del botón o pantalla de login.

  static const register = 'Registrarse';
      → Texto del botón o pantalla de registro.

  static const dashboard = 'Panel Principal';
      → Título de la pantalla principal o dashboard.

  static const reservations = 'Reservas';
      → Etiqueta para la sección de reservas dentro de la aplicación.

  static const reports = 'Reportes';
      → Etiqueta para la sección de reportes o estadísticas.

  static const profile = 'Perfil';
      → Texto usado en la sección de perfil de usuario.

  static const admin = 'Administración';
      → Texto usado para secciones de administración o configuraciones.
}

────────────────────────────────────────────────────────────
4. Clase AppDimensions:
────────────────────────────────────────────────────────────
class AppDimensions {
  static const double paddingSmall = 8.0;
      → Tamaño de padding pequeño, usado en contenedores o separaciones menores.

  static const double paddingMedium = 16.0;
      → Tamaño de padding medio, usado en secciones y formularios.

  static const double paddingLarge = 24.0;
      → Tamaño de padding grande, usado en encabezados, tarjetas o secciones principales.

  static const double borderRadius = 12.0;
      → Radio de borde estándar para botones, tarjetas y contenedores redondeados.

  static const double cardElevation = 2.0;
      → Elevación (sombra) predeterminada para tarjetas y contenedores.
}

────────────────────────────────────────────────────────────
RESUMEN:
────────────────────────────────────────────────────────────
- AppColors define todos los colores principales, secundarios, de acento,
  fondo y texto para la aplicación.
- AppStrings centraliza todos los textos clave de la app para mantener 
  consistencia y facilitar traducciones o modificaciones.
- AppDimensions centraliza medidas de padding, radios de borde y elevaciones
  para asegurar uniformidad visual.
- Todas las constantes son estáticas y constantes, por lo que pueden 
  accederse desde cualquier parte de la app sin instanciar las clases.













# responsive.dart
DOCUMENTACIÓN DEL CÓDIGO: CLASE Responsive
================================================================
Este archivo define la clase "Responsive", utilizada para manejar el
diseño responsivo de la aplicación, permitiendo adaptar la interfaz
de usuario a diferentes tamaños de pantalla: móvil, tablet y desktop.

Importa "widgets.dart" para poder acceder a BuildContext y MediaQuery,
herramientas clave para determinar las dimensiones de la pantalla.

────────────────────────────────────────────────────────────
1. Importaciones necesarias:
────────────────────────────────────────────────────────────
import 'package:flutter/widgets.dart';
    → Permite usar BuildContext y MediaQuery para obtener información
      sobre las dimensiones de la pantalla.

────────────────────────────────────────────────────────────
2. Definición de la clase Responsive:
────────────────────────────────────────────────────────────
class Responsive {
    → Clase estática que provee métodos para determinar el tipo de
      dispositivo y valores adaptativos según el tamaño de pantalla.

────────────────────────────────────────────────────────────
3. Método isMobile:
────────────────────────────────────────────────────────────
static bool isMobile(BuildContext context) =>
    MediaQuery.of(context).size.width < 850;
    → Retorna true si el ancho de la pantalla es menor a 850px,
      indicando que se trata de un dispositivo móvil.
    → Usa MediaQuery para obtener el tamaño de la pantalla desde el contexto.

────────────────────────────────────────────────────────────
4. Método isTablet:
────────────────────────────────────────────────────────────
static bool isTablet(BuildContext context) =>
    MediaQuery.of(context).size.width < 1100 &&
    MediaQuery.of(context).size.width >= 850;
    → Retorna true si el ancho de la pantalla está entre 850px y 1100px,
      indicando que se trata de un dispositivo tipo tablet.
    → Útil para adaptar la UI a pantallas intermedias.

────────────────────────────────────────────────────────────
5. Método isDesktop:
────────────────────────────────────────────────────────────
static bool isDesktop(BuildContext context) =>
    MediaQuery.of(context).size.width >= 1100;
    → Retorna true si el ancho de la pantalla es mayor o igual a 1100px,
      indicando que se trata de un escritorio o pantalla grande.
    → Permite mostrar layouts más amplios y complejos en desktop.

────────────────────────────────────────────────────────────
6. Método getResponsiveValue:
────────────────────────────────────────────────────────────
static double getResponsiveValue({
  required BuildContext context,
  required double mobile,
  required double tablet,
  required double desktop,
}) {
  if (isMobile(context)) return mobile;
  if (isTablet(context)) return tablet;
  return desktop;
}
    → Permite definir un valor (ej. tamaño de fuente, padding, ancho)
      específico según el tipo de dispositivo.
    → Recibe tres valores: mobile, tablet y desktop.
    → Devuelve el valor correspondiente según la pantalla actual.
    → Se basa en los métodos isMobile, isTablet y isDesktop.

────────────────────────────────────────────────────────────
RESUMEN:
────────────────────────────────────────────────────────────
- La clase Responsive centraliza la lógica para adaptar la UI a
  distintos tamaños de pantalla.
- isMobile, isTablet e isDesktop determinan el tipo de dispositivo
  según el ancho de la pantalla.
- getResponsiveValue permite retornar valores distintos según el
  tamaño de pantalla, facilitando un diseño responsivo.
- Todos los métodos son estáticos, por lo que no requieren instanciación.
- Mejora la mantenibilidad y consistencia del diseño en toda la app.






# validators.dart
DOCUMENTACIÓN DEL CÓDIGO: CLASE Validators
================================================================
Este archivo define la clase "Validators", que proporciona métodos
estáticos para validar campos de formularios como email, contraseña
y nombre de usuario. Su objetivo es centralizar la lógica de validación
y garantizar consistencia en toda la aplicación.

────────────────────────────────────────────────────────────
1. Definición de la clase Validators:
────────────────────────────────────────────────────────────
class Validators {
    → Clase estática que contiene métodos de validación.
    → No requiere instanciación, todos los métodos son estáticos.

────────────────────────────────────────────────────────────
2. Método validateEmail:
────────────────────────────────────────────────────────────
static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
        return 'El email es requerido';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
        return 'Ingrese un email válido';
    }
    return null;
}

- Valida que el campo email no sea nulo ni vacío.
- Usa una expresión regular para verificar que el formato del email sea correcto.
- Retorna un mensaje de error si no cumple los criterios, o null si es válido.
- Ejemplo de uso: `Validators.validateEmail('usuario@dominio.com')`.

────────────────────────────────────────────────────────────
3. Método validatePassword:
────────────────────────────────────────────────────────────
static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
        return 'La contraseña es requerida';
    }
    if (value.length < 6) {
        return 'La contraseña debe tener al menos 6 caracteres';
    }
    return null;
}

- Valida que el campo contraseña no sea nulo ni vacío.
- Verifica que la contraseña tenga al menos 6 caracteres.
- Retorna un mensaje de error si no cumple los criterios, o null si es válida.
- Ejemplo de uso: `Validators.validatePassword('123456')`.

────────────────────────────────────────────────────────────
4. Método validateName:
────────────────────────────────────────────────────────────
static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
        return 'El nombre es requerido';
    }
    if (value.length < 3) {
        return 'El nombre debe tener al menos 3 caracteres';
    }
    return null;
}

- Valida que el campo nombre no sea nulo ni vacío.
- Verifica que el nombre tenga al menos 3 caracteres.
- Retorna un mensaje de error si no cumple los criterios, o null si es válido.
- Ejemplo de uso: `Validators.validateName('Juan')`.

────────────────────────────────────────────────────────────
RESUMEN:
────────────────────────────────────────────────────────────
- La clase Validators centraliza la validación de formularios.
- Todos los métodos son estáticos y retornan null si el valor es válido.
- Incluye validación de email, contraseña y nombre de usuario.
- Facilita mantenimiento y consistencia en la validación de la app.
- Permite un manejo uniforme de errores de entrada en la UI.








# bahia_card.dart
DOCUMENTACIÓN DEL CÓDIGO: WIDGET BahiaCard
================================================================
Este archivo define el widget "BahiaCard", un componente visual
personalizado que representa una bahía dentro de la aplicación.
El card muestra información relevante como número de bahía, tipo,
estado y el usuario que la reservó. Está diseñado para ser reutilizable
y responsivo, con colores y estilos adaptados al estado de la bahía.

────────────────────────────────────────────────────────────
1. Importaciones necesarias:
────────────────────────────────────────────────────────────
import 'package:flutter/material.dart';
    → Permite usar widgets de Flutter y construir la UI.

import 'package:bahias_descarga_system/models/bahia_model.dart';
    → Importa el modelo Bahia para acceder a sus propiedades y métodos.

import 'package:bahias_descarga_system/utils/constants.dart';
    → Importa constantes de estilos (colores, padding, borderRadius)
      para mantener consistencia visual.

────────────────────────────────────────────────────────────
2. Definición de la clase BahiaCard:
────────────────────────────────────────────────────────────
class BahiaCard extends StatelessWidget {
    → Widget inmutable que representa una tarjeta visual de bahía.
    → Hereda de StatelessWidget porque su estado interno no cambia,
      solo depende de los datos recibidos.

────────────────────────────────────────────────────────────
3. Propiedades del widget:
────────────────────────────────────────────────────────────
final Bahia bahia;
    → Instancia del modelo Bahia que contiene la información de la bahía
      a mostrar (número, tipo, estado, usuario, etc.).

final VoidCallback? onTap;
    → Callback opcional que se ejecuta al tocar la tarjeta.
    → Permite manejar acciones externas, como navegar a detalles.

────────────────────────────────────────────────────────────
4. Constructor:
────────────────────────────────────────────────────────────
const BahiaCard({Key? key, required this.bahia, this.onTap})
    : super(key: key);
    → Constructor obligatorio para pasar la bahía y opcionalmente un onTap.
    → Utiliza "super.key" para identificar el widget en el árbol de widgets.

────────────────────────────────────────────────────────────
5. Método build:
────────────────────────────────────────────────────────────
@override
Widget build(BuildContext context) {
    return Card(
        elevation: AppDimensions.cardElevation,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
        ),
        child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
            child: Container(
                decoration: BoxDecoration(
                    color: bahia.colorEstado.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
                ),
                padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                        Text(
                            'Bahía ${bahia.numero}',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.white,
                            ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                            bahia.nombreTipo,
                            style: const TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                        const SizedBox(height: 8),
                        Text(
                            bahia.nombreEstado,
                            style: const TextStyle(color: Colors.white, fontSize: 14),
                        ),
                        if (bahia.reservadaPor != null) ...[
                            const SizedBox(height: 8),
                            Text(
                                'Reservada por: ${bahia.reservadaPor}',
                                style: const TextStyle(color: Colors.white70, fontSize: 10),
                                overflow: TextOverflow.ellipsis,
                            ),
                        ],
                    ],
                ),
            ),
        ),
    );
}

────────────────────────────────────────────────────────────
DETALLES DEL WIDGET:
────────────────────────────────────────────────────────────
- Card: Contenedor principal con elevación y bordes redondeados.
- InkWell: Permite detectar taps con efecto visual de ripple.
- Container: Personaliza color y padding del card.
- Column: Alinea los textos verticalmente.
- Text: Muestra información de la bahía (número, tipo, estado y usuario).
- SizedBox: Separadores entre textos para mejorar legibilidad.
- Opacidad de color: bahia.colorEstado.withOpacity(0.9) permite ver
  un efecto visual suave según el estado de la bahía.
- Condicional "if (bahia.reservadaPor != null)": solo muestra el texto
  de usuario si la bahía está reservada.
- TextOverflow.ellipsis: evita que el texto de usuario se desborde.

────────────────────────────────────────────────────────────
RESUMEN:
────────────────────────────────────────────────────────────
- BahiaCard es un widget reutilizable que representa visualmente una bahía.
- Usa colores, padding y bordes desde constantes para consistencia.
- Soporta interacción con onTap.
- Adapta dinámicamente la UI según el estado de la bahía y datos recibidos.
- Facilita mantenimiento y escalabilidad de la interfaz de la aplicación.











# custom_appbar.dart
DOCUMENTACIÓN DEL CÓDIGO: WIDGET CustomAppBar
================================================================
Este archivo define el widget "CustomAppBar", un componente
personalizado que extiende la barra de navegación superior (AppBar)
de Flutter. Su objetivo es ofrecer un AppBar reutilizable que
pueda mostrar título, acciones adicionales y manejar logout o
navegación al perfil del usuario de manera centralizada.

────────────────────────────────────────────────────────────
1. Importaciones necesarias:
────────────────────────────────────────────────────────────
import 'package:flutter/material.dart';
    → Permite usar widgets de Flutter y construir la UI.

import 'package:provider/provider.dart';
    → Permite acceder a providers y manejar estado global.

import 'package:bahias_descarga_system/providers/auth_provider.dart';
    → Importa el AuthProvider para manejar login/logout y datos de usuario.

import 'package:bahias_descarga_system/utils/constants.dart';
    → Importa constantes de estilo y colores (AppColors, etc.).

────────────────────────────────────────────────────────────
2. Definición de la clase CustomAppBar:
────────────────────────────────────────────────────────────
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
    → Widget inmutable que representa una barra de navegación personalizada.
    → Implementa PreferredSizeWidget para definir altura personalizada.

────────────────────────────────────────────────────────────
3. Propiedades del widget:
────────────────────────────────────────────────────────────
final String title;
    → Título que se mostrará en el AppBar.

final List<Widget>? actions;
    → Lista opcional de widgets que se mostrarán como acciones en el AppBar
      (ej. iconos, botones personalizados).

final bool showBackButton;
    → Define si se debe mostrar el botón de retroceso automáticamente.
    → Por defecto es true.

────────────────────────────────────────────────────────────
4. Constructor:
────────────────────────────────────────────────────────────
const CustomAppBar({
    Key? key,
    required this.title,
    this.actions,
    this.showBackButton = true,
}) : super(key: key);
    → Constructor obligatorio para pasar el título y opcionalmente
      acciones y control del botón de retroceso.
    → Utiliza super.key para identificar el widget en el árbol de widgets.

────────────────────────────────────────────────────────────
5. Propiedad preferredSize:
────────────────────────────────────────────────────────────
@override
Size get preferredSize => const Size.fromHeight(60);
    → Define la altura fija del AppBar en 60 píxeles.
    → Requerido al implementar PreferredSizeWidget.

────────────────────────────────────────────────────────────
6. Método build:
────────────────────────────────────────────────────────────
@override
Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
        → Obtiene el AuthProvider sin escuchar cambios.
        → Se usa para manejar logout y navegación al perfil.

    return AppBar(
        title: Text(title, style: const TextStyle(color: Colors.white)),
            → Muestra el título del AppBar con texto blanco.

        backgroundColor: AppColors.primary,
            → Establece el color de fondo usando la constante de la app.

        elevation: 0,
            → Quita la sombra del AppBar para estilo plano.

        automaticallyImplyLeading: showBackButton,
            → Controla si se muestra automáticamente el botón de retroceso.

        actions: [
            if (actions != null) ...actions!,
                → Inserta cualquier acción adicional pasada como lista.

            PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: Colors.white),
                    → Icono de menú de opciones vertical.

                onSelected: (value) {
                    if (value == 'logout') {
                        authProvider.logout();
                        Navigator.pushNamedAndRemoveUntil(
                            context, '/login', (route) => false);
                    } else if (value == 'profile') {
                        Navigator.pushNamed(context, '/profile');
                    }
                },
                    → Maneja la selección de las opciones del menú.
                    → "logout" cierra sesión y navega al login.
                    → "profile" navega al perfil del usuario.

                itemBuilder: (BuildContext context) {
                    return [
                        const PopupMenuItem<String>(
                            value: 'profile',
                            child: Text('Perfil'),
                        ),
                        const PopupMenuItem<String>(
                            value: 'logout',
                            child: Text('Cerrar Sesión'),
                        ),
                    ];
                },
            ),
        ],
    );
}

────────────────────────────────────────────────────────────
DETALLES DEL WIDGET:
────────────────────────────────────────────────────────────
- AppBar: Barra de navegación superior personalizada.
- Text: Muestra el título con estilo definido.
- actions: Permite agregar iconos o widgets adicionales.
- PopupMenuButton: Menú desplegable para acciones como perfil o logout.
- authProvider.logout(): Ejecuta el cierre de sesión mediante provider.
- Navigator.pushNamedAndRemoveUntil: Navega al login y limpia la pila.
- PreferredSizeWidget: Permite definir altura fija personalizada.
- Reutilizable en toda la app con consistencia visual.

────────────────────────────────────────────────────────────
RESUMEN:
────────────────────────────────────────────────────────────
- CustomAppBar es un AppBar personalizado y reutilizable.
- Controla título, acciones, botón de retroceso y menú de usuario.
- Integrado con AuthProvider para manejar sesión.
- Uso de constantes para colores y dimensiones mantiene consistencia.
- Facilita mantenimiento y escalabilidad de la UI de la aplicación.



























# login_screen.dart
DOCUMENTACIÓN DEL CÓDIGO: SCREEN LoginScreen
================================================================
Nombre del archivo: login_screen.dart
Propósito: Proporcionar la interfaz de inicio de sesión de la aplicación. 
           Permite a los usuarios autenticarse mediante email y contraseña
           y gestiona la navegación según el tipo de usuario.

────────────────────────────────────────────────────────────
1. Importaciones
────────────────────────────────────────────────────────────
import 'package:flutter/material.dart';
    → Permite usar widgets de Flutter para construir la interfaz gráfica
      (Scaffold, TextFormField, ElevatedButton, etc.).

import 'package:provider/provider.dart';
    → Permite acceder a Providers para la gestión de estado global
      (AuthProvider en este caso).

import 'package:bahias_descarga_system/providers/auth_provider.dart';
    → Importa el AuthProvider para ejecutar login, logout y acceder
      a la información del usuario autenticado.

import 'package:bahias_descarga_system/utils/constants.dart';
    → Importa las constantes de la aplicación: colores, strings y
      dimensiones reutilizables (AppColors, AppStrings, AppDimensions).

import 'package:bahias_descarga_system/utils/validators.dart';
    → Contiene funciones de validación para campos de formulario,
      como validar email y contraseña.

import 'package:bahias_descarga_system/models/usuario_model.dart';
    → Modelo de usuario y enum TipoUsuario, necesario para verificar
      si el usuario es administrador o estándar.

────────────────────────────────────────────────────────────
2. Clase LoginScreen
────────────────────────────────────────────────────────────
class LoginScreen extends StatefulWidget
    → StatefulWidget, porque la pantalla necesita actualizarse
      dinámicamente según:
      - Entrada del usuario
      - Indicador de carga (_isLoading)
      - Visibilidad de contraseña (_obscurePassword)

const LoginScreen({Key? key}) : super(key: key);
    → Constructor con key opcional.

@override
_LoginScreenState createState() => _LoginScreenState();
    → Crea el estado mutable asociado al widget.

────────────────────────────────────────────────────────────
3. Estado _LoginScreenState
────────────────────────────────────────────────────────────
Propiedades principales:
- _formKey: GlobalKey<FormState>
      → Identifica el formulario y permite validar todos sus campos.
- _emailController: TextEditingController
      → Controla el input del email, prellenado para pruebas.
- _passwordController: TextEditingController
      → Controla el input de la contraseña, prellenado para pruebas.
- _obscurePassword: bool
      → Determina si la contraseña se muestra u oculta.
- _isLoading: bool
      → Determina si mostrar indicador de carga durante login.

────────────────────────────────────────────────────────────
4. Método _submit()
────────────────────────────────────────────────────────────
Responsable de:
- Validar el formulario.
- Mostrar indicador de carga.
- Llamar al AuthProvider para autenticar usuario.
- Redirigir según el tipo de usuario.
- Manejar errores y notificar al usuario.

Flujo detallado:
1. Verificar si _formKey.currentState!.validate() es true.
2. setState: _isLoading = true para mostrar CircularProgressIndicator.
3. Obtener authProvider del contexto sin escuchar cambios (listen: false).
4. Ejecutar login con _emailController.text y _passwordController.text.
5. Comprobar tipo de usuario:
   - Administrador → Navegar a '/admin'.
   - Usuario estándar → Navegar a '/dashboard'.
6. Capturar cualquier excepción y mostrar mensaje SnackBar.
7. Finalmente, ocultar indicador de carga (_isLoading = false).

────────────────────────────────────────────────────────────
5. Método build(BuildContext context)
────────────────────────────────────────────────────────────
Estructura principal:
- Scaffold: Contenedor principal de la pantalla.
- Stack: Permite superponer:
    1. Imagen de fondo
    2. Overlay oscuro semi-transparente
    3. Formulario centrado
- Padding y ConstrainedBox:
    → Centran el formulario y limitan ancho máximo para adaptabilidad
      en tablet y desktop.
- Form:
    → Contiene los campos de entrada con validación.
- CircleAvatar:
    → Logo de la aplicación con imagen de red, redondeado.
- TextFormField (Email):
    → Input con validación mediante Validators.validateEmail.
    → Prefijo de icono email.
    → Estilo personalizado con colores y fuente.
- TextFormField (Password):
    → Input con validación Validators.validatePassword.
    → Prefijo icono candado.
    → Sufijo IconButton para alternar visibilidad de contraseña.
- ElevatedButton:
    → Botón para iniciar sesión.
    → Deshabilitado si _isLoading es true.
    → Muestra CircularProgressIndicator durante login.
- TextButton:
    → Redirige a la pantalla de registro si no tiene cuenta.

────────────────────────────────────────────────────────────
6. Gestión de estado y UI reactiva
────────────────────────────────────────────────────────────
- setState():
    → Actualiza la UI cuando cambia _isLoading o _obscurePassword.
- Provider<AuthProvider>:
    → Permite ejecutar login/logout y acceder a datos de usuario.
- Validadores:
    → Funciones reutilizables que aseguran la integridad de los datos.

────────────────────────────────────────────────────────────
7. Experiencia de usuario
────────────────────────────────────────────────────────────
- Fondo con imagen y overlay oscuro para contraste.
- Logo en CircleAvatar, centrado y atractivo.
- Campos de formulario con iconos y labels visibles.
- Mensajes de error claros si email o contraseña son inválidos.
- Botón deshabilitado y spinner durante la operación de login.
- Navegación automática según tipo de usuario.
- Link a registro para nuevos usuarios.

────────────────────────────────────────────────────────────
8. Consideraciones de seguridad
────────────────────────────────────────────────────────────
- Contraseña no se almacena en texto plano en la UI, solo se valida.
- Login simulado vía AuthProvider; en producción se recomienda
  hash de contraseñas y conexión segura HTTPS.
- Se maneja la visibilidad de contraseña de forma segura.
- Se captura cualquier excepción y se evita crash de la app.

────────────────────────────────────────────────────────────
9. Resumen
────────────────────────────────────────────────────────────
LoginScreen es una pantalla crítica que:
- Gestiona autenticación de usuarios.
- Mantiene la UI responsiva y adaptable.
- Integra validaciones, estados de carga y navegación.
- Ofrece buena experiencia visual y seguridad básica.

Recomendación: Mantener separadas las responsabilidades:
- Validación en Validators.
- Lógica de autenticación en AuthProvider.
- UI en LoginScreen.
















# register_screen.dart
DOCUMENTACIÓN DEL CÓDIGO: SCREEN RegisterScreen
================================================================
Nombre del archivo: register_screen.dart
Propósito: Proporcionar la interfaz de registro de nuevos usuarios
           en la aplicación. Permite crear una cuenta ingresando
           nombre, email y contraseña, validando los datos y
           gestionando la navegación posterior al registro.

────────────────────────────────────────────────────────────
1. Importaciones
────────────────────────────────────────────────────────────
import 'package:flutter/material.dart';
    → Proporciona widgets y herramientas UI de Flutter (Scaffold, 
      TextFormField, ElevatedButton, ListView, etc.).

import 'package:provider/provider.dart';
    → Permite acceder a Providers para la gestión de estado 
      global (AuthProvider en este caso).

import 'package:bahias_descarga_system/providers/auth_provider.dart';
    → Importa AuthProvider, que gestiona la lógica de registro y
      almacenamiento de usuarios en la app.

import 'package:bahias_descarga_system/utils/constants.dart';
    → Contiene constantes de diseño y estilo reutilizables:
      - AppColors: colores de la app
      - AppDimensions: padding, bordes, tamaños
      - AppStrings: nombres y textos de la app

import 'package:bahias_descarga_system/utils/validators.dart';
    → Funciones de validación de campos del formulario (email, 
      contraseña, nombre).

────────────────────────────────────────────────────────────
2. Clase RegisterScreen
────────────────────────────────────────────────────────────
class RegisterScreen extends StatefulWidget
    → StatefulWidget porque la pantalla requiere:
        - Actualización de la UI al mostrar/ocultar contraseñas
        - Indicador de carga durante el registro
        - Validación dinámica del formulario

const RegisterScreen({Key? key}) : super(key: key);
    → Constructor con key opcional.

@override
_RegisterScreenState createState() => _RegisterScreenState();
    → Crea el estado mutable asociado al widget.

────────────────────────────────────────────────────────────
3. Estado _RegisterScreenState
────────────────────────────────────────────────────────────
Propiedades principales:
- _formKey: GlobalKey<FormState>
    → Permite identificar y validar todos los campos del formulario.

- _nameController: TextEditingController
    → Controla el input del nombre completo del usuario.

- _emailController: TextEditingController
    → Controla el input del email.

- _passwordController: TextEditingController
    → Controla el input de la contraseña.

- _confirmPasswordController: TextEditingController
    → Controla el input para confirmar la contraseña.

- _obscurePassword: bool
    → Determina si la contraseña se muestra u oculta.

- _obscureConfirmPassword: bool
    → Determina si la confirmación de contraseña se muestra u oculta.

- _isLoading: bool
    → Indica si se está procesando el registro, activa 
      CircularProgressIndicator y deshabilita botones.

────────────────────────────────────────────────────────────
4. Método _submit()
────────────────────────────────────────────────────────────
Responsable de:
1. Validar todos los campos del formulario.
2. Verificar que contraseña y confirmación coincidan.
3. Mostrar indicador de carga (_isLoading = true).
4. Llamar al AuthProvider para registrar el usuario.
5. Manejar la navegación posterior:
   - Registro exitoso → '/dashboard'
6. Capturar errores y mostrar SnackBar con mensaje.
7. Ocultar indicador de carga (_isLoading = false).

────────────────────────────────────────────────────────────
5. Método build(BuildContext context)
────────────────────────────────────────────────────────────
Estructura principal:
- Scaffold: Contenedor de toda la pantalla.
- AppBar:
    → Título: 'Registro'
    → Color de fondo: AppColors.primary
- Padding:
    → Espaciado externo alrededor del formulario
- Center + ConstrainedBox:
    → Centran el formulario y limitan ancho máximo a 400px
      para adaptabilidad en desktop/tablet
- Form:
    → Contiene los campos de entrada con validaciones
- ListView:
    → Permite scroll en dispositivos con pantallas pequeñas

Campos del formulario:
1. FlutterLogo (80px)
    → Representación visual de la app
2. Título 'Crear cuenta'
    → Texto centrado, estilo bold, tamaño 24
3. Nombre completo (TextFormField)
    → Icono persona
    → Validador: Validators.validateName
4. Email (TextFormField)
    → Icono email
    → Validador: Validators.validateEmail
    → Tipo de teclado email
5. Contraseña (TextFormField)
    → Icono candado
    → Sufijo: IconButton para mostrar/ocultar contraseña
    → Validador: Validators.validatePassword
    → obscureText controlado por _obscurePassword
6. Confirmar contraseña (TextFormField)
    → Similar al anterior, controla _obscureConfirmPassword
7. ElevatedButton 'Registrarse'
    → Ancla acción _submit
    → Deshabilitado si _isLoading
    → Muestra CircularProgressIndicator si _isLoading
8. TextButton '¿Ya tienes cuenta? Inicia sesión'
    → Permite regresar a pantalla de login

────────────────────────────────────────────────────────────
6. Gestión de estado y UI reactiva
────────────────────────────────────────────────────────────
- setState():
    → Actualiza la UI al mostrar/ocultar contraseñas o
      al cambiar _isLoading
- Provider<AuthProvider>:
    → Llama al método register del proveedor y gestiona
      la creación del usuario
- Validadores:
    → Garantizan que los campos cumplan requisitos mínimos
      antes de enviar los datos

────────────────────────────────────────────────────────────
7. Experiencia de usuario
────────────────────────────────────────────────────────────
- Scroll automático para pantallas pequeñas.
- Iconos descriptivos en cada campo.
- Mensajes de error claros en validación.
- Botón deshabilitado mientras se procesa el registro.
- Feedback visual mediante CircularProgressIndicator.
- Navegación automática tras registro exitoso.

────────────────────────────────────────────────────────────
8. Consideraciones de seguridad
────────────────────────────────────────────────────────────
- Contraseñas no se almacenan en texto plano en la UI.
- Se valida que las contraseñas coincidan antes de llamar al provider.
- Registro gestionado por AuthProvider, permitiendo
  implementar hashing y seguridad adicional.
- Se capturan errores y se muestran mediante SnackBar
  evitando crash de la app.

────────────────────────────────────────────────────────────
9. Resumen
────────────────────────────────────────────────────────────
RegisterScreen es la pantalla de registro de la aplicación:
- Gestiona creación de usuarios con validaciones.
- UI responsiva y adaptada a mobile, tablet y desktop.
- Mantiene consistencia visual usando AppColors y AppDimensions.
- Integra control de estado (_isLoading, visibilidad de contraseña)
- Proporciona buena experiencia UX y seguridad básica.



    
# admin_dashboard.dart
============================================================
MANUAL TÉCNICO – AdminDashboard (Flutter)
============================================================

Archivo: admin_dashboard.dart
Propósito: Panel de administración para gestión de bahías y reservas.

------------------------------------------------------------
1. IMPORTACIONES
------------------------------------------------------------

import 'package:flutter/material.dart';  
// Importa Flutter Material Design para widgets y estilos.

import 'package:provider/provider.dart';  
// Importa Provider para manejo de estado reactivo.

import 'package:bahias_descarga_system/providers/bahia_provider.dart';  
// Proveedor de datos y funciones de bahías.

import 'package:bahias_descarga_system/providers/reserva_provider.dart';  
// Proveedor de datos y funciones de reservas.

import 'package:bahias_descarga_system/providers/auth_provider.dart';  
// Proveedor de autenticación y usuario.

import 'package:bahias_descarga_system/models/bahia_model.dart';  
// Modelo de datos para una bahía.

import 'package:bahias_descarga_system/models/reserva_model.dart';  
// Modelo de datos para reservas.

import 'package:bahias_descarga_system/widgets/custom_appbar.dart';  
// AppBar personalizado para el dashboard.

import 'package:bahias_descarga_system/utils/constants.dart';  
// Constantes globales (colores, estilos, etc.).

import 'package:bahias_descarga_system/utils/responsive.dart';  
// Funciones y clases para adaptabilidad de pantallas.

import 'package:syncfusion_flutter_charts/charts.dart';  
// Librería de gráficos (circular, barras, etc.).

import 'package:intl/intl.dart';  
// Formateo de fechas.

import 'dart:io';  
// Operaciones con archivos.

import 'dart:typed_data';  
// Manejo de datos binarios (PDF).

import 'package:pdf/pdf.dart';  
import 'package:pdf/widgets.dart' as pw;  
// Librería para generar PDFs.

import 'package:path_provider/path_provider.dart';  
// Obtener rutas de almacenamiento local.

------------------------------------------------------------
2. CLASE PRINCIPAL
------------------------------------------------------------

class AdminDashboard extends StatefulWidget {  
  // StatefulWidget permite mantener estado (selección de pestañas, datos dinámicos)
  
  const AdminDashboard({Key? key}) : super(key: key);  
  // Constructor de la clase con Key opcional
  
  @override
  _AdminDashboardState createState() => _AdminDashboardState();  
  // Crea el estado asociado
}

------------------------------------------------------------
3. ESTADO DEL DASHBOARD
------------------------------------------------------------

class _AdminDashboardState extends State<AdminDashboard>
    with SingleTickerProviderStateMixin {  
  // Se mezcla SingleTickerProviderStateMixin para animaciones de TabController

  late TabController _tabController;  
  // Controla las pestañas del dashboard

  int _selectedIndex = 0;  
  // Índice de pestaña activa

  @override
  void initState() {  
    super.initState();  
    // Inicializa estado

    _tabController = TabController(length: 4, vsync: this);  
    // TabController con 4 pestañas

    _tabController.addListener(() {  
      setState(() {  
        _selectedIndex = _tabController.index;  
        // Actualiza índice cuando se cambia de pestaña
      });  
    });  
  }

  @override
  void dispose() {  
    _tabController.dispose();  
    // Libera recursos del TabController
    super.dispose();  
  }

------------------------------------------------------------
4. MÉTODO BUILD PRINCIPAL
------------------------------------------------------------

  @override
  Widget build(BuildContext context) {  
    final bahiaProvider = Provider.of<BahiaProvider>(context);  
    final reservaProvider = Provider.of<ReservaProvider>(context);  
    final authProvider = Provider.of<AuthProvider>(context);  
    // Obtiene instancias de los providers para acceder a datos y funciones

    final bahias = bahiaProvider.bahias;  
    final reservas = reservaProvider.reservas;  
    // Listas locales de bahías y reservas

    // Estadísticas calculadas
    final totalBahias = bahias.length;  
    final bahiasLibres =
        bahias.where((b) => b.estado == EstadoBahia.libre).length;  
    final bahiasOcupadas =
        bahias.where((b) => b.estado == EstadoBahia.enUso).length;  
    final bahiasReservadas =
        bahias.where((b) => b.estado == EstadoBahia.reservada).length;  
    final bahiasMantenimiento =
        bahias.where((b) => b.estado == EstadoBahia.mantenimiento).length;  

------------------------------------------------------------
5. SCAFFOLD
------------------------------------------------------------

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Panel de Administración',  
        showBackButton: false,  
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_active, color: Colors.white),
            onPressed: () => _mostrarNotificaciones(context),  
            // Muestra notificaciones
          ),
          IconButton(
            icon: const Icon(Icons.bar_chart, color: Colors.white),
            onPressed: () => _mostrarReportesCompletos(context),  
            // Muestra reportes completos
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) {
              if (value == 'configuracion') {
                _mostrarConfiguracion(context);  
                // Muestra configuración
              } else if (value == 'backup') {
                _realizarBackup(context);  
                // Realiza backup
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem<String>(
                  value: 'configuracion',
                  child: Text('Configuración'),
                ),
                const PopupMenuItem<String>(
                  value: 'backup',
                  child: Text('Realizar Backup'),
                ),
              ];
            },
          ),
        ],
      ),

------------------------------------------------------------
6. BODY PRINCIPAL
------------------------------------------------------------

      body: Column(
        children: [
          _buildStatsRow(totalBahias, bahiasLibres, bahiasOcupadas,
              bahiasReservadas, bahiasMantenimiento),  
          // Fila de tarjetas con estadísticas

          Container(
            color: Colors.grey[100],
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              indicatorColor: AppColors.primary,
              labelColor: AppColors.primary,
              unselectedLabelColor: Colors.grey,
              tabs: const [
                Tab(icon: Icon(Icons.dashboard), text: 'Dashboard'),
                Tab(icon: Icon(Icons.local_shipping), text: 'Bahías'),
                Tab(icon: Icon(Icons.calendar_today), text: 'Reservas'),
                Tab(icon: Icon(Icons.analytics), text: 'Reportes'),
              ],
            ),
          ),  
          // Pestañas principales

          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildDashboardTab(bahias, reservas),  
                _buildBahiasTab(bahiaProvider, bahias),  
                _buildReservasTab(reservaProvider, reservas),  
                _buildReportesTab(bahias, reservas),  
              ],
            ),
          ),  
          // Contenido de cada pestaña
        ],
      ),

      floatingActionButton: _selectedIndex == 1
          ? FloatingActionButton(
              onPressed: () => _agregarNuevaBahia(context, bahiaProvider),
              child: const Icon(Icons.add),
              backgroundColor: AppColors.primary,
            )
          : null,  
      // Botón flotante solo en pestaña Bahías
    );
  }
============================================================
7. FUNCIONES DE ACCIÓN SOBRE BAHÍAS
============================================================

void _reservarBahia(BuildContext context, Bahia bahia) {  
  Navigator.pop(context);  
  // Cierra el bottom sheet de opciones

  Navigator.pushNamed(
    context,
    '/reservation',
    arguments: bahia,  
    // Navega a la pantalla de reservas pasando la bahía seleccionada
  );
}

void _ponerEnUso(BuildContext context, Bahia bahia, BahiaProvider bahiaProvider) async {  
  try {
    await bahiaProvider.actualizarEstadoBahia(bahia.id, EstadoBahia.enUso);  
    // Actualiza el estado de la bahía a "en uso"

    Navigator.pop(context);  
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Bahía puesta en uso')),  
      // Mensaje de confirmación
    );
  } catch (e) {
    Navigator.pop(context);  
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: $e')),  
      // Muestra error si falla
    );
  }
}

void _ponerEnMantenimiento(BuildContext context, Bahia bahia, BahiaProvider bahiaProvider) async {  
  try {
    await bahiaProvider.ponerEnMantenimiento(bahia.id, 'Mantenimiento programado');  
    // Cambia el estado de la bahía a mantenimiento

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

void _cancelarReserva(BuildContext context, Bahia bahia, BahiaProvider bahiaProvider) async {  
  try {
    await bahiaProvider.liberarBahia(bahia.id);  
    // Libera la bahía y cancela la reserva

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

void _liberarDeMantenimiento(BuildContext context, Bahia bahia, BahiaProvider bahiaProvider) async {  
  try {
    await bahiaProvider.liberarDeMantenimiento(bahia.id);  
    // Libera la bahía de mantenimiento

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

void _liberarBahia(BuildContext context, Bahia bahia, BahiaProvider bahiaProvider) async {  
  try {
    await bahiaProvider.liberarBahia(bahia.id);  
    // Libera la bahía en uso

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

------------------------------------------------------------
8. FUNCIONES DE DETALLES DE BAHÍA
------------------------------------------------------------

void _mostrarDetallesBahia(BuildContext context, Bahia bahia) {  
  Navigator.pop(context);  
  // Cierra bottom sheet

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
                  DateFormat('dd/MM/yyyy HH:mm').format(bahia.horaInicioReserva!)),
            if (bahia.horaFinReserva != null)
              _buildDetalleItem(
                  'Fin',
                  DateFormat('dd/MM/yyyy HH:mm').format(bahia.horaFinReserva!)),
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
  // Widget reutilizable para mostrar pares título-valor
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$titulo: ',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        Expanded(
          child: Text(valor),
        ),
      ],
    ),
  );
}

------------------------------------------------------------
9. FUNCIONES DE RESERVA INDIVIDUAL
------------------------------------------------------------

void _cancelarReservaIndividual(BuildContext context, Reserva reserva, ReservaProvider reservaProvider) {  
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Cancelar Reserva'),
      content: const Text('¿Está seguro de cancelar esta reserva? Esta acción no se puede deshacer.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('No, mantener'),
        ),
        TextButton(
          onPressed: () async {
            try {
              Navigator.pop(context);  
              // Cierra diálogo
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Reserva cancelada exitosamente')),
              );

              setState(() {});  
              // Actualiza UI
            } catch (e) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error al cancelar: $e')),
              );
            }
          },
          child: const Text('Sí, cancelar', style: TextStyle(color: Colors.red)),
        ),
      ],
    ),
  );
}

------------------------------------------------------------
10. FUNCIONES PARA BOTONES Y TARJETAS DE ESTADÍSTICAS
------------------------------------------------------------

Widget _buildBotonOpcion(String texto, IconData icono, Color color, VoidCallback onPressed) {  
  // Botón personalizado para opciones de bahía
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

Widget _buildStatsRow(int total, int libres, int ocupadas, int reservadas, int mantenimiento) {  
  // Fila de tarjetas con estadísticas generales
  return Padding(
    padding: const EdgeInsets.all(16.0),
    child: Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        _buildStatCard('Total Bahías', total, Icons.local_parking, Colors.blue),
        _buildStatCard('Libres', libres, Icons.check_circle, Colors.green),
        _buildStatCard('Ocupadas', ocupadas, Icons.do_not_disturb, Colors.red),
        _buildStatCard('Reservadas', reservadas, Icons.access_time, Colors.orange),
        _buildStatCard('Mantenimiento', mantenimiento, Icons.build, Colors.blueGrey),
      ],
    ),
  );
}

Widget _buildStatCard(String title, int value, IconData icon, Color color) {  
  // Tarjeta individual con estadística
  return Card(
    elevation: 4,
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: SizedBox(
        width: 150,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color),
                const Spacer(),
                Text(
                  value.toString(),
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    ),
  );
}

# Segunda parte:


------------------------------------------------------------
1. Widget _buildReservasTab
   - Línea: Widget _buildReservasTab(ReservaProvider reservaProvider, List<Reserva> reservas)
   - Función: Construye la pestaña de reservas en el panel de administración.
   - Parámetros:
     - reservaProvider: Proveedor de estado y métodos de reservas.
     - reservas: Lista completa de reservas a mostrar.

2. Declaración de controladores
   - final searchController = TextEditingController();
     - Función: Controla el texto ingresado en el campo de búsqueda.
   - String _filtroEstado = 'todas';
     - Función: Almacena el estado seleccionado para filtrar reservas.

3. Padding principal
   - return Padding(padding: const EdgeInsets.all(16.0), child: Column(...))
   - Función: Agrega espacio alrededor de la columna principal.

4. Barra de búsqueda y filtros
   - Row(
       children: [
         Expanded(
           child: TextField(
             controller: searchController,
             decoration: InputDecoration(
               labelText: 'Buscar reservas...',
               prefixIcon: const Icon(Icons.search),
               border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
             ),
             onChanged: (value) {
               // TODO: Implementar búsqueda dinámica
             },
           ),
         ),
         const SizedBox(width: 16),
         PopupMenuButton<String>(
           icon: const Icon(Icons.filter_list),
           onSelected: (value) { setState(() { _filtroEstado = value; }); },
           itemBuilder: (BuildContext context) {
             return [
               const PopupMenuItem<String>(value: 'todas', child: Text('Todas las reservas')),
               const PopupMenuItem<String>(value: 'activas', child: Text('Solo activas')),
               const PopupMenuItem<String>(value: 'completadas', child: Text('Solo completadas')),
               const PopupMenuItem<String>(value: 'canceladas', child: Text('Solo canceladas')),
             ];
           },
         ),
       ],
     )
   - Función: Permite al usuario buscar por texto y filtrar por estado.

5. Separador vertical
   - const SizedBox(height: 16)
   - Función: Agrega espacio entre la barra de búsqueda y el resumen.

6. Resumen rápido de reservas
   - _buildResumenReservas(reservas)
   - Función: Muestra tarjetas con estadísticas de reservas (total, activas, completadas, canceladas).

7. Lista de reservas
   - Expanded(
       child: ListView.builder(
         itemCount: reservas.length,
         itemBuilder: (context, index) {
           final reserva = reservas[index];

           // Filtrado según estado
           if (_filtroEstado == 'activas' && reserva.estado != 'activa') return Container();
           if (_filtroEstado == 'completadas' && reserva.estado != 'completada') return Container();
           if (_filtroEstado == 'canceladas' && reserva.estado != 'cancelada') return Container();

           return _buildReservaCard(reserva, reservaProvider);
         },
       ),
     )
   - Función: Construye la lista de tarjetas de reservas aplicando el filtro seleccionado.

------------------------------------------------------------
8. Widget _buildResumenReservas
   - final total = reservas.length
   - final activas = reservas.where((r) => r.estado == 'activa').length
   - final completadas = reservas.where((r) => r.estado == 'completada').length
   - final canceladas = reservas.where((r) => r.estado == 'cancelada').length
   - Función: Calcula estadísticas de reservas.
   - Devuelve Row de _buildMiniReservaCard para cada tipo de estadística.

9. Widget _buildMiniReservaCard
   - Parámetros: titulo, valor, icono, color
   - Estructura:
     - Expanded -> Card -> Padding -> Column
       - Icon(icono, size:16, color:color)
       - SizedBox(height:4)
       - Text(valor.toString(), estilo en negrita y color)
       - Text(titulo, tamaño pequeño)
   - Función: Mostrar indicador visual con icono y valor.

------------------------------------------------------------
10. Widget _buildReservaCard
    - Card con borde y forma personalizada según estado de reserva.
    - ListTile con:
      - leading: Icono circular que cambia según estado (activa, completada, cancelada)
      - title: Texto 'Reserva #ID'
      - subtitle: Column con:
          - Bahía, Usuario, Inicio, Fin, Chip con estado en mayúsculas y color correspondiente
      - trailing: PopupMenuButton con acciones:
          - editar, cancelar, completar, reactivar, detalles según estado de reserva

------------------------------------------------------------
11. Widget _buildReportesTab
    - Parámetros: List<Bahia> bahias, List<Reserva> reservas
    - Variables locales:
      - ahora: DateTime.now()
      - inicioDia: Primer momento del día actual
      - inicioSemana: Primer día de la semana
      - inicioMes: Primer día del mes
    - Conteo de reservas:
      - reservasHoy, reservasSemana, reservasMes
    - Contenido:
      - Texto 'Reportes y Estadísticas'
      - Card: Resumen del mes con _buildMetricaCard
      - _buildGraficoTendencia(reservas)
      - Card: Opciones de exportación con _buildBotonExportacion

------------------------------------------------------------
12. Widget _buildMetricaCard
    - Parámetros: titulo, valor, icono
    - Contenido: Icono, valor grande, texto del indicador

13. Widget _buildGraficoTendencia
    - Datos de ejemplo: Lista de ChartData (día, valor)
    - Card con SfCartesianChart
    - LineSeries con marcadores y etiquetas visibles

14. Widget _buildResumenReportes
    - Muestra tres tarjetas:
      - Reservas este mes
      - Bahías activas
      - Tasa de uso
    - Usa _buildMiniReporteCard para cada tarjeta

15. Widget _buildMiniReporteCard
    - Parámetros: titulo, valor, icono, color
    - Card con Icono, valor en grande, título centrado en gris

16. Widget _buildOpcionesExportacion
    - Verifica si lista de reservas está vacía
    - Muestra Card con botones:
      - Reporte Diario
      - Reporte Semanal
      - Reporte Mensual
      - Personalizado
    - Cada botón invoca función de exportación correspondiente

17. Widget _buildBotonExportacion
    - Parámetros: texto, icono, color, onPressed
    - Devuelve ElevatedButton.icon estilizado con colores y acción

------------------------------------------------------------
18. Métodos de acciones
    - _mostrarNotificaciones: AlertDialog simple
    - _mostrarReportesCompletos: Navegación a reportes completos
    - _mostrarConfiguracion: AlertDialog de configuración
    - _realizarBackup: AlertDialog simulando backup
    - _agregarNuevaBahia: AlertDialog simulando agregar bahía
    - _mostrarCalendarioReservas: Navegación a calendario de reservas

19. Métodos de gestión de reservas
    - _editarReserva: AlertDialog de edición
    - _completarReserva: Marca reserva como completada y muestra SnackBar
    - _reactivarReserva: Reactiva reserva y muestra SnackBar

20. Métodos de generación de reportes
    - _generarReporteDiario / Semanal / Mensual: Filtra reservas por rango y llama a _mostrarReporteGenerado
    - _generarReportePersonalizado: Selección de rango mediante showDateRangePicker
    - _mostrarReporteGenerado: AlertDialog con resumen y opción de exportar

21. Método _mostrarDetallesReserva
    - AlertDialog mostrando información completa:
      - ID, Bahía, Usuario, Estado, Inicio, Fin, Duración, Creación
      - Cada dato mediante _buildDetalleItem (no listado en código original)

22. Clase ChartData
    - Campos: x (String), y (int), color opcional
    - Usada para gráficos de tendencia

23. Métodos auxiliares para PDF
    - _generatePdf: Genera PDF con lista de reservas filtradas
    - _savePdf: Guarda PDF en directorio de documentos y muestra SnackBar
    - _exportarReporteDiario / Semanal / Mensual / Personalizado: Genera y guarda PDF usando _generatePdf y _savePdf


















# dashboard_screen.dart
MANUAL TÉCNICO DETALLADO – DASHBOARD SCREEN FLUTTER

------------------------------------------------------------
1. Importaciones
   - import 'package:flutter/material.dart';
     -> Biblioteca principal de Flutter para widgets, UI y layouts.
   - import 'package:provider/provider.dart';
     -> Permite usar Provider para gestión de estado.
   - import 'package:bahias_descarga_system/providers/bahia_provider.dart';
     -> Proveedor de estado y métodos para bahías.
   - import 'package:bahias_descarga_system/providers/reserva_provider.dart';
     -> Proveedor de estado y métodos para reservas.
   - import 'package:bahias_descarga_system/providers/auth_provider.dart';
     -> Proveedor de autenticación y permisos de usuario.
   - import 'package:bahias_descarga_system/widgets/custom_appbar.dart';
     -> Widget de AppBar personalizado.
   - import 'package:bahias_descarga_system/utils/constants.dart';
     -> Constantes de la aplicación.
   - import 'package:bahias_descarga_system/utils/responsive.dart';
     -> Utilidades para diseño responsivo.
   - import 'package:bahias_descarga_system/models/bahia_model.dart';
     -> Modelo de datos para bahías.
   - import 'package:bahias_descarga_system/models/reserva_model.dart';
     -> Modelo de datos para reservas.
   - import 'package:intl/intl.dart';
     -> Formateo de fechas y horas.

------------------------------------------------------------
2. Declaración de clase principal
   - class DashboardScreen extends StatefulWidget
     -> Pantalla principal del Dashboard, con estado mutable.
   - const DashboardScreen({Key? key}) : super(key: key)
     -> Constructor por defecto.
   - _DashboardScreenState createState() => _DashboardScreenState()
     -> Crea el estado asociado.

3. Estado de la pantalla
   - TipoBahia? _filtroTipo;
     -> Filtro opcional por tipo de bahía.
   - EstadoBahia? _filtroEstado;
     -> Filtro opcional por estado de bahía.
   - final TextEditingController _searchController = TextEditingController();
     -> Controlador del campo de búsqueda.

------------------------------------------------------------
4. Ciclo de vida
   - initState()
     -> Se ejecuta al iniciar el widget.
     -> Se obtiene el provider de bahías y se limpia la búsqueda inicial.
   - dispose()
     -> Limpia el controlador de búsqueda al destruir el widget.

------------------------------------------------------------
5. Método build
   - final bahiaProvider = Provider.of<BahiaProvider>(context);
   - final reservaProvider = Provider.of<ReservaProvider>(context);
   - final authProvider = Provider.of<AuthProvider>(context);
     -> Obtiene los providers para acceso a estado y métodos.
   - final bahias = bahiaProvider.bahias;
   - final reservas = reservaProvider.reservas;
     -> Listas locales de bahías y reservas.
   - Estadísticas:
     - totalBahias = bahias.length
     - bahiasLibres = bahias.where((b) => b.estado == EstadoBahia.libre).length
     - bahiasOcupadas = bahias.where((b) => b.estado == EstadoBahia.enUso).length
     - bahiasReservadas = bahias.where((b) => b.estado == EstadoBahia.reservada).length
     - bahiasMantenimiento = bahias.where((b) => b.estado == EstadoBahia.mantenimiento).length

------------------------------------------------------------
6. Estructura principal
   - return Scaffold(
       appBar: CustomAppBar(
         title: AppStrings.dashboard,
         showBackButton: false,
         actions: [
           IconButton(icon: Icon(Icons.notifications), onPressed: _mostrarNotificaciones),
           IconButton(icon: Icon(Icons.admin_panel_settings), onPressed: Navigator.pushNamed('/admin')),
         ],
       ),
       body: Column(
         children: [
           _buildStatsRow(...),      // Tarjetas estadísticas
           Padding( ... ),            // Barra de búsqueda y filtros
           Expanded(child: _buildBahiasGrid(...)), // Grid de bahías
         ],
       ),
     )

------------------------------------------------------------
7. Widget _buildStatsRow
   - Recibe cinco números: total, libres, ocupadas, reservadas, mantenimiento
   - Devuelve un Wrap con tarjetas de estadísticas:
     - _buildStatCard('Total Bahías', total, Icons.local_parking, Colors.blue)
     - _buildStatCard('Libres', libres, Icons.check_circle, Colors.green)
     - _buildStatCard('Ocupadas', ocupadas, Icons.do_not_disturb, Colors.red)
     - _buildStatCard('Reservadas', reservadas, Icons.access_time, Colors.orange)
     - _buildStatCard('Mantenimiento', mantenimiento, Icons.build, Colors.blueGrey)

8. Widget _buildStatCard
   - Card con Padding y Column
   - Row:
     - Icon con color
     - Spacer
     - Text con valor en negrita
   - Text con título en gris debajo del Row

------------------------------------------------------------
9. Widget _buildBahiasGrid
   - Aplica filtros de tipo y estado
   - GridView.builder con:
     - crossAxisCount = 5 si desktop, 3 si otro
     - childAspectRatio = 0.9
     - crossAxisSpacing y mainAxisSpacing = 10
   - Cada itemBuilder llama a _buildBahiaCard

10. Widget _buildBahiaCard
    - Card con borde de color según estado
    - InkWell para detectar taps
    - Container con:
      - Icono circular con estado
      - Número de bahía
      - Tipo
      - Estado
      - Información adicional (reservadaPor, horaFinReserva)
    - Todo estilizado con TextStyle, colores y padding

------------------------------------------------------------
11. Métodos de gestión de bahías
    - _reservarBahia: Navega a pantalla de reservas
    - _ponerEnUso: Cambia estado a enUso
    - _ponerEnMantenimiento: Cambia estado a mantenimiento
    - _liberarDeMantenimiento: Libera bahía de mantenimiento
    - _liberarBahia: Libera bahía de uso
    - _cancelarReservaBahia: Cancela reserva y libera
    - Cada método muestra SnackBar según resultado o error

------------------------------------------------------------
12. Métodos de detalle
    - _mostrarDetallesCompletosBahia:
      - Muestra AlertDialog con información completa de bahía
      - Usa _buildDetalleItem para cada fila de información
    - _buildDetalleItem:
      - Row con título en negrita y valor
      - Padding vertical de 4

------------------------------------------------------------
13. Métodos de opciones
    - _mostrarOpcionesBahia:
      - BottomSheet con opciones según estado de bahía y si es administrador
      - Opciones:
        - Reservar, Poner en uso, Poner en mantenimiento, Liberar, Cancelar, Ver detalles
      - Cada opción llama al método correspondiente
    - _buildBotonOpcion:
      - ElevatedButton.icon con ancho completo, icono, texto, color y acción

14. Método de notificaciones
    - _mostrarNotificaciones:
      - AlertDialog simple con mensaje "No hay notificaciones nuevas."

------------------------------------------------------------
15. Métodos auxiliares de textos
    - _getTipoBahiaText: Convierte TipoBahia a String legible
    - _getEstadoBahiaText: Convierte EstadoBahia a String legible

------------------------------------------------------------




# reservation_screen.dart
MANUAL TÉCNICO DETALLADO – RESERVATION SCREEN FLUTTER

------------------------------------------------------------
1. Importaciones
   - import 'package:flutter/material.dart';
     -> Biblioteca principal de Flutter para widgets y UI.
   - import 'package:provider/provider.dart';
     -> Permite usar Provider para gestión de estado.
   - import 'package:bahias_descarga_system/providers/bahia_provider.dart';
     -> Proveedor de estado y métodos para bahías.
   - import 'package:bahias_descarga_system/providers/reserva_provider.dart';
     -> Proveedor de estado y métodos para reservas.
   - import 'package:bahias_descarga_system/models/bahia_model.dart';
     -> Modelo de datos para bahías.
   - import 'package:bahias_descarga_system/widgets/custom_appbar.dart';
     -> Widget de AppBar personalizado.
   - import 'package:bahias_descarga_system/utils/constants.dart';
     -> Constantes de la aplicación (padding, dimensiones, etc.).

------------------------------------------------------------
2. Declaración de clase principal
   - class ReservationScreen extends StatefulWidget
     -> Pantalla de reserva de bahía con estado mutable.
   - const ReservationScreen({Key? key}) : super(key: key)
     -> Constructor por defecto.
   - _ReservationScreenState createState() => _ReservationScreenState()
     -> Crea el estado asociado.

3. Estado de la pantalla
   - final _formKey = GlobalKey<FormState>();
     -> Clave para controlar la validación del formulario.
   - late DateTime _fechaInicio;
     -> Fecha y hora de inicio de la reserva.
   - late DateTime _fechaFin;
     -> Fecha y hora de fin de la reserva.
   - late Bahia _bahia;
     -> Objeto de la bahía seleccionada.
   - bool _isLoading = false;
     -> Indicador de carga mientras se procesa la reserva.

------------------------------------------------------------
4. Ciclo de vida
   - didChangeDependencies()
     -> Se ejecuta cuando se cargan las dependencias del widget.
     -> Obtiene la bahía enviada por Navigator (ModalRoute).
     -> Inicializa _fechaInicio = ahora y _fechaFin = una hora después.

------------------------------------------------------------
5. Selección de fecha y hora
   - Future<void> _selectDateTime(BuildContext context, bool isStartDate)
     -> Abre un DatePicker y luego un TimePicker.
     -> Combina fecha y hora seleccionadas en un DateTime.
     -> Actualiza _fechaInicio o _fechaFin según corresponda.
     -> Si _fechaFin es antes de _fechaInicio, lo ajusta automáticamente.

------------------------------------------------------------
6. Envío del formulario
   - void _submitReservation()
     -> Valida el formulario (_formKey.currentState!.validate())
     -> Comprueba que _fechaFin sea posterior a _fechaInicio
     -> Cambia _isLoading a true para mostrar indicador
     -> Obtiene providers: BahiaProvider y ReservaProvider
     -> Simula usuario actual (en app real se usaría AuthProvider)
     -> Llama a:
        - bahiaProvider.reservarBahia(...) para actualizar estado de la bahía
        - reservaProvider.crearReserva(...) para crear registro de reserva
     -> Muestra SnackBar según éxito o error
     -> Navega hacia atrás si reserva exitosa
     -> Siempre finaliza con setState(() => _isLoading = false)

------------------------------------------------------------
7. Método build
   - return Scaffold(
       appBar: CustomAppBar(title: 'Reservar Bahía ${_bahia.numero}'),
       body: Padding(
         padding: AppDimensions.paddingLarge,
         child: Form(
           key: _formKey,
           child: ListView(
             children: [
               // Card 1: Información de la bahía
               Card(
                 child: Padding(
                   padding: AppDimensions.paddingMedium,
                   child: Column(
                     crossAxisAlignment: CrossAxisAlignment.start,
                     children: [
                       Text('Información de la bahía', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                       SizedBox(height: paddingMedium),
                       Row(children: [Text('Número: ', style: bold), Text('${_bahia.numero}')]),
                       Row(children: [Text('Tipo: ', style: bold), Text(_bahia.nombreTipo)]),
                       Row(children: [Text('Estado: ', style: bold), Text(_bahia.nombreEstado)]),
                     ],
                   ),
                 ),
               ),

               SizedBox(height: paddingLarge),

               // Card 2: Detalles de la reserva
               Card(
                 child: Padding(
                   padding: paddingMedium,
                   child: Column(
                     crossAxisAlignment: CrossAxisAlignment.start,
                     children: [
                       Text('Detalles de la reserva', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                       SizedBox(height: paddingMedium),
                       ListTile(
                         title: Text('Fecha y hora de inicio'),
                         subtitle: Text('${_fechaInicio.toString().substring(0,16)}'),
                         trailing: Icon(Icons.calendar_today),
                         onTap: () => _selectDateTime(context, true),
                       ),
                       ListTile(
                         title: Text('Fecha y hora de fin'),
                         subtitle: Text('${_fechaFin.toString().substring(0,16)}'),
                         trailing: Icon(Icons.calendar_today),
                         onTap: () => _selectDateTime(context, false),
                       ),
                       SizedBox(height: paddingMedium),
                       Divider(),
                       ListTile(
                         title: Text('Duración total'),
                         subtitle: Text('${_fechaFin.difference(_fechaInicio).inHours} horas '
                                        '${_fechaFin.difference(_fechaInicio).inMinutes.remainder(60)} minutos'),
                       ),
                     ],
                   ),
                 ),
               ),

               SizedBox(height: paddingLarge),

               // Botón de confirmación
               SizedBox(
                 width: double.infinity,
                 child: ElevatedButton(
                   onPressed: _isLoading ? null : _submitReservation,
                   child: _isLoading ? CircularProgressIndicator() : Text('Confirmar Reserva'),
                 ),
               ),
             ],
           ),
         ),
       ),
     )

------------------------------------------------------------
8. Notas adicionales
   - Los paddings se obtienen de AppDimensions para consistencia.
   - Se utiliza ListView para que la pantalla sea scrollable.
   - Se usan Cards y ListTiles para organizar visualmente la información.
   - _isLoading bloquea el botón mientras se procesa la reserva.
   - Validaciones básicas:
       - Fecha fin posterior a fecha inicio
       - Formulario válido
   - Se separan claramente:
       - Información de la bahía
       - Detalles de la reserva
       - Botón de acción







# profile_screen.dart
MANUAL TÉCNICO DETALLADO – PROFILE SCREEN FLUTTER

------------------------------------------------------------
1. Importaciones
   - import 'package:flutter/material.dart';
     -> Biblioteca principal de Flutter para widgets y construcción de UI.
   - import 'package:bahias_descarga_system/widgets/custom_appbar.dart';
     -> Widget personalizado para la AppBar de la aplicación.
   - import 'package:bahias_descarga_system/utils/constants.dart';
     -> Contiene constantes de la aplicación (paddings, dimensiones, textos, etc.).

------------------------------------------------------------
2. Declaración de clase principal
   - class ProfileScreen extends StatelessWidget
     -> Pantalla de perfil definida como widget sin estado mutable.
   - const ProfileScreen({Key? key}) : super(key: key)
     -> Constructor por defecto.

------------------------------------------------------------
3. Método build
   - Widget build(BuildContext context)
     -> Construye la UI de la pantalla.
     -> Retorna un Scaffold como contenedor principal:

     Scaffold(
       appBar: CustomAppBar(title: 'Perfil'),
       -> AppBar personalizado con el título "Perfil".

       body: Center(
         child: Text('Pantalla de Perfil - En desarrollo'),
       ),
       -> Contenido centrado en la pantalla.
       -> Se muestra un texto indicando que la funcionalidad aún no está implementada.
     )

------------------------------------------------------------
4. Notas adicionales
   - Es un placeholder o pantalla en desarrollo para futuras funcionalidades de perfil.
   - Se puede expandir en el futuro para mostrar:
       - Información del usuario
       - Opciones de configuración
       - Imagen de perfil
       - Botones para actualizar datos o cerrar sesión
   - Al ser StatelessWidget, no hay gestión de estado en esta pantalla.
   - Uso de CustomAppBar mantiene consistencia con otras pantallas de la app.


