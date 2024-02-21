import 'dart:io';

import 'package:app_medcab/src/utils/my_progress_dialog.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
// import 'package:progress_dialog/progress_dialog.dart';
// import 'package:app_medcab/src/models/client.dart';
import 'package:app_medcab/src/models/driver.dart';
import 'package:app_medcab/src/providers/auth_provider.dart';
// import 'package:app_medcab/src/providers/client_provider.dart';
import 'package:app_medcab/src/providers/driver_provider.dart';
// import 'package:app_medcab/src/utils/my_progress_dialog.dart';
import 'package:app_medcab/src/utils/snackbar.dart' as utils;
import 'package:progress_dialog2/progress_dialog2.dart';


class DriverEditController {

  BuildContext ? context;
  GlobalKey<ScaffoldState> key = GlobalKey<ScaffoldState>();

  TextEditingController usernameController = TextEditingController();

  TextEditingController pin1Controller = TextEditingController();
  TextEditingController pin2Controller = TextEditingController();
  TextEditingController pin3Controller = TextEditingController();
  TextEditingController pin4Controller = TextEditingController();
  TextEditingController pin5Controller = TextEditingController();
  TextEditingController pin6Controller = TextEditingController();

  AuthProvider ? _authProvider;
  DriverProvider ? _driverProvider;
  ProgressDialog ? _progressDialog;

  PickedFile ? pickedFile;
  File ? imageFile;

  Driver ? driver;

  Function ? refresh;

  Future init (BuildContext context, Function refresh) async {
    this.context = context;
    this.refresh = refresh;
    _authProvider = AuthProvider();
    _driverProvider = DriverProvider();
    _progressDialog = MyProgressDialog.createProgressDialog(context, 'Espere un momento...');
    getUserInfo();
  }

  void getUserInfo() async {
    driver = await _driverProvider!.getById(_authProvider!.getUser()!.uid);
    usernameController.text = driver!.username!;

    pin1Controller.text = driver!.plate![0];
    pin2Controller.text = driver!.plate![1];
    pin3Controller.text = driver!.plate![2];
    pin4Controller.text = driver!.plate![4];
    pin5Controller.text = driver!.plate![5];
    pin6Controller.text = driver!.plate![6];

    refresh!();
  }

  void showAlertDialog() {

    Widget galleryButton = ElevatedButton(
        onPressed: () {
          getImageFromGallery(ImageSource.gallery);
        },
        child: const Text('GALERIA')
    );

    Widget cameraButton = ElevatedButton(
        onPressed: () {
          getImageFromGallery(ImageSource.camera);
        },
        child: const Text('CAMARA')
    );

    AlertDialog alertDialog = AlertDialog(
      title: const Text('Selecciona tu imagen'),
      actions: [
        galleryButton,
        cameraButton
      ],
    );

    showDialog(
        context: context!,
        builder: (BuildContext context) {
          return alertDialog;
        }
    );

  }

  Future getImageFromGallery(ImageSource imageSource) async {
    // pickedFile = await ImagePicker().getImage(source: imageSource);
    // if (pickedFile != null) {
    //   imageFile = File(pickedFile.path);
    // }
    // else {
    //   print('No selecciono ninguna imagen');
    // }
    // Navigator.pop(context);
    // refresh();
  }

  void update() async {
    String username = usernameController.text;

    String pin1 = pin1Controller.text.trim();
    String pin2 = pin2Controller.text.trim();
    String pin3 = pin3Controller.text.trim();
    String pin4 = pin4Controller.text.trim();
    String pin5 = pin5Controller.text.trim();
    String pin6 = pin6Controller.text.trim();

    String plate = '$pin1$pin2$pin3-$pin4$pin5$pin6';


    if (username.isEmpty) {
      utils.Snackbar.showSnackbar(context!, key, 'Debes ingresar todos los campos');
      return;
    }
    _progressDialog!.show();

    if (pickedFile == null) {
      Map<String, dynamic> data = {
        'image': driver?.image,
        'username': username,
        'plate': plate,
      };

      await _driverProvider!.update(data, _authProvider!.getUser()!.uid);
      _progressDialog!.hide();
    }
    else {
      // TaskSnapshot snapshot = await _storageProvider!.uploadFile(pickedFile!);
      // String imageUrl = await snapshot.ref.getDownloadURL();

      // Map<String, dynamic> data = {
      //   'image': imageUrl,
      //   'username': username,
      //   'plate': plate,
      // };

      // await _driverProvider!.update(data, _authProvider!.getUser()!.uid);
    }

    _progressDialog!.hide();

    utils.Snackbar.showSnackbar(context!, key, 'Los datos se actualizaron');

  }

}