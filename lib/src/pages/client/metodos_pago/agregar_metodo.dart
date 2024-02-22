import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:app_medcab/src/pages/client/metodos_pago/mis_metodos_pago.dart';
import 'package:app_medcab/src/providers/variables_provider.dart';
import 'package:app_medcab/src/shared/avisos.dart';
import 'package:app_medcab/src/shared/colors.dart';
import 'package:app_medcab/src/shared/widgets/botones.dart';
import 'package:app_medcab/src/shared/widgets/form_general.dart';
import 'package:app_medcab/src/shared/widgets/pantalla_carga.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

class AgregarMetodoPage extends StatefulWidget {
  const AgregarMetodoPage({super.key});

  @override
  State<AgregarMetodoPage> createState() => _AgregarMetodoPageState();
}

class _AgregarMetodoPageState extends State<AgregarMetodoPage> {

  final _titularNombre = TextEditingController();
  final _titularCorreo = TextEditingController();

  final _focusNombre = FocusNode();
  final _focusCorreo = FocusNode();
  final _paletaColors = PaletaColors();

  final formKey = GlobalKey<FormState>();

  String emailUser = '';
  String userId = '';
  String idCostumerStripe = '';
  String clientSecretSetupIntente = '';
  String username = '';
  
  // String baseUrl = 'http://192.168.100.36:3000';
  String baseUrl = 'https://api-medcab.onrender.com';

  bool trabajando = true;
  bool autoValidar = false;
  bool errorReintentar = false;

  List<Map<String,dynamic>> listMisMetodos = [];
  List<IconData> listIconos = [
    FontAwesomeIcons.ccVisa,
    FontAwesomeIcons.ccMastercard,
    FontAwesomeIcons.ccPaypal,
    FontAwesomeIcons.creditCard,
    FontAwesomeIcons.ccAmex,
  ];

  FToast ? fToast;

  @override
  void initState() {
    fToast = FToast();
    fToast!.init(context);
    _initData();
    super.initState();
  }

  void _initData() async {
    final user = FirebaseAuth.instance.currentUser;
    final dataProvider = Provider.of<VariablesProvider>(context, listen: false);

    if(user != null){
      emailUser = user.email!;
      userId = user.uid;

      username = dataProvider.dataUsuario['nombre'];
      idCostumerStripe = dataProvider.dataUsuario['costumer'];

      if(dataProvider.dataUsuario['costumer'].isEmpty){
        DocumentSnapshot<Map<String, dynamic>> datos = await FirebaseFirestore.instance
        .collection('Clients')
        .doc(userId)
        .collection('informacion')
        .doc('personal')
        .get();

        if(datos.data() != null){
          Map<String,dynamic> datosUser = datos.data() as Map<String, dynamic>;
          idCostumerStripe = datosUser.containsKey('idCostumerStripe') ? datosUser['idCostumerStripe'] : '';
        }
      }
    }

    if(mounted){
      trabajando = false;
      setState((){});
    }
  }

  @override
  void dispose() {

    _titularNombre.dispose();
    _titularCorreo.dispose();
    _focusNombre.dispose();
    _focusCorreo.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return !trabajando ? Form(
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Agregar nuevo método',
            style: TextStyle(
              fontSize: 18
            )
          ),
        ),
        bottomNavigationBar: _botonContinuar(),
        body: Form(
          key: formKey,
          child: _body()
        ),
      ),
    ) : const PantallaCarga(titulo: 'Cargando...');
  }

  Widget _botonContinuar(){
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          MyBoton(
            titulo: 'Continuar', 
            fondo: (_titularCorreo.text.trim().isNotEmpty | _titularNombre.text.trim().isNotEmpty) ? _paletaColors.mainA : Colors.grey,
            onpress: (){
              _checkForm();
              if(formKey.currentState!.validate()){
                _obtenerClaves();
              }
            }
          ),
          const SizedBox(height: 10),
          SvgPicture.asset(
            'assets/stripe/Powered by Stripe - blurple.svg',
            height: 28,
          ),
        ],
      ),
    );
  }

  Widget _body(){
    final size = MediaQuery.of(context).size.width;
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: (size > 750) ? 200 : 40, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ..._listForms(),
          ],
        ),
      ),
    );
  }

  List<Widget> _listForms(){
    return [
      ..._listNombre(),
      ..._listCorreo()
    ];
  }

  List<Widget> _listNombre(){
    return [
      Align(
        alignment: Alignment.centerLeft,
        child: _tituloSeccion('Nombre completo del titular', 17.5)
      ),
      FormGeneralConTitulo(
        autovalidar: autoValidar,
        control: _titularNombre, 
        capitalizacion: TextCapitalization.words,
        titulo: 'Nombre', 
        onChange: (){}, 
        focusForm: _focusNombre, 
        onComplete: (){
          FocusScope.of(context).requestFocus(_focusCorreo);
        }, 
        maxLenght: 150, 
        validator: (String ? value){
          RegExp regex = RegExp(r"^[a-zA-Z\s]+$");
          if(value!.trim().length < 3){
            return 'Nombre(s) requeridos';
          } else
          if(!regex.hasMatch(value.trim())){
            return 'Verificar la escritura';
          } else {
            return null;
          }
        }
      ),
    ];
  }

  List<Widget> _listCorreo(){
    return [
      Align(
        alignment: Alignment.centerLeft,
        child: _tituloSeccion('Correo del titular', 17.5)
      ),
      FormGeneralConTitulo(
        autovalidar: autoValidar,
        control: _titularCorreo, 
        capitalizacion: TextCapitalization.none,
        titulo: 'Email', 
        onChange: (){}, 
        focusForm: _focusCorreo, 
        onComplete: (){
          FocusScope.of(context).unfocus();
        }, 
        tipoTeclado: TextInputType.emailAddress,
        maxLenght: 150, 
        validator: (String ? value){
          RegExp regex = RegExp(r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$');
          if (!regex.hasMatch(value!)) {
            return 'Formato de email incorrecto';
          } else {
            return null;
          }
        }
      ),
    ];
  }

  Widget _tituloSeccion(String titulo, double alto){
    return Padding(
      padding: const EdgeInsets.only(left: 10, top: 15, bottom: 15),
      child: Text(
        titulo,
        style: TextStyle(
          fontFamily: 'Titulos',
          color: _paletaColors.mainA,
          fontWeight: FontWeight.bold,
          fontSize: alto
        ),
      ),
    );
  }

  Future<void> _guardarMetodosPagoStripe(String setupIntentClientSecret, String customerId)async{
    if(mounted) Navigator.pop(context);
    try {
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          intentConfiguration: const IntentConfiguration(
            mode: IntentMode(
              currencyCode: 'MX', 
              amount: 100,
              setupFutureUsage: IntentFutureUsage.OnSession              
            )
          ),
          setupIntentClientSecret: setupIntentClientSecret,
          customerId: customerId,
          merchantDisplayName: 'MedCab',
          billingDetails: BillingDetails(
            name: username,
            email: emailUser,
          ),
        ),
      );
      await Stripe.instance.presentPaymentSheet();
      _regresarSucces();
    } catch(e){
      _regresarError();
    }
  }

  Future<void> _obtenerClaves() async {
    MisAvisos().ventanaTrabajando(context, 'Cargando...');
    final dataProvider = Provider.of<VariablesProvider>(context, listen: false);

    if(idCostumerStripe.isEmpty){
      idCostumerStripe = await _crearCutomer(emailUser);
    }

    if(idCostumerStripe.isNotEmpty){
      clientSecretSetupIntente = await _crearSetupIntent(idCostumerStripe);
    }

    if(idCostumerStripe.isNotEmpty && clientSecretSetupIntente.isNotEmpty){
      dataProvider.dataUsuario.update('costumer', (value)=> idCostumerStripe);

      await FirebaseFirestore.instance
      .collection('Clients')
      .doc(userId)
      .collection('informacion')
      .doc('personal')
      .set({
        'idCostumerStripe': idCostumerStripe
      }, SetOptions(merge: true));

      _guardarMetodosPagoStripe(
        clientSecretSetupIntente,
        idCostumerStripe
      );
    } else {
      if(mounted){
        Navigator.pop(context);
      } else {
        MisAvisos().showToast(
          'Intente nuevamente\nverifique su conexión.', 
          2200, 
          fToast!, 
          true
        );
      }
    }
  }

  Future<String> _crearCutomer(String correo) async {
    String miNewCustomer = '';

    try {
      Dio dio = Dio();
      String url = '$baseUrl/api/medcab/crearCostumerStripe';

      Map<String, dynamic> datos = {
        'emailUser' : correo,
      };

      Response response = await dio.post(
        url,
        data: datos,
      );

      if(response.statusCode == 200){
        miNewCustomer = response.data['clientSecretCostumer'];
      }
      return miNewCustomer;

    } catch (e) {
      return '';
    }
  }

  Future<String> _crearSetupIntent(String idCostumer) async {
    String miClientSetup = '';

    try {
      Dio dio = Dio();
      String url = '$baseUrl/api/medcab/crearSetUpIntent';

      Map<String, dynamic> datos = {
        'isUserCostumerStripe' : idCostumer,
      };

      Response response = await dio.post(
        url,
        data: datos,
      );

      if(response.statusCode == 200){
        miClientSetup = response.data['clientSecret'];
      }
      return miClientSetup;

    } catch (e) {
      return '';
    }
  }

  void _regresarError(){
    Navigator.pop(context);
    errorReintentar = true;
    MisAvisos().showToast(
      'Intente nuevamente\nverifique su conexión.', 
      2200, 
      fToast!, 
      true
    );
  }

  void _regresarSucces(){
    Navigator.pop(context);
    MisAvisos().showToast(
      'Método creado\ncorrectamente!', 
      2200, 
      fToast!, 
      false
    );
    Navigator.pushReplacement(
      context,
      MaterialPageRoute<void>(
        builder: (BuildContext context) => const MetodosPage(),
      ),
    );
  }

  void _checkForm(){
    if(!formKey.currentState!.validate()){
      autoValidar = true;
    } else {
      autoValidar = false;
    }
  }
}
