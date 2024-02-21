import 'package:app_medcab/src/shared/colors.dart';
import 'package:flutter/material.dart';


class MisWidgets {
  final _paletaColors = PaletaColors();

  AppBar miAppBar(String titulo, Function onpres, {bool isStripe = false}) {
    return AppBar(
      elevation: 0,
      backgroundColor: isStripe ? _paletaColors.colorStripe : _paletaColors.mainA,
      leading: InkWell(
        onTap: ()=> onpres(),
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        hoverColor: Colors.transparent,
        child: const Icon(Icons.arrow_back, color: Colors.white)
      ),
      title: Text(
        titulo,
        textAlign: TextAlign.start,
        style: const TextStyle(
          fontFamily: 'Titulos',
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color:Colors.white
        )
      ),
    );
  }

}