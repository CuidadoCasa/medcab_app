import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:app_medcab/src/shared/avisos.dart';
import 'package:app_medcab/src/shared/colors.dart';
import 'package:app_medcab/src/shared/widgets/botones.dart';
import 'package:app_medcab/src/shared/widgets/icono_fondo.dart';
import 'package:app_medcab/src/shared/widgets/pantalla_carga.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'package:fluttertoast/fluttertoast.dart';

class EditarPerfilPage extends StatefulWidget {
  final String nombreUsuario;
  final String userId;
  
  const EditarPerfilPage({
    super.key,
    required this.nombreUsuario,
    required this.userId
  });

  @override
  State<EditarPerfilPage> createState() => _EditarPerfilPageState();
}

class _EditarPerfilPageState extends State<EditarPerfilPage> {
  final _paletaColors = PaletaColors();
  final formKey = GlobalKey<FormState>();

  final _controlNombr = TextEditingController();
  final _focusNombr = FocusNode();

  String nombrInit = '';
  String emailInit = '';

  bool autovalidar = false;
  bool cargando = true;
  bool onlyReadNombr = true;
  bool onlyReadEmail = true;

  FToast ? fToast;

  @override
  void initState() {
    _initData();
    fToast = FToast();
    fToast!.init(context);
    super.initState();
  }

  void _initData(){
    _controlNombr.value = TextEditingValue(text: widget.nombreUsuario);
    nombrInit = _controlNombr.text;

    cargando = false;

    if(mounted){
      setState((){});
    }
  }

  @override
  void dispose() {
    _controlNombr.dispose();
    _focusNombr.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          child: const Icon(Icons.arrow_back)
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        toolbarHeight: 40,
      ),
      body: SafeArea(
        child: !cargando ? Stack(
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
            ),
            IconoFondo(icono: Icons.person),
            _body(),
          ],
        ) : const PantallaCarga(titulo: 'Cargando...')
      )
    );
  }

  Widget _body(){
    return Form(
      key: formKey,
      child: ListView(
        children: _widgetsCuerpo()
      ),
    );
  }

  List<Widget> _widgetsCuerpo(){
    return [
      _header(),
      _espacio(),
      const SizedBox(height: 70),
      _formGeneral('Nombre', 300, _formNombre(), _focusNombr, 0),
      const SizedBox(height: 60),
      _botonGuardar()
    ];
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
            'Editar mi Perfil',
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

  Widget _botonGuardar(){

    bool nombrHasCambios = false;
    bool emailHasCambios = false;
    bool numerHasCambios = false;

    if(_controlNombr.text.isNotEmpty){
      if(_controlNombr.text != nombrInit){
        nombrHasCambios = true;
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 35),
      child: MyBoton(
        titulo: 'Guardar Cambios',
        fondo: (nombrHasCambios | emailHasCambios | numerHasCambios) ? _paletaColors.mainA : Colors.grey.shade400,
        onpress: ()=> _ingresar(), 
      ),
    );
  }

  Widget _formGeneral(String titulo, double ancho, Widget form, FocusNode focus, int tipo){
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 35),
      child: SizedBox(
        width: ancho,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            _tituloForm(titulo, ancho, focus, tipo),
            const SizedBox(height: 5),
            form
          ],
        ),
      ),
    ); 
  }

  Widget _formNombre(){
    return TextFormField(
      autovalidateMode: autovalidar ? AutovalidateMode.always : AutovalidateMode.disabled,
      controller: _controlNombr,
      keyboardType: TextInputType.text,
      textCapitalization: TextCapitalization.words,
      style: const TextStyle(
        fontSize: 14,
        fontFamily: 'Textos'
      ),
      readOnly: onlyReadNombr,
      decoration: _decoracionForm(),
      focusNode: _focusNombr,
      validator: (String ? value){
        if (value == null || value.isEmpty) {
          return 'Por favor, ingresa tu nombre completo.';
        }
        if (!value.trim().contains(' ')) {
          return 'Por favor, ingresa tu nombre completo.';
        }
        return null;
      },
      onChanged: (value) {
        setState((){});
      },
    );
  }

  InputDecoration _decoracionForm() {
    return InputDecoration(
      filled: true,
      fillColor: Colors.white,
      errorStyle: TextStyle(
        fontSize: 12,
        fontFamily: 'Textos',
        color: _paletaColors.rojoMain,
      ),
      errorMaxLines: 4,
    );
  }

  Widget _tituloForm(String titulo, double ancho, FocusNode focus, int tipo){
    return Container(
      height: 40,
      width: ancho,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
          IconButton(
            icon: Icon(
              Icons.edit,
              color: _paletaColors.rojoMain,
            ),
            onPressed: (){
              if(tipo == 0){
                onlyReadNombr = false;
                setState((){});
              } else
              if(tipo == 1){
                setState((){});
                onlyReadEmail = false;
              }
              focus.requestFocus();
            },
          )
        ],
      )
    );
  }

  _showToast(String mensaje, int duracion, bool hasError) {
    Widget toast = Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        color: hasError ? _paletaColors.rojoMain : _paletaColors.mainA,
      ),
      child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
          const Icon(Icons.info_outline, color: Colors.white),
          const SizedBox(width: 12),
          Text(
            mensaje,
            style: const TextStyle(
              color: Colors.white,
              fontFamily: 'Textos'
            )
          ),
        ],
      ),
    );

    fToast!.showToast(
      child: toast,
      gravity: ToastGravity.TOP,
      toastDuration: Duration(milliseconds: duracion),
    );
  }

  Widget _espacio(){
    return const SizedBox(
      height: 10
    );
  }

  void _ingresar(){
    if(formKey.currentState!.validate()){
      _guardarCambios();
    } else {
      _pruebaValidar();
      _showToast('Los campos no han sido\nllenados correctamente', 2500, true);
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

    bool nombrHasCambios = false;
    Map<String,dynamic> mapData = {};

    if(_controlNombr.text.isNotEmpty){
      if(_controlNombr.text != nombrInit){
        mapData.addEntries({
          'username' : _controlNombr.text.trim()
        }.entries);
        nombrHasCambios = true;
      }
    }

    try {
      MisAvisos().ventanaTrabajando(context, 'Actualizando...');

      final user = FirebaseAuth.instance.currentUser;
      if(nombrHasCambios){
        await FirebaseFirestore.instance
        .collection('Drivers')
        .doc(widget.userId)
        .update(mapData);
        await user!.updateDisplayName(_controlNombr.text.trim());
        await user.reload();
      }

      if(mounted) Navigator.pop(context);
      _showToast('Actualización correcta', 1500, false);
      if(mounted) Navigator.pop(context, {'newNombr': _controlNombr.text.trim()});

    } catch(e){
      if(mounted) Navigator.pop(context);
      _showToast('Actualización fallida\nintentar nuevamente', 2500, true);
    }
  }
}