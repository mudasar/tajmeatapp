import 'package:flutter/material.dart';
import 'package:flutter_grocery/data/model/response/base/api_response.dart';
import 'package:flutter_grocery/data/model/response/config_model.dart';
import 'package:flutter_grocery/data/repository/splash_repo.dart';
import 'package:flutter_grocery/provider/auth_provider.dart';
import 'package:flutter_grocery/utill/app_constants.dart';
import 'package:flutter_grocery/view/base/custom_snackbar.dart';
import 'package:provider/provider.dart';

class SplashProvider extends ChangeNotifier {
  final SplashRepo splashRepo;
  SplashProvider({@required this.splashRepo});

  ConfigModel _configModel;
  BaseUrls _baseUrls;
  int _pageIndex = 0;
  bool _fromSetting = false;
  bool _firstTimeConnectionCheck = true;
  bool _cookiesShow = true;


  ConfigModel get configModel => _configModel;
  BaseUrls get baseUrls => _baseUrls;
  int get pageIndex => _pageIndex;
  bool get fromSetting => _fromSetting;
  bool get firstTimeConnectionCheck => _firstTimeConnectionCheck;
  bool get cookiesShow => _cookiesShow;


  Future<bool> initConfig(BuildContext context) async {
    ApiResponse apiResponse = await splashRepo.getConfig();
    bool isSuccess;
    if (apiResponse.response != null && apiResponse.response.statusCode == 200) {
      _configModel = ConfigModel.fromJson(apiResponse.response.data);
      _baseUrls = ConfigModel.fromJson(apiResponse.response.data).baseUrls;
      isSuccess = true;

      if(!Provider.of<AuthProvider>(context, listen: false).isLoggedIn()){
       await Provider.of<AuthProvider>(context, listen: false).updateFirebaseToken();
      }

      notifyListeners();
    } else {
      isSuccess = false;
      print(apiResponse.error);
      showCustomSnackBar(apiResponse.error.toString(), context,isError: true);
      }
    return isSuccess;
  }


  void setFirstTimeConnectionCheck(bool isChecked) {
    _firstTimeConnectionCheck = isChecked;
  }

  void setPageIndex(int index) {
    _pageIndex = index;
    notifyListeners();
  }

  Future<bool> initSharedData() {
    return splashRepo.initSharedData();
  }

  Future<bool> removeSharedData() {
    return splashRepo.removeSharedData();
  }

  void setFromSetting(bool isSetting) {
    _fromSetting = isSetting;
  }
  String getLanguageCode(){
    return splashRepo.sharedPreferences.getString(AppConstants.LANGUAGE_CODE);
  }

  bool showIntro() {
    return splashRepo.showIntro()??true;
  }

  void disableIntro() {
    splashRepo.disableIntro();
  }

  void cookiesStatusChange(String data) {
    if(data != null){
      splashRepo.sharedPreferences.setString(AppConstants.COOKIES_MANAGEMENT, data);
    }
    _cookiesShow = false;
    notifyListeners();
  }

  bool getAcceptCookiesStatus(String data) => splashRepo.sharedPreferences.getString(AppConstants.COOKIES_MANAGEMENT) != null
      && splashRepo.sharedPreferences.getString(AppConstants.COOKIES_MANAGEMENT) == data;


}