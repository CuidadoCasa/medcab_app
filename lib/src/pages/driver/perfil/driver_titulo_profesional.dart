import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:app_medcab/src/shared/avisos.dart';
import 'package:app_medcab/src/shared/colors.dart';
import 'package:app_medcab/src/shared/widgets/botones.dart';
import 'package:app_medcab/src/shared/widgets/icono_fondo.dart';
import 'package:app_medcab/src/shared/widgets/pantalla_carga.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';

class TituloProfesionalPage extends StatefulWidget {
  final String userId;
  
  const TituloProfesionalPage({
    super.key,
    required this.userId
  });

  @override
  State<TituloProfesionalPage> createState() => _TituloProfesionalPageState();
}

class _TituloProfesionalPageState extends State<TituloProfesionalPage> {
  
  final _paletaColors = PaletaColors();
  final ImagePicker picker = ImagePicker();
  GlobalKey<ScaffoldState> key = GlobalKey<ScaffoldState>();

  String urlFotoCedula = '';
  String userId = '';
  bool cargando = true;

  FToast ? fToast;
  XFile ? imageSelect;


  @override
  void initState() {
    _initData();
    fToast = FToast();
    fToast!.init(context);
    super.initState();
  }

  void _initData() async {
    Map<String,dynamic> datosUser = {};
    userId = widget.userId;

    DocumentSnapshot<Map<String, dynamic>> datos = await FirebaseFirestore.instance
    .collection('Drivers')
    .doc(userId)
    .collection('informacion')
    .doc('personal')
    .get();

    if(datos.data() != null){
      datosUser = datos.data() as Map<String, dynamic>;
      urlFotoCedula = datosUser.containsKey('titulo') ? datosUser['titulo'] : '';
    }

    cargando = false;

    if(mounted){
      setState(() {});
    }
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
        child: !cargando ? Stack(
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: Center(
                child: IconoFondo(icono: CupertinoIcons.doc_append),
              ),
            ),            
            _body(),
          ],
        ) : const PantallaCarga(titulo: 'Cargando...')
      )
    );
  }

  Widget _body(){
    return Column(
      children: [
        _header(),
        _widgetsCuerpo(),
      ],
    );
  }

  Widget _widgetsCuerpo(){
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: _tituloSeccion('Imágen titulo', 17.5)
          ),
          _espacio(),
          _imageMarco(),
          _botonGuardar()
        ]
      ),
    );
  }

  Widget _tituloSeccion(String titulo, double alto){
    return Text(
      titulo,
      style: TextStyle(
        fontFamily: 'Titulos',
        color: _paletaColors.mainA,
        fontWeight: FontWeight.bold,
        fontSize: alto
      ),
    );
  }

  Widget _imageMarco(){
    return Align(
      alignment: Alignment.center,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            height: 330,
            width:  250,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.8),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: _paletaColors.mainA)
            ),
            child: _image(),
          ),
          InkWell(
            onTap: ()=> _selectImagen(),
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            hoverColor: Colors.transparent,
            child: const SizedBox(
              height: 180,
              width: 280,
            ),
          ),
        ],
      ),
    );
  }

  Widget _image(){
    if(imageSelect != null){
      return _imageClip(
        Image.file(
          File(imageSelect!.path),
          fit: BoxFit.cover,
        )
      );
    } else
    if(urlFotoCedula.isNotEmpty){
      return _imageClip(
        Image.network(
          urlFotoCedula,
          fit: BoxFit.cover,
        )
      );
    } else {
      return Icon(Icons.document_scanner_outlined, size: 60, color: _paletaColors.mainA);
    }
  }

  Widget _imageClip(Widget image){
    return ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: SizedBox(
        height: 180,
        width: 280,
        child: image,
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
            'Titulo Profesional',
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

    bool hasCambio = false;
    if(imageSelect != null){
      hasCambio = true;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: MyBoton(
        titulo: 'Guardar Cambios',
        fondo: hasCambio ? _paletaColors.mainA : Colors.grey.shade400,
        onpress: ()=> _ingresar(), 
        // onpress: ()=> MisAvisos().ventanaTrabajando(context, 'Actualizando titulo...')
      ),
    );
  }

  Future<void> _selectImagen() async {
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if(image != null){
      imageSelect = image;
      setState((){});
    }
  }

  Widget _espacio(){
    return const SizedBox(
      height: 10
    );
  }

  void _ingresar(){
    if(imageSelect != null){
      _crearRegistro();
    }
  }

  void _crearRegistro() async {
    String nameC = 'cedula';
    String urlAuxC = '';
    String uid  = widget.userId;

    final storageRefC = FirebaseStorage.instance.ref();
    final mountainsRefF = storageRefC.child('users/$uid/personal/$nameC.jpg');

    MisAvisos().ventanaTrabajando(context, 'Actualizando titulo...');

    try {
      if(imageSelect != null){
        await mountainsRefF.putFile(
          File(imageSelect!.path), 
          SettableMetadata(contentType: "image/jpeg")
        );

        urlAuxC = await mountainsRefF.getDownloadURL();
        await FirebaseFirestore.instance
        .collection('Drivers')
        .doc(uid)
        .collection('informacion')
        .doc('personal')
        .set({
          'titulo': urlAuxC,
        }, SetOptions(merge: true));
      }

      await FirebaseFirestore.instance
      .collection('Drivers')
      .doc(widget.userId)
      .update({
        'hasTitulo': 1
      });
      
      if(mounted) Navigator.pop(context);
      MisAvisos().showToast('¡Cédula actualizada!', 2000, fToast!, false);
      if(mounted) Navigator.pop(context, {'newTitulo': 1});
    
    } catch(e){
      debugPrint('$e');
      if(mounted) Navigator.pop(context);
      MisAvisos().showToast('Error', 1500, fToast!, true);
    }
  }

}