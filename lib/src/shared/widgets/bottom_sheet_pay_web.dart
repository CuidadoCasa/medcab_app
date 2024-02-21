import 'package:app_medcab/src/shared/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


class PagoSheet {

  final _paletaColores = PaletaColors();
  
  void verSheet(BuildContext context, List<Widget> contenido, String monto, Function funcion2)  {
    double alto = MediaQuery.of(context).size.height;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: _paletaColores.fondoMain,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, void Function(void Function()) setState) {
            return SizedBox(
              height: alto * 0.60,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                          '',
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
                    height: alto * 0.40,
                    color: _paletaColores.fondoMain,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 60),
                      child: Column(
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
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              elevation: 0,
                              backgroundColor: Colors.blueAccent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: SizedBox(
                              width: 300,
                              child: Center(
                                child: Text(
                                  'Pagar  $monto MX',
                                  style: const TextStyle(
                                    fontSize: 17,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            onPressed: ()=> funcion2(),
                          ),
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
    );
  }
}