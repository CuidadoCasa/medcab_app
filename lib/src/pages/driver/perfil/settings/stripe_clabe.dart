import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:app_medcab/src/providers/variables_provider.dart';
import 'package:app_medcab/src/shared/avisos.dart';
import 'package:app_medcab/src/shared/colors.dart';
import 'package:app_medcab/src/shared/widgets/botones.dart';
import 'package:app_medcab/src/shared/widgets/form_general.dart';
import 'package:app_medcab/src/shared/widgets/pantalla_carga.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

class MicuentaCLABE extends StatefulWidget {

  final Map<String,dynamic> dataConnect;
  final String userId;
  final bool hasClab;

  const MicuentaCLABE({
    super.key,
    required this.dataConnect,
    required this.userId,
    required this.hasClab
  });

  @override
  State<MicuentaCLABE> createState() => _MicuentaCLABEState();
}

class _MicuentaCLABEState extends State<MicuentaCLABE> {

  // String baseUrl = 'http://192.168.100.36:3000';
  String baseUrl = 'https://cuidadoencasa-api-test.onrender.com';

  final _paletaColors = PaletaColors();
  final formKey = GlobalKey<FormState>();

  final _controlCLABE = TextEditingController();
  final _focusCLABE = FocusNode();

  bool mostrarMensaje = false;
  bool cargando = true;
  bool autoValidar = false;

  String userId = '';

  Map<String, String> bancosMap = {
    '40138': 'ABC CAPITAL',
    '40133': 'ACTINVER',
    '40062': 'AFIRME',
    '90661': 'ALTERNATIVOS',
    '90706': 'ARCUS',
    '90659': 'ASP INTEGRA OPC',
    '40128': 'AUTOFIN',
    '40127': 'AZTECA',
    '37166': 'BaBien',
    '40030': 'BAJIO',
    '40002': 'BANAMEX',
    '40154': 'BANCO COVALTO',
    '37006': 'BANCOMEXT',
    '40137': 'BANCOPPEL',
    '40160': 'BANCO S3',
    '40152': 'BANCREA',
    '37019': 'BANJERCITO',
    '40147': 'BANKAOOL',
    '40106': 'BANK OF AMERICA',
    '40159': 'BANK OF CHINA',
    '37009': 'BANOBRAS',
    '40072': 'BANORTE',
    '40058': 'BANREGIO',
    '40060': 'BANSI',
    '40129': 'BARCLAYS',
    '40145': 'BBASE',
    '40012': 'BBVA MEXICO',
    '40112': 'BMONEX',
    '90677': 'CAJA POP MEXICA',
    '90683': 'CAJA TELEFONIST',
    '90630': 'CB INTERCAM',
    '40143': 'CIBANCO',
    '90631': 'CI BOLSA',
    '90901': 'CLS',
    '90903': 'CoDi Valida',
    '40130': 'COMPARTAMOS',
    '40140': 'CONSUBANCO',
    '90652': 'CREDICAPITAL',
    '90688': 'CREDICLUB',
    '90680': 'CRISTOBAL COLON',
    '40151': 'DONDE',
    '90616': 'FINAMEX',
    '90634': 'FINCOMUN',
    '90689': 'FOMPED',
    '90685': 'FONDO (FIRA)',
    '90601': 'GBM',
    '37168': 'HIPOTECARIA FED',
    '40021': 'HSBC',
    '40155': 'ICBC',
    '40036': 'INBURSA',
    '90902': 'INDEVAL',
    '40150': 'INMOBILIARIO',
    '40136': 'INTERCAM BANCO',
    '90686': 'INVERCAP',
    '40059': 'INVEX',
    '40110': 'JP MORGAN',
    '90653': 'KUSPIT',
    '90670': 'LIBERTAD',
    '90602': 'MASARI',
    '40042': 'MIFEL',
    '40158': 'MIZUHO BANK',
    '90600': 'MONEXCB',
    '40108': 'MUFG',
    '40132': 'MULTIVA BANCO',
    '37135': 'NAFIN',
    '90638': 'NU MEXICO',
    '90710': 'NVIO',
    '40148': 'PAGATODO',
    '90620': 'PROFUTURO',
    '40156': 'SABADELL',
    '40014': 'SANTANDER',
    '40044': 'SCOTIABANK',
    '40157': 'SHINHAN',
    '90646': 'STP',
    '90703': 'TESORED',
    '90684': 'TRANSFER',
    '90656': 'UNAGRA',
    '90617': 'VALMEX',
    '90605': 'VALUE',
    '90608': 'VECTOR',
    '40113': 'VE POR MAS',
    '40141': 'VOLKSWAGEN'
  };

  Map<String,dynamic> ubicBanco = {
    '138' : '40138',
    '133' : '40133',
    '062' : '40062',
    '661' : '90661',
    '706' : '90706',
    '659' : '90659',
    '128' : '40128',
    '127' : '40127',
    '166' : '37166',
    '030' : '40030',
    '002' : '40002',
    '154' : '40154',
    '006' : '37006',
    '137' : '40137',
    '160' : '40160',
    '152' : '40152',
    '019' : '37019',
    '147' : '40147',
    '106' : '40106',
    '159' : '40159',
    '009' : '37009',
    '072' : '40072',
    '058' : '40058',
    '060' : '40060',
    '129' : '40129',
    '145' : '40145',
    '012' : '40012',
    '112' : '40112',
    '677' : '90677',
    '683' : '90683',
    '630' : '90630',
    '143' : '40143',
    '631' : '90631',
    '901' : '90901',
    '903' : '90903',
    '130' : '40130',
    '140' : '40140',
    '652' : '90652',
    '688' : '90688',
    '680' : '90680',
    '151' : '40151',
    '616' : '90616',
    '634' : '90634',
    '689' : '90689',
    '685' : '90685',
    '601' : '90601',
    '168' : '37168',
    '021' : '40021',
    '155' : '40155',
    '036' : '40036',
    '902' : '90902',
    '150' : '40150',
    '136' : '40136',
    '686' : '90686',
    '059' : '40059',
    '110' : '40110',
    '653' : '90653',
    '670' : '90670',
    '602' : '90602',
    '042' : '40042',
    '158' : '40158',
    '600' : '90600',
    '108' : '40108',
    '132' : '40132',
    '135' : '37135',
    '638' : '90638',
    '710' : '90710',
    '148' : '40148',
    '620' : '90620',
    '156' : '40156',
    '014' : '40014',
    '044' : '40044',
    '157' : '40157',
    '646' : '90646',
    '703' : '90703',
    '684' : '90684',
    '656' : '90656',
    '617' : '90617',
    '605' : '90605',
    '608' : '90608',
    '113' : '40113',
    '141' : '40141',
  };

  FToast ? fToast;

  @override
  void initState() {
    fToast = FToast();
    fToast!.init(context);
    _initData();
    super.initState();
  }

  void _initData() {
    userId = widget.userId;
    Map<String,dynamic> dataConnect = widget.dataConnect;

    String strCLABE = dataConnect.containsKey('connecttCLABE') ? dataConnect['connecttCLABE'] : '';
    _controlCLABE.value = TextEditingValue(text: strCLABE);

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
  void dispose() {
    _controlCLABE.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return !cargando ? Scaffold(
      bottomNavigationBar: _logoStripe(),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: _paletaColors.colorStripe,
        leading: InkWell(
          onTap: (){
            Navigator.pop(context);
          },
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          hoverColor: Colors.transparent,
          child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white)
        ),
        title: const Text(
          'Mi CLABE',
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
          child: Form(
            key: formKey,  
            child: _body()
          ),
        )
      )
    ) : const PantallaCarga(titulo: 'Cargando...');
  }

  Widget _body(){
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ..._listForms(),
          const SizedBox(height: 15),
          _miBancoRef()
        ],
      ),
    );
  }

  List<Widget> _listForms(){
    return [
      FormGeneralConTitulo(
        tipoTeclado: TextInputType.number,
        autovalidar: autoValidar,
        control: _controlCLABE, 
        titulo: 'CLABE Interbancaria', 
        onChange: (){
          if(_controlCLABE.text.length == 18){
            setState((){});
          }
        }, 
        focusForm: _focusCLABE, 
        onComplete: (){
          FocusScope.of(context).unfocus();
          if(_controlCLABE.text.length == 18){
            setState((){});
          }
        }, 
        maxLenght: 18, 
        validator: (String ? value){
          RegExp regex = RegExp(r'^[0-9]+$');
          if (!regex.hasMatch(value!)) {
            return 'CLABE incorrecta';
          } else
          if(value.trim().length != 18){
            return 'CLABE incompleta';
          } else {
            return null;
          }
        }
      ),
    ];
  }

  Widget _miBancoRef(){
    return Text(
      _miBanco(),
      style: TextStyle(
        fontSize: 14,
        color: _paletaColors.mainB,
        fontWeight: FontWeight.bold
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
              titulo: 'Agregar CLABE', 
              fondo: !widget.hasClab ? _paletaColors.mainB : Colors.grey,
              onpress: ()=> !widget.hasClab ? _crearCuentaConnect() : (){}
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

  String _miBanco(){
    String banco = '';
    if(_controlCLABE.text.length == 18){
      String ref = _controlCLABE.text.substring(0,3);
      if(ubicBanco.containsKey(ref)){
        banco = bancosMap[ubicBanco[ref]]!;
      } else {
        banco = 'Banco no reconocido';
      }
    }
    return banco;
  }

  void _crearCuentaConnect(){
    _checkForm();
    if(formKey.currentState!.validate()){
      MisAvisos().ventanaConfirmarAccion(
        context, 
        'Para garantizar una experiencia fluida, asegúrese de ingresar una CLABE interbancaria válida y registrada a su nombre. Esto es fundamental para el procesamiento correcto de sus transacciones. ¡Gracias por su colaboración!', 
        ()=> _agregarCLABE(),
        sizeFuente: 14
      );
    }
  }

  void _checkForm(){
    if(!formKey.currentState!.validate()){
      autoValidar = true;
    } else {
      autoValidar = false;
    }
  }
  
  void _agregarCLABE() async {
    final dataProvider = Provider.of<VariablesProvider>(context, listen: false);
    String nombre = dataProvider.nombreCompleto;
    String idConn = dataProvider.idCuentaConnect;

    if(nombre.isEmpty | idConn.isEmpty){
      MisAvisos().ventanaAviso(context, 'Parece que no ha creado su cuenta connect, regrese a el menu atrás y coloque sus datos');
    } else {
      MisAvisos().ventanaTrabajando(context, 'Agregando su CLABE...');

      try {
        Dio dio = Dio();
        String url = '$baseUrl/api/enfermera/actualizarInfoBanco';

        Map<String, dynamic> datos = {
          'id_seller': idConn,
          'account_number': _controlCLABE.text,
          'propietario': nombre
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
            'connecttCLABE': _controlCLABE.text,
          }, SetOptions(merge: true));

          await FirebaseFirestore.instance
          .collection('Drivers')
          .doc(userId)
          .set({
            'hasClab': 1,
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
    Navigator.pop(context, {'hasClabe': 1});
    MisAvisos().showToast(
      'CLABE agregada\ncorrectamente!', 
      2200, 
      fToast!, 
      false
    );
  }
}
