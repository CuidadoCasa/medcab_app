import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:app_medcab/src/pages/client/map/places_search.dart';
import 'package:app_medcab/src/pages/client/metodos_pago/mis_metodos_pago.dart';
import 'package:app_medcab/src/pages/client/servicios/servicios_detalle_page.dart';
import 'package:app_medcab/src/pages/client/servicios/servicios_page.dart';
import 'package:app_medcab/src/pages/client/perfil/client_perfil.dart';
import 'package:app_medcab/src/providers/variables_provider.dart';
import 'package:app_medcab/src/shared/avisos.dart';
import 'package:app_medcab/src/shared/map_theme.dart';
import 'package:firebase_auth/firebase_auth.dart' as authaux;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:location/location.dart' as location;
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:progress_dialog2/progress_dialog2.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:app_medcab/src/utils/snackbar.dart' as utils;
import 'package:app_medcab/src/utils/my_progress_dialog.dart';
import 'package:app_medcab/src/providers/auth_provider.dart';
import 'package:app_medcab/src/providers/geofire_provider.dart';
import 'package:app_medcab/src/providers/client_provider.dart';
import 'package:app_medcab/src/providers/push_notifications_provider.dart';
import 'package:app_medcab/src/models/client.dart';
import 'package:provider/provider.dart';

class ClientMapController {

  BuildContext ? context;
  Function ? refresh;
  GlobalKey<ScaffoldState> key = GlobalKey<ScaffoldState>();
  final Completer<GoogleMapController> _mapController = Completer();

  CameraPosition initialPosition = const CameraPosition(
    target: LatLng(21.831120, -101.521867),
    zoom: 5
  );

  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};

  Position ? _position;
  StreamSubscription<Position> ? _positionStream;

  BitmapDescriptor ? markerDriver;

  GeofireProvider ? _geofireProvider;
  AuthProvider ? _authProvider;
  ClientProvider ? _clientProvider;
  PushNotificationsProvider ? _pushNotificationsProvider;

  bool isConnect = false;
  // ignore: unused_field
  ProgressDialog ? _progressDialog;

  StreamSubscription<DocumentSnapshot> ? _statusSuscription;
  StreamSubscription<DocumentSnapshot> ? _clientInfoSubscription;

  Client ? client;

  String ? from;
  LatLng ? fromLatLng;

  String ? to;
  LatLng ? toLatLng;
  String ? ciudad;

  String ? referenciaEstado;
  String ? referenciaCiudad;

  bool isFromSelected = true;
  bool hasMetodosAsociados = false;

  double porcentajeAumentoPaquetes = 0;

  Map<String,dynamic> mapPaqueteSelect = {};
  int indexPaqueteSelect = 1102;
  List<Map<String,dynamic>> listInfoPaquetes = [];
  
  String baseUrl = 'https://api-medcab.onrender.com';
  
  String refCobertura = '';

  List<Color> colorsPastel = [
    const Color(0xFFFFD1DC),
    const Color(0xFFADD8E6),
    const Color(0xFFB2F0B2),
    const Color(0xFFFFFACD),
    const Color(0xFFE6E6FA),
    const Color(0xFFFFDAB9),
    const Color(0xFF98FB98),
  ];

  Future init(BuildContext context, Function refresh) async {
    this.context = context;
    this.refresh = refresh;
    _geofireProvider = GeofireProvider();
    _authProvider =  AuthProvider();
    _clientProvider =  ClientProvider();
    _pushNotificationsProvider =  PushNotificationsProvider();
    _progressDialog = MyProgressDialog.createProgressDialog(context, 'Conectandose...');
    markerDriver = await createMarkerImageFromAsset('assets/img/icon_enfermera.png');
    saveToken();
    // await _checkMetodosPago();
    // checkGPS();
    // getClientInfo();
    // await getPaquetes();
    _checkStatusLastService();
  }

  void _checkStatusLastService() async {
    String userClient = authaux.FirebaseAuth.instance.currentUser!.uid;
    Map<String,dynamic> mapAuxTemp = {};
    final dataLastService = await FirebaseFirestore.instance
    .collection('TravelInfo')
    .doc(userClient)
    .get();

    if(dataLastService.data() != null){
      mapAuxTemp = dataLastService.data()!;
      if(mapAuxTemp['statusSolicitud'] == 3 && (mapAuxTemp['status'] == 'accepted' || mapAuxTemp['status'] == 'started')){
        Navigator.pushNamedAndRemoveUntil(context!, 'client/travel/map', (route) => false);
      } else {
        checkGPS();
        getClientInfo();
        await getPaquetes();
      }
    } else {
      checkGPS();
      getClientInfo();
      await getPaquetes();
    }
  }

  void getClientInfo() {
    Stream<DocumentSnapshot> clientStream = _clientProvider!.getByIdStream(_authProvider!.getUser()!.uid);
    _clientInfoSubscription = clientStream.listen((DocumentSnapshot document) {
      client = Client.fromJson(document.data() as Map<String,dynamic>);
      refresh!();
    });
  }

  void openDrawer() {
    key.currentState!.openDrawer();
  }

  void dispose() {
    _positionStream?.cancel();
    _statusSuscription?.cancel();
    _clientInfoSubscription?.cancel();
  }

  void signOut() async {
    MisAvisos().ventanaTrabajando(context!, 'Cerrando sesión...');
    await _authProvider!.signOut();
    Navigator.pop(context!);
    _navegar();
  }

  void _navegar(){
    Navigator.pushNamedAndRemoveUntil(context!, 'home', (route) => false);
  }

  void onMapCreated(GoogleMapController controller) {
    controller.setMapStyle(jsonEncode(mapTheme));
    _mapController.complete(controller);
  }

  void updateLocation() async  {
    try {
      await _determinePosition();
      _position = (await Geolocator.getLastKnownPosition())!;
      centerPosition();
      getNearbyDrivers();
    } catch(error) {
      debugPrint('Error en la localizacion: $error');
    }
  }

  void requestDriver() async {
    MisAvisos().ventanaTrabajando(context!, 'Iniciando...');
    await _checkMetodosPago();
    Navigator.pop(context!);

    if(!hasMetodosAsociados){
      MisAvisos().ventanaAviso(context!, 'Antes de solicitar su primer servicio, es necesario que tenga un método de pago asociado a su cuenta.');
    } else
    if(fromLatLng != null && toLatLng != null){
      Navigator.pushNamed(context!, 'client/travel/info', arguments: {
        'from': from,
        'to': to,
        'fromLatLng': fromLatLng,
        'toLatLng': toLatLng,
        'paquete': listInfoPaquetes[indexPaqueteSelect]
      });
    } else {
      utils.Snackbar.showSnackbar(context!, key, 'Seleccionar la ubicación del servicio.');
    }
  } 

  Future<bool> _hasCobertura() async {

    String ciudadRef = quitarAcentos(referenciaCiudad!).toLowerCase();
    String estadoRef = quitarAcentos(referenciaEstado!).toLowerCase();

    if(Platform.isIOS){
      int indexEstado = estadosMexico.indexWhere((element) => element.contains(estadoRef));
      if(indexEstado != -1){
        estadoRef = estadosMexico[indexEstado];
      }
    }

    final cobertura = await FirebaseFirestore.instance
    .collection('Cobertura')
    .doc(estadoRef)
    .get();

    final coberturaGeneral = await FirebaseFirestore.instance
    .collection('Cobertura')
    .doc('general')
    .get();

    Map<String,dynamic> dataRef = cobertura.data() ?? {};

    if(dataRef.containsKey('ciudades')){
      List<dynamic> listResult = dataRef['ciudades'].where((map)=> map['ciudad'] == ciudadRef).toList();
      if(listResult.isNotEmpty){
        porcentajeAumentoPaquetes = 0;
        porcentajeAumentoPaquetes = ((listResult.first['porcentaje'].toDouble())/100) + 1;

        for(int j = 0; j < listInfoPaquetes.length; j++){
          double montoPaquete = listInfoPaquetes[j]['base'].toDouble();
          double montoFinal = (montoPaquete * porcentajeAumentoPaquetes).roundToDouble();
          listInfoPaquetes[j].update('costo', (value) => montoFinal);
        }

        return true;
      } else {
        porcentajeAumentoPaquetes = ((coberturaGeneral['porcentaje'].toDouble())/100) + 1;

        for(int j = 0; j < listInfoPaquetes.length; j++){
          double montoPaquete = listInfoPaquetes[j]['base'].toDouble();
          double montoFinal = (montoPaquete * porcentajeAumentoPaquetes).roundToDouble();
          listInfoPaquetes[j].update('costo', (value) => montoFinal);
        }

        return true;
      }
    } else {
      porcentajeAumentoPaquetes = ((coberturaGeneral['porcentaje'].toDouble())/100) + 1;

      for(int j = 0; j < listInfoPaquetes.length; j++){
        double montoPaquete = listInfoPaquetes[j]['base'].toDouble();
        double montoFinal = (montoPaquete * porcentajeAumentoPaquetes).roundToDouble();
        listInfoPaquetes[j].update('costo', (value) => montoFinal);
      }

      return true;
    }
  }

  String quitarAcentos(String refe) {
    String input = refe.toLowerCase();
    return input.replaceAll(RegExp(r'[áÁ]'), 'a')
    .replaceAll(RegExp(r'[éÉ]'), 'e')
    .replaceAll(RegExp(r'[íÍ]'), 'i')
    .replaceAll(RegExp(r'[óÓ]'), 'o')
    .replaceAll(RegExp(r'[úÚ]'), 'u')
    .replaceAll('.', '')
    .replaceAll(RegExp(r'ciudad de '), '');
  }

  void buscarFunction() async {
    Map<String,dynamic> data = await Navigator.push(
      context!,
      MaterialPageRoute(
        builder: (BuildContext context) => const BusquedaPage()
      )
    );

    if(data['ciudad'].toString().isNotEmpty){
      
      String direccion = data['ciudad'].toString();
      double lat = data['lat'];
      double lng = data['lng'];

      if (isFromSelected) {
        from = direccion;
        fromLatLng =  LatLng(lat, lng);
        to = direccion;
        toLatLng =  LatLng(lat, lng);
      }

      referenciaCiudad = data['referenciaCiudad'];
      referenciaEstado = data['referenciaEstado'];

      animateCameraToPosition(lat, lng, 18);
      await _hasCobertura();
    }
    
    refresh!();
  }

  Future<void> setLocationDraggableInfo() async {
    double lat = initialPosition.target.latitude;
    double lng = initialPosition.target.longitude;
    
    List<Placemark> address = await placemarkFromCoordinates(lat, lng);

    if (address.isNotEmpty) {
      String ? direction = address[0].thoroughfare;
      String ? street = address[0].subThoroughfare;
      String ? city = address[0].locality;
      String ? department = address[0].administrativeArea;

      if (isFromSelected) {
        from = '$direction #$street, $city, $department';
        fromLatLng =  LatLng(lat, lng);
        to = '$direction #$street, $city, $department';
        toLatLng =  LatLng(lat, lng);
        
        referenciaCiudad = address.first.locality; 
        referenciaEstado = address.first.administrativeArea; 
        await _hasCobertura();
      }

      refresh!();
    }
  }

  void goToEditPage() {
    Navigator.push(
      context!,
      MaterialPageRoute<void>(
        builder: (BuildContext context) => PerfilClientPage(
          userId: client!.id!,
          username: client!.username!,
          image: (client!.image == null) ? '' : client!.image!,
        ),
      ),
    );
  }

  void goToHistoryPage() {
    Navigator.pushNamed(context!, 'client/history');
  }

  void goToServiciosPage(){
    Navigator.push(
      context!,
      MaterialPageRoute<void>(
        builder: (BuildContext context) => const ServiciosPage(),
      ),
    );
  }

  void goToMetodos(){
    Navigator.push(
      context!,
      MaterialPageRoute<void>(
        builder: (BuildContext context) => const MetodosPage(),
      ),
    );
  }

  void goToServicioDetailPage(){
    Navigator.push(
      context!,
      MaterialPageRoute<void>(
        builder: (BuildContext context) => const ServiciosDetallePage(),
      ),
    );
  }

  void saveToken() {
    _pushNotificationsProvider!.saveToken(_authProvider!.getUser()!.uid, 'client');
  }

  void getNearbyDrivers() {
    Stream<List<DocumentSnapshot>> stream = _geofireProvider!.getNearbyDrivers(_position!.latitude, _position!.longitude, 3.5);

    List<MarkerId> keysToRemove = [];

    stream.listen((List<DocumentSnapshot> documentList) {
      for (MarkerId m in markers.keys) {
        bool remove = true;

        for (DocumentSnapshot d in documentList) {
          if (m.value == d.id) {
            remove = false;
            break;
          }
        }

        if (remove) {
          keysToRemove.add(m);
        }
      }

      for (MarkerId m in keysToRemove) {
        markers.remove(m);
      }

      for (DocumentSnapshot d in documentList) {
        GeoPoint point = (d.data() as Map<String, dynamic>)['position']['geopoint'];
        addMarker(
          d.id,
          point.latitude,
          point.longitude,
          'Conductor disponible',
          d.id,
          markerDriver!,
        );
      }

      refresh!();
    });
  }

  // void getNearbyDrivers() {
  //   Stream<List<DocumentSnapshot>> stream = _geofireProvider!.getNearbyDrivers(_position!.latitude, _position!.longitude, 50);

  //   stream.listen((List<DocumentSnapshot> documentList) {

  //     for (MarkerId m in markers.keys) {
  //       bool remove = true;

  //       for (DocumentSnapshot d in documentList) {
  //         if (m.value == d.id) {
  //           remove = false;
  //         }
  //       }

  //       if (remove) {
  //         markers.remove(m);
  //         refresh!();
  //       }
  //     }

  //     for (DocumentSnapshot d in documentList) {
  //       GeoPoint point = (d.data() as Map<String,dynamic>) ['position']['geopoint'];
  //       addMarker(
  //         d.id,
  //         point.latitude,
  //         point.longitude,
  //         'Conductor disponible',
  //         d.id,
  //         markerDriver!
  //       );
  //     }

  //     refresh!();

  //   });
  // }

  void centerPosition() {
    if (_position != null) {
      animateCameraToPosition(_position!.latitude, _position!.longitude, 13);
    }
    else {
      utils.Snackbar.showSnackbar(context!, key, 'Activa el GPS para obtener la posicion');
    }
  }

  void checkGPS() async {
    bool isLocationEnabled = await Geolocator.isLocationServiceEnabled();
    if (isLocationEnabled) {
      updateLocation();
    }
    else {
      bool locationGPS = await location.Location().requestService();
      if (locationGPS) {
        updateLocation();
      }
    }

  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permantly denied, we cannot request permissions.');
    }

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse && permission != LocationPermission.always) {
        return Future.error('Location permissions are denied (actual value: $permission).');
      }
    }

    return await Geolocator.getCurrentPosition();
  }

  Future animateCameraToPosition(double latitude, double longitude, double zoom) async {
    GoogleMapController controller = await _mapController.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(
          bearing: 0,
          target: LatLng(latitude, longitude),
          zoom: zoom
        )
      )
    );
  }

  Future<BitmapDescriptor> createMarkerImageFromAsset(String path) async {
    ImageConfiguration configuration = const ImageConfiguration();
    BitmapDescriptor bitmapDescriptor =
    await BitmapDescriptor.fromAssetImage(configuration, path);
    return bitmapDescriptor;
  }

  void addMarker(String markerId, double lat, double lng, String title, String content, BitmapDescriptor iconMarker) {
    MarkerId id = MarkerId(markerId);
    Marker marker = Marker(
      markerId: id,
      icon: iconMarker,
      position: LatLng(lat, lng),
      infoWindow: InfoWindow(title: title, snippet: content),
      draggable: false,
      zIndex: 2,
      flat: true,
      anchor: const Offset(0.5, 0.5),
      rotation: _position!.heading
    );

    markers[id] = marker;
  }

  Future<void> getPaquetes() async {
    Map<String,dynamic> dataTemp = {};
    List<String> listKeys = [];

    final informacionTemp = await FirebaseFirestore.instance
    .collection('Paquetes')
    .doc('Enfermeria')
    .get();

    dataTemp = informacionTemp.data()!;
    listKeys = dataTemp.keys.toList();

    for(int i = 0; i < listKeys.length; i++){
      listInfoPaquetes.add(dataTemp[listKeys[i]]);
    }

    refresh!();
  }

  void selectPaquete(int indexSelect){
    indexPaqueteSelect = indexSelect;
    mapPaqueteSelect = listInfoPaquetes[indexSelect];
    refresh!();
  }

  void mostrarBottomSheet(Widget contenido){
    showModalBottomSheet(
      context: context!,
      isScrollControlled: true,
      builder: (BuildContext context) {    
        return Container(
          height: 480,
          width: MediaQuery.of(context).size.width,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20)
            )
          ),
          child: contenido
        );
      },
    );
  }

  Future<void> _checkMetodosPago() async {
    final dataProvider = Provider.of<VariablesProvider>(context!, listen: false);
    final user = authaux.FirebaseAuth.instance.currentUser;

    String uidUser = '';
    bool hasMetodos = false;

    String idCostumerStripe = '';
    String nombreUser = '';
    String correoUser = '';

    if(user != null){
      uidUser = user.uid;

      DocumentSnapshot<Map<String, dynamic>> datosInit = await FirebaseFirestore.instance
      .collection('Clients')
      .doc(uidUser)
      .get();
      if(datosInit.data() != null){
        Map<String,dynamic> datosInitData = datosInit.data()!;
        nombreUser = datosInitData['username'];
        correoUser = datosInitData['email'];
      }

      DocumentSnapshot<Map<String, dynamic>> datosPerson = await FirebaseFirestore.instance
      .collection('Clients')
      .doc(uidUser)
      .collection('informacion')
      .doc('personal')
      .get();
      if(datosPerson.data() != null){
        Map<String,dynamic> datosPersonData = datosPerson.data()!;
        idCostumerStripe = datosPersonData.containsKey('idCostumerStripe') ? datosPersonData['idCostumerStripe'] : '';
      }

      if(idCostumerStripe.isNotEmpty){
        List<dynamic> listMisMetodos = await _recuperarListaMetodos(idCostumerStripe);
        if(listMisMetodos.isNotEmpty){
          hasMetodos = true;
        } else {
          hasMetodos = false;
        }
      } else {
        hasMetodos = false;
      }
    }

    dataProvider.dataUsuario.update('nombre', (value) => nombreUser);
    dataProvider.dataUsuario.update('correo', (value) => correoUser);
    dataProvider.dataUsuario.update('costumer', (value) => idCostumerStripe);

    hasMetodosAsociados = hasMetodos;
  }
  
  Future<List<dynamic>> _recuperarListaMetodos(String idCustomer) async {
    List<dynamic> misMetodosReturn = [];
    final variablesProvider = Provider.of<VariablesProvider>(context!, listen: false);

    try {
      Dio dio = Dio();
      String url = '';
      url = variablesProvider.isModeTest ? '$baseUrl/api/test/medcab/listMisMetodos' : '$baseUrl/api/medcab/listMisMetodos';

      Map<String, dynamic> datos = {
        'isUserCostumerStripe' : idCustomer,
      };

      Response response = await dio.post(
        url,
        data: datos,
      );

      if(response.statusCode == 200){
        misMetodosReturn = response.data['listMetodos'];
      }
      return misMetodosReturn;

    } catch (e) {
      return [];
    }
  }
  
  List<String> estadosMexico = [
    'aguascalientes',
    'baja california',
    'baja california sur',
    'campeche',
    'chiapas',
    'chihuahua',
    'ciudad de mexico',
    'coahuila',
    'colima',
    'durango',
    'guanajuato',
    'guerrero',
    'hidalgo',
    'jalisco',
    'estado de mexico',
    'michoacan',
    'morelos',
    'nayarit',
    'nuevo leon',
    'oaxaca',
    'puebla',
    'queretaro',
    'quintana roo',
    'san luis potosi',
    'sinaloa',
    'sonora',
    'tabasco',
    'tamaulipas',
    'tlaxcala',
    'veracruz',
    'yucatan',
    'zacatecas',
  ];

}