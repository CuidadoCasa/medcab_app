import 'package:flutter/material.dart';

class FotoPerfil extends StatelessWidget {
  
  final String url;
  final double alto;
  final double ancho;

  const FotoPerfil({
    super.key,
    required this.url,
    required this.alto,
    required this.ancho
  });

  @override
  Widget build(BuildContext context) {
    if(url.isNotEmpty){
      return FadeInImage(
        height: alto,
        width: ancho,
        fit: BoxFit.cover,
        image: NetworkImage(url),
        placeholder: const AssetImage('assets/images/uhome_avatar_carga.png'),
      );
    } else {
      return SizedBox(
        height: alto,
        width: ancho,
        child: const Center(
          child: Icon(Icons.person),
        ),
      );
    }
  }
}