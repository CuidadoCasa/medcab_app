import 'package:app_medcab/src/shared/avisos.dart';
import 'package:app_medcab/src/shared/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:app_medcab/src/utils/colors.dart' as utils;
import 'package:app_medcab/src/widgets/button_app.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

final _paletaColors = PaletaColors();

class RecuperarPassPage extends StatefulWidget {
  const RecuperarPassPage({super.key});
  @override
  State<RecuperarPassPage> createState() => _RecuperarPassPageState();
}

class _RecuperarPassPageState extends State<RecuperarPassPage> {

  final formKey = GlobalKey<FormState>();
  final _controlEmail = TextEditingController();
  final _focusEmail = FocusNode();

  bool autovalidar = false;

  @override
  void dispose() {
    _controlEmail.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: _paletaColors.mainA,
        iconTheme: const IconThemeData(
          color: Colors.white
        ),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: formKey,
          child: Column(
            children: [
              _banner(),
              const SizedBox(height: 80),
              _columnCorreo(),
              _buttonLogin(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _banner(){
    return ClipPath(
      clipper: WaveClipperTwo(),
      child: Container(
        color: _paletaColors.mainA,
        height: 160,
        child: Column(
          children: [
            _textDescription(),
          ],
        ),
      ),
    );
  }

  Widget _buttonLogin() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 25),
      child: ButtonApp(
        onPressed: (){
          _pruebaValidar();
          if(formKey.currentState!.validate()){
            _sendEmailPass();
          }
        },
        text: 'Recuperar',
        color: utils.Colors.uberCloneColor,
        icono: const FaIcon(
          FontAwesomeIcons.envelopeCircleCheck,
          color: Colors.white,
        ),
      ),
    );
  }

  void _sendEmailPass() async {
    MisAvisos().ventanaTrabajando(context, 'Enviando correo de recuperación...');
    
    try {

      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: _controlEmail.text.trim(),
      );

      if(mounted) Navigator.pop(context);
      if(mounted) MisAvisos().showSnackBar(context, 'Correo de recuperación enviado al email: ${_controlEmail.text.trim()}', 2300, false);
    } catch (e){
      if(mounted) Navigator.pop(context);
      if(mounted) MisAvisos().showSnackBar(context, 'Error intente nuevamente.', 1300, true);
    }
  }

  Widget _columnCorreo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Dirección de correo',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w100
            ),
          ),
          const SizedBox(height: 20),
          _textFieldEmail(),
          const SizedBox(height: 20),
        ]
      ),
    );
  }

  Widget _textFieldEmail(){
    return TextFormField(
      autovalidateMode: autovalidar ? AutovalidateMode.always : AutovalidateMode.disabled,
      controller: _controlEmail,
      focusNode: _focusEmail,
      keyboardType: TextInputType.emailAddress,
      style: const TextStyle(
        fontSize: 14,
      ),
      decoration: _decoracionBordes('Correo'),
      validator: (String ? value){
        RegExp regex = RegExp(r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$');
        if (!regex.hasMatch(value!)) {
          return 'Formato de email incorrecto';
        } else {
          return null;
        }
      },
      onEditingComplete: (){
        FocusScope.of(context).unfocus();
      },
    );
  }

  Widget _textDescription() {
    return Container(
      alignment: Alignment.centerLeft,
      margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
      child: Text(
        'Recupera tu\ncontraseña',
        style: TextStyle(
          color: _paletaColors.grisC,
          fontSize: 24,
          fontFamily: 'NimbusSans'
        ),
      ),
    );
  }

  InputDecoration _decoracionBordes(String hinText){
    return InputDecoration(
      filled: true,
      fillColor: Colors.white,
      errorStyle: const TextStyle(
        fontSize: 12,
        color: Colors.red,
      ),
      hintText: hinText,
      errorMaxLines: 4,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(vertical: 13, horizontal: 10),
      border: _borde(),
      focusedBorder: _borderGris(),
      enabledBorder: _borderGris(),
      disabledBorder: _borderGris(),
      errorBorder: _bordeRojo(),
      counter: const SizedBox.shrink()
    );
  }

  OutlineInputBorder _borde(){
    return OutlineInputBorder(
      borderSide: const BorderSide(
        color: Colors.transparent, 
        width: 0
      ),
      borderRadius: BorderRadius.circular(10)
    );
  }

  OutlineInputBorder _bordeRojo(){
    return OutlineInputBorder(
      borderSide: const BorderSide(
        color: Colors.red, 
        width: 1
      ),
      borderRadius: BorderRadius.circular(10)
    );
  }

  OutlineInputBorder _borderGris(){
    return OutlineInputBorder(
      borderSide: BorderSide(
        color: Colors.grey.shade200, 
        width: 1
      ),
      borderRadius: BorderRadius.circular(10)
    );
  }

  void refresh() {
    if(mounted){
      setState(() {});
    }
  }
  
  void _pruebaValidar() async {
    if(!formKey.currentState!.validate()){
      autovalidar = true;
    } else {
      autovalidar = false;
    }
    setState((){});
  }
}
