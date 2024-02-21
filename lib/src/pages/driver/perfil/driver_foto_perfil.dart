import 'dart:io';

import 'package:app_medcab/src/providers/driver_provider.dart';
import 'package:app_medcab/src/providers/storage_provider.dart';
import 'package:app_medcab/src/shared/avisos.dart';
import 'package:app_medcab/src/shared/colors.dart';
import 'package:app_medcab/src/shared/widgets/botones.dart';
import 'package:app_medcab/src/shared/widgets/icon_perfil.dart';
import 'package:app_medcab/src/shared/widgets/icono_fondo.dart';
import 'package:app_medcab/src/shared/widgets/pantalla_carga.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';

class FotoPerfilPage extends StatefulWidget {
  final String urlFoto;
  final String userId;
  
  const FotoPerfilPage({
    super.key,
    required this.urlFoto,
    required this.userId
  });

  @override
  State<FotoPerfilPage> createState() => _FotoPerfilPageState();
}

class _FotoPerfilPageState extends State<FotoPerfilPage> {
  
  final _paletaColors = PaletaColors();
  final ImagePicker picker = ImagePicker();
  GlobalKey<ScaffoldState> key = GlobalKey<ScaffoldState>();

  DriverProvider ? _driverProvider;
  StorageProvider ? _storageProvider;
  
  String urlFotoInit = '';
  bool cargando = true;

  FToast ? fToast;
  XFile ? imageSelect;


  @override
  void initState() {
    _initData();
    fToast = FToast();
    fToast!.init(context);
    _storageProvider = StorageProvider();
    _driverProvider = DriverProvider();
    super.initState();
  }

  void _initData(){
    urlFotoInit = widget.urlFoto;
    cargando = false;
    if(mounted){
      setState((){});
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
                child: IconoFondo(icono: Icons.person),
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
          _espacio(),
          _avatar(),
          const SizedBox(height: 100),
          _botonGuardar()
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
      ),
    );
  }

  Widget _avatar(){
    return Center(
      child: SizedBox(
        width:  200,
        height: 200,
        child: Stack(
          children: [
            CircleAvatar(
              radius: 100,
              child: _imageAvatar(),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: InkWell(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                hoverColor: Colors.transparent,
                onTap: ()=> _selectImagenes(),
                child: Container(
                  height: 45,
                  width:  45,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: _paletaColors.rojoMain,
                    borderRadius: BorderRadius.circular(20)
                  ),
                  child: const Icon(
                    Icons.add_photo_alternate_outlined, 
                    color: Colors.white
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _imageAvatar(){
    if(imageSelect != null){
      return _clipFoto(
        Image.file(
          File(imageSelect!.path),
          fit: BoxFit.cover,
        )
      );
    } else
    if(urlFotoInit.isNotEmpty){
      return _clipFoto(
        FotoPerfil(
          alto: 200,
          ancho: 200,
          url: urlFotoInit,
        ),
      );
    } else {
      return const Icon(Icons.person, size: 60);
    }
  }

  Widget _clipFoto(Widget foto){
    return ClipRRect(
      borderRadius: BorderRadius.circular(100),
      child: SizedBox(
        height: 200,
        width:  200,
        child: foto
      ),
    );
  }

  Future<void> _selectImagenes() async {
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
    MisAvisos().ventanaTrabajando(context, 'Cargando foto...');

    try {
      TaskSnapshot snapshot = await _storageProvider!.uploadFile(imageSelect!);
      String imageUrl = await snapshot.ref.getDownloadURL();

      Map<String, dynamic> data = {
        'image': imageUrl,
      };

      await _driverProvider!.update(data, widget.userId);
      
      if(mounted) Navigator.pop(context);
      MisAvisos().showToast('¡Foto actualizada!', 2000, fToast!, false);
      if(mounted) Navigator.pop(context, {'newFoto': imageUrl});
    
    } catch(e){
      debugPrint('$e');
      if(mounted) Navigator.pop(context);
      MisAvisos().showToast('Error', 1500, fToast!, true);
    }
  }

}