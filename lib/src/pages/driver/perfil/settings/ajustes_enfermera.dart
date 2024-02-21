import 'package:app_medcab/src/pages/driver/perfil/settings/mis_ajustes_menu.dart';
import 'package:app_medcab/src/shared/colors.dart';
import 'package:app_medcab/src/shared/widgets/botones.dart';
import 'package:app_medcab/src/shared/widgets/pantalla_carga.dart';
import 'package:app_medcab/src/shared/widgets/widgets_general.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AjustesEnfermera extends StatefulWidget {

  final String userId;
  const AjustesEnfermera({
    super.key,
    required this.userId
  });

  @override
  State<AjustesEnfermera> createState() => _AjustesEnfermeraState();
}

class _AjustesEnfermeraState extends State<AjustesEnfermera> {
  final _paletaColors = PaletaColors();
  
  FToast ? fToast;

  String userId = '';
  bool cargando = true;

  @override
  void initState() {
    fToast = FToast();
    fToast!.init(context);
    _initData();
    super.initState();
  }

  void _initData() async {
    userId = widget.userId;
    cargando = false;

    if(mounted){
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return !cargando ? Scaffold(
      backgroundColor: Colors.white,
      appBar: MisWidgets().miAppBar(
        'Mi cuenta Connect',
        (){
          Navigator.pop(context);
        },
        isStripe: true
      ),
      body: SafeArea(
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: _body(),
        )
      )
    ) : const PantallaCarga(titulo: 'Cargando...');
  }

  Widget _body(){
    final size = MediaQuery.of(context).size.width;
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: (size > 750) ? 200 : 40, vertical: 10),
        child: Column(
          children: _widgetsCuerpo(),
        ),
      ),
    );
  }

  List<Widget> _widgetsCuerpo(){
    return [
      _espacio(),
      _logoStripe(),
      _espacio(),
      _descripcion('En esta sección, tendrás la capacidad de proporcionar la información necesaria para recibir los ingresos generados por los servicios médicos desempeñados. La gestión de tus fondos se llevará a cabo a través de la reconocida plataforma de pagos Stripe, garantizando así un entorno seguro y confiable para el manejo de tus transacciones.'),
      _espacio(),
      _espacio(),
      const SizedBox(height: 60),
      _boton()
    ];
  }

  Widget _logoStripe(){
    return Center(
      child: Image.asset(
        'assets/stripe/Stripe wordmark - blurple (small).png',
        height: 60,
      )
    );
  }

  Widget _descripcion(String text){
    return Text(
      text,
      textAlign: TextAlign.justify,
      style: const TextStyle(
        // color: _paletaColors.negroMain,
        fontSize: 14
      ),
    );
  }

  Widget _boton(){
    return MyBoton(
      titulo: 'Continuar',
      fondo: _paletaColors.mainA,
      onpress: (){
        Navigator.push(
          context,
          MaterialPageRoute<void>(
            builder: (BuildContext context) =>  MiCuentaConnnectAjustes(userId: widget.userId)
          )
        );
      },      
    );
  }

  Widget _espacio(){
    return const SizedBox(
      height: 15
    );
  }
}