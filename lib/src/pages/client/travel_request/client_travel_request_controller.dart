import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:app_medcab/src/providers/variables_provider.dart';
import 'package:app_medcab/src/shared/avisos.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:app_medcab/src/models/driver.dart';
import 'package:app_medcab/src/models/travel_info.dart';
import 'package:app_medcab/src/providers/auth_provider.dart';
import 'package:app_medcab/src/providers/driver_provider.dart';
import 'package:app_medcab/src/providers/geofire_provider.dart';
import 'package:app_medcab/src/providers/push_notifications_provider.dart';
import 'package:app_medcab/src/providers/travel_info_provider.dart';
import 'package:app_medcab/src/utils/snackbar.dart' as utils;
import 'package:firebase_auth/firebase_auth.dart' as authaux;
import 'package:provider/provider.dart';

class ClientTravelRequestController {

  BuildContext ? context;
  Function ? refresh;
  GlobalKey<ScaffoldState> key = GlobalKey<ScaffoldState>();

  String ? from;
  String ? to;
  LatLng ? fromLatLng;
  LatLng ? toLatLng;

  int ? costo;
  int ? pacientes;
  int ? statusSolicitud;
  String ? codigoConfirmacion;
  String ? nombre;
  String ? descripcion;
  String ? uidCustomer;
  
  String ? connectAsociado;
  String ? transaccionID;

  List<dynamic> ? servicios;

  TravelInfoProvider ? _travelInfoProvider;
  AuthProvider ? _authProvider;
  DriverProvider ? _driverProvider;
  GeofireProvider ? _geofireProvider;
  PushNotificationsProvider ? _pushNotificationsProvider;

  List<String> nearbyDrivers = [];

  StreamSubscription<List<DocumentSnapshot>> ? _streamSubscription;
  StreamSubscription<DocumentSnapshot> ? _streamStatusSubscription;

  String baseUrl = 'https://api-medcab.onrender.com';

  Future init(BuildContext context, Function refresh) async {
    this.context = context;
    this.refresh = refresh;

    _travelInfoProvider = TravelInfoProvider();
    _authProvider = AuthProvider();
    _driverProvider = DriverProvider();
    _geofireProvider = GeofireProvider();
    _pushNotificationsProvider = PushNotificationsProvider();

    Map<String, dynamic> arguments = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    from = arguments['from'];
    to = arguments['to'];
    fromLatLng = arguments['fromLatLng'];
    toLatLng = arguments['toLatLng'];

    costo = arguments['costo'].round();
    pacientes = arguments['pacientes'];
    nombre = arguments['nombre'];
    descripcion = arguments['descripcion'];
    servicios = arguments['servicios'];

    statusSolicitud = arguments['statusSolicitud'];
    codigoConfirmacion = arguments['codigoConfirmacion'];

    connectAsociado = arguments['connectAsociado'];
    transaccionID = arguments['transaccionID'];

    _createTravelInfo();
    _getNearbyDrivers();
  }

  void _checkDriverResponse() {
    Stream<DocumentSnapshot> stream = _travelInfoProvider!.getByIdStream(_authProvider!.getUser()!.uid);
    _streamStatusSubscription = stream.listen((DocumentSnapshot document) {
      TravelInfo travelInfo = TravelInfo.fromJson(document.data() as Map<String,dynamic>);

      connectAsociado = travelInfo.connectAsociado;

      if (travelInfo.idDriver != null && travelInfo.status == 'accepted' && travelInfo.statusSolicitud == 3) {
        Navigator.pushNamedAndRemoveUntil(context!, 'client/travel/map', (route) => false);
      } else 
      if (travelInfo.status == 'no_accepted') {
        utils.Snackbar.showSnackbar(context!, key, 'Servicio no aceptado');

        Future.delayed(const Duration(milliseconds: 4000), () {
          Navigator.pushNamedAndRemoveUntil(context!, 'client/map', (route) => false);
        });
      }
      
      if(travelInfo.statusSolicitud == 2){
        MisAvisos().ventanaConfirmarAccion(
          context!, 
          'Para completar tu solicitud por favor confirme su método de pago.', 
          ()=> _makePago()
        );
      }

    });
  }

  void _makePago() async {
    final dataProvider = Provider.of<VariablesProvider>(context!, listen: false);
    MisAvisos().ventanaTrabajando(context!, 'Cargando información...');

    if(dataProvider.dataUsuario['costumer'].toString().isEmpty){
      await _checkLicencias();
    }

    if(connectAsociado!.isNotEmpty && (connectAsociado != null)){

      double montoConnect = (costo! * 0.3).roundToDouble();
      Map<String,dynamic> response = await _getClientSecret(costo!.toDouble(), connectAsociado!, montoConnect);
      String claveEfim = await _getClaveEfimera(dataProvider.dataUsuario['costumer']);
      String uidSetupIntent = await _crearSetupIntent(dataProvider.dataUsuario['costumer']);
      
      String clientSecret = response['client'];
      transaccionID = response['id'];

      if(clientSecret.isNotEmpty && claveEfim.isNotEmpty && uidSetupIntent.isNotEmpty){
        Navigator.pop(context!);
        Navigator.pop(context!);
        await _initializePaymentSheet(clientSecret, uidSetupIntent, claveEfim, dataProvider.dataUsuario['costumer'], transaccionID!);
      } else {
        Navigator.pop(context!);
      }
    } else {
      Navigator.pop(context!);
    }
  }

  Future<Map<String,dynamic>> _getClientSecret(double amount, String idConnect, double gananciaCuentaConnect)async{
    final dataProvider = Provider.of<VariablesProvider>(context!, listen: false);

    Dio dio = Dio();
    String barer = '';

    if(dataProvider.isModeTest){
      barer = 'Bearer ${dotenv.env['STRIPE_SK_TEST']}';
    } else {
      barer = 'Bearer ${dotenv.env['STRIPE_SK']}';
    }

    var response = await dio.post(
      'https://api.stripe.com/v1/payment_intents',
      options: Options(
        headers: {
          'Authorization': barer,
          'Content-Type': 'application/x-www-form-urlencoded'
        },
      ),
      data: {
        'amount': _calculateAmount(amount),
        'currency': 'MXN',
        'capture_method': 'manual',
        'transfer_data': {
          'destination': idConnect,
          'amount': _calculateAmount(gananciaCuentaConnect),
        },
        'customer': dataProvider.dataUsuario['costumer'],
        'metadata': {
          'customer_name': dataProvider.dataUsuario['nombre'],
          'customer_email': dataProvider.dataUsuario['correo'],
          'product_id': 'MedCab',
        },
      },
    );
    return {
      'client' : response.data['client_secret'],
      'id'     : response.data['id']
    };
  }
  
  Future<String> _getClaveEfimera(String idCustomer) async {
    String miClaveEfimera = '';
    final variablesProvider = Provider.of<VariablesProvider>(context!, listen: false);


    try {
      Dio dio = Dio();
      String url = '';
      url = variablesProvider.isModeTest ? '$baseUrl/api/test/medcab/crearClaveEfimera' : '$baseUrl/api/medcab/crearClaveEfimera';

      Map<String, dynamic> datos = {
        'isUserCostumerStripe' : idCustomer,
      };

      Response response = await dio.post(
        url,
        data: datos,
      );

      if(response.statusCode == 200){
        miClaveEfimera = response.data['ephemeralKey'];
      }
      return miClaveEfimera;

    } catch (e) {
      return '';
    }
  }

  Future<String> _crearSetupIntent(String idCostumer) async {
    String miClientSetup = '';
    final variablesProvider = Provider.of<VariablesProvider>(context!, listen: false);

    try {
      Dio dio = Dio();
      String 
      url = variablesProvider.isModeTest ? '$baseUrl/api/test/medcab/crearSetUpIntent' : '$baseUrl/api/medcab/crearSetUpIntent';

      Map<String, dynamic> datos = {
        'isUserCostumerStripe' : idCostumer,
      };

      Response response = await dio.post(
        url,
        data: datos,
      );

      if(response.statusCode == 200){
        miClientSetup = response.data['clientSecret'];
      }
      return miClientSetup;

    } catch (e) {
      return '';
    }
  }

  Future<void> _initializePaymentSheet(String clientSecret, String setupIntent, String claveEfimera, String customerID, String id)async{
    try {
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          setupIntentClientSecret: setupIntent,
          customerEphemeralKeySecret: claveEfimera,
          customerId: customerID,
          merchantDisplayName: 'MedCab',
        ),
      );
      await Stripe.instance.presentPaymentSheet();
      await continuarPagoExitoso(id);
    } catch(e){
      Navigator.pop(context!);
      pagoFallido();
      utils.Snackbar.showSnackbar(context!, key, 'Pago fallido intentar nuevamente');
    }
  }

  int _calculateAmount(double amount) {
    String montoString = amount.toStringAsFixed(2);
    double montoFinal = double.parse(montoString);

    final calculatedAmount = (montoFinal * 100).truncate();
    return calculatedAmount;
  }

  Future<void> _checkLicencias() async {
    final user = authaux.FirebaseAuth.instance.currentUser;
    final dataProvider = Provider.of<VariablesProvider>(context!, listen: false);

    String uidUser = '';

    if(user != null){
      uidUser = user.uid;
      
      if(dataProvider.dataUsuario['costumer'].toString().isEmpty){
        DocumentSnapshot<Map<String, dynamic>> datos = await FirebaseFirestore.instance
        .collection('Clients')
        .doc(uidUser)
        .collection('informacion')
        .doc('personal')
        .get();

        if(datos.data() != null){
          Map<String,dynamic> userData = datos.data()!;
          uidCustomer = userData.containsKey('idCostumerStripe') ? userData['idCostumerStripe'] : '';
          dataProvider.dataUsuario.update('costumer', (value) => uidCustomer);
        }
      }

    }
  }

  void dispose () {
    _streamSubscription?.cancel();
    _streamStatusSubscription?.cancel();
  }

  void _getNearbyDrivers() {
    Stream<List<DocumentSnapshot>> stream = _geofireProvider!.getNearbyDrivers(
      fromLatLng!.latitude,
      fromLatLng!.longitude,
      3.5
    );

    _streamSubscription = stream.listen((List<DocumentSnapshot> documentList) {
      for (DocumentSnapshot d in documentList) {
        nearbyDrivers.add(d.id);
      }

      if(nearbyDrivers.isNotEmpty){
        getDriverInfo(nearbyDrivers[0]); 
      }

      _streamSubscription?.cancel();
    });
  }

  void _createTravelInfo() async {
    TravelInfo travelInfo = TravelInfo(
      id: _authProvider!.getUser()!.uid,
      from: from,
      to: to,
      fromLat: fromLatLng!.latitude,
      fromLng: fromLatLng!.longitude,
      toLat: toLatLng!.latitude,
      toLng: toLatLng!.longitude,

      costo: costo,
      pacientes: pacientes,
      nombre: nombre,
      descripcion: descripcion,
      servicios: servicios,

      codigoConfirmacion: codigoConfirmacion,
      statusSolicitud: statusSolicitud,

      connectAsociado: connectAsociado,
      transaccionID: transaccionID,

      status: 'created',
    );

    await _travelInfoProvider!.create(travelInfo);
    _checkDriverResponse();
  }

  Future<void> getDriverInfo(String idDriver) async {
    Driver ? driver = await _driverProvider!.getById(idDriver);
    _sendNotification(driver!.token!);
  }

  void _sendNotification(String token) {
    Map<String, dynamic> data = {
      'click_action': 'FLUTTER_NOTIFICATION_CLICK',
      'idClient': _authProvider!.getUser()!.uid,
      'origin': from,
      'destination': to,
      'costo': costo,
      'pacientes': pacientes,
      'nombre': nombre,
      'descripcion': descripcion,
      'servicios': servicios,
    };
    _pushNotificationsProvider!.sendMessage(token, data, 'Solicitud de servicio', 'Un cliente esta solicitando atención');
  }

  Future<void> continuarPagoExitoso(String idTransaccion) async {
    Map<String, dynamic> data = {
      'transaccionID': idTransaccion,
      'statusSolicitud': 3
    };
    await _travelInfoProvider!.update(data, _authProvider!.getUser()!.uid);
  }

  void cancelTravel() {
    Map<String, dynamic> data = {
      'status': 'cancel',
      'statusSolicitud': 1
    };
    _travelInfoProvider!.update(data, _authProvider!.getUser()!.uid);
    Navigator.pushNamedAndRemoveUntil(context!, 'client/map', (route) => false);
  }

  void pagoFallido(){
    Map<String, dynamic> data = {
      'statusSolicitud': 2
    };
    _travelInfoProvider!.update(data, _authProvider!.getUser()!.uid);
  }

}