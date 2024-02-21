import 'package:app_medcab/src/shared/colors.dart';
import 'package:app_medcab/src/utils/formato_dinero.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'package:app_medcab/src/pages/driver/travel_request/driver_travel_request_controller.dart';
import 'package:app_medcab/src/widgets/button_app.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

final _paletaColors = PaletaColors();

class DriverTravelRequestPage extends StatefulWidget {
  const DriverTravelRequestPage({super.key});

  @override
  State<DriverTravelRequestPage> createState() => _DriverTravelRequestPageState();
}

class _DriverTravelRequestPageState extends State<DriverTravelRequestPage> {

  final _con = DriverTravelRequestController();

  @override
  void dispose() {
    super.dispose();
    _con.dispose();
  }

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
      body: SingleChildScrollView(
        child: Column(
          children: [
            _bannerClientInfo(),
            ..._lisInformacion(),
            _textTimeLimit()
          ],
        ),
      ),
      bottomNavigationBar: _buttonsAction(),
    );
  }

  List<Widget> _lisInformacion(){

    int total = 0;
    double comision = 0;
    double ganancia = 0;

    if(_con.costo != null){
      total = _con.costo!;
      comision = (total * 0.3).roundToDouble();
      ganancia = total - comision;
    }

    return [
      _listTileInfoServicio(
        'Ubicación',
        _con.from ?? '',
        const Icon(Icons.gps_fixed_outlined)
      ),
      _listTileInfoServicio(
        'Servicio',
        _con.nombre ?? '',
        const Icon(Icons.medical_information_rounded)
      ),
      _listTileInfoServicio(
        'Descripción',
        _con.descripcion ?? '',
        const Icon(Icons.edit_document)
      ),
      _listTileInfoServicio(
        'Costo',
        (_con.costo == null) ? '\$ 0.00' : FormatoDinero().convertirNum(_con.costo!.toDouble()),
        const Icon(Icons.attach_money_rounded)
      ),
      _listTileInfoServicio(
        'Ganancia',
        (_con.costo == null) ? '\$ 0.00' : FormatoDinero().convertirNum(ganancia),
        const Icon(Icons.attach_money_rounded)
      ),
    ];
  }

  Widget _buttonsAction() {
    return Container(
      height: 50,
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.45,
            child: ButtonApp(
              onPressed: _con.cancelTravel,
              text: 'Cancelar',
              icon: Icons.cancel_outlined,
              fondoBoton: _paletaColors.grisC,
              icono: const SizedBox()
            ),
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.45,
            child: ButtonApp(
              onPressed: _con.siguienteStatus,
              // onPressed: _con.acceptTravel,
              text: 'Aceptar',
              fondoBoton: _paletaColors.mainB,
              icon: Icons.check,
              icono: const SizedBox(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _textTimeLimit() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 30),
      child: Text(
        _con.seconds.toString(),
        style: const TextStyle(
          fontSize: 50
        ),
      ),
    );
  }

  Widget _bannerClientInfo() {
    return ClipPath(
      clipper: WaveClipperOne(),
      child: Container(
        height: 220,
        width: double.infinity,
        color: _paletaColors.mainB,
        padding: const EdgeInsets.only(left: 20, top: 20),
        child: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.white,
                child: FaIcon(
                  FontAwesomeIcons.clipboardUser,
                  color: _paletaColors.grisO,
                  size: 60,
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(left: 15),
                    child: const Text(
                      'Paciente',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 5, left: 15),
                    child: Text(
                      _con.client?.username?? '',
                      style: const TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.bold
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _listTileInfoServicio(String titulo, String descripcion, Widget icono){
    return ListTile(
      title: Text(
        titulo,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: _paletaColors.mainA
        ),
      ),
      subtitle: Text(
        descripcion,
        style: const TextStyle(
          fontSize: 15
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      leading: icono,
    );
  }

  void refresh() {
    if(mounted){
      setState(() {});
    }
  }
}
