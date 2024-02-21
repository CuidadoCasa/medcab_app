import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:app_medcab/src/models/driver.dart';
import 'package:app_medcab/src/pages/driver/perfil/driver_cedula_profesional.dart';
import 'package:app_medcab/src/pages/driver/perfil/driver_change_pass.dart';
import 'package:app_medcab/src/pages/driver/perfil/driver_comprobante_domicilio.dart';
import 'package:app_medcab/src/pages/driver/perfil/driver_eliminar_datos_cuenta.dart';
import 'package:app_medcab/src/pages/driver/perfil/driver_foto_perfil.dart';
import 'package:app_medcab/src/pages/driver/perfil/driver_identificacion.dart';
import 'package:app_medcab/src/pages/driver/perfil/driver_perfil_editar.dart';
import 'package:app_medcab/src/pages/driver/perfil/driver_recomendacion.dart';
import 'package:app_medcab/src/pages/driver/perfil/driver_situacion_fiscal.dart';
import 'package:app_medcab/src/pages/driver/perfil/driver_titulo_profesional.dart';
import 'package:app_medcab/src/pages/driver/perfil/preguntas_frecuentes.dart';
import 'package:app_medcab/src/pages/terminos/terminos.dart';
import 'package:app_medcab/src/shared/colors.dart';
import 'package:app_medcab/src/shared/widgets/icon_perfil.dart';
import 'package:app_medcab/src/shared/widgets/pantalla_carga.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class PerfilEnfermeraPage extends StatefulWidget {

  final Driver ? user;

  const PerfilEnfermeraPage({
    super.key,
    required this.user
  });

  @override
  State<PerfilEnfermeraPage> createState() => _PerfilEnfermeraPageState();
}

class _PerfilEnfermeraPageState extends State<PerfilEnfermeraPage> {

  final _paletaColors = PaletaColors();

  bool cargando = true;
  bool hasPorpiedades = false;
  
  FToast ? fToast;
  Driver ? miUsuario;
  String userId = '';
  String urlFotoPerfil = '';
  String nombreUsuario = '';
  
  int hasINE = 0;
  int hasCedula = 0;
  int hasTitulo = 0;

  int hasDomicilio = 0;
  int hasFiscal = 0;
  int hasCartas = 0;

  @override
  void initState() {
    fToast = FToast();
    fToast!.init(context);
    _initData();
    super.initState();
  }

  void _initData() async {
    Map<String,dynamic> dataTemp = {};

    if(widget.user != null){
      miUsuario = widget.user;
      userId = miUsuario!.id!;
      urlFotoPerfil = miUsuario!.image ?? ''; 
      nombreUsuario = miUsuario!.username!;
      if(miUsuario != null){
        if(miUsuario!.hasINE != null){
          hasINE = miUsuario!.hasINE!;
        }
        if(miUsuario!.hasCedula != null){
          hasCedula = miUsuario!.hasCedula!;
        }
        if(miUsuario!.hasTitulo != null){
          hasTitulo = miUsuario!.hasTitulo!;
        }

        if(miUsuario!.hasFiscal != null){
          hasFiscal = miUsuario!.hasFiscal!;
        }
        if(miUsuario!.hasDomicilio != null){
          hasDomicilio = miUsuario!.hasDomicilio!;
        }
        if(miUsuario!.hasCartas != null){
          hasCartas = miUsuario!.hasCartas!;
        }
      }
    } else {
      final userRef = FirebaseAuth.instance.currentUser;
      if(userRef != null){
        userId = userRef.uid;
        final informacionTemp = await FirebaseFirestore.instance
        .collection('Driver')
        .doc(userId)
        .get();

        if(informacionTemp.data() != null){
          dataTemp = informacionTemp.data()!;
          miUsuario = driverFromJson(jsonEncode(dataTemp));
          userId = miUsuario!.id!;
          urlFotoPerfil = miUsuario!.image ?? ''; 
          nombreUsuario = miUsuario!.username!;
          if(miUsuario != null){
            if(miUsuario!.hasINE != null){
              hasINE = miUsuario!.hasINE!;
            }
            if(miUsuario!.hasCedula != null){
              hasCedula = miUsuario!.hasCedula!;
            }
            if(miUsuario!.hasTitulo != null){
              hasTitulo = miUsuario!.hasTitulo!;
            }

            if(miUsuario!.hasFiscal != null){
              hasFiscal = miUsuario!.hasFiscal!;
            }
            if(miUsuario!.hasDomicilio != null){
              hasDomicilio = miUsuario!.hasDomicilio!;
            }
            if(miUsuario!.hasCartas != null){
              hasCartas = miUsuario!.hasCartas!;
            }
          }
        }
      }
    }

    cargando = false;
    if(mounted){
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return !cargando ? Scaffold(
      backgroundColor: _paletaColors.fondoMain,
      appBar: AppBar(
        backgroundColor: _paletaColors.mainA,
        title: const Text(
          'Perfil',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: _body()
      )
    ) : const PantallaCarga(titulo: 'Cargando...');
  }

  Widget _body(){
    final size = MediaQuery.of(context).size.width;

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: (size > 750) ? 200 : 20, vertical: 10),
      itemCount: _widgetsCuerpo().length,
      itemBuilder: (BuildContext text, int index){
        return _widgetsCuerpo()[index];
      }
    );
  }

  List<Widget> _widgetsCuerpo(){
    return [
      _espacio(),
      _avatar(),
      _espacio(),
      _cajaOpciones(),
      const SizedBox(height: 20),
      _widgetDocumento('Términos y Condiciones', 0),
      _widgetDocumento('Aviso de Privacidad', 1),
      const SizedBox(height: 20),
    ];
  }

  Widget _avatar(){
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircleAvatar(
          radius: 62.5,
          backgroundColor: _paletaColors.mainB,
          child: _imageAvatar(),
        ),
        const SizedBox(width: 15),
        SizedBox(
          height: 90,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _nombre(),
            ],
          ),
        )
      ],
    );
  }

  Widget _imageAvatar(){
    if(urlFotoPerfil.isNotEmpty){
      return _clipFoto(
        FotoPerfil(
          alto:  125,
          ancho: 125,
          url: urlFotoPerfil,
        ),
      );
    } else {
      return const Icon(Icons.person, size: 60, color: Colors.white);
    }
  }

  Widget _clipFoto(Widget foto){
    return ClipRRect(
      borderRadius: BorderRadius.circular(100),
      child: SizedBox(
        height: 125,
        width:  125,
        child: foto
      ),
    );
  }

  Widget _nombre(){
    return SizedBox(
      width: 300,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10, top: 10),
        child: Text(
          miUsuario!.username!,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: _paletaColors.negroMain
          )
        ),
      ),
    );
  }

  Widget _cajaOpciones(){
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15)
      ),
      child: Column(
        children: [
          _itemOpcion(
            'Nombre', 
            Icons.person_outline, 
            false, 
            ()=> _navegarNombre(),
            false
          ),
          _itemOpcion(
            'Foto de perfil', 
            Icons.person_pin_outlined, 
            false, 
            ()=> _navegarFoto(),
            urlFotoPerfil.isEmpty
          ),
          _itemOpcion(
            'Cambiar contraseña', 
            Icons.lock_open, 
            false, 
            (){
              _navegar(const CambiarPassPage());
            },
            false
          ),
          _itemOpcion(
            'Identificación', 
            Icons.document_scanner_outlined, 
            false, 
            ()=> _navegarIdentificacion(),
            hasINE == 0
          ),
          _itemOpcion(
            'Comprobante de domicilio', 
            Icons.document_scanner_outlined, 
            false, 
            ()=> _navegarComprobanteDomicilio(),
            hasDomicilio == 0
          ),
          _itemOpcion(
            'Cédula profesional', 
            CupertinoIcons.doc_append, 
            false, 
            ()=> _navegarCedula(),
            hasCedula == 0
          ),
          _itemOpcion(
            'Titulo profesional', 
            CupertinoIcons.doc_append, 
            false, 
            ()=> _navegarTitulo(),
            hasTitulo == 0
          ),
          _itemOpcion(
            'Constancia situación fiscal', 
            CupertinoIcons.doc_append, 
            false, 
            ()=> _navegarFiscal(),
            hasFiscal == 0
          ),
          _itemOpcion(
            'Cartas recomendación', 
            CupertinoIcons.doc_append, 
            false, 
            ()=> _navegarCartas(),
            hasCartas == 0
          ),
          const SizedBox(height: 15),
          _itemOpcion(
            'Eliminar mi cuenta y/o datos', 
            CupertinoIcons.delete_solid, 
            false, 
            (){
              Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (BuildContext context) => const EliminarDatosCuentaPage(),
                ),
              );
            },
            false
          ),
          _itemOpcion(
            'Preguntas Frecuentes', 
            Icons.question_mark_outlined, 
            false, 
            (){
              _navegar(const PreguntasFrecuentes());
            },
            false
          )
        ],
      ),
    );
  }
  
  void _navegarFoto() async {
    var data = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FotoPerfilPage(
          userId: userId, 
          urlFoto: urlFotoPerfil,
        )
      ),
    );

    if (data != null) {
      urlFotoPerfil = data['newFoto'];
      setState((){});
    } else {
      debugPrint('Sin data');
    }
  }

  void _navegarNombre() async {
    var data = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditarPerfilPage(
          userId: userId, 
          nombreUsuario: nombreUsuario,
        )
      ),
    );

    if (data != null) {
      nombreUsuario = data['newNombr'];
      setState((){});
    } else {
      debugPrint('Sin data');
    }
  }

  void _navegarIdentificacion() async {
    var data = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => IdentificacionPage(userId: userId)
      ),
    );

    if (data != null) {
      hasINE = data['newIne'];
      setState((){});
    } else {
      debugPrint('Sin data');
    }
  }

  void _navegarCedula() async {
    var data = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CedulaProfesionalPage(userId: userId)
      ),
    );

    if (data != null) {
      hasCedula = data['newCedula'];
      setState((){});
    } else {
      debugPrint('Sin data');
    }
  }

  void _navegarTitulo() async {
    var data = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TituloProfesionalPage(userId: userId)
      ),
    );

    if (data != null) {
      hasTitulo = data['newTitulo'];
      setState((){});
    } else {
      debugPrint('Sin data');
    }
  }

  void _navegarComprobanteDomicilio() async {
    var data = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ComprobanteDomicilioPage(userId: userId)
      ),
    );

    if (data != null) {
      hasDomicilio = data['newComprobanteDomicilio'];
      setState((){});
    } else {
      debugPrint('Sin data');
    }
  }

  void _navegarCartas() async {
    var data = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CartasRecomendacionPage(userId: userId)
      ),
    );

    if (data != null) {
      hasCartas = data['newCartas'];
      setState((){});
    } else {
      debugPrint('Sin data');
    }
  }

  void _navegarFiscal() async {
    var data = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ComprobanteFiscalPage(userId: userId)
      ),
    );

    if (data != null) {
      hasFiscal = data['newfiscal'];
      setState((){});
    } else {
      debugPrint('Sin data');
    }
  }

  Widget _widgetDocumento(String titulo, int tipo){
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15)
      ),
      child: Column(
        children: [
          _itemOpcion(
            titulo, 
            CupertinoIcons.doc_append, 
            true, 
            (){
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context)=> ViewTerminosPage(tipo: tipo)
                )
              );
            },
            false
          ),
        ],
      ),
    );
  }

  void _navegar(Widget pagina){
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (BuildContext context){
          return pagina;
        } 
      ),
    );
  }

  Widget _itemOpcion(String titulo, IconData icono, bool isLast, Function onpress, bool faltaData){
    return InkWell(
      onTap: ()=> onpress(),
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      hoverColor: Colors.transparent,
      child: Container(
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 15),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isLast ? Colors.transparent : Colors.grey.shade200,
              width: 1
            )
          )
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              child: Row(
                children: [
                  Container(
                    width:  30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: _paletaColors.mainB,
                      borderRadius: BorderRadius.circular(7)
                    ),
                    child: Icon(icono, color: Colors.white, size: 18)
                  ),
                  const SizedBox(width: 15),
                  faltaData ? Icon(
                    Icons.circle,
                    color: faltaData ? _paletaColors.rojoMain : Colors.transparent,
                  ) : const SizedBox(),
                  SizedBox(width: faltaData ? 5 : 0),
                  Text(
                    titulo,
                    style: const TextStyle(
                      fontSize: 15
                    ),
                  ),
                ],
              )
            ),
            const Icon(
              Icons.arrow_forward_ios_outlined,
              size: 25,
              color: Colors.grey,
            )
          ],
        ),
      ),
    );
  }

  Widget _espacio(){
    return const SizedBox(
      height: 10
    );
  }
}