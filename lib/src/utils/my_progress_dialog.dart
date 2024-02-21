import 'package:app_medcab/src/shared/colors.dart';
import 'package:flutter/material.dart';
import 'package:progress_dialog2/progress_dialog2.dart';

final _paletaColors = PaletaColors();

class MyProgressDialog {

  static ProgressDialog createProgressDialog(BuildContext context, String text) {

    ProgressDialog progressDialog = ProgressDialog(
      context,
      type: ProgressDialogType.Normal,
      isDismissible: false,
      showLogs: false
    );

    progressDialog.style(
      padding: const EdgeInsets.only(top: 20, bottom: 20, left: 15),
      message: text,
      borderRadius: 10.0,
      backgroundColor: Colors.white,
      progressWidget: CircularProgressIndicator(
        color: _paletaColors.mainB,
      ),
      elevation: 10.0,
      insetAnimCurve: Curves.easeInOut,
      progress: 0.0,
      maxProgress: 100.0,
      progressTextStyle: const TextStyle(
        color: Colors.black, 
        fontSize: 12.0, 
        fontWeight: FontWeight.w400
      ),
      messageTextStyle: const TextStyle(
        color: Colors.black, 
        fontSize: 17.0, 
        fontWeight: FontWeight.w600
      )
    );

    return progressDialog;
  }

}