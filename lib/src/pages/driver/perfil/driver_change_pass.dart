import 'package:app_medcab/src/shared/avisos.dart';
import 'package:app_medcab/src/shared/colors.dart';
import 'package:app_medcab/src/shared/widgets/botones.dart';
import 'package:app_medcab/src/shared/widgets/icono_fondo.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'package:fluttertoast/fluttertoast.dart';

class CambiarPassPage extends StatefulWidget {
  const CambiarPassPage({super.key});
  @override
  State<CambiarPassPage> createState() => _CambiarPassPageState();
}

class _CambiarPassPageState extends State<CambiarPassPage> {
  
  final _paletaColors = PaletaColors();
  final formKey = GlobalKey<FormState>();
  final _controlPassw = TextEditingController();

  bool autovalidar = false;
  bool verPass = false;
  
  FToast ? fToast;

  @override
  void initState() {
    fToast = FToast();
    fToast!.init(context);
    super.initState();
  }

  @override
  void dispose() {
    _controlPassw.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _paletaColors.fondoMain,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: _paletaColors.mainB,
        leading: InkWell(
          onTap: (){
            Navigator.pop(context);
          },
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          hoverColor: Colors.transparent,
          child: const Icon(Icons.arrow_back),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        toolbarHeight: 40,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
            ),
            IconoFondo(icono: Icons.lock_open),
            _body(),
          ],
        )
      )
    );
  }

  Widget _body(){
    return SingleChildScrollView(
      child: Form(
        key: formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _header(),
            _widgetsCuerpo(),
          ],
        ),
      ),
    );
  }

  Widget _widgetsCuerpo(){
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Column(
        children: [
          const SizedBox(height: 50),
          _formGeneral('Contraseña', 500, _formPass()),
          _espacio(),
          _cumplirAspectosPass(),
          const SizedBox(height: 70),
          MyBoton(
            titulo: 'Cambiar', 
            fondo: _paletaColors.mainA,
            onpress: ()=> _ingresar()
          ),
          const SizedBox(height: 20),
        ]
      ),
    );
  }

  Widget _header() {
    return ClipPath(
      clipper: WaveClipperTwo(),
      child: Container(
        color: _paletaColors.mainB,
        height: 110,
        alignment: AlignmentDirectional.topStart,
        child: Container(
          margin: const EdgeInsets.only(left: 30, top: 20),
          child: const Text(
            'Cambiar mi contraseña',
            style: TextStyle(
              fontSize: 19,
              color: Colors.white,
              fontWeight: FontWeight.bold
            ),
          ),
        ),
      ),
    );
  }

  Widget _cumplirAspectosPass(){
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _itemCumplir('Un letra minúscula', RegExp(r'[a-z]').hasMatch(_controlPassw.text)),
        _itemCumplir('Una letra mayúscula', RegExp(r'[A-Z]').hasMatch(_controlPassw.text)),
        _itemCumplir('Un caracter especial', RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(_controlPassw.text)),
        _itemCumplir('Un numero', RegExp(r'[0-9]').hasMatch(_controlPassw.text)),
        _itemCumplir('Mínimo 8 caracteres', (_controlPassw.text.length >= 8)),
      ],
    );
  }

  Widget _itemCumplir(String titulo, bool cumple){
    return Row(
      children: [
        Icon(
          cumple ? Icons.check_circle_outline_outlined : Icons.circle_outlined,
          color: _paletaColors.mainA,
        ),
        const SizedBox(width: 15),
        Text(
          titulo,
          style: TextStyle(
            fontFamily: 'Textos',
            color: cumple ? _paletaColors.mainA : Colors.grey
          )
        )
      ],
    );
  }

  Widget _formGeneral(String titulo, double ancho, Widget form){
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: SizedBox(
        width: ancho,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              titulo, 
              style: const TextStyle(
                fontFamily: 'Textos',
                color: Colors.grey, 
                fontWeight: FontWeight.normal, 
                fontSize: 15
              )
            ),
            const SizedBox(height: 5),
            form
          ],
        ),
      ),
    ); 
  }

  Widget _formPass(){
    return TextFormField(
      autovalidateMode: autovalidar ? AutovalidateMode.always : AutovalidateMode.disabled,
      controller: _controlPassw,
      keyboardType: TextInputType.visiblePassword,
      textCapitalization: TextCapitalization.none,
      style: const TextStyle(
        fontSize: 14,
        fontFamily: 'Textos'
      ),
      decoration: _decoracionBordesPass(),
      obscureText: !verPass,
      validator: (String ? value){
        RegExp regex = RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$');
        if (!regex.hasMatch(value!)) {
          return 'La contraseña debe tener al menos 8 caracteres y contener al menos una letra mayúscula, una letra minúscula, un número y un carácter especial.';
        } else {
          return null;
        }
      },
      onChanged: (String ? value){
        setState(() {});
      },
    );
  }

  Widget _espacio(){
    return const SizedBox(
      height: 15
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
        if(verPass){
          verPass = false;
        } else {
          verPass = true;
        }
        setState((){});
      },
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      hoverColor: Colors.transparent,
      child: Icon(
        verPass ? CupertinoIcons.eye_slash : CupertinoIcons.eye,
        color: !verPass ? _paletaColors.mainA : Colors.grey,
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
      borderSide: BorderSide(
        color: _paletaColors.rojoMain, 
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

  void _ingresar(){
    if(formKey.currentState!.validate()){
      _guardarCambios();
    } else {
      _pruebaValidar();
      MisAvisos().showToast('Los campos no han sido\nllenados correctamente', 2500, fToast!, true);
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

  void _guardarCambios() async {
    MisAvisos().ventanaTrabajando(context, 'Actualizando...');
    
    try {
      final user = FirebaseAuth.instance.currentUser;
      await user!.updatePassword(_controlPassw.text.trim());
      await user.reload();

      if(mounted) Navigator.pop(context);
      MisAvisos().showToast('Actualización correcta', 1500, fToast!, false);
      if(mounted) Navigator.pop(context);

    } catch(e){
      if(mounted) Navigator.pop(context);
      MisAvisos().showToast('Actualización fallida\nintentar nuevamente', 2500, fToast!, true);
    }
  }
}