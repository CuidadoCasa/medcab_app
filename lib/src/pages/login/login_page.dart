import 'package:app_medcab/src/pages/login/login_recuperar_pass.dart';
import 'package:app_medcab/src/shared/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:app_medcab/src/pages/login/login_controller.dart';
import 'package:app_medcab/src/utils/colors.dart' as utils;
import 'package:app_medcab/src/widgets/button_app.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

final _paletaColors = PaletaColors();

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  final _con = LoginController();
  final formKey = GlobalKey<FormState>();

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
      key: _con.key,
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
              SizedBox(height: MediaQuery.of(context).size.height * 0.15),
              _columnCorreo(),
              _columnPass(),
              _buttonLogin(),
              _textDontHaveAccount(),
              _recuperarPass()
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
            _textLogin(),
          ],
        ),
      ),
    );
  }

  Widget _textDontHaveAccount() {
    return GestureDetector(
      onTap: _con.goToRegisterPage,
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        child: const Text(
          '¿No tienes cuenta?',
          style: TextStyle(
            fontSize: 15,
            color: Colors.grey
          ),
        ),
      ),
    );
  }

  Widget _recuperarPass() {
    return GestureDetector(
      onTap: (){
        Navigator.push(
          context,
          MaterialPageRoute<void>(
            builder: (BuildContext context) => const RecuperarPassPage(),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 30),
        child: const Text(
          '¿Olvidaste tu contraseña?',
          style: TextStyle(
            fontSize: 15,
            color: Colors.grey
          ),
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
            _con.login();
          }
        },
        text: 'Iniciar',
        color: utils.Colors.uberCloneColor,
        icono: const FaIcon(
          FontAwesomeIcons.doorOpen,
          color: Colors.white,
        ),
      ),
    );
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

  Widget _columnPass() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Contraseña',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w100
            ),
          ),
          const SizedBox(height: 20),
          _textFieldPassword(),
          const SizedBox(height: 20),
        ]
      ),
    );
  }

  Widget _textFieldEmail(){
    return TextFormField(
      autovalidateMode: _con.autovalidar ? AutovalidateMode.always : AutovalidateMode.disabled,
      controller: _con.emailController,
      focusNode: _con.focusEmail,
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
        FocusScope.of(context).requestFocus(_con.focusContr);
      },
    );
  }

  Widget _textFieldPassword(){
    return TextFormField(
      autovalidateMode: _con.autovalidar ? AutovalidateMode.always : AutovalidateMode.disabled,
      controller: _con.passwordController,
      focusNode: _con.focusContr,
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

  Widget _textDescription() {
    return Container(
      alignment: Alignment.centerLeft,
      margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
      child: Text(
        'Bienvenido',
        style: TextStyle(
          color: _paletaColors.grisC,
          fontSize: 24,
          fontFamily: 'NimbusSans'
        ),
      ),
    );
  }

  Widget _textLogin() {
    return Container(
      alignment: Alignment.centerLeft,
      margin: const EdgeInsets.symmetric(horizontal: 30),
      child: Text(
        _con.isPaciente ? 'Login Paciente' : 'Login Médico',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 28
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

  InputDecoration _decoracionBordesPass(){
    return InputDecoration(
      suffixIcon: _iconoVer(),
      filled: true,
      fillColor: Colors.white,
      errorStyle: const TextStyle(
        fontSize: 12,
        color: Colors.red,
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
      hoverColor: Colors.transparent,
      child: Icon(
        _con.verPass ? CupertinoIcons.eye_slash : CupertinoIcons.eye,
        color: !_con.verPass ? _paletaColors.mainA : _paletaColors.grisO,
      ),
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
      _con.autovalidar = true;
    } else {
      _con.autovalidar = false;
    }
    setState((){});
  }
}
