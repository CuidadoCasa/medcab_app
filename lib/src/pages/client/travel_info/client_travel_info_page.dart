import 'package:app_medcab/src/utils/formato_dinero.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:app_medcab/src/pages/client/travel_info/client_travel_info_controller.dart';
import 'package:app_medcab/src/widgets/button_app.dart';

class ClientTravelInfoPage extends StatefulWidget {
  const ClientTravelInfoPage({super.key});

  @override
  State<ClientTravelInfoPage> createState() => _ClientTravelInfoPageState();
}

class _ClientTravelInfoPageState extends State<ClientTravelInfoPage> {

  final _con = ClientTravelInfoController();

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
          Align(
            alignment: Alignment.topCenter,
            child: _googleMapsWidget(),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: _cardTravelInfo(),
          ),
          Align(
            alignment: Alignment.topLeft,
            child: _buttonBack(),
          ),
        ],
      ),
    );
  }

  Widget _cardTravelInfo() {
    return Container(
      height: 320,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30))
      ),
      child: Column(
        children: [
          _listTileInfoServicio(
            'Ubicación del paciente',
            _con.from ?? '',
            const Icon(Icons.location_on)
          ),
          _listTileInfoServicio(
            'Servicio solicitado',
            _con.dataPaquete.isNotEmpty ? '${_con.dataPaquete['nombre']}. ${_con.dataPaquete['descripcion']}' : '-',
            const FaIcon(FontAwesomeIcons.briefcaseMedical)
          ),
          _listTileInfoServicio(
            'Costo',
            _con.dataPaquete.isNotEmpty ? FormatoDinero().convertirNum(_con.dataPaquete['costo'].toDouble()) : '\$ 0.00',
            const Icon(Icons.attach_money)
          ),
          // _listTileInfoServicio(
          //   'Método de pago',
          //   '1102',
          //   const Icon(Icons.card_travel_rounded)
          // ),
          const Spacer(),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
            child: ButtonApp(
              onPressed: _con.goToRequest,
              text: 'CONFIRMAR',
              icono: const FaIcon(
                FontAwesomeIcons.checkToSlot,
                color: Colors.white,
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _listTileInfoServicio(String titulo, String descripcion, Widget icono){
    return ListTile(
      title: Text(
        titulo,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold
        ),
      ),
      subtitle: Text(
        descripcion,
        style: const TextStyle(
          fontSize: 13
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      leading: icono,
    );
  }

  Widget cardKmInfo(String ? km) {
    return SafeArea(
        child: Container(
          width: 110,
          padding: const EdgeInsets.symmetric(horizontal: 30),
          margin: const EdgeInsets.only(right: 10, top: 10),
          decoration: const BoxDecoration(
            color: Colors.amber,
            borderRadius: BorderRadius.all(Radius.circular(20))
          ),
          child: Text(km ?? '0 Km', maxLines: 1,),
        )
    );
  }

  Widget cardMinInfo(String ? min) {
    return SafeArea(
        child: Container(
          width: 110,
          padding: const EdgeInsets.symmetric(horizontal: 30),
          margin: const EdgeInsets.only(right: 10, top: 35),
          decoration: const BoxDecoration(
            color: Colors.yellow,
            borderRadius: BorderRadius.all(Radius.circular(20))
          ),
          child: Text(min ?? '0 Min', maxLines: 1,),
        )
    );
  }

  Widget _buttonBack() {
    return SafeArea(
      child: GestureDetector(
        onTap: ()=> Navigator.pop(context),
        child: Container(
          margin: const EdgeInsets.only(left: 10),
          child: const CircleAvatar(
            radius: 20,
            backgroundColor: Colors.white,
            child: Icon(Icons.arrow_back, color: Colors.black,),
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
      // polylines: _con.polylines,
    );
  }

  void refresh() {
    if(mounted){
      setState(() {});
    }
  }
}
