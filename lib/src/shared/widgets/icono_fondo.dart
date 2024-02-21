import 'package:app_medcab/src/shared/colors.dart';
import 'package:flutter/cupertino.dart';

class IconoFondo extends StatelessWidget {

  final IconData icono;
  IconoFondo({
    super.key,
    required this.icono
  });

  final _paletaColors = PaletaColors();

  @override
  Widget build(BuildContext context) {
    return Icon(
      icono,
      color: _paletaColors.mainA.withOpacity(0.1),
      size: 500,
    );
  }
}