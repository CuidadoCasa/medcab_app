import 'package:app_medcab/src/models/client.dart';
import 'package:app_medcab/src/providers/client_provider.dart';
import 'package:flutter/material.dart';
import 'package:app_medcab/src/providers/auth_provider.dart';
import 'package:app_medcab/src/providers/travel_history_provider.dart';
import 'package:app_medcab/src/models/travel_history.dart';

class EnfermeraHistoryController {

  Function ? refresh;
  BuildContext ? context;
  GlobalKey<ScaffoldState> key = GlobalKey<ScaffoldState>();

  TravelHistoryProvider ? _travelHistoryProvider;
  AuthProvider ? _authProvider;

  Future init(BuildContext context, Function refresh) async {
    this.context = context;
    this.refresh = refresh;
    _travelHistoryProvider = TravelHistoryProvider();
    _authProvider = AuthProvider();

    refresh();
  }

  Future<String> getName (String idDriver) async {
    ClientProvider clientProvider = ClientProvider();
    Client ? client = await clientProvider.getById(idDriver);
    return client!.username!;
  }

  Future<List<TravelHistory>> getAll() async {
    return await _travelHistoryProvider!.getByIdDriver(_authProvider!.getUser()!.uid);
  }

  void goToDetailHistory(String id) {
    Navigator.pushNamed(context!, 'driver/history/detail', arguments: id);
  }

}