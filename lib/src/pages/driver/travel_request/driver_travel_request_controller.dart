import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:app_medcab/src/models/driver.dart';
import 'package:app_medcab/src/models/travel_info.dart';
import 'package:app_medcab/src/providers/driver_provider.dart';
import 'package:app_medcab/src/shared/avisos.dart';
import 'package:app_medcab/src/shared/colors.dart';
import 'package:firebase_auth/firebase_auth.dart' as authaux;
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:app_medcab/src/models/client.dart';
import 'package:app_medcab/src/providers/client_provider.dart';
import 'package:app_medcab/src/providers/geofire_provider.dart';
import 'package:app_medcab/src/utils/shared_pref.dart';
import 'package:app_medcab/src/providers/travel_info_provider.dart';
import 'package:app_medcab/src/providers/auth_provider.dart';

class DriverTravelRequestController {

  final _paletaColors = PaletaColors();

  BuildContext ? context;
  GlobalKey<ScaffoldState> key = GlobalKey();
  Function ? refresh;
  SharedPref ? _sharedPref;

  String ? from;
  String ? to;
  String ? idClient;
  Client ? client;
  Driver ? driverInfo;

  ClientProvider ? _clientProvider;
  TravelInfoProvider ? _travelInfoProvider;
  DriverProvider ? _driverProvider;
  AuthProvider ? _authProvider;
  GeofireProvider ? _geofireProvider;

  Timer ? _timer;
  int seconds = 30;

  int ? costo;
  int ? pacientes;
  String ? nombre;
  String ? descripcion;
  List<dynamic> ? servicios;
  
  StreamSubscription<DocumentSnapshot> ? _streamStatusSubscription;

  Future init (BuildContext context, Function refresh) async {
    this.context = context;
    this.refresh = refresh;
    _sharedPref = SharedPref();
    _sharedPref!.save('isNotification', 'false');

    _clientProvider = ClientProvider();
    _travelInfoProvider = TravelInfoProvider();
    _authProvider = AuthProvider();
    _geofireProvider = GeofireProvider();
    _driverProvider = DriverProvider();

    Map<String, dynamic> arguments = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    from = arguments['origin'];
    to = arguments['destination'];
    idClient = arguments['idClient'];

    costo = int.parse(arguments['costo']);
    pacientes = int.parse(arguments['pacientes']);
    nombre = arguments['nombre'];
    descripcion = arguments['descripcion'];
    servicios = jsonDecode(arguments['servicios']);
    await getDriverInfo();
    getClientInfo();
    startTimer();
    _checkDriverResponse();
  }

  void _checkDriverResponse() {
    Stream<DocumentSnapshot> stream = _travelInfoProvider!.getByIdStream(idClient!);

    _streamStatusSubscription = stream.listen((DocumentSnapshot document) {

      TravelInfo travelInfo = TravelInfo.fromJson(document.data() as Map<String,dynamic>);

      if(travelInfo.statusSolicitud == 3 && travelInfo.status != 'finished'){
        acceptTravel();
      }
      
      if(travelInfo.status == 'cancel'){
        _timer?.cancel();
        updatedTravel();
        MisAvisos().ventanaAvisoNullAction(context!, 'Servicio cancelado por el paciente');
        Future.delayed(const Duration(milliseconds: 3000), () {
          Navigator.pushNamedAndRemoveUntil(context!, 'driver/map', (route) => false);
        });
      }

    });
  }

  void updatedTravel() {
    Map<String, dynamic> data = {
      'status': 'created',
      'statusSolicitud': 1,
      'connectAsociado': ''
    };
    _travelInfoProvider!.update(data, idClient!);
  }

  void siguienteStatus(){
    Map<String, dynamic> data = {
      'statusSolicitud': 2,
      'connectAsociado': driverInfo!.idStripe
    };
    _timer?.cancel();
    _mostrarBottomSheet();
    _travelInfoProvider!.update(data, idClient!);
  }

  void _mostrarBottomSheet(){
     showModalBottomSheet(
      context: context!,
      isDismissible: false,
      builder: (BuildContext context) {
        return Container(
          height: 200,
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 250,
                  child: LinearProgressIndicator(
                    color: _paletaColors.mainA,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Confirmando los detalles del servicio con el paciente. Por favor espere el proceso puede demorar unos segundos.',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void dispose () {
    _timer?.cancel();
    _streamStatusSubscription?.cancel();
  }

  void startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      seconds = seconds - 1;
      refresh!();
      if (seconds == 0) {
        cancelTravel();
      }
    });
  }

  void acceptTravel() {
    Map<String, dynamic> data = {
      'idDriver': _authProvider!.getUser()!.uid,
      'status': 'accepted',
    };

    _timer?.cancel();
    _streamStatusSubscription?.cancel();

    _travelInfoProvider!.update(data, idClient!);
    _geofireProvider!.delete(_authProvider!.getUser()!.uid);
    Navigator.pushNamedAndRemoveUntil(context!, 'driver/travel/map', (route) => false, arguments: idClient);
    // Navigator.pushReplacementNamed(context, 'driver/travel/map', arguments: idClient);
  }

  void cancelTravel() {
    Map<String, dynamic> data = {
      'status': 'no_accepted'
    };
    _timer?.cancel();
    _travelInfoProvider!.update(data, idClient!);
    Navigator.pushNamedAndRemoveUntil(context!, 'driver/map', (route) => false);
  }

  void getClientInfo() async {
    client = await _clientProvider!.getById(idClient!);
    refresh!();
  }

  Future<void> getDriverInfo() async {
    final user = authaux.FirebaseAuth.instance.currentUser;
    String idUser = user!.uid;
    driverInfo = await _driverProvider!.getById(idUser);
  }

}