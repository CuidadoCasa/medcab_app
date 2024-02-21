import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:app_medcab/src/providers/variables_provider.dart';
import 'package:app_medcab/src/shared/avisos.dart';
import 'package:app_medcab/src/shared/colors.dart';
import 'package:app_medcab/src/shared/widgets/botones.dart';
import 'package:app_medcab/src/shared/widgets/form_general.dart';
import 'package:app_medcab/src/shared/widgets/pantalla_carga.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

class CuentaConnect extends StatefulWidget {

  final Map<String,dynamic> dataConnect;
  final bool hasCuentaConnect;
  final String userId;

  const CuentaConnect({
    super.key,
    required this.dataConnect,
    required this.hasCuentaConnect,
    required this.userId
  });

  @override
  State<CuentaConnect> createState() => _CuentaConnectState();
}

class _CuentaConnectState extends State<CuentaConnect> {

  // String baseUrl = 'http://192.168.100.36:3000';
  String baseUrl = 'https://cuidadoencasa-api-test.onrender.com';

  final _paletaColors = PaletaColors();
  final formKey = GlobalKey<FormState>();

  bool mostrarMensaje = false;
  bool cargando = true;
  bool autoValidar = false;

  final _controlCorreo = TextEditingController();
  final _controlNombre = TextEditingController();
  final _controlApelli = TextEditingController();
  final _controlNacDia = TextEditingController();
  final _controlNacMes = TextEditingController();
  final _controlNacAno = TextEditingController();
  final _controlCalles = TextEditingController();
  final _controlNumero = TextEditingController();
  final _controlCiudad = TextEditingController();
  final _controlEstado = TextEditingController();
  final _controlCodiPo = TextEditingController();
  final _controlUsrRFC = TextEditingController();
  final _controlUsCURP = TextEditingController();
  final _controlTelfon = TextEditingController();

  final _focusCorreo = FocusNode();
  final _focusNombre = FocusNode();
  final _focusApelli = FocusNode();
  final _focusNacDia = FocusNode();
  final _focusNacMes = FocusNode();
  final _focusNacAno = FocusNode();
  final _focusCalles = FocusNode();
  final _focusNumero = FocusNode();
  final _focusCiudad = FocusNode();
  final _focusEstado = FocusNode();
  final _focusCodiPo = FocusNode();
  final _focusUsrRFC = FocusNode();
  final _focusUsCURP = FocusNode();
  final _focusTelfon = FocusNode();

  FToast ? fToast;

  @override
  void initState() {
    fToast = FToast();
    fToast!.init(context);
    _initData();
    super.initState();
  }

  void _initData() {
    Map<String,dynamic> dataConnect = widget.dataConnect;

    String strCorreo = dataConnect.containsKey('connectCorreo') ? dataConnect['connectCorreo'].toString() : '';
    String strNombre = dataConnect.containsKey('connectNombre') ? dataConnect['connectNombre'].toString() : '';
    String strApelli = dataConnect.containsKey('connectApelli') ? dataConnect['connectApelli'].toString() : '';
    String strNacDia = dataConnect.containsKey('connectNacDia') ? dataConnect['connectNacDia'].toString() : '';
    String strNacMes = dataConnect.containsKey('connectNacMes') ? dataConnect['connectNacMes'].toString() : '';
    String strNacAno = dataConnect.containsKey('connectNacAno') ? dataConnect['connectNacAno'].toString() : '';
    String strCalles = dataConnect.containsKey('connectCalles') ? dataConnect['connectCalles'].toString() : '';
    String strNumero = dataConnect.containsKey('connectNumero') ? dataConnect['connectNumero'].toString() : '';
    String strCiudad = dataConnect.containsKey('connectCiudad') ? dataConnect['connectCiudad'].toString() : '';
    String strEstado = dataConnect.containsKey('connectEstado') ? dataConnect['connectEstado'].toString() : '';
    String strCodiPo = dataConnect.containsKey('connectCodiPo') ? dataConnect['connectCodiPo'].toString() : '';
    String strUsrRFC = dataConnect.containsKey('connectUsrRFC') ? dataConnect['connectUsrRFC'].toString() : '';
    String strUsCURP = dataConnect.containsKey('connectUsCURP') ? dataConnect['connectUsCURP'].toString() : '';
    String strTelfon = dataConnect.containsKey('connectTelfon') ? dataConnect['connectTelfon'].toString() : '';

    _controlCorreo.value = TextEditingValue(text: strCorreo);
    _controlNombre.value = TextEditingValue(text: strNombre);
    _controlApelli.value = TextEditingValue(text: strApelli);
    _controlNacDia.value = TextEditingValue(text: strNacDia);
    _controlNacMes.value = TextEditingValue(text: strNacMes);
    _controlNacAno.value = TextEditingValue(text: strNacAno);
    _controlCalles.value = TextEditingValue(text: strCalles);
    _controlNumero.value = TextEditingValue(text: strNumero);
    _controlCiudad.value = TextEditingValue(text: strCiudad);
    _controlEstado.value = TextEditingValue(text: strEstado);
    _controlCodiPo.value = TextEditingValue(text: strCodiPo);
    _controlUsrRFC.value = TextEditingValue(text: strUsrRFC);
    _controlUsCURP.value = TextEditingValue(text: strUsCURP);
    _controlTelfon.value = TextEditingValue(text: strTelfon);

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
    _controlCorreo.dispose();
    _controlNombre.dispose();
    _controlApelli.dispose();
    _controlNacDia.dispose();
    _controlNacMes.dispose();
    _controlNacAno.dispose();
    _controlCalles.dispose();
    _controlNumero.dispose();
    _controlCiudad.dispose();
    _controlEstado.dispose();
    _controlCodiPo.dispose();
    _controlUsrRFC.dispose();
    _controlUsCURP.dispose();
    _controlTelfon.dispose();

    _focusCorreo.dispose();
    _focusNombre.dispose();
    _focusApelli.dispose();
    _focusNacDia.dispose();
    _focusNacMes.dispose();
    _focusNacAno.dispose();
    _focusCalles.dispose();
    _focusNumero.dispose();
    _focusCiudad.dispose();
    _focusEstado.dispose();
    _focusCodiPo.dispose();
    _focusUsrRFC.dispose();
    _focusUsCURP.dispose();
    _focusTelfon.dispose();
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
          child: const Icon(Icons.arrow_back, color: Colors.white)
        ),
        title: const Text(
          'Stripe Connect',
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
      ..._listFechaNacimiento(),
      ..._listContacto(),
      ..._listDireccion(),
      ..._adicionales()
    ];
  }

  List<Widget> _listNombre(){
    return [
      Align(
        alignment: Alignment.centerLeft,
        child: _tituloSeccion('Nombre', 17.5)
      ),
      FormGeneralConTitulo(
        autovalidar: autoValidar,
        control: _controlNombre, 
        capitalizacion: TextCapitalization.characters,
        titulo: 'Nombre', 
        onChange: (){}, 
        focusForm: _focusNombre, 
        onComplete: (){
          FocusScope.of(context).requestFocus(_focusApelli);
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
      FormGeneralConTitulo(
        capitalizacion: TextCapitalization.characters,
        autovalidar: autoValidar,
        control: _controlApelli, 
        titulo: 'Apellidos', 
        onChange: (){}, 
        focusForm: _focusApelli, 
        onComplete: (){
          FocusScope.of(context).requestFocus(_focusNacDia);
        }, 
        maxLenght: 150, 
        validator: (String ? value){
          RegExp regex = RegExp(r'^[a-zA-ZáéíóúÁÉÍÓÚüÜñÑ\s]*\s+[a-zA-ZáéíóúÁÉÍÓÚüÜñÑ\s]+$');
          if(!value!.trim().contains(' ')){
            return 'Apellido completo requerido';
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

  List<Widget> _listFechaNacimiento(){
    return [
      Align(
        alignment: Alignment.centerLeft,
        child: _tituloSeccion('Fecha de nacimiento', 17.5)
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FormGeneralConTitulo(
            tipoTeclado: TextInputType.number,
            autovalidar: autoValidar,
            ancho: 80,
            control: _controlNacDia, 
            titulo: 'Día', 
            onChange: (){}, 
            focusForm: _focusNacDia, 
            onComplete: (){
              FocusScope.of(context).requestFocus(_focusNacMes);
            }, 
            maxLenght: 2, 
            validator: (String ? value){
              RegExp regex = RegExp(r"^[0-9]+$");
              if(value!.trim().isEmpty){
                return 'Ingrese su día de nacimiento';
              } else 
              if(!regex.hasMatch(value.trim())){
                return 'Verificar la escritura';
              } else {
                return null;
              }
            }
          ),
          FormGeneralConTitulo(
            tipoTeclado: TextInputType.number,
            autovalidar: autoValidar,
            ancho: 80,
            control: _controlNacMes, 
            titulo: 'Mes', 
            onChange: (){}, 
            focusForm: _focusNacMes, 
            onComplete: (){
              FocusScope.of(context).requestFocus(_focusNacAno);
            }, 
            maxLenght: 2, 
            validator: (String ? value){
              RegExp regex = RegExp(r"^[0-9]+$");
              if(value!.trim().isEmpty){
                return 'Ingrese su día de nacimiento';
              } else 
              if(!regex.hasMatch(value.trim())){
                return 'Verificar la escritura';
              } else {
                return null;
              }      
            }
          ),
          FormGeneralConTitulo(
            tipoTeclado: TextInputType.number,
            autovalidar: autoValidar,
            ancho: 80,
            control: _controlNacAno, 
            titulo: 'Año', 
            onChange: (){}, 
            focusForm: _focusNacAno, 
            onComplete: (){
              FocusScope.of(context).requestFocus(_focusCorreo);
            }, 
            maxLenght: 4, 
            validator: (String ? value){
              RegExp regex = RegExp(r"^[0-9]+$");
              if(value!.trim().isEmpty){
                return 'Ingrese su día de nacimiento';
              } else 
              if(!regex.hasMatch(value.trim())){
                return 'Verificar la escritura';
              } else
              if(value.length != 4){
                return 'Ingrese el año correcto';
              } else {
                return null;
              }      
            }
          ),
        ],
      ),
    ];
  }

  List<Widget> _listContacto(){
    return [
      Align(
        alignment: Alignment.centerLeft,
        child: _tituloSeccion('Contacto', 17.5)
      ),
      FormGeneralConTitulo(
        tipoTeclado: TextInputType.emailAddress,
        capitalizacion: TextCapitalization.none,
        autovalidar: autoValidar,
        control: _controlCorreo, 
        titulo: 'Correo', 
        onChange: (){}, 
        focusForm: _focusCorreo, 
        onComplete: (){
          FocusScope.of(context).requestFocus(_focusTelfon);
        }, 
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
      FormGeneralConTitulo(
        tipoTeclado: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(10), 
          PhoneNumberFormatter(),
        ],
        autovalidar: autoValidar,
        control: _controlTelfon, 
        titulo: 'Télefono', 
        onChange: (){
          if(_controlTelfon.text.length <= 12){
            _controlTelfon.selection = TextSelection.fromPosition(
              TextPosition(offset: _controlTelfon.text.length)
            );
          }
        }, 
        focusForm: _focusTelfon, 
        onComplete: (){
          FocusScope.of(context).requestFocus(_focusCalles);
        }, 
        maxLenght: 150, 
        validator: (String ? value){
          RegExp regex = RegExp(r"^[0-9\s]+$");
          if(value!.trim().isEmpty){
            return 'Ingrese su número de télefono';
          } else 
          if(!regex.hasMatch(value.trim())){
            return 'Verificar la escritura';
          } else
          if(value.length != 12){
            return 'Ingrese su número correcto';
          } else {
            return null;
          }     
        }
      ),
    ];
  }

  List<Widget> _listDireccion(){
    return [
      Align(
        alignment: Alignment.centerLeft,
        child: _tituloSeccion('Dirección', 17.5)
      ),
      FormGeneralConTitulo(
        capitalizacion: TextCapitalization.characters,
        autovalidar: autoValidar,
        control: _controlCalles, 
        titulo: 'Calle', 
        onChange: (){}, 
        focusForm: _focusCalles, 
        onComplete: (){
          FocusScope.of(context).requestFocus(_focusCiudad);
        }, 
        maxLenght: 200, 
        validator: (String ? value){
          if(value!.trim().isEmpty){
            return 'Ingrese el nombre de la calle.';
          } else 
          if(value.length < 5){
            return 'Ingrese el nombre de la calle completa.';
          } else {
            return null;
          }
        }
      ),
      FormGeneralConTitulo(
        capitalizacion: TextCapitalization.characters,
        autovalidar: autoValidar,
        control: _controlCiudad, 
        titulo: 'Ciudad', 
        onChange: (){}, 
        focusForm: _focusCiudad, 
        onComplete: (){
          FocusScope.of(context).requestFocus(_focusEstado);
        }, 
        maxLenght: 200, 
        validator: (String ? value){
          if(value!.trim().isEmpty){
            return 'Ingrese el nombre de la calle.';
          } else 
          if(value.length < 4){
            return 'Ingrese el nombre de la calle completa.';
          } else {
            return null;
          }
        }
      ),
      FormGeneralConTitulo(
        capitalizacion: TextCapitalization.characters,
        autovalidar: autoValidar,
        control: _controlEstado, 
        titulo: 'Estado', 
        onChange: (){}, 
        focusForm: _focusEstado, 
        onComplete: (){
          FocusScope.of(context).requestFocus(_focusCodiPo);
        }, 
        maxLenght: 200, 
        validator: (String ? value){
          if(value!.trim().isEmpty){
            return 'Ingrese el nombre de la calle.';
          } else 
          if(value.length < 4){
            return 'Ingrese el nombre de la calle completa.';
          } else {
            return null;
          }
        }
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FormGeneralConTitulo(
            tipoTeclado: TextInputType.number,
            autovalidar: autoValidar,
            ancho: 100,
            control: _controlCodiPo, 
            titulo: 'Código Postal', 
            onChange: (){}, 
            focusForm: _focusCodiPo, 
            onComplete: (){
              FocusScope.of(context).requestFocus(_focusNumero);
            }, 
            maxLenght: 150, 
            validator: (String ? value){
              RegExp regex = RegExp(r"^[0-9]+$");
              if(value!.trim().isEmpty){
                return 'Ingrese su el cp';
              } else 
              if(!regex.hasMatch(value.trim())){
                return 'Verificar la escritura';
              } else
              if(value.length != 5){
                return 'Ingrese su cp correcto';
              } else {
                return null;
              }      
            }
          ),
          FormGeneralConTitulo(
            capitalizacion: TextCapitalization.characters,
            autovalidar: autoValidar,
            ancho: 160,
            control: _controlNumero, 
            titulo: 'Número', 
            onChange: (){}, 
            focusForm: _focusNumero, 
            onComplete: (){
              FocusScope.of(context).requestFocus(_focusUsCURP);
            }, 
            maxLenght: 150, 
            validator: (String ? value){
              if(value!.trim().isEmpty){
                return 'Escriba su número.';
              } else {
                return null;
              }
            }
          ),
        ],
      ),
    ];
  }

  List<Widget> _adicionales(){
    return [
      Align(
        alignment: Alignment.centerLeft,
        child: _tituloSeccion('Datos adicionales', 17.5)
      ),
      FormGeneralConTitulo(
        capitalizacion: TextCapitalization.characters,
        autovalidar: autoValidar,
        control: _controlUsCURP, 
        titulo: 'CURP', 
        onChange: (){}, 
        focusForm: _focusUsCURP, 
        onComplete: (){
          FocusScope.of(context).requestFocus(_focusUsrRFC);
        }, 
        maxLenght: 18, 
        validator: (String ? value){
          RegExp regex = RegExp(r'^[A-Z]{4}\d{6}[HM][A-Z]{5}[A-Z0-9]\d$');
          if(value!.trim().isEmpty){
            return 'Ingrese su CURP';
          } else
          if(!regex.hasMatch(value)){
            return 'Formato incorrecto';
          } else {
            return null;
          }      
        }
      ),
      FormGeneralConTitulo(
        capitalizacion: TextCapitalization.characters,
        autovalidar: autoValidar,
        control: _controlUsrRFC, 
        titulo: 'RFC (con homoclave)', 
        onChange: (){}, 
        focusForm: _focusUsrRFC, 
        onComplete: (){
          FocusScope.of(context).unfocus();
        }, 
        maxLenght: 13, 
        validator: (String ? value){
          // RegExp regex = RegExp(r'^[A-Z&Ññ]{3,4}\d{2}(0[1-9]|1[0-2])(0[1-9]|[12]\d|3[01])[A-Z0-9]{2}[A\d]$');
          // if(value!.trim().isEmpty){
          //   return 'Ingrese su RFC con homoclave';
          // } else
          // if(!regex.hasMatch(value)){
          //   return 'Formato incorrecto';
          // } else {
            return null;
          // }
        }
      ),
    ];
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
              titulo: 'Crear cuenta', 
              fondo: !widget.hasCuentaConnect ? _paletaColors.mainA : Colors.grey,
              onpress: ()=> !widget.hasCuentaConnect ? _crearCuentaConnect() : (){}
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

  void _crearCuentaConnect(){
    _checkForm();
    if(formKey.currentState!.validate()){
      MisAvisos().ventanaConfirmarAccion(
        context, 
        'Por favor, presione "Aceptar" únicamente si está plenamente seguro de la exactitud de los datos proporcionados. Cualquier error podría prolongar el proceso de aprobación más allá de lo habitual. Su colaboración en este paso es fundamental.', 
        ()=> _aceptarContratoStripe(),
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
  
  void _aceptarContratoStripe() async {
    final dataProvider = Provider.of<VariablesProvider>(context, listen: false);
    MisAvisos().ventanaTrabajando(context, 'Creando cuenta...');

    String strCorreo = _controlCorreo.text.trim();
    String strNombre = _controlNombre.text.trim().toUpperCase();
    String strApelli = _controlApelli.text.trim().toUpperCase();
    int intNacDia = int.parse(_controlNacDia.text.trim());
    int intNacMes = int.parse(_controlNacMes.text.trim());
    int intNacAno = int.parse(_controlNacAno.text.trim());
    String strCalles = _controlCalles.text.trim().toUpperCase();
    String strNumero = _controlNumero.text.trim().toUpperCase();
    String strCiudad = _controlCiudad.text.trim().toUpperCase();
    String strEstado = _controlEstado.text.trim().toUpperCase();
    String strCodiPo = _controlCodiPo.text.trim().toUpperCase();
    String strUsrRFC = _controlUsrRFC.text.trim().toUpperCase();
    String strUsCURP = _controlUsCURP.text.trim().toUpperCase();
    String strTelfon = '+52 ${_controlTelfon.text.trim()}';
    String idResponse = '';

    Map<String,dynamic> dataFirebase = {
      'connectCorreo' : strCorreo,
      'connectNombre' : strNombre,
      'connectApelli' : strApelli,
      'connectNacDia' : intNacDia,
      'connectNacMes' : intNacMes,
      'connectNacAno' : intNacAno,
      'connectCalles' : strCalles,
      'connectNumero' : strNumero,
      'connectCiudad' : strCiudad,
      'connectEstado' : strEstado,
      'connectCodiPo' : strCodiPo,
      'connectUsrRFC' : strUsrRFC,
      'connectUsCURP' : strUsCURP,
      'connectTelfon' : strTelfon,
    };

    try {
      Dio dio = Dio();
      String url = '$baseUrl/api/enfermera/crerCuentaConnect';

      Map<String, dynamic> datos = {
        'email' : strCorreo, 
        'nombre' : strNombre, 
        'apellido': strApelli, 
        'fechaNacimiento' : {
          'dia' : intNacDia,
          'mes' : intNacMes,
          'ano' : intNacAno
        }, 
        'direccion' : '$strCalles $strNumero', 
        'ciudad' : strCiudad, 
        'estado' : strEstado,
        'codigoPostal' : strCodiPo, 
        'rfc' : strUsrRFC, 
        'telefono' : strTelfon
      };

      Response response = await dio.post(
        url,
        data: datos,
      );

      if(response.statusCode == 200){
        Map<String,dynamic> dataResponse = response.data;
        idResponse = dataResponse['accountId'];
        dataFirebase.addEntries({'connectUserID' : idResponse}.entries);

        await FirebaseFirestore.instance
        .collection('Drivers')
        .doc(widget.userId)
        .collection('informacion')
        .doc('personal')
        .set(dataFirebase, SetOptions(merge: true));

        await FirebaseFirestore.instance
        .collection('Drivers')
        .doc(widget.userId)
        .set({
          'idStripe' : idResponse,
          'hasConnect' : 1
        }, SetOptions(merge: true));

        dataProvider.nombreCompleto = '$strNombre $strApelli';
        dataProvider.idCuentaConnect = idResponse;
      }

      if(response.statusCode == 200){
        _regresarSucces(idResponse);
      } else {
        _regresarError();
      }
    } catch (e) {
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

  void _regresarSucces(String idConnect){
    Navigator.pop(context);
    Navigator.pop(context);
    Navigator.pop(context, {'connect' : 1, 'connectUserID' : idConnect});
    MisAvisos().showToast(
      '¡Cuenta creada\ncorrectamente!', 
      2200, 
      fToast!, 
      false
    );
  }
  
}

class PhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final int newTextLength = newValue.text.length;

    if (newTextLength > 0 && newTextLength < 4) {
      return TextEditingValue(
        text: newValue.text,
        selection: newValue.selection,
      );
    } else if (newTextLength >= 4 && newTextLength < 7) {
      return TextEditingValue(
        text: '${newValue.text.substring(0, 3)} ${newValue.text.substring(3)}',
        selection: newValue.selection,
      );
    } else if (newTextLength >= 7) {
      return TextEditingValue(
        text:
            '${newValue.text.substring(0, 3)} ${newValue.text.substring(3, 6)} ${newValue.text.substring(6)}',
        selection: newValue.selection,
      );
    } else {
      return newValue;
    }
  }
}
