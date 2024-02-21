import 'package:app_medcab/src/shared/colors.dart';
import 'package:app_medcab/src/utils/formato_dinero.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:app_medcab/src/pages/client/history_detail/client_history_detail_controller.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

final _paletaColors = PaletaColors();

class ClientHistoryDetailPage extends StatefulWidget {
  const ClientHistoryDetailPage({super.key});
  @override
  State<ClientHistoryDetailPage> createState() => _ClientHistoryDetailPageState();
}

class _ClientHistoryDetailPageState extends State<ClientHistoryDetailPage> {

  final _con = ClientHistoryDetailController();

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
      appBar: AppBar(title: const Text('Detalle del servicio'),),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _bannerInfoDriver(),
            _listTileInfo(
              'Ubicación', 
              (_con.travelHistory == null) ? '' : _con.travelHistory!.from!, 
              Icons.location_on
            ),
            _listTileInfo(
              'Mi calificacion', 
              (_con.travelHistory == null) ? '' : _con.travelHistory!.calificationClient.toString(), 
              Icons.star_border
            ),
            _listTileInfo(
              'Calificacion del médico', 
              (_con.travelHistory == null) ? '' : _con.travelHistory!.calificationDriver.toString(), 
              Icons.star
            ),
            _listTileInfo(
              'Costo', 
              (_con.travelHistory == null) ? '' : FormatoDinero().convertirNum(_con.travelHistory!.price!), 
              Icons.monetization_on_outlined
            ),
          ],
        ),
      ),
    );
  }

  Widget _listTileInfo(String title, String value, IconData icon) {
    return ListTile(
      title: Text(
        title,
        style: TextStyle(
          color: _paletaColors.mainA,
          fontWeight: FontWeight.bold
        ),
      ),
      subtitle: Text(value),
      leading: Icon(icon),
    );
  }

  Widget _bannerInfoDriver() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.27,
      width: double.infinity,
      color: _paletaColors.mainA,
      child: Column(
        children: [
          const SizedBox(height: 15),
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.white,
            child: FaIcon(
              FontAwesomeIcons.userNurse, 
              color: _paletaColors.mainA,
              size: 40,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            (_con.driver == null) ? '' : _con.driver!.username!,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17
            ),
          )
        ],
      ),
    );
  }

  void refresh() {
    if(mounted){
      setState(() {});
    }
  }
}
