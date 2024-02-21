import 'package:app_medcab/src/shared/avisos.dart';
import 'package:app_medcab/src/shared/colors.dart';
import 'package:app_medcab/src/widgets/button_app.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:app_medcab/src/pages/client/travel_map/client_travel_map_controller.dart';
import 'package:flutter/scheduler.dart';

final _paletaColors = PaletaColors();

class ClientTravelMapPage extends StatefulWidget {
  const ClientTravelMapPage({super.key});
  
  @override
  State<ClientTravelMapPage> createState() => _ClientTravelMapPageState();
}

class _ClientTravelMapPageState extends State<ClientTravelMapPage> {

  final _con = ClientTravelMapController();

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      _con.init(context, refresh);
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      key: _con.key,
      body: Stack(
        children: [
          _googleMapsWidget(),
          SafeArea(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buttonUserInfo(),
                    _cardStatusInfo(_con.currentStatus),
                    _buttonCenterPosition(),
                  ],
                ),
                Expanded(child: Container()),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _cardCodigo(
                  (_con.travelInfo != null) ? (_con.travelInfo!.codigoConfirmacion != null) ? _con.travelInfo!.codigoConfirmacion! : '' : ''             
                ),
                _cancelarServicio()
              ],
            )
          ),
        ],
      ),
    );
  }

  Widget _cancelarServicio() {
    return Container(
      height: 50,
      alignment: Alignment.bottomCenter,
      margin: const EdgeInsets.only(bottom: 30, left: 30, right: 30),
      child: ButtonApp(
        onPressed: (){
          MisAvisos().ventanaConfirmarAccion(
            context, 
            'Confirma que desea cancelar el servicio', 
            (){
              _con.cancelTravel();
            },
            sizeFuente: 15
          );
        },
        text: 'Cancelar Servicio',
        fondoBoton: _paletaColors.rojoMain,
        icono: const SizedBox()
      ),
    );
  }
  
  Widget _cardCodigo(String status) {
    return SafeArea(
      child: Container(
        width: 160,
        padding: const EdgeInsets.symmetric(vertical: 5),
        margin: const EdgeInsets.only(bottom: 15),
        decoration: BoxDecoration(
          color: _paletaColors.mainA,
          borderRadius: const BorderRadius.all(Radius.circular(10))
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              status,
              maxLines: 2,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18
              ),
            ),
            const Text(
              'Mi código',
              maxLines: 2,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white
              ),
            ),
          ],
        ),
      )
    );
  }

  Widget _cardStatusInfo(String status) {
    return SafeArea(
      child: Container(
        width: 110,
        padding: const EdgeInsets.symmetric(vertical: 10),
        margin: const EdgeInsets.only(top: 10),
        decoration: BoxDecoration(
          color: _paletaColors.mainB,
          borderRadius: const BorderRadius.all(Radius.circular(30))
        ),
        child: Text(
          status,
          maxLines: 2,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white
          ),
        ),
      )
    );
  }

  Widget _buttonUserInfo() {
    return GestureDetector(
      onTap: _con.openBottomSheet,
      child: Container(
        alignment: Alignment.centerLeft,
        margin: const EdgeInsets.symmetric(horizontal: 5),
        child: Card(
          shape: const CircleBorder(),
          color: Colors.white,
          elevation: 4.0,
          child: Container(
            padding: const EdgeInsets.all(10),
            child: Icon(
              Icons.person,
              color: Colors.grey[600],
              size: 20,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buttonCenterPosition() {
    return GestureDetector(
      onTap: () {},
      child: Container(
        alignment: Alignment.centerRight,
        margin: const EdgeInsets.symmetric(horizontal: 5),
        child: Card(
          shape: const CircleBorder(),
          color: Colors.white,
          elevation: 4.0,
          child: Container(
            padding: const EdgeInsets.all(10),
            child: Icon(
              Icons.location_searching,
              color: Colors.grey[600],
              size: 20,
            ),
          ),
        ),
      ),
    );
  }

  Widget _googleMapsWidget() {
    return GoogleMap(
      mapType: MapType.normal,
      initialCameraPosition: _con.initialPosition,
      onMapCreated: _con.onMapCreated,
      myLocationEnabled: false,
      myLocationButtonEnabled: false,
      zoomControlsEnabled: false,
      markers: Set<Marker>.of(_con.markers.values),
      polylines: _con.polylines,
    );
  }

  void refresh() {
    if(mounted){
      setState(() {});
    }
  }
}
