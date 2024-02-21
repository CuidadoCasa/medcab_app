import 'package:app_medcab/src/pages/driver/perfil/settings/stripe_aceptar_tc.dart';
import 'package:app_medcab/src/pages/driver/perfil/settings/stripe_clabe.dart';
import 'package:app_medcab/src/pages/driver/perfil/settings/stripe_connect.dart';
import 'package:app_medcab/src/providers/variables_provider.dart';
import 'package:app_medcab/src/shared/avisos.dart';
import 'package:app_medcab/src/shared/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

class MiCuentaConnnectAjustes extends StatefulWidget {

  final String userId;

  const MiCuentaConnnectAjustes({
    super.key,
    required this.userId
  });

  @override
  State<MiCuentaConnnectAjustes> createState() => _MiCuentaConnnectAjustesState();
}

class _MiCuentaConnnectAjustesState extends State<MiCuentaConnnectAjustes> {
  final _paletaColors = PaletaColors();
  
  // PlatformFile ? ineFrente;
  // PlatformFile ? ineRevers;
  FToast ? fToast;

  String userId = '';
  String ineFre = '';
  String ineRev = '';
  String connectUserID = '';
  String nombreCompleto = '';
  String connectCLABE = '';

  bool cargando = true;

  int hasConnect = 0;
  int hasAcepTyC = 0;
  int hasCLABE =   0;

  Map<String,dynamic> datosUser = {};

  @override
  void initState() {
    fToast = FToast();
    fToast!.init(context);
    _initData();
    super.initState();
  }

  void _initData() async {
    final dataProvider = Provider.of<VariablesProvider>(context, listen: false);
    userId = widget.userId;

    String nombreAux = '';
    String apelliAux = '';

    DocumentSnapshot<Map<String, dynamic>> datos = await FirebaseFirestore.instance
    .collection('Drivers')
    .doc(userId)
    .collection('informacion')
    .doc('personal')
    .get();

    datosUser = datos.data() as Map<String, dynamic>;
    
    hasAcepTyC = datosUser.containsKey('hasAcepTyC') ? datosUser['hasAcepTyC'] : 0;
    nombreAux = datosUser.containsKey('connectNombre') ? datosUser['connectNombre'] : '';
    apelliAux = datosUser.containsKey('connectApelli') ? datosUser['connectApelli'] : '';
    connectCLABE  = datosUser.containsKey('connecttCLABE') ? datosUser['connecttCLABE'] : '';
    connectUserID = datosUser.containsKey('connectUserID') ? datosUser['connectUserID'] : '';

    nombreCompleto = '$nombreAux $apelliAux';
    dataProvider.nombreCompleto = nombreCompleto;
    dataProvider.idCuentaConnect = connectUserID;

    if(connectUserID.isNotEmpty){
      hasConnect = 1;
    }

    if(connectCLABE.isNotEmpty){
      hasCLABE = 1;
    }

    cargando = false;

    if(mounted){
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: _logoStripe(),
      appBar: AppBar(
        backgroundColor: _paletaColors.colorStripe,
        elevation: 0,
        iconTheme: const IconThemeData(
          color: Colors.white
        ),
        title: const Text(
          'Mi cuenta stripe',
          textAlign: TextAlign.start,
          style: TextStyle(
            fontFamily: 'Titulos',
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white
          )
        ),
      ),
      body: SafeArea(
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: _body(),
        )
      )
    );
  }

  Widget _body(){
    final size = MediaQuery.of(context).size.width;
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: (size > 750) ? 200 : 25, vertical: 10),
        child: Column(
          children: _widgetsCuerpo(),
        ),
      ),
    );
  }

  List<Widget> _widgetsCuerpo(){
    return [
      _espacio(),
      ..._botonesOpciones(),
      _espacio(),
    ];
  }

  List<Widget> _botonesOpciones(){
    return [
      _itemOpcion(
        'Crear cuenta Connect',
        Icons.account_balance,
        false,
        (hasConnect == 1),
        ()=> _navegarCuentaConnnect()
      ),
      _itemOpcion(
        'Mi CLABE',
        CupertinoIcons.creditcard_fill,
        false,
        (hasCLABE == 1),
        ()=> _navegarCuentaCLABE()
      ),
      _itemOpcion(
        'Aceptar contrato',
        Icons.edit_document,
        false,
        (hasAcepTyC == 1),
        ()=> _navegarAceptarTC()
      ),
    ];
  }

  void _navegarCuentaConnnect() async {
    var data = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CuentaConnect(
          dataConnect: datosUser, 
          hasCuentaConnect: (hasConnect == 1),
          userId: userId,
        )
      ),
    );

    if (data != null) {
      hasConnect = data['connect'];
      connectUserID = data['connectUserID'];
      setState((){});
    } else {
      debugPrint('Cuenta no creada');
    }
  }

  void _navegarCuentaCLABE() async {
    if(connectUserID == ''){
      MisAvisos().ventanaAviso(context, 'Antes de agregar la CLABE debe crear su cuenta Connect.');
    } else {
      var data = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => MicuentaCLABE(
            dataConnect: datosUser, 
            userId: userId,
            hasClab: (hasCLABE == 1),
          )
        ),
      );

      if (data != null) {
        hasCLABE = data['hasClabe'];
        setState((){});
      } else {
        debugPrint('clabe no agregada');
      }
    }
  }

  void _navegarAceptarTC() async {
    if(connectUserID == ''){
      MisAvisos().ventanaAviso(context, 'No se pueden aceptar el contrato sin antes crear su cuenta Connect');
    } else
    if(hasCLABE == 0){
      MisAvisos().ventanaAviso(context, 'Antes de aceptar el contrato Connect pOR favor agregue su CLABE.');
    } else {
      var data = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => AceptarTConnect(
            dataConnect: datosUser, 
            userId: userId, 
            connectUserID: connectUserID, 
            isAcepTC: (hasAcepTyC == 1)
          )
        ),
      );

      if (data != null) {
        hasAcepTyC = data['aceptoTC'];
        setState((){});
      } else {
        debugPrint('clabe no agregada');
      }
    }
  }

  Widget _itemOpcion(String titulo, IconData icono, bool isLast, bool isComplte, Function onpress){
    return InkWell(
      onTap: ()=> onpress(),
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      hoverColor: Colors.transparent,
      child: Container(
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 15),
        margin: const EdgeInsets.only(bottom: 30),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              child: Row(
                children: [
                  Container(
                    width:  50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: _paletaColors.mainB,
                      borderRadius: BorderRadius.circular(10)
                    ),
                    child: Icon(icono, color: Colors.white, size: 30)
                  ),
                  const SizedBox(width: 15),
                  Text(
                    titulo,
                    style: const TextStyle(
                      fontSize: 15
                    ),
                  ),
                ],
              )
            ),
            SizedBox(
              width: 50,
              child: Row(
                children: [
                  Icon(
                    Icons.circle,
                    color: isComplte ? Colors.white : Colors.redAccent,
                  ),
                  const Icon(
                    Icons.arrow_forward_ios_outlined,
                    size: 25,
                    color: Colors.grey,
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _logoStripe(){
    return SizedBox(
      height: 50,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: SvgPicture.asset(
          'assets/stripe/Powered by Stripe - white.svg',
        ),
      ),
    );
  }

  Widget _espacio(){
    return const SizedBox(
      height: 15
    );
  }
}