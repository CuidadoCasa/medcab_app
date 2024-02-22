import 'package:app_medcab/src/shared/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

final _paletaColors = PaletaColors();

class PantallaCarga extends StatelessWidget {
  final String titulo;

  const PantallaCarga({
    super.key,
    required this.titulo
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: PaletaColors().fondoMain,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: PaletaColors().fondoMain,
        automaticallyImplyLeading: false,
        title: Text(
          'MedCab',
          style: TextStyle(
            fontFamily: 'Titulos',
            color: PaletaColors().mainA,
            fontWeight: FontWeight.bold,
            fontSize: 25
          ),
        ),
        centerTitle: true,
      ),
      body: SizedBox(
        width: size.width,
        height: size.height,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CupertinoActivityIndicator(
              radius: 40,
              color: _paletaColors.mainB,
            ),
            const SizedBox(height: 15),
            Text(
              titulo,
              style: const TextStyle(
                fontFamily: 'Textos',
                color: Colors.grey,
                fontSize: 16
              )
            )
          ],
        )
      ),
    );
  }
}