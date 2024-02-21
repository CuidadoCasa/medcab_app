import 'package:app_medcab/src/shared/colors.dart';
import 'package:flutter/material.dart';

final paletaColors = PaletaColors();

class MyBoton extends StatelessWidget {

  final bool botonChico;
  final String titulo;
  final Color fondo;
  final Function onpress;
  final Color letra;
  final bool negrita;

  const MyBoton({
    Key? key, 
    this.fondo = Colors.deepOrange,
    this.letra = Colors.white,
    this.botonChico = false,
    this.negrita = false,
    required this.titulo,
    required this.onpress
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: InkWell(
        onTap: ()=> onpress(),
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        hoverColor: Colors.transparent,
        child: Container(
          width:  botonChico ? 100 : 200,
          height: botonChico ?  45 : 50,
          alignment: AlignmentDirectional.center,
          decoration: BoxDecoration(
            color: fondo,
            borderRadius: BorderRadius.circular(botonChico ? 10 : 20),
            // boxShadow: [
            //   BoxShadow(
            //     spreadRadius: 1,
            //     blurRadius: 10,
            //     color: fondo
            //   )
            // ]
          ),
          child: Text(
            titulo, 
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Textos',
              fontWeight: negrita ? FontWeight.bold : FontWeight.normal,
              color: letra, 
              fontSize: botonChico ? 14 : 16),
            )
        ),
      ),
    );
  }
}