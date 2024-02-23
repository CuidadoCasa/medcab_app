import 'package:flutter/material.dart';
// import 'package:progress_dialog/progress_dialog.dart';
import 'package:app_medcab/src/models/client.dart';
import 'package:app_medcab/src/models/driver.dart';
import 'package:app_medcab/src/providers/auth_provider.dart';
import 'package:app_medcab/src/providers/client_provider.dart';
import 'package:app_medcab/src/providers/driver_provider.dart';
import 'package:app_medcab/src/utils/my_progress_dialog.dart';
import 'package:app_medcab/src/utils/shared_pref.dart';
import 'package:app_medcab/src/utils/snackbar.dart' as utils;
import 'package:progress_dialog2/progress_dialog2.dart';


class LoginController {

  BuildContext ? context;
  GlobalKey<ScaffoldState> key = GlobalKey<ScaffoldState>();

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  FocusNode focusEmail = FocusNode();
  FocusNode focusContr = FocusNode();

  AuthProvider ? _authProvider;
  ProgressDialog ? _progressDialog;
  DriverProvider ? _driverProvider;
  ClientProvider ? _clientProvider;

  SharedPref ? _sharedPref;
  String ? _typeUser;

  bool verPass = false;
  bool isPaciente = false;
  bool autovalidar = false;

  Function ? refresh;

  Future init (BuildContext context, Function refresh) async {
    this.context = context;
    this.refresh = refresh;

    _authProvider = AuthProvider();
    _driverProvider = DriverProvider();
    _clientProvider = ClientProvider();
    _progressDialog = MyProgressDialog.createProgressDialog(context, 'Cargando...');
    _sharedPref = SharedPref();
    _typeUser = await _sharedPref!.read('typeUser');
    _checkUserType();
  }

  void _checkUserType(){
    bool check = false;
    check = (ModalRoute.of(context!)!.settings.arguments as Map<String,dynamic>)['isPaciente'];
    isPaciente = check;
    refresh!();
  }

  void goToRegisterPage() {

    if (_typeUser == 'client') {
      Navigator.pushNamed(context!, 'client/register');
    } else {
      Navigator.pushNamed(context!, 'driver/register');
    }


  }

  void login() async {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    _progressDialog!.show();

    try {

      bool isLogin = await _authProvider!.login(email, password);
      _progressDialog!.hide();

      if (isLogin) {

        if (_typeUser == 'client') {
          Client ? client = await _clientProvider!.getById(_authProvider!.getUser()!.uid);

          if (client != null) {
            Navigator.pushNamedAndRemoveUntil(context!, 'client/map', (route) => false);
          }
          else {
            utils.Snackbar.showSnackbar(context!, key, 'El usuario no es válido');
            await _authProvider!.signOut();
          }

        }
        else if (_typeUser == 'driver') {
          Driver ? driver = await _driverProvider!.getById(_authProvider!.getUser()!.uid);

          if (driver != null) {
            Navigator.pushNamedAndRemoveUntil(context!, 'driver/map', (route) => false);
          }
          else {
            utils.Snackbar.showSnackbar(context!, key, 'El usuario no es válido');
            await _authProvider!.signOut();
          }

        }

      }
      else {
        utils.Snackbar.showSnackbar(context!, key, 'El usuario no se pudo autenticar');
      }

    } catch(error) {
      utils.Snackbar.showSnackbar(context!, key, 'Verifique el correo y contraseña.');
      _progressDialog!.hide();
    }

  }

}