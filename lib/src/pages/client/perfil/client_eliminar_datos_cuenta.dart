import 'package:app_medcab/src/shared/colors.dart';
import 'package:app_medcab/src/shared/widgets/botones.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

final _paletaColors = PaletaColors();

class EliminarDatosCuentaPageClient extends StatelessWidget {
  const EliminarDatosCuentaPageClient({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: _botonIrPagina(),
      appBar: AppBar(
        title: const Text(
          'Elimar cueta/datos',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18
          ),
        ),
        backgroundColor: _paletaColors.mainB,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _cuerpo(),
    );
  }

  Widget _cuerpo(){
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
      children: const [
         Text(
          'Gracias por utilizar nuestros servicios. Queremos asegurarnos de que tengas el control total sobre tus datos personales. Si deseas eliminar tu cuenta o solicitar la eliminación de tus datos, por favor, sigue las instrucciones detalladas en nuestra página web.',
          textAlign: TextAlign.justify,
        ),
        SizedBox(height: 15),
        Text(
          'Al hacer clic en el botón de abajo, serás dirigido a nuestra página web donde encontrarás las instrucciones paso a paso para solicitar la eliminación de tu cuenta o datos personales. Asegúrate de seguir cada paso cuidadosamente para completar el proceso de manera correcta.\n\nTen en cuenta que una vez que se eliminen tus datos, es posible que no puedas recuperarlos, y perderás acceso a tu cuenta y cualquier información asociada a ella. Por favor, asegúrate de hacer una copia de seguridad de cualquier dato importante antes de proceder con la eliminación.\n\nSi tienes alguna pregunta o necesitas ayuda adicional, no dudes en ponerte en contacto con nuestro equipo de soporte. Estaremos encantados de ayudarte en cualquier momento.\n\nGracias por confiar en nosotros y por tu comprensión.',
          textAlign: TextAlign.justify,
        ),
      ],
    );
  }

  Widget _botonIrPagina(){
    return Container(
      margin: const EdgeInsets.only(bottom: 20, left: 20, right: 20),
      child: MyBoton(
        titulo: 'Solicitar eliminación de datos', 
        fondo: _paletaColors.mainA,
        onpress: ()=> _abrirNavegador(Uri.parse('https://cuidadoencasa.com.mx/cancelacion-de-cuenta-medcab/'))
      ),
    );
  }
  
  Future<void> _abrirNavegador(Uri url) async {
    if (!await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    )) {
      throw Exception('Could not launch $url');
    }
  }
}