import 'package:app_medcab/src/providers/variables_provider.dart';
import 'package:app_medcab/src/shared/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:app_medcab/src/pages/driver/map/driver_map_controller.dart';
import 'package:app_medcab/src/widgets/button_app.dart';
import 'package:provider/provider.dart';

final _paletaColors = PaletaColors();

class DriverMapPage extends StatefulWidget {
  const DriverMapPage({super.key});

  @override
  State<DriverMapPage> createState() => _DriverMapPageState();
}

class _DriverMapPageState extends State<DriverMapPage> {

  final _con = DriverMapController();

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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buttonDrawer(),
                    _buttonCenterPosition(),
                  ],
                ),
                Expanded(child: Container()),
                _buttonConnect()
              ],
            ),
          ),
          _indicadorActivo()
        ],
      ),
    );
  }

  Widget _indicadorActivo(){
    return Align(
      alignment: Alignment.topCenter,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            height: 50,
            width: _con.isConnect ? 100 : 50,
            decoration: BoxDecoration(
              color: _con.isConnect ? Colors.greenAccent.shade400 : Colors.grey.shade700,
              borderRadius: BorderRadius.circular(25)
            ),
            child: Center(
              child: FaIcon(
                _con.isConnect ? FontAwesomeIcons.plugCircleCheck : FontAwesomeIcons.plugCircleXmark,
                color: _con.isConnect ? Colors.green.shade900 : Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _drawer() {
    return Drawer(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
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
              color:  _paletaColors.mainA
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  child: Text(
                    _con.driver?.username ?? 'Nombre de usuario',
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
                    _con.driver?.email ?? 'Correo electronico' ,
                    style: const TextStyle(
                        fontSize: 13,
                        color: Colors.white,
                        fontWeight: FontWeight.normal
                    ),
                    maxLines: 1,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: _con.driver?.image != null
                          ? NetworkImage(_con.driver!.image!)
                          : const AssetImage('assets/img/profile.png') as ImageProvider<Object>?,
                      radius: 35,
                    ),
                    const SizedBox(width: 15),
                    Column(
                      children: [
                        const Text(
                          'Estatus cuenta',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12
                          ),
                        ),
                        Text(
                          (_con.driver != null) ? (_con.driver!.isAutorizado != null) ? (_con.driver!.isAutorizado == 0) ? 'En revisión' : 'Autorizada' : '' : '-',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold
                          ),
                        )
                      ],
                    )
                  ],
                )
              ],
            ),
          ),
          _opcionMenu(
            'Ajustes perfil',
            Icons.settings,
            _con.goToEditPage,
            0
          ),
          _opcionMenu(
            'Mis servicios',
            Icons.line_weight_sharp,
            _con.goToHistoryPage,
            1
          ),
          // _opcionMenu(
          //   'Mis ganancias',
          //   Icons.credit_card,
          //   (){},
          //   2
          // ),
          _opcionMenu(
            'Ajustes cuenta pago', 
            CupertinoIcons.creditcard, 
            _con.goToConnect,
            3
          ),
          _opcionMenu(
            'Cerrar sesion',
            Icons.power_settings_new,
            (){
              _con.signOut();
            },
            4
          ),
        ],
      ),
    );
  }

  Widget _opcionMenu(String titulo, IconData icono, Function onTap, int index){

    bool faltanDatos = true;

    if(index == 0){
      if(_con.driver != null){
        if(_con.driver!.hasCedula == 0 || _con.driver!.hasTitulo == 0 || _con.driver!.hasINE == 0 || _con.driver!.image!.isEmpty ||  _con.driver!.hasCartas == 0 ||  _con.driver!.hasFiscal == 0 ||  _con.driver!.hasDomicilio == 0){
          faltanDatos = true;
        } else {
          faltanDatos = false;
        }
      }
    } else
    if(index == 3){
      if(_con.driver != null){
        if(_con.driver!.hasConnect == 0 || _con.driver!.hasAcepTyC == 0 || _con.driver!.hasClab == 0){
          faltanDatos = true;
        } else {
          faltanDatos = false;
        }
      }
    } else {
      faltanDatos = false;
    }

    return ListTile(
      title: Text(
        titulo,
        style: TextStyle(
          color: Colors.grey.shade600,
          fontSize: 15
        )
      ),
      leading: _cuadroIcono(icono),
      trailing: Icon(
        Icons.circle,
        color: faltanDatos ? _paletaColors.rojoMain : Colors.white
      ),
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

  Widget _buttonDrawer() {
    return Container(
      height: 50,
      width: 50,
      alignment: Alignment.center,
      margin: const EdgeInsets.only(top: 8, left: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color:_paletaColors.mainA
      ),
      child: IconButton(
        onPressed: _con.openDrawer,
        icon: const Icon(Icons.menu, color: Colors.white,),
      ),
    );
  }

  Widget _buttonConnect() {
    final dataProvider = Provider.of<VariablesProvider>(context, listen: false);

    return Container(
      height: 50,
      alignment: Alignment.bottomCenter,
      margin: const EdgeInsets.symmetric(horizontal: 60, vertical: 30),
      child: ButtonApp(
        onPressed: (){
          if(dataProvider.isConect){
            dataProvider.isConect = false;
          } else {
            dataProvider.isConect = true;
          }
          _con.connect(!dataProvider.isConect);
        },
        text: _con.isConnect ? 'Desconectarme' : 'Conectarme',
        fondoBoton: _con.isConnect ? _paletaColors.mainB : Colors.grey,
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
    );
  }

  void refresh() {
    if(mounted){
      setState(() {});
    }
  }

}
