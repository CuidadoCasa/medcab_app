import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:app_medcab/src/providers/variables_provider.dart';
import 'package:app_medcab/src/shared/avisos.dart';
import 'package:app_medcab/src/shared/colors.dart';
import 'package:app_medcab/src/shared/widgets/botones.dart';
import 'package:app_medcab/src/shared/widgets/pantalla_carga.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class AceptarTConnect extends StatefulWidget {

  final Map<String,dynamic> dataConnect;
  final String userId;
  final String connectUserID;
  final bool isAcepTC;

  const AceptarTConnect({
    super.key,
    required this.dataConnect,
    required this.userId,
    required this.connectUserID,
    required this.isAcepTC
  });

  @override
  State<AceptarTConnect> createState() => _AceptarTConnectState();
}

class _AceptarTConnectState extends State<AceptarTConnect> {
  // String baseUrl = 'http://192.168.100.36:3000';
  String baseUrl = 'https://cuidadoencasa-api-test.onrender.com';

  final _paletaColors = PaletaColors();

  bool mostrarMensaje = false;
  bool cargando = true;
  bool isAcepted = false;
  int hasTermCon = 0;

  String connectUserID = '';
  String userId = '';
  
  FToast ? fToast;

  @override
  void initState() {
    fToast = FToast();
    fToast!.init(context);
    _initData();
    super.initState();
  }

  void _initData() {
    final dataProvider = Provider.of<VariablesProvider>(context, listen: false);
    Map<String,dynamic> dataConnect = widget.dataConnect;
    connectUserID = dataProvider.idCuentaConnect;
    userId = widget.userId;

    cargando = false;
    if(mounted){
      setState((){});
    }
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if(dataConnect.isEmpty){
        MisAvisos().ventanaAviso(context, 'Para crear tu cuenta stripe connect es necesario que proporciones información veridica y escrita de forma correcta, tenga a la mano su INE, CURP y RFC con homoclave.');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return !cargando ? Scaffold(
      bottomNavigationBar: _logoStripe(),
      appBar: AppBar(
        elevation: 0,
        leading: InkWell(
          onTap: (){
            Navigator.pop(context);
          },
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          hoverColor: Colors.transparent,
          child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white)
        ),
        backgroundColor: _paletaColors.colorStripe,
        title: const Text(
          'Contrato cuenta Connect',
          textAlign: TextAlign.start,
          style: TextStyle(
            fontFamily: 'Titulos',
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white
          )
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline, color: Colors.white),
            onPressed: (){
              MisAvisos().ventanaAviso(
                context, 
                'Stripe Connect es una plataforma segura de pagos en línea que facilita la transacción de fondos entre usuarios y proveedores de servicios, ofreciendo una experiencia confiable y protegida.'
              );
            }, 
          )
        ],
      ),
      body: SafeArea(
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: _body()
        )
      )
    ) : const PantallaCarga(titulo: 'Cargando...');
  }

  Widget _body(){
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          _descripcion(),
          const SizedBox(height: 20),
          _botonEnlace(),
        ],
      ),
    );
  }

  Widget _descripcion(){
    return const Text(
      '\nAl presionar el botón a continuación, será redirigido a la página oficial de Stripe, donde se presentarán los términos y condiciones de su contrato de cuenta Connect. Le recomendamos leerlos detenidamente para comprender plenamente el alcance de su contrato.',
      textAlign: TextAlign.justify,
      style: TextStyle(
        fontSize: 13
      ),
    );
  }

  Widget _botonEnlace(){
    return InkWell(
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      hoverColor: Colors.transparent,
      onTap: ()=> _abrirNavegador(Uri.parse('https://stripe.com/mx/legal/connect-account')),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Abrir enlace',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: _paletaColors.mainB,
              fontSize: 16
            ),
          ),
          const SizedBox(width: 10),
          Icon(Icons.link, color: _paletaColors.mainB, size: 40),
        ],
      ),
    );
  }

  Widget _logoStripe(){
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 5,
            blurRadius: 7,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      height: 120,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Column(
          children: [
            MyBoton(
              titulo: 'Aceptar Contrato', 
              fondo: !widget.isAcepTC ?_paletaColors.mainB : Colors.grey,
              onpress: ()=>  !widget.isAcepTC ? _crearCuentaConnect() : (){},
            ),
            const SizedBox(height: 10),
            SvgPicture.asset(
              'assets/stripe/Powered by Stripe - blurple.svg',
              height: 28,
            ),
          ],
        ),
      ),
    );
  }

  void _crearCuentaConnect(){
    MisAvisos().ventanaConfirmarAccion(
      context, 
      'Al aceptar, declaro que he revisado y comprendido completamente los términos y condiciones del contrato de mi cuenta Connect. Estoy de acuerdo en cumplir con todas las disposiciones establecidas.', 
      ()=> _aceptarContratoStripe(),
      sizeFuente: 14
    );
  }
  
  Future<void> _abrirNavegador(Uri url) async {
    if (!await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    )) {
      throw Exception('Could not launch $url');
    }
  }
  
  void _aceptarContratoStripe() async {
    MisAvisos().ventanaTrabajando(context, 'Aceptando contrato...');
    String miIP = await _obtenerDireccionIPPublica();

    if(miIP != 'error'){
      try {
        Dio dio = Dio();
        String url = '$baseUrl/api/enfermera/aceptarTC';

        Map<String, dynamic> datos = {
          'accountId': connectUserID,
          'ipAddress': miIP
        };

        Response response = await dio.post(
          url,
          data: datos,
        );

        if(response.statusCode == 200){
          await FirebaseFirestore.instance
          .collection('Drivers')
          .doc(userId)
          .collection('informacion')
          .doc('personal')
          .set({
            'hasAcepTyC': 1,
          }, SetOptions(merge: true));

          await FirebaseFirestore.instance
          .collection('Drivers')
          .doc(userId)
          .set({
            'hasAcepTyC': 1,
          }, SetOptions(merge: true));
        }

        if(response.statusCode == 200){
          _regresarSucces();
        } else {
          _regresarError();
        }
      } catch (e) {
        _regresarError();
      }

    } else {
      _regresarError();
    }
  }

  void _regresarError(){
    Navigator.pop(context);
    Navigator.pop(context);
    MisAvisos().showToast(
      'Intente nuevamente\nverifique su conexión.', 
      2200, 
      fToast!, 
      true
    );
  }

  void _regresarSucces(){
    Navigator.pop(context);
    Navigator.pop(context);
    Navigator.pop(context, {'aceptoTC': 1});
    MisAvisos().showToast(
      '¡Contrato aceptado\ncorrectamente!', 
      2200, 
      fToast!, 
      false
    );
  }

  Future<String> _obtenerDireccionIPPublica() async {
    try {
      Dio dio = Dio();
      Response response = await dio.get('https://api.ipify.org');
      String ipPublica = response.data;
      return ipPublica;
    } catch (e) {
      return 'error';
    }
  }

}
