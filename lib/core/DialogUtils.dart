import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pharmago/core/resources/ColorManger.dart';

class DialogUtils {
  static showMassageDialog({
    required BuildContext context,
    required String massage,
    required String posTitle,
    required void Function() posClick,
    String? neqTitle,
    void Function()? negClick,
  }) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(massage),
            actions: [
              ElevatedButton(onPressed: posClick, child: Text(posTitle)),
              Visibility(
                  visible: neqTitle!=null,
                  child: ElevatedButton(onPressed: negClick, child: Text(neqTitle??''))),
            ],
          ),
    );
  }
  static showLoading(BuildContext context){
    showDialog(context: context, builder: (context)=>AlertDialog(
      title: Center(child: CircularProgressIndicator(),),
    ));
  }
  static showSnackBar(String massage){
    Fluttertoast.showToast(
        msg: massage,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.grey,
        textColor: ColorManger.black,
        fontSize: 16.0
    );
  }
}
