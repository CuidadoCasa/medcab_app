import 'package:app_medcab/src/shared/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:app_medcab/src/pages/client/register/client_register_controller.dart';
import 'package:app_medcab/src/utils/colors.dart' as utils;
import 'package:app_medcab/src/widgets/button_app.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

final _paletaColors = PaletaColors();

class ClientRegisterPage extends StatefulWidget {
  const ClientRegisterPage({super.key});
  @override
  State<ClientRegisterPage> createState() => _ClientRegisterPageState();
}

class _ClientRegisterPageState extends State<ClientRegisterPage> {

  final _con = ClientRegisterController();
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      _con.init(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _con.key,
      appBar: AppBar(
        backgroundColor: _paletaColors.mainB,
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
              const SizedBox(height: 30),
              _columnMain('Usuario', _textFieldUsername()),
              _columnMain('Dirección de correo', _textFieldEmail()),
              _columnMain('Contraseña', _textFieldPassword()),
              _buttonRegister(),
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
        color: _paletaColors.mainB,
        height: 120,
        child: Column(
          children: [
            _textLogin(),
          ],
        ),
      ),
    );
  }

  Widget _columnMain(String titulo, Widget form){
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w100
            ),
          ),
          const SizedBox(height: 10),
          form,
          const SizedBox(height: 12),
        ]
      ),
    );
  }

  Widget _textFieldEmail(){
    return TextFormField(
      autovalidateMode: _con.autovalidar ? AutovalidateMode.always : AutovalidateMode.disabled,
      controller: _con.emailController,
      focusNode: _con.focusEmailName,
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
        FocusScope.of(context).requestFocus(_con.focusPass1Name);
      },
    );
  }

  Widget _textFieldUsername(){
    return TextFormField(
      autovalidateMode: _con.autovalidar ? AutovalidateMode.always : AutovalidateMode.disabled,
      controller: _con.usernameController,
      focusNode: _con.focusUserName,
      keyboardType: TextInputType.text,
      textCapitalization: TextCapitalization.words,
      style: const TextStyle(
        fontSize: 14,
      ),
      decoration: _decoracionBordes('Nombre completo'),
      onEditingComplete: (){
        FocusScope.of(context).requestFocus(_con.focusEmailName);
      },
      validator: (String ? value){
        if (value == null || value.isEmpty) {
          return 'Por favor, ingresa tu nombre completo.';
        }
        if (!value.trim().contains(' ')) {
          return 'Por favor, ingresa tu nombre completo.';
        }
        return null;
      },
    );
  }

  Widget _textFieldPassword() {
    return TextFormField(
      autovalidateMode: _con.autovalidar ? AutovalidateMode.always : AutovalidateMode.disabled,
      controller: _con.passwordController,
      focusNode: _con.focusPass1Name,
      keyboardType: TextInputType.visiblePassword,
      textCapitalization: TextCapitalization.none,
      style: const TextStyle(
        fontSize: 14,
      ),
      decoration: _decoracionBordesPass(),
      obscureText: !_con.verPass,
      validator: (String ? value){
        RegExp regex = RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$');
        if (!regex.hasMatch(value!)) {
          return 'La contraseña debe tener al menos 8 caracteres y contener al menos una letra mayúscula, una letra minúscula, un número y un carácter especial.';
        } else {
          return null;
        }
      },
    );
  }

  Widget _textLogin() {
    return Container(
      alignment: Alignment.centerLeft,
      margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
      child: const Text(
        'Registro Paciente',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 25
        ),
      ),
    );
  }

  Widget _buttonRegister() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 25),
      child: ButtonApp(
        onPressed: (){
          _pruebaValidar();
          if(formKey.currentState!.validate()){
            _con.register();
          }
        },
        text: 'Registrar ahora',
        color: utils.Colors.uberCloneColor,
        icono: const FaIcon(
          FontAwesomeIcons.listCheck,
          color: Colors.white,
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

  InputDecoration _decoracionBordesPass(){
    return InputDecoration(
      suffixIcon: _iconoVer(),
      filled: true,
      fillColor: Colors.white,
      errorStyle: TextStyle(
        fontSize: 12,
        fontFamily: 'Textos',
        color: _paletaColors.rojoMain,
      ),
      errorMaxLines: 4,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      border: _borde(),
      focusedBorder: _borderGris(),
      enabledBorder: _borderGris(),
      disabledBorder: _borderGris(),
      errorBorder: _bordeRojo(),
      counter: const SizedBox.shrink()
    );
  }

  Widget _iconoVer(){
    return InkWell(
      onTap: (){
        if(_con.verPass){
          _con.verPass = false;
        } else {
          _con.verPass = true;
        }
        setState((){});
      },
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Icon(
        _con.verPass ? CupertinoIcons.eye_slash : CupertinoIcons.eye,
        color: !_con.verPass ? _paletaColors.mainA : Colors.grey,
      ),
    );
  }
  
  void _pruebaValidar() async {
    if(!formKey.currentState!.validate()){
      _con.autovalidar = true;
    } else {
      _con.autovalidar = false;
    }
    setState((){});
  }
}
