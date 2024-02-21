import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:app_medcab/src/shared/map_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:app_medcab/src/api/environment.dart';
import 'package:app_medcab/src/models/directions.dart';
import 'package:app_medcab/src/models/prices.dart';
import 'package:app_medcab/src/providers/google_provider.dart';
import 'package:app_medcab/src/providers/prices_provider.dart';

class ClientTravelInfoController {

  GoogleProvider ? _googleProvider;
  PricesProvider ? _pricesProvider;

  Function ? refresh;
  BuildContext ? context;
  GlobalKey<ScaffoldState> key = GlobalKey<ScaffoldState>();

  final Completer<GoogleMapController> _mapController = Completer();

  CameraPosition initialPosition = const CameraPosition(
    target: LatLng(21.831120, -101.521867),
    zoom: 5
  );

  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};

  String ? from;
  String ? to;
  LatLng ? fromLatLng;
  LatLng ? toLatLng;

  Set<Polyline> polylines = {};
  List<LatLng> points = [];

  BitmapDescriptor ? fromMarker;
  BitmapDescriptor ? toMarker;

  Direction ? _directions;
  String ? min;
  String ? km;

  double ? minTotal;
  double ? maxTotal;

  Map<String,dynamic> dataPaquete = {};

  Future init(BuildContext context, Function refresh) async {
    this.context = context;
    this.refresh = refresh;

    Map<String, dynamic> arguments = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    from = arguments['from'];
    to = arguments['to'];
    fromLatLng = arguments['fromLatLng'];
    toLatLng = arguments['toLatLng'];
    dataPaquete = arguments['paquete'];

    _googleProvider = GoogleProvider();
    _pricesProvider = PricesProvider();

    fromMarker = await createMarkerImageFromAsset('assets/img/map_pin_red.png');
    toMarker = await createMarkerImageFromAsset('assets/img/map_pin_blue.png');

    animateCameraToPosition(fromLatLng!.latitude, fromLatLng!.longitude);
    // getGoogleMapsDirections(fromLatLng!, toLatLng!);
  }

  void getGoogleMapsDirections(LatLng from, LatLng to) async {
    _directions = await _googleProvider!.getGoogleMapsDirections(
      from.latitude,
      from.longitude,
      to.latitude,
      to.longitude
    );
    min = _directions!.duration!.text;
    km = _directions!.distance!.text;

    calculatePrice();
    refresh!();
  }

  void goToRequest() {
    String codigoConfirmacion = generarCodigoAleatorio();

    Map<String,dynamic> dataService = {
      'from': from,
      'to': to,
      'fromLatLng': fromLatLng,
      'toLatLng': toLatLng,
    };

    Map<String,dynamic> codigoConf = {
      'codigoConfirmacion': codigoConfirmacion,
      'statusSolicitud': 1,
      'connectAsociado': '',
      'transaccionID': ''
    };

    dataService.addEntries(dataPaquete.entries);
    dataService.addEntries(codigoConf.entries);

    Navigator.pushNamed(context!, 'client/travel/request', arguments: dataService);
  }

  
  String generarCodigoAleatorio() {
    final random = Random();
    const caracteresPermitidos = '0123456789';
    String codigo = '';

    for (int i = 0; i < 5; i++) {
      codigo += caracteresPermitidos[random.nextInt(caracteresPermitidos.length)];
    }

    return codigo;
  }

  void calculatePrice() async {
    Prices prices = await _pricesProvider!.getAll();
    double kmValue = double.parse(km!.split(" ")[0]) * prices.km!;
    double minValue = double.parse(min!.split(" ")[0]) * prices.min!;
    double total = kmValue + minValue;

    minTotal = total - 0.5;
    maxTotal = total + 0.5;

    refresh!();
  }

  Future<void> setPolylines() async {
    PointLatLng pointFromLatLng = PointLatLng(fromLatLng!.latitude, fromLatLng!.longitude);
    PointLatLng pointToLatLng = PointLatLng(toLatLng!.latitude, toLatLng!.longitude);

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
      color: Colors.blue,
      points: points,
      width: 6
    );

    polylines.add(polyline);

    addMarker('from', fromLatLng!.latitude, fromLatLng!.longitude, 'Recoger aqui', '', fromMarker!);
    addMarker('to', toLatLng!.latitude, toLatLng!.longitude, 'Destino', '', toMarker!);

    refresh!();
  }

  void setMarkerUbicacion(){
    addMarker('to', toLatLng!.latitude, toLatLng!.longitude, 'Destino', '', toMarker!);
    refresh!();
  }

  Future animateCameraToPosition(double latitude, double longitude) async {
    GoogleMapController controller = await _mapController.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(
          bearing: 0,
          target: LatLng(latitude, longitude),
          zoom: 15
        )
      )
    );
  }

  void onMapCreated(GoogleMapController controller) async {
    controller.setMapStyle(jsonEncode(mapTheme));
    _mapController.complete(controller);
    setMarkerUbicacion();
    // await setPolylines();
  }

  Future<BitmapDescriptor> createMarkerImageFromAsset(String path) async {
    ImageConfiguration configuration = const ImageConfiguration();
    BitmapDescriptor bitmapDescriptor =
    await BitmapDescriptor.fromAssetImage(configuration, path);
    return bitmapDescriptor;
  }

  void addMarker(
      String markerId,
      double lat,
      double lng,
      String title,
      String content,
      BitmapDescriptor iconMarker
      ) {

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