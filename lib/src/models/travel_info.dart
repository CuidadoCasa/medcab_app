import 'dart:convert';

TravelInfo travelInfoFromJson(String str) => TravelInfo.fromJson(json.decode(str));

String travelInfoToJson(TravelInfo data) => json.encode(data.toJson());

class TravelInfo {
  TravelInfo({
    this.id,
    this.status,
    this.idDriver,
    this.from,
    this.to,
    this.idTravelHistory,
    this.fromLat,
    this.fromLng,
    this.toLat,
    this.toLng,
    this.price,

    this.costo,
    this.pacientes,
    this.nombre,
    this.descripcion,
    this.servicios,

    this.statusSolicitud,
    this.codigoConfirmacion,
    this.connectAsociado,
    this.transaccionID,

  });

  String ? id;
  String ? status;
  String ? idDriver;
  String ? from;
  String ? to;
  String ? idTravelHistory;
  double ? fromLat;
  double ? fromLng;
  double ? toLat;
  double ? toLng;
  double ? price;

  int ? costo;
  int ? pacientes;
  String ? nombre;
  String ? descripcion;
  List<dynamic> ? servicios;

  int ? statusSolicitud;
  String ? codigoConfirmacion;
  String ? connectAsociado;
  String ? transaccionID;

  factory TravelInfo.fromJson(Map<String, dynamic> json) => TravelInfo(
    id: json["id"],
    status: json["status"],
    idDriver: json["idDriver"],
    from: json["from"],
    to: json["to"],
    idTravelHistory: json["idTravelHistory"],
    fromLat: json["fromLat"]?.toDouble() ?? 0,
    fromLng: json["fromLng"]?.toDouble() ?? 0,
    toLat: json["toLat"]?.toDouble() ?? 0,
    toLng: json["toLng"]?.toDouble() ?? 0,
    price: json["price"]?.toDouble() ?? 0,

    costo: json["costo"] ?? 0,
    pacientes: json["pacientes"] ?? 0,
    nombre: json["nombre"] ?? '',
    descripcion: json["descripcion"] ?? '',
    servicios: json["servicios"] ?? [],

    statusSolicitud: json["statusSolicitud"] ?? 1,
    codigoConfirmacion: json["codigoConfirmacion"] ?? '',
    connectAsociado: json["connectAsociado"] ?? '',
    transaccionID: json["transaccionID"] ?? ''

  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "status": status,
    "idDriver": idDriver,
    "from": from,
    "to": to,
    "idTravelHistory": idTravelHistory,
    "fromLat": fromLat,
    "fromLng": fromLng,
    "toLat": toLat,
    "toLng": toLng,
    "price": price,

    "costo": costo,
    "pacientes": pacientes,
    "nombre": nombre,
    "descripcion": descripcion,
    "servicios": servicios,

    "statusSolicitud": statusSolicitud,
    "codigoConfirmacion": codigoConfirmacion,
    "connectAsociado": connectAsociado,
    "transaccionID": transaccionID
  };
}