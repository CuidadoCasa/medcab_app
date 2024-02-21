import 'package:app_medcab/src/shared/avisos.dart';
import 'package:app_medcab/src/shared/colors.dart';
import 'package:app_medcab/src/shared/widgets/botones.dart';
import 'package:app_medcab/src/utils/formato_dinero.dart';
import 'package:app_medcab/src/utils/numero_aleatorio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:app_medcab/src/widgets/button_app.dart';
import 'package:app_medcab/src/pages/client/map/client_map_controller.dart';
import 'package:app_medcab/src/utils/snackbar.dart' as utils;

final _paletaColors = PaletaColors();

class ClientMapPage extends StatefulWidget {
  const ClientMapPage({super.key});
  @override
  State<ClientMapPage> createState() => _ClientMapPageState();
}

class _ClientMapPageState extends State<ClientMapPage> {

  final _con = ClientMapController();

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      _con.init(context, refresh);
    });
  }

  @override
  void dispose() {
    super.dispose();
    _con.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _con.key,
      drawer: _drawer(),
      body: Stack(
        children: [
          _googleMapsWidget(),
          SafeArea(
            child: Column(
              children: [
                _buttonDrawer(),
                _cardGooglePlaces(),
                _buttonCenterPosition(),
                const Spacer(),
                // _verMas(),
                (_con.porcentajeAumentoPaquetes >= 1) ? _paquetes() : const SizedBox(height: 0),
                _buttonRequest()
              ],
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: _iconMyLocation(),
          )
        ],
      ),
    );
  }

  Widget verMas(){
    return Align(
      alignment: Alignment.centerRight,
      child: Padding(
        padding: const EdgeInsets.only(right: 10),
        child: ElevatedButton(
          onPressed: ()=> _con.goToServicioDetailPage(), 
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent
          ),
          child: const Text(
            'Ver más',
            style: TextStyle(
              color: Colors.white
            )
          )
        ),
      ),
    );
  }

  Widget _paquetes(){
    return SizedBox(
      height: 190,
      width: MediaQuery.of(context).size.width,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _con.listInfoPaquetes.length,
        itemBuilder: (BuildContext context, int index) {  
          return _itemPaquete(_con.listInfoPaquetes[index], index);
        },
      ),
    );
  }

  Widget _itemPaquete(Map<String,dynamic> data, int index){

    int intRandom = Calculos.obtenerNumeroAleatorio();
    bool isItemSelect = (index == _con.indexPaqueteSelect);


    return Stack(
      children: [
        InkWell(
          onTap: (){
            _con.selectPaquete(index);
          },
          child: Container(
            height: 170,
            width: 140,
            margin: EdgeInsets.only(right: 20, left: (index == 0) ? 10 : 0, top: 10, bottom: 10),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: isItemSelect ? _paletaColors.mainA : Colors.white,
              boxShadow: [
                BoxShadow(
                  blurRadius: 10,
                  color: _con.colorsPastel[intRandom]
                )
              ]
            ),
            child: _contenidoPaquete(data, isItemSelect),
          ),
        ),
        Positioned(
          bottom: 10,
          right:  18,
          child: IconButton(
            icon: Icon(
              Icons.info_outline,
              color: Colors.grey.withOpacity(0.6)
            ),
            onPressed: ()=> _con.mostrarBottomSheet(_contenidoSheet(data)),
          ),
        )
      ],
    );
  }

  Widget _contenidoSheet(Map<String,dynamic> data){
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            data['nombre'],
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18
            )
          ),
          const Divider(),
          const SizedBox(height: 20),
          _renglonRow(
            'Atención para',
            '${data['pacientes']} persona'
          ),
          const SizedBox(height: 20),
          _renglonRow(
            'Costo paquete',
            FormatoDinero().convertirNum(data['costo'].toDouble())
          ),
          const Spacer(),
          Text(
            data['descripcion'],
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16
            )
          ),
          const SizedBox(height: 15),
          ButtonApp(
            onPressed: ()=> Navigator.pop(context),
            text: 'Aceptar',
            textColor: _paletaColors.mainA,
            icono: const SizedBox(),
            fondoBoton: Colors.white,
          ),
          const SizedBox(height: 15),
        ],
      ),
    );
  }

  Widget _renglonRow(String text1, String text2){
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          text1,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16
          )
        ),
        Text(
          text2,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16
          )
        ),
      ],
    );
  }

  Widget _contenidoPaquete(Map<String,dynamic> data, bool isSelect){
    return Column(
      children: [
        Text(
          data['nombre'],
          style: TextStyle(
            fontSize: 14,
            color: isSelect ? Colors.white : _paletaColors.mainA
          ),
        ),
        const SizedBox(height: 5),
        FaIcon(
          FontAwesomeIcons.briefcaseMedical,
          color: _con.colorsPastel[4],
          size: 45,
        ),
        const SizedBox(height: 5),
        Text(
          FormatoDinero().convertirNum(data['costo'].roundToDouble()),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isSelect ? Colors.white : _paletaColors.mainA
          ),
        ),
        const Spacer(),
        Text(
          'Atención a ${data['pacientes']} paciente',
          style: TextStyle(
            fontSize: 12,
            color: isSelect ? Colors.white : Colors.black
          ),
        ),
      ],
    );
  }

  Widget _iconMyLocation() {
    return Image.asset(
      'assets/img/my_location.png',
      width: 65,
      height: 65,
    );
  }

  Widget _drawer() {
    return Drawer(
      shape: const ContinuousRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.zero,
          bottomRight: Radius.zero,
        ),
      ),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: _paletaColors.mainA
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  child: Text(
                    (_con.client == null) ? 'Nombre' : _con.client!.username!,
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.bold
                    ),
                    maxLines: 1,
                  ),
                ),
                SizedBox(
                  child: Text(
                    (_con.client == null) ? 'Correo' : _con.client!.email!,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.white,
                      fontWeight: FontWeight.bold
                    ),
                    maxLines: 1,
                  ),
                ),
                const SizedBox(height: 10),
                CircleAvatar(
                  backgroundImage: (_con.client == null) ? const AssetImage('assets/img/profile.png') : _con.client!.image != null ? NetworkImage(_con.client!.image!) : const AssetImage('assets/img/profile.png') as ImageProvider<Object>?,
                  radius: 35,
                )
              ],
            ),
          ),
          _opcionMenu(
            'Ajustes perfil',
            Icons.edit,
            _con.goToEditPage,
          ),
          _opcionMenu(
            'Historial de servicios',
            Icons.timer,
            _con.goToHistoryPage,
          ),
          _opcionMenu(
            'Métodos de pago',
            Icons.card_membership_rounded,
            _con.goToMetodos,
          ),
          _opcionMenu(
            'Cerrar sesion',
            Icons.power_settings_new,
            _con.signOut,
          ),
        ],
      ),
    );
  }

  Widget _opcionMenu(String titulo, IconData icono, Function onTap){
    return ListTile(
      title: Text(
        titulo,
        style: TextStyle(
          color: Colors.grey.shade600,
          fontSize: 15
        )
      ),
      leading: _cuadroIcono(icono),
      onTap: ()=> onTap(),
    );
  }

  Widget _cuadroIcono(IconData icono){
    return Container(
      height: 36,
      width:  36,
      decoration: BoxDecoration(
        color: _paletaColors.mainB,
        border: Border.all(
          color: Colors.blueGrey,
        ),
        borderRadius: BorderRadius.circular(10)
      ),
      alignment: AlignmentDirectional.center,
      child: Icon(
        icono,
        color: Colors.white,
      ),
    );
  }

  Widget _buttonCenterPosition() {
    return GestureDetector(
      onTap: _con.centerPosition,
      child: Container(
        alignment: Alignment.centerRight,
        margin: const EdgeInsets.symmetric(horizontal: 18),
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

  Widget _buttonDrawer() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        height: 50,
        width: 50,
        alignment: Alignment.center,
        margin: const EdgeInsets.only(top: 8, left: 8, bottom: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: _paletaColors.mainA
        ),
        child: IconButton(
          onPressed: _con.openDrawer,
          icon: const Icon(Icons.menu, color: Colors.white,),
        ),
      ),
    );
  }

  Widget _buttonRequest() {
    return Container(
      height: 50,
      alignment: Alignment.bottomCenter,
      margin: const EdgeInsets.only(left: 60, right: 60, bottom: 20, top: 15),
      child: ButtonApp(
        fondoBoton: paletaColors.mainA,
        onPressed: (){
          if(_con.porcentajeAumentoPaquetes <= 1){
            MisAvisos().ventanaAviso(context, 'Actualmente la ubicación del servicio no se encuentra en un área de cobertura activa. Lamentamos los inconvenientes.');
          } else
          if(_con.mapPaqueteSelect.isEmpty){
            utils.Snackbar.showSnackbar(context, _con.key, 'Elejir el paquete de atención deseado');
          } else {
            _con.requestDriver();
          }
        },
        text: 'SOLICITAR',
        icono: const FaIcon(
          FontAwesomeIcons.hospitalUser,
          color: Colors.white,
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
      onCameraMove: (position)  {
        _con.initialPosition = position;
      },
      onCameraIdle: () async {
        await _con.setLocationDraggableInfo();
      },
    );
  }

  Widget _cardGooglePlaces() {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.9,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20)
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _infoCardLocation(
                'Ubicación paciente',
                _con.from ?? '',
                () async {
                  _con.isFromSelected = true;
                  _con.buscarFunction();
                }
              ),
              const SizedBox(height: 5),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoCardLocation(String title, String value, Function function) {
    return GestureDetector(
      onTap: ()=> function(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 10
            ),
            textAlign: TextAlign.start,
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 14,
              fontWeight: FontWeight.bold
            ),
            maxLines: 2,
          ),
        ],
      ),
    );
  }

  void refresh() {
    if(mounted){
      setState(() {});
    }
  }

}
