import 'package:flutter/material.dart';
import 'package:app_medcab/src/providers/auth_provider.dart';
import 'package:app_medcab/src/utils/shared_pref.dart';

class HomeController {

  BuildContext ? context;
  SharedPref ? _sharedPref;

  AuthProvider ? _authProvider;
  String ? _typeUser;
  String ? _isNotification;

  Future init(BuildContext context) async {
    this.context = context;
    _sharedPref = SharedPref();
    _authProvider = AuthProvider();

    _typeUser = await _sharedPref!.read('typeUser');
    _isNotification = await _sharedPref!.read('isNotification');
    checkIfUserIsAuth();
  }

  void checkIfUserIsAuth() {
    bool isSigned = _authProvider!.isSignedIn();
    if (isSigned) {

      if (_isNotification != 'true') {
        if (_typeUser == 'client') {
          Navigator.pushNamedAndRemoveUntil(context!, 'client/map', (route) => false);
          // Navigator.pushNamed(context, 'client/map');
        }
        else {
          Navigator.pushNamedAndRemoveUntil(context!, 'driver/map', (route) => false);
          // Navigator.pushNamed(context, 'driver/map');
        }
      }

    }
    else {
      debugPrint('NO ESTA LOGEADO');
    }
  }

  void goToLoginPage(String typeUser, bool isPaciente) {
    saveTypeUser(typeUser);
    Navigator.pushNamed(context!, 'login', arguments: {'isPaciente': isPaciente});
  }

  void saveTypeUser(String typeUser) async {
    _sharedPref!.save('typeUser', typeUser);
  }

}