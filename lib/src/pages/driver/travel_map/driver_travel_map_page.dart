import 'package:app_medcab/src/shared/avisos.dart';
import 'package:app_medcab/src/shared/widgets/form_general.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:app_medcab/src/pages/driver/travel_map/driver_travel_map_controller.dart';
import 'package:flutter/scheduler.dart';
import 'package:app_medcab/src/widgets/button_app.dart';

class DriverTravelMapPage extends StatefulWidget {
  const DriverTravelMapPage({super.key});

  @override
  State<DriverTravelMapPage> createState() => _DriverTravelMapPageState();
}

class _DriverTravelMapPageState extends State<DriverTravelMapPage> {

  final _con = DriverTravelMapController();

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
                    _buttonCenterPosition(),
                  ],
                ),
                const Spacer(),
                _buttonStatus(),
                _cancelarServicio()
              ],
            ),
          )
        ],
      ),
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
      onTap: _con.centerPosition,
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
        fondoBoton: paletaColores.rojoMain,
        icono: const SizedBox()
      ),
    );
  }

  Widget _buttonStatus() {
    return Container(
      height: 50,
      alignment: Alignment.bottomCenter,
      margin: const EdgeInsets.symmetric(horizontal: 60, vertical: 15),
      child: ButtonApp(
        onPressed: (){
          if(_con.currentStatus == 'FINALIZAR SERVICIO'){
            _con.updateStatus();
          } else {
            MisAvisos().ventanaConfirmarCodigo(
              context, 
              _rowPings(),
              () async {
                String c1 = _con.control1.text;
                String c2 = _con.control2.text;
                String c3 = _con.control3.text;
                String c4 = _con.control4.text;
                String c5 = _con.ultimoControl.text;
                String codigoComplete = c1 + c2 + c3 + c4 + c5;
                if(codigoComplete == _con.travelInfo!.codigoConfirmacion){
                  MisAvisos().ventanaTrabajando(context, 'Iniciando...');

                  String statusAceptarPago = await _con.aceptarPago(_con.travelInfo!.transaccionID!);
                  if(statusAceptarPago == 'succeeded'){
                    await _con.startTravel();
                    if(mounted) Navigator.pop(context);
                    if(mounted) Navigator.pop(context);
                  }
                  
                } else {
                  const snackBar = SnackBar(
                    content: Text('El código no coincide'),
                    duration: Duration(seconds: 2),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);                
                }
              }
            );
          }
        },
        text: _con.currentStatus,
        color: _con.colorStatus,
        icono: const SizedBox()
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

  Widget _rowPings(){
    return StatefulBuilder(
      builder: (BuildContext context, void Function(void Function()) setState) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 20),
            const Text(
              'Confirme el código de servicio con el paciente.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _modeloPing(context, 0, _con.focusNode1, _con.focusNode2, _con.control1, setState),
                _modeloPing(context, 1, _con.focusNode2, _con.focusNode3, _con.control2, setState),
                _modeloPing(context, 2, _con.focusNode3, _con.focusNode4, _con.control3, setState),
                _modeloPing(context, 3, _con.focusNode4, _con.focusNode5, _con.control4, setState),
                _modeloPing(context, 4, _con.focusNode5, _con.focusNode5, _con.ultimoControl, setState),
              ],
            ),
          ]
        );
      }
    );
  }

  Widget _modeloPing(context, int index, FocusNode nodoRaiz, FocusNode nodoProx, TextEditingController control, void Function(void Function()) setState){
    return Container(
      width:  40,
      height: 50,
      alignment: AlignmentDirectional.center,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(15)
      ),
      child: TextFormField(
        focusNode: nodoRaiz,
        controller: control,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(
          isDense: true,
          border: InputBorder.none,
          error: SizedBox(height: 0)
        ),
        onChanged: (value){
          if((index != 4) && (value.length == 1)){
            FocusScope.of(context).requestFocus(nodoProx);
          }
          if(value.isNotEmpty && (index == 4)){
            _con.ultimoControl.value = TextEditingValue(text: value);
            setState(() {});
          }
        }
      ),
    );
  }
}
