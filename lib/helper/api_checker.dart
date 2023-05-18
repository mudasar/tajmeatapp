import 'package:flutter/material.dart';
import 'package:flutter_grocery/data/model/response/base/api_response.dart';
import 'package:flutter_grocery/data/model/response/base/error_response.dart';
import 'package:flutter_grocery/helper/route_helper.dart';
import 'package:flutter_grocery/main.dart';
import 'package:flutter_grocery/provider/splash_provider.dart';
import 'package:flutter_grocery/view/base/custom_snackbar.dart';
import 'package:flutter_grocery/view/screens/auth/login_screen.dart';
import 'package:provider/provider.dart';

class ApiChecker {
  static void checkApi(ApiResponse apiResponse) {
    String _message = ErrorResponse.fromJson(apiResponse.error).errors[0].message;
    if(_message == 'Unauthorized.' ||  _message == 'Unauthenticated.'
        && ModalRoute.of(Get.context).settings.name != RouteHelper.getLoginRoute()) {
      Provider.of<SplashProvider>(Get.context, listen: false).removeSharedData();
      Navigator.pushAndRemoveUntil(Get.context, MaterialPageRoute(builder: (_) => LoginScreen()), (route) => false);
    }
    else {
      String _errorMessage;
      if (apiResponse.error is String) {
        _errorMessage = apiResponse.error.toString();
      } else {
        _errorMessage = apiResponse.error.errors[0].message;
      }
      print(_errorMessage);
      showCustomSnackBar(_errorMessage, Get.context,isError: true);
       }
  }
}