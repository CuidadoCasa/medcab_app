import 'package:app_medcab/src/models/driver.dart';
import 'package:app_medcab/src/models/travel_info.dart';
import 'package:app_medcab/src/shared/colors.dart';
import 'package:flutter/material.dart';

final _paletaColors = PaletaColors();

class BottomSheetClientInfo extends StatefulWidget {

  final Driver usuario;
  final TravelInfo infoService;

  const BottomSheetClientInfo({
    super.key, 
    required this.usuario,
    required this.infoService 
  });

  @override
  State<BottomSheetClientInfo> createState() => _BottomSheetClientInfoState();
}

class _BottomSheetClientInfoState extends State<BottomSheetClientInfo> {

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 400,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: _paletaColors.mainA,
      ),
      child: Column(
        children: [
          const Text(
            'Información',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white
            ),
          ),
          const SizedBox(height: 15),
          _itemOpcion(
            'Paciente',
            widget.usuario.username ?? '',
            Icons.person
          ),
          _itemOpcion(
            'Paquete',
            widget.infoService.nombre ?? '',
            Icons.text_format_rounded
          ),
          _itemOpcion(
            'Descripción',
            widget.infoService.descripcion ?? '',
            Icons.document_scanner_outlined
          ),
        ],
      ),
    );
  }

  Widget _itemOpcion(String titulo, String descripcion, IconData icono){
    return ListTile(
      title: Text(
        titulo,
        style: const TextStyle(
          fontSize: 15,
          color: Colors.white,
          fontWeight: FontWeight.bold
        ),
      ),
      subtitle: Text(
        descripcion,
        maxLines: 3,
        style: TextStyle(
          fontSize: 15,
          color: _paletaColors.grisC,
        ),
      ),
      leading: Icon(
        icono,
        color: Colors.white,
      ),
    );
  }
}
