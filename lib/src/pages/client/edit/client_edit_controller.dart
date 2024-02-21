import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:app_medcab/src/models/client.dart';
import 'package:app_medcab/src/providers/auth_provider.dart';
import 'package:app_medcab/src/providers/client_provider.dart';
import 'package:app_medcab/src/providers/storage_provider.dart';
import 'package:app_medcab/src/utils/my_progress_dialog.dart';
import 'package:app_medcab/src/utils/snackbar.dart' as utils;
import 'package:progress_dialog2/progress_dialog2.dart';

class ClientEditController {

  BuildContext ? context;
  GlobalKey<ScaffoldState> key = GlobalKey<ScaffoldState>();
  Function ? refresh;

  TextEditingController usernameController = TextEditingController();

  AuthProvider ? _authProvider;
  ClientProvider ? _clientProvider;
  ProgressDialog ? _progressDialog;
  StorageProvider ? _storageProvider;

  XFile ? pickedFile;
  File ? imageFile;

  Client ? client;

  Future init (BuildContext context, Function refresh) async {
    this.context = context;
    this.refresh = refresh;
    _authProvider = AuthProvider();
    _clientProvider = ClientProvider();
    _storageProvider = StorageProvider();
    _progressDialog = MyProgressDialog.createProgressDialog(context, 'Espere un momento...');
    getUserInfo();
  }


  void getUserInfo() async {
    client = await _clientProvider!.getById(_authProvider!.getUser()!.uid);
    usernameController.text = client!.username!;
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

  void update() async {
    String username = usernameController.text;

    if (username.isEmpty) {
      utils.Snackbar.showSnackbar(context!, key, 'Debes ingresar todos los campos');
      return;
    }
    _progressDialog!.show();

    if (pickedFile == null) {
      Map<String, dynamic> data = {
        'image': client?.image,
        'username': username,
      };

      await _clientProvider!.update(data, _authProvider!.getUser()!.uid);
      _progressDialog!.hide();
    }
    else {
      TaskSnapshot snapshot = await _storageProvider!.uploadFile(pickedFile!);
      String imageUrl = await snapshot.ref.getDownloadURL();

      Map<String, dynamic> data = {
        'image': imageUrl,
        'username': username,
      };

      await _clientProvider!.update(data, _authProvider!.getUser()!.uid);
    }

    _progressDialog!.hide();

    utils.Snackbar.showSnackbar(context!, key, 'Los datos se actualizaron');

  }

  Future getImageFromGallery(ImageSource imageSource) async {
    // pickedFile = await ImagePicker().pickImage(source: imageSource);
    // pickedFile = await ImagePicker().getImage(source: imageSource);
    if (pickedFile != null) {
      imageFile = File(pickedFile!.path);
    }
    else {
      debugPrint('No selecciono ninguna imagen');
    }
    Navigator.pop(context!);
    refresh!();
  }

}

