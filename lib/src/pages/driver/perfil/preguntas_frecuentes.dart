import 'package:app_medcab/src/shared/colors.dart';
import 'package:flutter/material.dart';

class PreguntasFrecuentes extends StatefulWidget {
  
  const PreguntasFrecuentes({
    super.key,
  });

  @override
  State<PreguntasFrecuentes> createState() => _PreguntasFrecuentesState();
}

class _PreguntasFrecuentesState extends State<PreguntasFrecuentes> {

  final _paletaColors = PaletaColors();

  List<Map<String,dynamic>> listPreguntas = [
    {
      'p': '¿Cómo funciona la aplicación de alquiler de casas?',
      'r': 'Nuestra aplicación de alquiler de casas te permite buscar, reservar y alojarte en casas, apartamentos y otros tipos de alojamiento en todo el país. Puedes explorar listados, comunicarte con los anfitriones y realizar reservas de forma sencilla.'
    },
    {
      'p': '¿Es seguro reservar alojamientos a través de la aplicación?',
      'r': 'Sí, la seguridad es una prioridad para nosotros. Verificamos a los anfitriones y ofrecemos sistemas seguros de pago. También puedes leer reseñas de otros huéspedes y contactar con el anfitrión antes de reservar.'
    },
    {
      'p': '¿Cómo puedo contactar a un anfitrión?',
      'r': 'Puedes enviar mensajes a los anfitriones directamente a través de la aplicación. Solo después de haber realizado tu reservación.'
    },
    {
      'p': '¿Cuáles son las opciones de pago disponibles?',
      'r': 'Aceptamos varias opciones de pago, como tarjetas de crédito y débito.'
    },
    {
      'p': '¿Puedo cancelar una reserva?',
      'r': 'Sí, puedes cancelar una reserva, pero ten en cuenta que las políticas de cancelación pueden variar según el anfitrión. Asegúrate de revisar las políticas de cancelación antes de hacer una reserva.'
    },
    {
      'p': '¿Cómo funciona el proceso de check-in y check-out?',
      'r': 'El proceso de check-in y check-out depende del anfitrión y la propiedad. La mayoría de los anfitriones te proporcionarán instrucciones detalladas para tu llegada y salida.'
    },
    {
      'p': '¿Qué hago si tengo un problema durante mi estancia?',
      'r': 'Si experimentas algún problema durante tu estancia, comunícate primero con el anfitrión para resolverlo. Si no puedes llegar a un acuerdo, contáctanos y estaremos encantados de ayudarte.'
    },
    {
      'p': '¿Qué tarifas o comisiones se aplican al utilizar la aplicación?',
      'r': 'Para ofrecer nuestros servicios y mantener la plataforma, se aplican tarifas y comisiones tanto a los anfitriones como a los huéspedes. Las tarifas pueden incluir una comisión de servicio y otros cargos relacionados con el procesamiento de pagos. Estos costos se detallan durante el proceso de reserva y se incluyen en el resumen de precios antes de la confirmación.'
    },
    {
      'p': '¿Cómo se calculan las comisiones para los anfitriones?',
      'r': 'Las comisiones para los anfitriones se calculan como un porcentaje del precio de la reserva. El porcentaje exacto puede variar y se mostrará claramente durante el proceso de registro de un alojamiento.'
    },
    {
      'p': '¿Cuándo y cómo se realizan los pagos de las comisiones?',
      'r': 'Las comisiones se deducen en 8 días del pago del huésped en el momento de la reserva. Los anfitriones reciben el monto restante después de deducir las comisiones y cualquier otra tarifa aplicable.'
    },
    {
      'p': '¿Los huéspedes también deben pagar comisiones adicionales?',
      'r': 'Sí, los huéspedes pueden estar sujetos a una comisión de servicio que se agrega al costo total de la reserva. Esta tarifa se muestra de manera transparente durante el proceso de reserva.'
    }
  ];
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PaletaColors().fondoMain,
      appBar: AppBar(
        backgroundColor: PaletaColors().fondoMain,
        elevation: 1,
        title: const Text(
          'Preguntas frecuentes',
          style: TextStyle(
            fontFamily: 'Titulos',
            fontWeight: FontWeight.bold,
            fontSize: 18
          )
        ),
      ),
      body: _listaPregunta()
    );
  }

  Widget _listaPregunta(){
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 40),
      itemCount: listPreguntas.length,
      itemBuilder: (BuildContext context, int index){
        return _itemPregunta(listPreguntas[index]['p'],listPreguntas[index]['r'], (index + 1));
      }
    );
  }

  Widget _itemPregunta(String titulo, String respuesta, int index){
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$index. $titulo',
          style: TextStyle(
            color: _paletaColors.mainA,
            fontFamily: 'Titulos',
            fontWeight: FontWeight.bold
          ),
        ),
        const SizedBox(height: 10),
        Text(
          respuesta,
          style: const TextStyle(
            fontFamily: 'Titulos',
            fontWeight: FontWeight.normal,
            fontSize: 14
          ),
        ),
        const SizedBox(height: 30),
      ],
    );
  }
}