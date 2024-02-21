import 'package:app_medcab/src/utils/formato_dinero.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:app_medcab/src/models/travel_history.dart';
import 'package:app_medcab/src/pages/client/history/client_history_controller.dart';
import 'package:app_medcab/src/utils/relative_time_util.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ClientHistoryPage extends StatefulWidget {
  const ClientHistoryPage({super.key});

  @override
  State<ClientHistoryPage> createState() => _ClientHistoryPageState();
}

class _ClientHistoryPageState extends State<ClientHistoryPage> {

  final _con = ClientHistoryController();

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
      appBar: AppBar(title: const Text('Historial de servicios'),),
      body: FutureBuilder(
        future: _con.getAll(),
        builder: (context, AsyncSnapshot<List<TravelHistory>> snapshot) {
          return ListView.builder(
            itemCount: snapshot.data?.length ?? 0,
            itemBuilder: (_, index) {
              return _cardHistoryInfo(
                snapshot.data![index].from!,
                snapshot.data![index].to!,
                snapshot.data![index].nameDriver!,
                snapshot.data![index].price.toString(),
                snapshot.data![index].calificationDriver.toString(),
                RelativeTimeUtil.getRelativeTime(snapshot.data![index].timestamp!),
                snapshot.data![index].id!,
              );

            }
          );
        },
      )
    );
  }

  Widget _cardHistoryInfo(
    String from,
    String to,
    String name,
    String price,
    String calification,
    String timestamp,
    String idTravelHistory,
  ) {
    return GestureDetector(
      onTap: () {
        _con.goToDetailHistory(idTravelHistory);
      },
      child: Container(
        margin: const EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 10),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.1),
          borderRadius: const BorderRadius.all(Radius.circular(10))
        ),
        child: Column(
          children: [
            _espacio(),
            _listInfo(
              FontAwesomeIcons.userNurse,
              'Médico: ',
              name,
            ),
            _espacio(),
            _listInfo(
              FontAwesomeIcons.locationDot,
              'Ubicación: ',
              from,
            ),
            _espacio(),
            _listInfo(
              FontAwesomeIcons.moneyBill,
              'Costo: ',
              FormatoDinero().convertirNum(double.parse(price)),
            ),
            _espacio(),
            _listInfo(
              FontAwesomeIcons.star,
              'Calificación: ',
              calification,
            ),
            _espacio(),
            _listInfo(
              FontAwesomeIcons.clock,
              'Hora: ',
              timestamp,
            ),
            _espacio(),
          ],
        ),
      ),
    );
  }

  Widget _espacio(){
    return const SizedBox(height: 8);
  }

  Widget _listInfo(IconData icono, String titulo, String descripcion){
    return Row(
      children: [
        const SizedBox(width: 5),
        FaIcon(icono, size: 20),
        const SizedBox(width: 5),
        Text(
          titulo,
          style: const TextStyle(
            fontWeight: FontWeight.bold
          ),
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.55,
          child: Text(
            descripcion,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        )
      ],
    );
  }

  void refresh() {
    if(mounted){
      setState(() {});
    }
  }
}
