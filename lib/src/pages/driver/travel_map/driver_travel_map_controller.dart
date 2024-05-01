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
import 'package:app_medcab/src/models/travel_history.dart';
import 'package:app_medcab/src/models/client.dart';
import 'package:app_medcab/src/models/travel_info.dart';
import 'package:app_medcab/src/providers/auth_provider.dart';
import 'package:app_medcab/src/providers/client_provider.dart';
import 'package:app_medcab/src/providers/geofire_provider.dart';
import 'package:app_medcab/src/providers/driver_provider.dart';
import 'package:app_medcab/src/providers/travel_history_provider.dart';
import 'package:app_medcab/src/providers/travel_info_provider.dart';
import 'package:app_medcab/src/utils/my_progress_dialog.dart';
import 'package:app_medcab/src/utils/snackbar.dart' as utils;
import 'package:app_medcab/src/models/driver.dart';
import 'package:app_medcab/src/widgets/bottom_sheet_driver_info.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:progress_dialog2/progress_dialog2.dart';
import 'package:provider/provider.dart';


class DriverTravelMapController {

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
  BitmapDescriptor ? fromMarker;
  BitmapDescriptor ? toMarker;

  GeofireProvider ? _geofireProvider;
  AuthProvider ? _authProvider;
  DriverProvider ? _driverProvider;
  TravelInfoProvider ? _travelInfoProvider;
  ClientProvider ? _clientProvider;
  TravelHistoryProvider ? _travelHistoryProvider;

  bool isConnect = false;
  ProgressDialog ? _progressDialog;

  StreamSubscription<DocumentSnapshot> ? _statusSuscription;
  StreamSubscription<DocumentSnapshot> ? _driverInfoSuscription;

  Set<Polyline> polylines = {};
  List<LatLng> points = [];

  Driver ? driver;
  Client ? _client;

  String ? _idTravel;
  TravelInfo ? travelInfo;

  String currentStatus = 'INICIAR SERVICIO';
  Color colorStatus = Colors.amber;

  double ? _distanceBetween;

  Timer ? _timer;
  int seconds = 0;
  double mt = 0;
  double km = 0;

  final focusNode1 = FocusNode();
  final focusNode2 = FocusNode();
  final focusNode3 = FocusNode();
  final focusNode4 = FocusNode();
  final focusNode5 = FocusNode();

  final control1 = TextEditingController();
  final control2 = TextEditingController();
  final control3 = TextEditingController();
  final control4 = TextEditingController();
  final ultimoControl = TextEditingController();

  StreamSubscription<DocumentSnapshot> ? _streamStatusSubscription;

  String baseUrl = 'https://api-medcab.onrender.com';

  Future init(BuildContext context, Function refresh) async {
    this.context = context;
    this.refresh = refresh;

    _idTravel = ModalRoute.of(context)!.settings.arguments as String;

    _geofireProvider = GeofireProvider();
    _authProvider = AuthProvider();
    _driverProvider = DriverProvider();
    _travelInfoProvider = TravelInfoProvider();
    _clientProvider = ClientProvider();
    _travelHistoryProvider = TravelHistoryProvider();
    _progressDialog = MyProgressDialog.createProgressDialog(context, 'Conectandose...');

    markerDriver = await createMarkerImageFromAsset('assets/img/car_enfermera_icon.png');
    fromMarker = await createMarkerImageFromAsset('assets/img/map_pin_red.png');
    toMarker = await createMarkerImageFromAsset('assets/img/map_pin_blue.png');

    checkGPS();
    getDriverInfo();
  }

  void _checkTravelInfo() {
    if(travelInfo != null){
      Stream<DocumentSnapshot> stream = _travelInfoProvider!.getByIdStream(travelInfo!.id!);

      _streamStatusSubscription = stream.listen((DocumentSnapshot document) {

        TravelInfo travelInfo = TravelInfo.fromJson(document.data() as Map<String,dynamic>);
        if (travelInfo.status == 'refound') {
          _activoReturn();
          MisAvisos().ventanaAvisoNullAction(context!, 'Servicio cancelado por el paciente');
          Future.delayed(const Duration(milliseconds: 3000), () {
            Navigator.pushNamedAndRemoveUntil(context!, 'driver/map', (route) => false);
          });
        }

      });
    }
  }

  void getClientInfo() async {
    _client = await _clientProvider!.getById(_idTravel!);
  }

  Future<double> calculatePrice() async {
    double costo = travelInfo!.costo!.toDouble();
    return costo;
  }

  void startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      seconds = timer.tick;
      refresh!();
    });
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
      _travelInfoProvider!.update(data, travelInfo!.id!);
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
    String estado = '';
    final variablesProvider = Provider.of<VariablesProvider>(context!, listen: false);

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

  void isCloseToPickupPosition(LatLng from, LatLng to) {
    _distanceBetween = Geolocator.distanceBetween(
      from.latitude,
      from.longitude,
      to.latitude,
      to.longitude
    );
  }

  void updateStatus () {
    if (travelInfo!.status == 'accepted') {
      startTravel();
    }
    else if (travelInfo!.status == 'started') {
      finishTravel();
    }
  }

  Future<String> aceptarPago(String idPayment) async {
    String estado = '';
    final variablesProvider = Provider.of<VariablesProvider>(context!, listen: false);

    try {
      Dio dio = Dio();
      String url = '';
      url = variablesProvider.isModeTest ? '$baseUrl/api/test/medcab/confirmPay' : '$baseUrl/api/medcab/confirmPay';

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
      return 'error';
    }
  }

  Future<void> startTravel() async {
    if (_distanceBetween! <= 50) {
      Map<String, dynamic> data = {
        'status': 'started',
      };
      await _travelInfoProvider!.update(data, _idTravel!);
      travelInfo!.status = 'started';
      currentStatus = 'FINALIZAR SERVICIO';
      colorStatus = Colors.cyan;

      polylines = {};
      points = [];
      // markers.remove(markers['from']);
      markers.removeWhere((key, marker) => marker.markerId.value == 'from');
      addSimpleMarker(
        'to',
        travelInfo!.toLat!,
        travelInfo!.toLng!,
        'Destino',
        '',
        toMarker!
      );

      // LatLng from = LatLng(_position!.latitude, _position!.longitude);
      // LatLng to = LatLng(travelInfo!.toLat!, travelInfo!.toLng!);

      // setPolylines(from, to);
      startTimer();
      refresh!();
    }
    else {
      utils.Snackbar.showSnackbar(context!, key, 'Debes estar en la ubicación del paciente para iniciar el servicio.');
    }

    refresh!();
  }

  void finishTravel() async {
    _timer?.cancel();

    double total = await calculatePrice();

    saveTravelHistory(total);
  }

  void saveTravelHistory(double price) async {
    TravelHistory travelHistory = TravelHistory(
      from: travelInfo!.from,
      to: travelInfo!.to,
      idDriver: _authProvider!.getUser()!.uid,
      idClient: _idTravel,
      timestamp: DateTime.now().millisecondsSinceEpoch,
      price: price,
      paquete: travelInfo!.nombre,
      descripcion: travelInfo!.descripcion,
      transaccionID: travelInfo!.transaccionID,
    );

    String ? id = await _travelHistoryProvider!.create(travelHistory);

    Map<String, dynamic> data = {
      'status': 'finished',
      'idTravelHistory': id,
      'price': price,
    };
    await _travelInfoProvider!.update(data, _idTravel!);
    travelInfo!.status = 'finished';

    Navigator.pushNamedAndRemoveUntil(context!, 'driver/travel/calification', (route) => false, arguments: id);
  }

  void _getTravelInfo() async {
    travelInfo = await _travelInfoProvider!.getById(_idTravel!);
    LatLng from = LatLng(_position!.latitude, _position!.longitude);
    LatLng to = LatLng(travelInfo!.fromLat!, travelInfo!.fromLng!);
    addSimpleMarker('from', to.latitude, to.longitude, 'Recoger aqui', '', fromMarker!);
    setPolylines(from, to);
    getClientInfo();
    _checkTravelInfo();
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

    // addMarker('to', toLatLng.latitude, toLatLng.longitude, 'Destino', '', toMarker);

    refresh!();
  }

  void getDriverInfo() {
    Stream<DocumentSnapshot> driverStream = _driverProvider!.getByIdStream(_authProvider!.getUser()!.uid);
    _driverInfoSuscription = driverStream.listen((DocumentSnapshot document) {
      driver = Driver.fromJson(document.data() as Map<String,dynamic>);
      refresh!();
    });
  }

  void dispose() {
    _timer?.cancel();
    _positionStream?.cancel();
    _statusSuscription?.cancel();
    _driverInfoSuscription?.cancel();
    _streamStatusSubscription!.cancel();
    control1.dispose();
    control2.dispose();
    control3.dispose();
    control4.dispose();
    ultimoControl.dispose();
    focusNode1.dispose();
    focusNode2.dispose();
    focusNode3.dispose();
    focusNode4.dispose();
    focusNode5.dispose();
  }

  void onMapCreated(GoogleMapController controller) {
    controller.setMapStyle(jsonEncode(mapTheme));
    _mapController.complete(controller);
  }

  void saveLocation() async {
    await _geofireProvider!.createWorking(
      _authProvider!.getUser()!.uid,
      _position!.latitude,
      _position!.longitude
    );
    _progressDialog!.hide();
  }

  void _activoReturn() async {
    await _geofireProvider!.create(
      _authProvider!.getUser()!.uid,
      _position!.latitude,
      _position!.longitude
    );
    _progressDialog!.hide();
  }

  void updateLocation() async  {
    try {
      await _determinePosition();
      _position = await Geolocator.getLastKnownPosition();
      _getTravelInfo();
      centerPosition();
      saveLocation();

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
      )
      .listen((Position position) {

        if (travelInfo?.status == 'started') {
          mt = mt + Geolocator.distanceBetween(
            _position!.latitude,
            _position!.longitude,
            position.latitude,
            position.longitude
          );
          km = mt / 1000;
        }

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

        if (travelInfo!.fromLat != null && travelInfo!.fromLng != null) {
          LatLng from = LatLng(_position!.latitude, _position!.longitude);
          LatLng to = LatLng(travelInfo!.fromLat!, travelInfo!.fromLng!);
          isCloseToPickupPosition(from, to);
        }

        saveLocation();
        refresh!();
      });

    } catch(error) {
      debugPrint('Error en la localizacion: $error');
    }
  }

  void openBottomSheet() {
    if (_client == null) return;

    showMaterialModalBottomSheet(
      context: context!,
      builder: (context) => BottomSheetDriverInfo(
        usuario: _client!,
        infoService: travelInfo!,
      )
    );
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
      return Future.error(
          'Location permissions are permantly denied, we cannot request permissions.');
    }

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        return Future.error(
            'Location permissions are denied (actual value: $permission).');
      }
    }

    return await Geolocator.getCurrentPosition();
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

  void addMarker( String markerId, double lat, double lng, String title, String content, BitmapDescriptor iconMarker) {
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