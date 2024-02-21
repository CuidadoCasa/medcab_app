import 'package:flutter/cupertino.dart';

class ImagenInternet extends StatelessWidget {
  
  final String url;
  final double alto;
  final double ancho;

  const ImagenInternet({
    super.key,
    required this.url,
    required this.alto,
    required this.ancho
  });

  @override
  Widget build(BuildContext context) {
    return FadeInImage(
      height: alto,
      width: ancho,
      fit: BoxFit.cover,
      image: NetworkImage(url),
      placeholder: const AssetImage('assets/images/uhome_carga.png'),
    );
  }
}