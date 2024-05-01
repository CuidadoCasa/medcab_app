import 'dart:async';
import 'dart:convert';
import 'package:app_medcab/src/providers/variables_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:app_medcab/src/shared/avisos.dart';
import 'package:app_medcab/src/shared/map_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as location;
import 'package:app_medcab/src/api/environment.dart';
import 'package:app_medcab/src/models/travel_info.dart';
import 'package:app_medcab/src/providers/auth_provider.dart';
import 'package:app_medcab/src/providers/geofire_provider.dart';
import 'package:app_medcab/src/providers/driver_provider.dart';
import 'package:app_medcab/src/providers/travel_info_provider.dart';
import 'package:app_medcab/src/utils/my_progress_dialog.dart';
import 'package:app_medcab/src/models/driver.dart';
import 'package:app_medcab/src/widgets/bottom_sheet_client_info.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:progress_dialog2/progress_dialog2.dart';
import 'package:provider/provider.dart';

class ClientTravelMapController {

  BuildContext ? context;
  Function ? refresh;
  GlobalKey<ScaffoldState> key = GlobalKey<ScaffoldState>();
  final Completer<GoogleMapController> _mapController = Completer();

  CameraPosition initialPosition = const CameraPosition(
    target: LatLng(21.831120, -101.521867),
    zoom: 5
  );

  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};

  BitmapDescriptor ? markerDriver;
  BitmapDescriptor ? fromMarker;
  BitmapDescriptor ? toMarker;

  GeofireProvider ? _geofireProvider;
  AuthProvider ? _authProvider;
  DriverProvider ? _driverProvider;
  TravelInfoProvider ? _travelInfoProvider;

  bool isConnect = false;
  // ignore: unused_field
  ProgressDialog ? _progressDialog;

  StreamSubscription<DocumentSnapshot> ? _statusSuscription;
  StreamSubscription<DocumentSnapshot> ? _driverInfoSuscription;
  StreamSubscription<DocumentSnapshot> ? _streamStatusSubscription;

  Set<Polyline> polylines = {};
  List<LatLng> points = [];

  Driver ? driver;
  LatLng ? _driverLatLng;
  TravelInfo ? travelInfo;

  bool isRouteReady = false;

  String currentStatus = '';
  Color colorStatus = Colors.white;

  bool isPickupTravel = false;
  bool isStartTravel = false;
  bool isFinishTravel = false;

  StreamSubscription<DocumentSnapshot> ? _streamLocationController;
  StreamSubscription<DocumentSnapshot> ? _streamTravelController;

  String baseUrl = 'https://api-medcab.onrender.com';

  Future init(BuildContext context, Function refresh) async {
    this.context = context;
    this.refresh = refresh;

    _geofireProvider =  GeofireProvider();
    _authProvider =  AuthProvider();
    _driverProvider =  DriverProvider();
    _travelInfoProvider =  TravelInfoProvider();
    _progressDialog = MyProgressDialog.createProgressDialog(context, 'Conectandose...');

    markerDriver = await createMarkerImageFromAsset('assets/img/icon_enfermera.png');
    fromMarker = await createMarkerImageFromAsset('assets/img/map_pin_red.png');
    toMarker = await createMarkerImageFromAsset('assets/img/map_pin_blue.png');

    checkGPS();
  }

  void getDriverLocation(String idDriver) {
    Stream<DocumentSnapshot> stream = _geofireProvider!.getLocationByIdStream(idDriver);
    _streamLocationController = stream.listen((DocumentSnapshot document) {
      GeoPoint geoPoint = (document.data() as Map<String,dynamic>) ['position']['geopoint'];
      _driverLatLng =  LatLng(geoPoint.latitude, geoPoint.longitude);
      addSimpleMarker(
        'driver',
        _driverLatLng!.latitude,
        _driverLatLng!.longitude,
        'Tu conductor',
        '',
        markerDriver!
      );

      refresh!();

      if (!isRouteReady) {
        isRouteReady = true;
        checkTravelStatus();
      }

    });
  }

  void pickupTravel() {
    if (!isPickupTravel) {
      isPickupTravel = true;
      LatLng from =  LatLng(_driverLatLng!.latitude, _driverLatLng!.longitude);
      LatLng to =  LatLng(travelInfo!.fromLat!, travelInfo!.fromLng!);
      addSimpleMarker('from', to.latitude, to.longitude, 'Recoger aqui', '', fromMarker!);
      setPolylines(from, to);
    }
  }

  void checkTravelStatus() async {
    Stream<DocumentSnapshot> stream = _travelInfoProvider!.getByIdStream(_authProvider!.getUser()!.uid);
    _streamTravelController = stream.listen((DocumentSnapshot document) {
      travelInfo = TravelInfo.fromJson(document.data() as Map<String,dynamic>);

      if (travelInfo!.status == 'accepted') {
        currentStatus = 'Servicio aceptado';
        colorStatus = Colors.white;
        pickupTravel();
      }
      else if (travelInfo!.status == 'started') {
        currentStatus = 'Servicio en curso';
        colorStatus = Colors.amber;
        startTravel();
      }
      else if (travelInfo!.status == 'finished') {
        currentStatus = 'Servicio finalizado';
        colorStatus = Colors.cyan;
        finishTravel();
      }

      refresh!();

    });
  }



  void openBottomSheet() {
    if (driver == null) return;

    showMaterialModalBottomSheet(
      context: context!,
      builder: (context) => BottomSheetClientInfo(
        usuario: driver!,
        infoService: travelInfo!,
      )
    );
  }

  void finishTravel() {
    if (!isFinishTravel) {
      isFinishTravel = true;
      Navigator.pushNamedAndRemoveUntil(context!, 'client/travel/calification', (route) => false, arguments: travelInfo!.idTravelHistory);
    }
  }

  void startTravel() {
    if (!isStartTravel) {
      isStartTravel = true;
      polylines = {};
      points = [];
      markers.removeWhere((key, marker) => marker.markerId.value == 'from');
      addSimpleMarker(
        'to',
        travelInfo!.toLat!,
        travelInfo!.toLng!,
        'Destino',
        '',
        toMarker!
      );

      LatLng from =  LatLng(_driverLatLng!.latitude, _driverLatLng!.longitude);
      LatLng to =  LatLng(travelInfo!.toLat!, travelInfo!.toLng!);

      setPolylines(from, to);
      refresh!();
    }
  }

  void _getTravelInfo() async {
    travelInfo = await _travelInfoProvider!.getById(_authProvider!.getUser()!.uid);
    animateCameraToPosition(travelInfo!.fromLat!, travelInfo!.fromLng!);
    getDriverInfo(travelInfo!.idDriver!);
    getDriverLocation(travelInfo!.idDriver!);
    _checkTravelInfo();
  }

  void _checkTravelInfo() {
    if(travelInfo != null){
      Stream<DocumentSnapshot> stream = _travelInfoProvider!.getByIdStream(travelInfo!.id!);

      _streamStatusSubscription = stream.listen((DocumentSnapshot document) {

        TravelInfo travelInfo = TravelInfo.fromJson(document.data() as Map<String,dynamic>);
        if (travelInfo.status == 'refound') {
          MisAvisos().ventanaAvisoNullAction(context!, 'Servicio cancelado por el profesional.');
          Future.delayed(const Duration(milliseconds: 3000), () {
            Navigator.pushNamedAndRemoveUntil(context!, 'client/map', (route) => false);
          });
        }

      });
    }
  }

  void cancelTravel() async {
    MisAvisos().ventanaTrabajando(context!, 'Cancelando serivicio...');
    String statusCancelPago = '';

    if(travelInfo!.status != 'started'){
      statusCancelPago = await _cancelarPago(travelInfo!.transaccionID!);
    } else {
      statusCancelPago = 'canceled';
    }

    if(statusCancelPago == 'canceled'){
      Map<String, dynamic> data = {
        'status': 'refound',
        'statusSolicitud': 1
      };
      _travelInfoProvider!.update(data, _authProvider!.getUser()!.uid);
    } else {
      MisAvisos().ventanaConfirmarAccion(
        context!, 
        'No se pudo cancelar el viaje, intente nuevamente.',
        (){
          Navigator.pop(context!);
          Navigator.pop(context!);
        },
        sizeFuente: 15
      );
    }

  }

  Future<String> _cancelarPago(String idPayment) async {
    final variablesProvider = Provider.of<VariablesProvider>(context!, listen: false);
    String estado = '';

    try {
      Dio dio = Dio();
      String url = '';
      url = variablesProvider.isModeTest ? '$baseUrl/api/test/medcab/cancelPay' : '$baseUrl/api/medcab/cancelPay';

      Map<String, dynamic> datos = {
        'idPaymentIntent' : idPayment,
      };

      Response response = await dio.post(
        url,
        data: datos,
      );

      if(response.statusCode == 200){
        estado = response.data['status'];
      }
      return estado;

    } catch (e) {
      return '';
    }
  }

  Future<void> setPolylines(LatLng from, LatLng to) async {

    PointLatLng pointFromLatLng = PointLatLng(from.latitude, from.longitude);
    PointLatLng pointToLatLng = PointLatLng(to.latitude, to.longitude);

    PolylineResult result = await PolylinePoints().getRouteBetweenCoordinates(
      Environment.API_KEY_MAPS,
      pointFromLatLng,
      pointToLatLng
    );

    for (PointLatLng point in result.points) {
      points.add(LatLng(point.latitude, point.longitude));
    }

    Polyline polyline = Polyline(
      polylineId: const PolylineId('poly'),
      color: Colors.amber,
      points: points,
      width: 6
    );

    polylines.add(polyline);

    refresh!();
  }

  void getDriverInfo(String id) async {
    driver = await _driverProvider!.getById(id);
    refresh!();
  }

  void dispose() {
    _statusSuscription?.cancel();
    _driverInfoSuscription?.cancel();
    _streamLocationController?.cancel();
    _streamTravelController?.cancel();
    _streamStatusSubscription?.cancel();
  }

  void onMapCreated(GoogleMapController controller) {
    controller.setMapStyle(jsonEncode(mapTheme));
    _mapController.complete(controller);

    _getTravelInfo();
  }

  void checkGPS() async {
    bool isLocationEnabled = await Geolocator.isLocationServiceEnabled();
    if (isLocationEnabled) {
    }
    else {
      bool locationGPS = await location.Location().requestService();
      if (locationGPS) {
      }
    }

  }

  Future animateCameraToPosition(double latitude, double longitude) async {
    GoogleMapController controller = await _mapController.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(
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

  void addSimpleMarker( String markerId, double lat, double lng, String title, String content, BitmapDescriptor iconMarker) {
    MarkerId id = MarkerId(markerId);
    Marker marker = Marker(
      markerId: id,
      icon: iconMarker,
      position: LatLng(lat, lng),
      infoWindow: InfoWindow(title: title, snippet: content),
    );
    markers[id] = marker;
  }

}