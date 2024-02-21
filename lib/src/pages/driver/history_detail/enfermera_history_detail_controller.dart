import 'package:app_medcab/src/models/client.dart';
import 'package:app_medcab/src/providers/client_provider.dart';
import 'package:flutter/material.dart';
import 'package:app_medcab/src/models/travel_history.dart';
import 'package:app_medcab/src/providers/travel_history_provider.dart';


class EnfermeraHistoryDetailController {
  Function ? refresh;
  BuildContext ? context;
  GlobalKey<ScaffoldState> key = GlobalKey<ScaffoldState>();

  TravelHistoryProvider ? _travelHistoryProvider;
  ClientProvider ? _clientProvider;

  TravelHistory ? travelHistory;
  Client ? client;

  String ? idTravelHistory;

  Future init(BuildContext context, Function refresh) async {
    this.context = context;
    this.refresh = refresh;
    _travelHistoryProvider = TravelHistoryProvider();
    _clientProvider = ClientProvider();

    idTravelHistory = ModalRoute.of(context)!.settings.arguments as String;
    getTravelHistoryInfo();
  }

  void getTravelHistoryInfo() async {
    travelHistory = await  _travelHistoryProvider!.getById(idTravelHistory!);
    getClientInfo(travelHistory!.idClient!);
  }

  void getClientInfo(String idClient) async {
    client = await _clientProvider?.getById(idClient);
    refresh!();
  }

}

