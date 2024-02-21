import 'package:flutter/material.dart';
import 'package:app_medcab/src/models/client.dart';
import 'package:app_medcab/src/providers/auth_provider.dart';
import 'package:app_medcab/src/providers/client_provider.dart';
import 'package:app_medcab/src/utils/my_progress_dialog.dart';
import 'package:app_medcab/src/utils/snackbar.dart' as utils;
import 'package:progress_dialog2/progress_dialog2.dart';

class ClientRegisterController {

  BuildContext ? context;
  GlobalKey<ScaffoldState> key = GlobalKey<ScaffoldState>();

  TextEditingController usernameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  FocusNode focusUserName = FocusNode();
  FocusNode focusEmailName = FocusNode();
  FocusNode focusPass1Name = FocusNode();

  AuthProvider ? _authProvider;
  ClientProvider ? _clientProvider;
  ProgressDialog ? _progressDialog;

  bool autovalidar = false;
  bool verPass = false;

  Future init (BuildContext context) async {
    this.context = context;
    _authProvider = AuthProvider();
    _clientProvider = ClientProvider();
    _progressDialog = MyProgressDialog.createProgressDialog(context, 'Espere un momento...');
  }

  void register() async {
    String username = usernameController.text;
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if (username.isEmpty && email.isEmpty && password.isEmpty) {
      utils.Snackbar.showSnackbar(context!, key, 'Debes ingresar todos los campos');
      return;
    }

    _progressDialog!.show();

    try {

      bool isRegister = await _authProvider!.register(email, password);

      if (isRegister) {

        Client client = Client(
          id: _authProvider!.getUser()!.uid,
          email: _authProvider!.getUser()!.email!,
          username: username,
          password: password,
        );

        await _clientProvider!.create(client);

        _progressDialog!.hide();
        Navigator.pushNamedAndRemoveUntil(context!, 'client/map', (route) => false);

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