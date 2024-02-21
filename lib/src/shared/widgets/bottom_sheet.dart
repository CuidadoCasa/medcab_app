import 'package:app_medcab/src/shared/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'botones.dart';


class BusquedaSheet {

  final _paletaColores = PaletaColors();
  
  void verSheet(BuildContext context, List<Widget> contenido, Function funcion1, Function funcion2)  {
    double alto = MediaQuery.of(context).size.height;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: _paletaColores.fondoMain,
      builder: (BuildContext context) {
        return SizedBox(
          height: alto * 0.85,
          child: Column(
            children: [
              Container(
                height: alto * 0.1,
                decoration: BoxDecoration(
                  color: _paletaColores.fondoMain,
                  borderRadius: const BorderRadius.only(
                    topLeft:  Radius.circular(20),
                    topRight: Radius.circular(20)
                  )
                ),
                padding: const EdgeInsets.only(right: 5),
                alignment: Alignment.centerLeft,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      splashRadius: 20,
                      icon: Icon(
                        CupertinoIcons.arrow_left_circle,
                        color: _paletaColores.negroMain,
                      ),
                      onPressed: ()=> Navigator.pop(context)
                    ),
                    const Text(
                      'Ajustes de Búsqueda',
                      style: TextStyle(
                        fontFamily: 'Titulos',
                        fontWeight: FontWeight.bold
                      )
                    ),
                    const SizedBox(
                      height: 40,
                      width:  40,
                    )
                  ],
                ),
              ),
              Container(
                height: alto * 0.65,
                color: _paletaColores.fondoMain,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: ListView(
                    children: contenido,
                  ),
                ),
              ),
              Container(
                height: alto * 0.1,
                decoration: BoxDecoration(
                  color: _paletaColores.fondoMain,
                  border: Border(
                    top: BorderSide(color: Colors.grey.shade200, width: 1)
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    MyBoton(
                      titulo: 'Reset Ajustes',
                      botonChico: true,
                      letra: _paletaColores.mainA,
                      fondo: _paletaColores.fondoMain,
                      negrita: true,
                      onpress: ()=> funcion1(), 
                    ),
                    MyBoton(
                      titulo: 'Aplicar Ajustes',
                      botonChico: false,
                      fondo: _paletaColores.negroMain,
                      onpress: ()=> funcion2(), 
                    ),
                  ]
                ),
              ),
            ]
          ),
        );
      }
    );
  }
}