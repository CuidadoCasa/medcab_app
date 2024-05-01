import 'package:app_medcab/src/providers/variables_provider.dart';
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
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:progress_dialog2/progress_dialog2.dart';
import 'package:provider/provider.dart';


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
    final dataProvider = Provider.of<VariablesProvider>(context!, listen: false);

    _progressDialog!.show();

    try {

      bool isLogin = await _authProvider!.login(email, password);

      if (isLogin) {

        if (_typeUser == 'client') {
          Client ? client = await _clientProvider!.getById(_authProvider!.getUser()!.uid);

          if (client != null) {
            bool isUserTest = (email == 'paciente@gmail.com' || email == 'medico@gmail.com');
            dataProvider.isModeTest = isUserTest;

            if(isUserTest){
              Stripe.publishableKey = dotenv.env['STRIPE_PK_TEST']!;
            } else {
              Stripe.publishableKey = dotenv.env['STRIPE_PK']!;
            }
            
            await _progressDialog!.hide();
            Navigator.pushNamedAndRemoveUntil(context!, 'client/map', (route) => false);
          }
          else {
            await _progressDialog!.hide();
            utils.Snackbar.showSnackbar(context!, key, 'El usuario no es válido');
            await _authProvider!.signOut();
          }

        }
        else if (_typeUser == 'driver') {
          Driver ? driver = await _driverProvider!.getById(_authProvider!.getUser()!.uid);

          if (driver != null) {
            await _progressDialog!.hide();
            Navigator.pushNamedAndRemoveUntil(context!, 'driver/map', (route) => false);
          }
          else {
            await _progressDialog!.hide();
            utils.Snackbar.showSnackbar(context!, key, 'El usuario no es válido');
            await _authProvider!.signOut();
          }

        }

      }
      else {
        await _progressDialog!.hide();
        utils.Snackbar.showSnackbar(context!, key, 'El usuario no se pudo autenticar');
      }

    } catch(error) {
      await _progressDialog!.hide();
      utils.Snackbar.showSnackbar(context!, key, 'Verifique el correo y contraseña.');
      _progressDialog!.hide();
    }

  }

}