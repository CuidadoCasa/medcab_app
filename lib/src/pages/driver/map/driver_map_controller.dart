import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:app_medcab/src/pages/driver/perfil/driver_perfil.dart';
import 'package:app_medcab/src/pages/driver/perfil/settings/ajustes_enfermera.dart';
import 'package:app_medcab/src/providers/variables_provider.dart';
import 'package:app_medcab/src/shared/avisos.dart';
import 'package:app_medcab/src/shared/map_theme.dart';
import 'package:firebase_auth/firebase_auth.dart' as authaux;
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as location;
import 'package:app_medcab/src/providers/auth_provider.dart';
import 'package:app_medcab/src/providers/geofire_provider.dart';
import 'package:app_medcab/src/providers/driver_provider.dart';
import 'package:app_medcab/src/providers/push_notifications_provider.dart';
import 'package:app_medcab/src/utils/my_progress_dialog.dart';
import 'package:app_medcab/src/utils/snackbar.dart' as utils;
import 'package:app_medcab/src/models/driver.dart';
import 'package:progress_dialog2/progress_dialog2.dart';
import 'package:provider/provider.dart';


class DriverMapController {

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
  DriverProvider ? _driverProvider;
  PushNotificationsProvider ? _pushNotificationsProvider;

  bool isConnect = false;
  ProgressDialog ? _progressDialog;

  StreamSubscription<DocumentSnapshot> ? _statusSuscription;
  StreamSubscription<DocumentSnapshot> ? _driverInfoSuscription;

  Driver ? driver;

  Future init(BuildContext context, Function refresh) async {
    this.context = context;
    this.refresh = refresh;
    _geofireProvider = GeofireProvider();
    _authProvider = AuthProvider();
    _driverProvider = DriverProvider();
    _pushNotificationsProvider = PushNotificationsProvider();
    _progressDialog = MyProgressDialog.createProgressDialog(context, 'Conectandose...');
    markerDriver = await createMarkerImageFromAsset('assets/img/car_enfermera_icon.png');
    checkGPS();
    // getDriverInfo();
    // saveToken();
    _checkStatusLastService();
  }

  void _checkStatusLastService() async {
    String userClient = authaux.FirebaseAuth.instance.currentUser!.uid;
    Map<String,dynamic> mapAuxTemp = {};
    final dataLastService = await FirebaseFirestore.instance
    .collection('TravelInfo')
    .where('idDriver', isEqualTo: userClient)
    .limit(1)
    .get();

    if(dataLastService.docs.isNotEmpty){
      mapAuxTemp = dataLastService.docs.first.data();
      if(mapAuxTemp['statusSolicitud'] == 3 && (mapAuxTemp['status'] == 'accepted' || mapAuxTemp['status'] == 'started')){
        Navigator.pushNamedAndRemoveUntil(context!, 'driver/travel/map', (route) => false, arguments: mapAuxTemp['id']);
      } else {
        getDriverInfo();
        saveToken();
      }
    } else {
      getDriverInfo();
      saveToken();
    }
  }

  void prueba(){
    _progressDialog!.show();
  }

  void getDriverInfo() {
    Stream<DocumentSnapshot> driverStream = _driverProvider!.getByIdStream(_authProvider!.getUser()!.uid);
    _driverInfoSuscription = driverStream.listen((DocumentSnapshot document) {
      driver = Driver.fromJson(document.data() as Map<String,dynamic>);
      // refresh!();
    });
  }

  // void _mensajeFaltaInformacion(){
  //   int hasCedula = driver!.hasCedula!;
  //   int hasTitulo = driver!.hasTitulo!;
  //   int hasConnect = driver!.hasConnect!;
  //   int hasINE = driver!.hasINE!;

  //   if(hasCedula == 0 || hasTitulo == 0 || hasConnect == 0 || hasINE == 0){
  //     MisAvisos().ventanaAviso(
  //       context!, 
  //       'Su cuenta aun no ha sido configurada. Para conectarse y empezar a realizar servicios por favor verifique en el menú los apartados que tiene que completar.'
  //     );
  //   }
  // }

  void saveToken() {
    _pushNotificationsProvider!.saveToken(_authProvider!.getUser()!.uid, 'driver');
  }

  void openDrawer() {
    key.currentState!.openDrawer();
  }

  void goToEditPage() {
    Navigator.push(
      context!,
      MaterialPageRoute<void>(
        builder: (BuildContext context) => PerfilEnfermeraPage(
          user: driver!,
        ),
      ),
    );
  }

  void goToConnect(){
    Navigator.push(
      context!,
      MaterialPageRoute<void>(
        builder: (BuildContext context) => AjustesEnfermera(userId: driver!.id!),
      ),
    );
  }

  void goToHistoryPage(){
    Navigator.pushNamed(context!, 'driver/history');
  }

  void dispose() {
    _positionStream?.cancel();
    _statusSuscription?.cancel();
    _driverInfoSuscription?.cancel();
  }

  void signOut() async {
    MisAvisos().ventanaTrabajando(context!, 'Cerrando sesión...');
    final dataProvider = Provider.of<VariablesProvider>(context!, listen: false);

    if(isConnect){
      await _positionStream?.cancel();
      await _geofireProvider!.delete(_authProvider!.getUser()!.uid);
      dataProvider.isConect = false;
    }
    await _authProvider!.signOut();
    Navigator.pop(context!);
    Navigator.pushNamedAndRemoveUntil(context!, 'home', (route) => false);
  }

  void onMapCreated(GoogleMapController controller) {
    controller.setMapStyle(jsonEncode(mapTheme));
    _mapController.complete(controller);
  }

  void saveLocation() async {
    await _geofireProvider!.create(
      _authProvider!.getUser()!.uid,
      _position!.latitude,
      _position!.longitude
    );
    _progressDialog!.hide();
  }

  void connect() {
    if(driver != null){
      if((driver!.isAutorizado != null) && (driver!.isAutorizado != 0)){
        if (isConnect) {
          disconnect();
        } else {
          _progressDialog!.show();
          updateLocation();
        }
      } else {
        MisAvisos().ventanaAviso(context!, 'Para poder conectarse y brindar sus servicios su usuario debe ser verificado y aprobado por el equipo de MedCab, por favor verifique el estatus de su cuenta en su perfil.');
      }
    } else {
      MisAvisos().ventanaAviso(context!, 'Error, cargue nuevamente la app');
    }
  }

  void disconnect() {
    _positionStream?.cancel();
    _geofireProvider!.delete(_authProvider!.getUser()!.uid);
  }

  void checkIfIsConnect() {
    Stream<DocumentSnapshot> status = _geofireProvider!.getLocationByIdStream(_authProvider!.getUser()!.uid);

    _statusSuscription = status.listen((DocumentSnapshot document) {
      if (document.exists) {
        isConnect = true;
      }
      else {
        isConnect = false;
      }

      refresh!();
    });

  }

  void updateLocation() async {
    final dataProvider = Provider.of<VariablesProvider>(context!, listen: false);

    try {
      await _determinePosition();
      _position = await Geolocator.getLastKnownPosition();
      centerPosition();
      if(driver != null){
        if((driver!.isAutorizado != null) && (driver!.isAutorizado != 0) && (dataProvider.isConect)){
          saveLocation();
        }
      }

      addMarker(
        'driver',
        _position!.latitude,
        _position!.longitude,
        'Tu posicion',
        '',
        markerDriver!
      );
      refresh!();

      _positionStream = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.best,
          distanceFilter: 1
        )
      ).listen((Position position) {
        _position = position;
        addMarker(
          'driver',
          _position!.latitude,
          _position!.longitude,
          'Tu posicion',
          '',
          markerDriver!
        );
        animateCameraToPosition(_position!.latitude, _position!.longitude);
        if(driver != null){
          if((driver!.isAutorizado != null) && (driver!.isAutorizado != 0) && (dataProvider.isConect)){
            saveLocation();
          }
        }
        refresh!();
      });

    } catch(error) {
      debugPrint('Error en la localizacion: $error');
    }
  }

  void centerPosition() {
    if (_position != null) {
      animateCameraToPosition(_position!.latitude, _position!.longitude);
    }
    else {
      utils.Snackbar.showSnackbar(context!, key, 'Activa el GPS para obtener la posicion');
    }
  }

  void checkGPS() async {
    bool isLocationEnabled = await Geolocator.isLocationServiceEnabled();
    if (isLocationEnabled) {
      updateLocation();
      checkIfIsConnect();
    }
    else {
      bool locationGPS = await location.Location().requestService();
      if (locationGPS) {
        updateLocation();
        checkIfIsConnect();
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

  Future animateCameraToPosition(double latitude, double longitude) async {
    GoogleMapController controller = await _mapController.future;
    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          bearing: 0,
          target: LatLng(latitude, longitude),
          zoom: 17
        )
      )
    );
  }

  Future<BitmapDescriptor> createMarkerImageFromAsset(String path) async {
    ImageConfiguration configuration = const ImageConfiguration();
    BitmapDescriptor bitmapDescriptor = await BitmapDescriptor.fromAssetImage(configuration, path);
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

}