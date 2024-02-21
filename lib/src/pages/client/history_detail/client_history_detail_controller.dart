import 'package:flutter/material.dart';
import 'package:app_medcab/src/models/driver.dart';
import 'package:app_medcab/src/models/travel_history.dart';
import 'package:app_medcab/src/providers/driver_provider.dart';
import 'package:app_medcab/src/providers/travel_history_provider.dart';


class ClientHistoryDetailController {
  Function ? refresh;
  BuildContext ? context;
  GlobalKey<ScaffoldState> key = GlobalKey<ScaffoldState>();

  TravelHistoryProvider ? _travelHistoryProvider;
  DriverProvider ? _driverProvider;

  TravelHistory ? travelHistory;
  Driver ? driver;

  String ? idTravelHistory;

  Future init(BuildContext context, Function refresh) async {
    this.context = context;
    this.refresh = refresh;
    _travelHistoryProvider = TravelHistoryProvider();
    _driverProvider = DriverProvider();

    idTravelHistory = ModalRoute.of(context)!.settings.arguments as String;

    getTravelHistoryInfo();
  }

  void getTravelHistoryInfo() async {
    travelHistory = await  _travelHistoryProvider!.getById(idTravelHistory!);
    getDriverInfo(travelHistory!.idDriver!);
  }

  void getDriverInfo(String idDriver) async {
    driver = await _driverProvider!.getById(idDriver);
    refresh!();
  }

}

