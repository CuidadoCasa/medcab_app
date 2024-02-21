import 'package:app_medcab/src/shared/colors.dart';
import 'package:app_medcab/src/utils/formato_dinero.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:app_medcab/src/pages/client/travel_calification/client_travel_calification_controller.dart';
import 'package:app_medcab/src/widgets/button_app.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

final _paletaColors = PaletaColors();

class ClientTravelCalificationPage extends StatefulWidget {
  const ClientTravelCalificationPage({super.key});

  @override
  State<ClientTravelCalificationPage> createState() => _ClientTravelCalificationPageState();
}

class _ClientTravelCalificationPageState extends State<ClientTravelCalificationPage> {

  final _con = ClientTravelCalificationController();

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      _con.init(context, refresh);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _con.key,
      bottomNavigationBar: _buttonCalificate(),
      body: Column(
        children: [
          _bannerPriceInfo(),
          const SizedBox(height: 30),
          _listTileTravelInfo('Ubicación', _con.travelHistory?.from ?? '', Icons.location_on),
          const SizedBox(height: 30),
          _textCalificateYourDriver(),
          const SizedBox(height: 15),
          _ratingBar()
        ],
      ),
    );
  }

  Widget _buttonCalificate() {
    return Container(
      height: 50,
      margin: const EdgeInsets.all(30),
      child: ButtonApp(
        onPressed: _con.calificate,
        text: 'CALIFICAR',
        color: Colors.amber,
        icono: const FaIcon(
          FontAwesomeIcons.rankingStar,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _ratingBar() {
    return Center(
      child: RatingBar.builder(
          itemBuilder: (context, _) => Icon(
            Icons.star,
          color: _paletaColors.mainB,
          ),
          itemCount: 5,
          initialRating: 0,
          direction: Axis.horizontal,
          allowHalfRating: true,
          itemPadding: const EdgeInsets.symmetric(horizontal: 4),
          unratedColor: Colors.grey[300],
          onRatingUpdate: (rating) {
            _con.calification = rating;
          }
      ),
    );
  }
  
  Widget _textCalificateYourDriver() {
    return Text(
      'CALIFICA A TU MÉDICO',
      style: TextStyle(
        color: _paletaColors.mainB,
        fontWeight: FontWeight.bold,
        fontSize: 18
      ),
    );
  }

  Widget _listTileTravelInfo(String title, String value, IconData icon) {
    return Container(
      width: double.infinity,
      alignment: Alignment.center,
      margin: const EdgeInsets.symmetric(horizontal: 30),
      child: ListTile(
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 14
          ),
          maxLines: 1,
        ),
        subtitle: Text(
          value,
          style: const TextStyle(
              color: Colors.grey,
              fontWeight: FontWeight.bold,
              fontSize: 14
          ),
          maxLines: 2,
        ),
        leading: Icon(icon, color: Colors.grey,),
      ),
    );
  }

  Widget _bannerPriceInfo() {
    return ClipPath(
      clipper: OvalBottomBorderClipper(),
      child: Container(
        height: 290,
        width: double.infinity,
        color: _paletaColors.mainA,
        child: SafeArea(
          child: Column(
            children: [
              Icon(Icons.check_circle, color: _paletaColors.grisC, size: 100),
              const SizedBox(height: 20),
              Text(
                'Servicio Finalizado',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: _paletaColors.grisC
                ),
              ),
              const SizedBox(height: 30),
              const Text(
                'Costo',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white
                ),
              ),
              Text(
                (_con.travelHistory != null) ? (_con.travelHistory!.price != null) ? FormatoDinero().convertirNum(_con.travelHistory!.price!.toDouble()): '\$ 0.00' : '\$ 0.00',
                style: const TextStyle(
                  fontSize: 25,
                  color: Colors.white,
                  fontWeight:FontWeight.bold
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void refresh() {
    if(mounted){
      setState(() {});
    }
  }
}
