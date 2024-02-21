import 'package:app_medcab/src/pages/client/perfil/client_change_pass.dart';
import 'package:app_medcab/src/pages/client/perfil/client_eliminar_datos_cuenta.dart';
import 'package:app_medcab/src/pages/client/perfil/client_foto_perfil.dart';
import 'package:app_medcab/src/pages/client/perfil/client_perfil_editar.dart';
import 'package:app_medcab/src/pages/driver/perfil/preguntas_frecuentes.dart';
import 'package:app_medcab/src/pages/terminos/terminos.dart';
import 'package:app_medcab/src/shared/colors.dart';
import 'package:app_medcab/src/shared/widgets/icon_perfil.dart';
import 'package:app_medcab/src/shared/widgets/pantalla_carga.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class PerfilClientPage extends StatefulWidget {

  final String userId;
  final String username;
  final String image;

  const PerfilClientPage({
    super.key,
    required this.userId,
    required this.username,
    required this.image
  });

  @override
  State<PerfilClientPage> createState() => _PerfilClientPageState();
}

class _PerfilClientPageState extends State<PerfilClientPage> {

  final _paletaColors = PaletaColors();
  String nombreUsuario = '';
  String urlFotoPerfil = '';
  String userId = '';

  bool cargando = true;
  bool hasPorpiedades = false;
  
  FToast ? fToast;

  @override
  void initState() {
    fToast = FToast();
    fToast!.init(context);
    _initData();
    super.initState();
  }

  void _initData() async {
    urlFotoPerfil = widget.image;
    nombreUsuario = widget.username;
    userId = widget.userId;

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
          nombreUsuario,
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
            ()=> _navegarNombre()
          ),
          _itemOpcion(
            'Foto de perfil', 
            Icons.person_pin_outlined, 
            false, 
            ()=> _navegarFoto()
          ),
          _itemOpcion(
            'Cambiar contraseña', 
            Icons.lock_open, 
            false, 
            (){
              _navegar(const ClientCambiarPassPage());
            }
          ),
          _itemOpcion(
            'Eliminar mi cuenta y/o datos', 
            Icons.lock_open, 
            false, 
            (){
              _navegar(const EliminarDatosCuentaPageClient());
            }
          ),
          _itemOpcion(
            'Preguntas Frecuentes', 
            Icons.question_mark_outlined, 
            false, 
            (){
              _navegar(const PreguntasFrecuentes());
            }
          )
        ],
      ),
    );
  }
  
  void _navegarFoto() async {
    var data = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ClientFotoPerfilPage(
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
        builder: (context) => ClientEditarPerfilPage(
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
            }
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

  Widget _itemOpcion(String titulo, IconData icono, bool isLast, Function onpress){
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