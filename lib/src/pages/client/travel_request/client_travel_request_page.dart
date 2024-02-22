
import 'package:app_medcab/src/shared/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:app_medcab/src/pages/client/travel_request/client_travel_request_controller.dart';
import 'package:app_medcab/src/widgets/button_app.dart';
// import 'dart:convert';
// import 'package:http/http.dart' as http;

final _paletaColors = PaletaColors();

class ClientTravelRequestPage extends StatefulWidget {
  const ClientTravelRequestPage({super.key});
  @override
  State<ClientTravelRequestPage> createState() => _ClientTravelRequestPageState();
}

class _ClientTravelRequestPageState extends State<ClientTravelRequestPage> {

  final _con = ClientTravelRequestController();

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
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _driverInfo(),
          const Spacer(),
          _lottieAnimation(),
          const Spacer(),
          _textLookingFor(),
        ],
      ),
      bottomNavigationBar: _buttonCancel(),
    );
  }

  Widget _buttonCancel() {
    return Container(
      height: 50,
      margin: const EdgeInsets.all(30),
      child: ButtonApp(
        text: 'Cancelar solicitud',
        icon: Icons.cancel_outlined,
        onPressed: _con.cancelTravel,
        icono: const FaIcon(
          FontAwesomeIcons.circleXmark,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _lottieAnimation() {
    return Lottie.asset(
      'assets/json/busqueda.json',
      width:  250,
      height: 250,
      fit: BoxFit.fill
    );
  }

  Widget _textLookingFor() {
    return const SizedBox(
      child: Text(
        'Buscando...',
        style: TextStyle(
          fontSize: 16
        ),
      ),
    );
  }

  Widget _driverInfo() {
    return ClipPath(
      clipper: WaveClipperOne(),
      child: Container(
        height: 220,
        color: _paletaColors.mainA,
        width: double.infinity,
        child: const Padding(
          padding: EdgeInsets.only(left: 30, top: 30),
          child: SafeArea(
            child: Text(
              'MedCab',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 30
              ),
            ),
          ),
        ),
      ),
    );
  }


  void refresh() {
    if(mounted){
      setState(() {});
    }
  }
}
