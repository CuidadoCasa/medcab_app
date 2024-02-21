import 'dart:convert';

Driver driverFromJson(String str) => Driver.fromJson(json.decode(str));

String driverToJson(Driver data) => json.encode(data.toJson());

class Driver {
  Driver({
    this.id,
    this.username,
    this.email,
    this.password,
    this.plate,
    this.token,
    this.image,

    this.hasCedula,
    this.hasINE,
    this.hasTitulo,
    this.isAutorizado,
    this.hasConnect,
    this.idStripe,
    this.hasAcepTyC,
    this.hasClab,

    this.hasDomicilio,
    this.hasFiscal,
    this.hasCartas,
  });

  String ? id;
  String ? username;
  String ? email;
  String ? password;
  String ? plate;
  String ? token;
  String ? image;

  int ? hasCedula;
  int ? hasINE;
  int ? hasTitulo;
  int ? isAutorizado;
  int ? hasConnect;
  String ? idStripe;
  int ? hasAcepTyC;
  int ? hasClab;

  int ? hasDomicilio;
  int ? hasFiscal;
  int ? hasCartas;


  factory Driver.fromJson(Map<String, dynamic> json) => Driver(
    id: json["id"],
    username: json["username"],
    email: json["email"],
    password: json["password"],
    plate: json["plate"],
    token: json["token"],
    image: json["image"],

    hasCedula: json["hasCedula"] ?? 0,
    hasINE: json["hasINE"] ?? 0,
    hasTitulo: json["hasTitulo"] ?? 0,
    isAutorizado: json["isAutorizado"] ?? 0,
    hasConnect: json["hasConnect"] ?? 0,
    idStripe: json["idStripe"] ?? '',
    hasAcepTyC: json["hasAcepTyC"]?? 0,
    hasClab: json["hasClab"]?? 0,

    hasDomicilio: json["hasDomicilio"] ?? 0,
    hasFiscal: json["hasFiscal"] ?? 0,
    hasCartas: json["hasCartas"] ?? 0,
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "username": username,
    "email": email,
    "plate": plate,
    "token": token,
    "image": image,

    "hasCedula": hasCedula,
    "hasINE": hasINE,
    "hasTitulo": hasTitulo,
    "isAutorizado": isAutorizado,
    "hasConnect": hasConnect,
    "idStripe": idStripe,
    "hasAcepTyC": hasAcepTyC,
    "hasClab": hasClab,

    "hasDomicilio": hasDomicilio,
    "hasFiscal": hasFiscal,
    "hasCartas": hasCartas,
  };
}
