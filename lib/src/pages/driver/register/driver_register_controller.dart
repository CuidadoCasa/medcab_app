import 'package:app_medcab/src/providers/variables_provider.dart';
import 'package:flutter/material.dart';
import 'package:app_medcab/src/models/driver.dart';
import 'package:app_medcab/src/providers/auth_provider.dart';
import 'package:app_medcab/src/providers/driver_provider.dart';
import 'package:app_medcab/src/utils/my_progress_dialog.dart';
import 'package:app_medcab/src/utils/snackbar.dart' as utils;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:progress_dialog2/progress_dialog2.dart';
import 'package:provider/provider.dart';

class DriverRegisterController {

  BuildContext ? context;
  GlobalKey<ScaffoldState> key = GlobalKey<ScaffoldState>();

  TextEditingController usernameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  FocusNode focusUserName = FocusNode();
  FocusNode focusEmailName = FocusNode();
  FocusNode focusPass1Name = FocusNode();

  AuthProvider ? _authProvider;
  DriverProvider ? _driverProvider;
  ProgressDialog ? _progressDialog;

  bool autovalidar = false;
  bool verPass = false;

  Future init (BuildContext context) async {
    this.context = context;
    _authProvider = AuthProvider();
    _driverProvider = DriverProvider();
    _progressDialog = MyProgressDialog.createProgressDialog(context, 'Espere un momento...');
  }

  void register() async {
    String username = usernameController.text;
    String email = emailController.text.trim();
    String password = passwordController.text.trim();
    final dataProvider = Provider.of<VariablesProvider>(context!, listen: false);

    String plate = '000-000';

    if (username.isEmpty && email.isEmpty && password.isEmpty) {
      utils.Snackbar.showSnackbar(context!, key, 'Debes ingresar todos los campos');
      return;
    }

    _progressDialog!.show();

    try {

      bool isRegister = await _authProvider!.register(email, password);

      if (isRegister) {

        Driver driver = Driver(
          id: _authProvider!.getUser()!.uid,
          email: _authProvider!.getUser()!.email,
          username: username,
          password: password,
          plate: plate
        );

        await _driverProvider!.create(driver);
        
        bool isUserTest = (email == 'paciente@gmail.com' || email == 'medico@gmail.com');
        dataProvider.isModeTest = isUserTest;

        if(isUserTest){
          Stripe.publishableKey = dotenv.env['STRIPE_PK_TEST']!;
        } else {
          Stripe.publishableKey = dotenv.env['STRIPE_PK']!;
        }

        _progressDialog!.hide();
        Navigator.pushNamedAndRemoveUntil(context!, 'driver/map', (route) => false);
        utils.Snackbar.showSnackbar(context!, key, 'El usuario se registro correctamente');
      }
      else {
        _progressDialog!.hide();
      }

    } catch(error) {
      _progressDialog!.hide();
      utils.Snackbar.showSnackbar(context!, key, 'Error: $error');
    }

  }

}