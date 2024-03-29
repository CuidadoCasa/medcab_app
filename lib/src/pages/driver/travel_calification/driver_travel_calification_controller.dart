import 'package:flutter/material.dart';
import 'package:app_medcab/src/models/travel_history.dart';
import 'package:app_medcab/src/providers/travel_history_provider.dart';
import 'package:app_medcab/src/utils/snackbar.dart' as utils;

class DriverTravelCalificationController {

  BuildContext ? context;
  GlobalKey<ScaffoldState> key = GlobalKey();
  Function ? refresh;

  String ? idTravelHistory;

  TravelHistoryProvider ? _travelHistoryProvider;
  TravelHistory ? travelHistory;

  double ? calification;

  Future init (BuildContext context, Function refresh) async {
    this.context = context;
    this.refresh = refresh;

    idTravelHistory = ModalRoute.of(context)!.settings.arguments as String;

    _travelHistoryProvider = TravelHistoryProvider();

    getTravelHistory();
  }

  void calificate() async {
    if (calification == null) {
      utils.Snackbar.showSnackbar(context!, key, 'Por favor califica a tu cliente');
      return;
    }
    if (calification == 0) {
      utils.Snackbar.showSnackbar(context!, key, 'La calificacion minima es 1');
      return;
    }
    Map<String, dynamic> data = {
      'calificationClient': calification
    };

    await _travelHistoryProvider!.update(data, idTravelHistory!);
    Navigator.pushNamedAndRemoveUntil(context!, 'driver/map', (route) => false);
  }

  void getTravelHistory() async {
    travelHistory = await _travelHistoryProvider!.getById(idTravelHistory!);
    refresh!();
  }


}