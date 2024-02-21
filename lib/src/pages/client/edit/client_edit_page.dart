import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'package:app_medcab/src/pages/client/edit/client_edit_controller.dart';
import 'package:app_medcab/src/utils/colors.dart' as utils;
import 'package:app_medcab/src/widgets/button_app.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ClientEditPage extends StatefulWidget {
  const ClientEditPage({super.key});
  @override
  State<ClientEditPage> createState() => _ClientEditPageState();
}

class _ClientEditPageState extends State<ClientEditPage> {

  final _con = ClientEditController();

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
      appBar: AppBar(),
      bottomNavigationBar: _buttonRegister(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _bannerApp(),
            _textLogin(),
            _textFieldUsername(),
          ],
        ),
      ),
    );
  }

  Widget _buttonRegister() {
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 25),
      child: ButtonApp(
        onPressed: _con.update,
        text: 'Actualizar ahora',
        color: utils.Colors.uberCloneColor,
        icono: const FaIcon(
          FontAwesomeIcons.rotateRight,
          color: Colors.white,
        ),
      ),
    );
  }



  Widget _textFieldUsername() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
      child: TextField(
        controller: _con.usernameController,
        decoration: const InputDecoration(
            hintText: 'Pepito Perez',
            labelText: 'Nombre de usuario',
            suffixIcon: Icon(
              Icons.person_outline,
              color: utils.Colors.uberCloneColor,
            )
        ),
      ),
    );
  }

  Widget _textLogin() {
    return Container(
      alignment: Alignment.centerLeft,
      margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
      child: const Text(
        'Editar perfil',
        style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 25
        ),
      ),
    );
  }

  Widget _bannerApp() {
    return ClipPath(
      clipper: WaveClipperTwo(),
      child: Container(
        color: utils.Colors.uberCloneColor,
        height: MediaQuery.of(context).size.height * 0.22,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
           GestureDetector(
             onTap: _con.showAlertDialog,
             child: CircleAvatar(
               backgroundImage: _con.imageFile != null ?
               AssetImage(_con.imageFile?.path ?? 'assets/img/profile.png'):
               _con.client?.image != null
                   ? NetworkImage(_con.client!.image!)
                   : AssetImage(_con.imageFile?.path ?? 'assets/img/profile.png') as ImageProvider<Object>,
               radius: 50,
             ),
           ),
            Container(
              margin: const EdgeInsets.only(top: 30),
              child: Text(
                _con.client?.email ?? '',
                style: const TextStyle(
                  fontFamily: 'Pacifico',
                  fontSize: 17,
                  color: Colors.white,
                  fontWeight: FontWeight.bold
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  void refresh() {
    if(mounted){
      setState(() {});
    }
  }

}
