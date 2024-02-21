import 'package:app_medcab/src/shared/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:app_medcab/src/pages/home/home_controller.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

final _paletaColors = PaletaColors();

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _con = HomeController();

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      _con.init(context);
    });
  }

  @override
  Widget build(BuildContext context) {

    final size = MediaQuery.of(context).size;

    return Stack(
      children: [
        Column(
          children: [
            Container(
              height: 180,
              width: size.width,
              color: Colors.white,
              alignment: AlignmentDirectional.bottomCenter,
              child: Image.asset('assets/img/icon.png'),
            ),
            Container(
              height: size.height - 180,
              width: size.width,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white,
                    _paletaColors.mainA, 
                    _paletaColors.mainB,
                  ],
                )
              ),
            ),
          ],
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                ),
                _textSelectYourRol(),
                _textAnuncio(),
                const SizedBox(height: 50),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _opcion(
                      _imageTypeUser(context, 'client', true),
                      _textTypeUser('Paciente'),
                    ),
                    const SizedBox(width: 20),
                    _opcion(
                      _imageTypeUser(context, 'driver', false),
                      _textTypeUser('Médico')
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _opcion(Widget op1, Widget op2){
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        op1,
        const SizedBox(height: 10),
        op2
      ],
    );
  }

  Widget _textSelectYourRol() {
    return const Text(
      'Elija una opción',
      style: TextStyle(
        color: Colors.white,
        fontSize: 30,
        fontWeight: FontWeight.bold
      ),
    );
  }

  Widget _textAnuncio() {
    return const Text(
      'Si desea atención medica seleccione\nla opción de paciente',
      textAlign: TextAlign.center,
      style: TextStyle(
        color: Colors.white,
        fontSize: 15,
      ),
    );
  }

  Widget _imageTypeUser(BuildContext context, String typeUser, bool isPaciente) {
    return GestureDetector(
      onTap: () => _con.goToLoginPage(typeUser, isPaciente),
      child: CircleAvatar(
        radius: 50,
        backgroundColor: Colors.white,
        child: FaIcon(
          isPaciente ? FontAwesomeIcons.hospitalUser : FontAwesomeIcons.userDoctor, 
          size: 45,
          color: _paletaColors.mainB
        ),
      ),
    );
  }

  Widget _textTypeUser(String typeUser) {
    return Text(
      typeUser,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.bold
      ),
    );
  }
}
