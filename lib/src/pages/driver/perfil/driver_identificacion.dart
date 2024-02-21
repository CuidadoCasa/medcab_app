import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:app_medcab/src/shared/avisos.dart';
import 'package:app_medcab/src/shared/colors.dart';
import 'package:app_medcab/src/shared/widgets/botones.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';

class IdentificacionPage extends StatefulWidget {

  final String userId;

  const IdentificacionPage({
    super.key,
    required this.userId
  });

  @override
  State<IdentificacionPage> createState() => _IdentificacionPageState();
}

class _IdentificacionPageState extends State<IdentificacionPage> {
  
  final _paletaColors = PaletaColors();
  final ImagePicker picker = ImagePicker();
  GlobalKey<ScaffoldState> key = GlobalKey<ScaffoldState>();
  
  XFile ? ineFrente;
  XFile ? ineRevers;

  FToast ? fToast;

  String userId = '';
  String ineFre = '';
  String ineRev = '';
  bool cargando = true;

  @override
  void initState() {
    fToast = FToast();
    fToast!.init(context);
    _initData();
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
      ineFre = datosUser.containsKey('ineFre') ? datosUser['ineFre'] : '';
      ineRev = datosUser.containsKey('ineRev') ? datosUser['ineRev'] : '';
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
          child: const Icon(Icons.arrow_back)
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
            Positioned(
              right: -230,
              child: Align(
                alignment: Alignment.centerRight,
                child: Icon(
                  Icons.document_scanner_outlined, 
                  color: Colors.grey.withOpacity(0.2),
                  size: 500,
                )
              ),
            ),
            _body(),
          ],
        )
      )
    );
  }

  Widget _body(){
    return SingleChildScrollView(
      child: Column(
        children: [
          _header(),
          _widgetsCuerpo()
        ],
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
            'Identificación',
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

  Widget _widgetsCuerpo(){
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: _tituloSeccion('Identificación Frente', 17.5)
          ),
          _espacio(),
          _imageIne(true),
          _espacio(),
          Align(
            alignment: Alignment.centerLeft,
            child: _tituloSeccion('Identificación Reverso', 17.5)
          ),
          _espacio(),
          _imageIne(false),
          _botonGuardar()
        ]
      ),
    );
  }

  Widget _botonGuardar(){
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: MyBoton(
        titulo: 'Guardar Cambios',
        fondo: ((ineFrente != null) | (ineRevers != null)) ? _paletaColors.mainA : Colors.grey.shade400,
        onpress: (){
          if((ineFrente != null) | (ineRevers != null)){
            _guardarDatos();
          }
        } 
      ),
    );
  }

  Widget _imageIne(bool isFrente){
    return Align(
      alignment: Alignment.center,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            height: 180,
            width: 280,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.8),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: _paletaColors.mainA)
            ),
            child: _image(isFrente),
          ),
          InkWell(
            onTap: ()=> _selectImagen(isFrente),
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

  Widget _image(bool isFrente){
    if(isFrente){
      if(ineFrente != null){
        return _imageClip(
          Image.file(
            File(ineFrente!.path),
            fit: BoxFit.cover,
          )
        );
      } else
      if(ineFre.isNotEmpty){
        return _imageClip(
          Image.network(
            ineFre,
            fit: BoxFit.cover,
          )
        );
      } else {
        return Icon(Icons.document_scanner_outlined, size: 60, color: _paletaColors.mainA);
      }
    } else {
      if(ineRevers != null){
        return _imageClip(
          Image.file(
            File(ineRevers!.path),
            fit: BoxFit.cover,
          )
        );
      } else
      if(ineRev.isNotEmpty){
        return _imageClip(
          Image.network(
            ineRev,
            fit: BoxFit.cover,
          )
        );
      } else {
        return Icon(Icons.document_scanner_outlined, size: 60, color: _paletaColors.mainA);
      }      
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

  Widget _espacio(){
    return const SizedBox(
      height: 15
    );
  }

  Future<void> _selectImagen(bool isFrente) async {
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if(image != null){
      if(isFrente){
        ineFrente = image;
      } else {
        ineRevers = image;
      }
      setState(() {});
    }
  }

  void _guardarDatos() async {
    String nameF = 'ine_f';
    String nameR = 'ine_r';
    String urlAuxF = '';
    String urlAuxR = '';    
    String uid  = widget.userId;

    final storageRefF = FirebaseStorage.instance.ref();
    final storageRefR = FirebaseStorage.instance.ref();

    final mountainsRefF = storageRefF.child('users/$uid/personal/$nameF.jpg');
    final mountainsRefR = storageRefR.child('users/$uid/personal/$nameR.jpg');

    MisAvisos().ventanaTrabajando(context, 'Actualizando identificación...');

    try {
      if(ineFrente != null){
        await mountainsRefF.putFile(
          File(ineFrente!.path), 
          SettableMetadata(contentType: "image/jpeg")
        );

        urlAuxF = await mountainsRefF.getDownloadURL();
        await FirebaseFirestore.instance
        .collection('Drivers')
        .doc(uid)
        .collection('informacion')
        .doc('personal')
        .set({
          'ineFre': urlAuxF,
        }, SetOptions(merge: true));
      }

      if(ineRevers != null){
        await mountainsRefR.putFile(
          File(ineRevers!.path), 
          SettableMetadata(contentType: "image/jpeg")
        );

        urlAuxR = await mountainsRefR.getDownloadURL();
        await FirebaseFirestore.instance
        .collection('Drivers')
        .doc(uid)
        .collection('informacion')
        .doc('personal')
        .set({
          'ineRev': urlAuxR,
        }, SetOptions(merge: true));
      }

      await FirebaseFirestore.instance
      .collection('Drivers')
      .doc(widget.userId)
      .update({
        'hasINE': 1
      });
      
      if(mounted) Navigator.pop(context);
      MisAvisos().showToast('¡Identificación actualizada!', 2000, fToast!, false);
      if(mounted) Navigator.pop(context, {'newIne': 1});
    
    } catch(e){
      debugPrint('$e');
      if(mounted) Navigator.pop(context);
      MisAvisos().showToast('Error', 1500, fToast!, true);
    }
  }

}