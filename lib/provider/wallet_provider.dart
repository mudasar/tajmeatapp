import 'package:flutter/material.dart';
import 'package:flutter_grocery/data/model/response/base/api_response.dart';
import 'package:flutter_grocery/data/model/response/wallet_model.dart';
import 'package:flutter_grocery/data/repository/wallet_repo.dart';
import 'package:flutter_grocery/helper/api_checker.dart';
import 'package:flutter_grocery/localization/language_constrants.dart';
import 'package:flutter_grocery/main.dart';
import 'package:flutter_grocery/utill/images.dart';
import 'package:flutter_grocery/view/screens/wallet/wallet_screen.dart';
import 'package:provider/provider.dart';

import 'profile_provider.dart';

List<TabButtonModel> tabButtonList =  [
  TabButtonModel(getTranslated('convert_to_money', Get.context), Images.wallet, (){}),
  TabButtonModel(getTranslated('earning', Get.context), Images.earning_image, (){}),
  TabButtonModel(getTranslated('converted', Get.context), Images.converted_image, (){}),
];

class WalletProvider with ChangeNotifier {
  final WalletRepo walletRepo;
  WalletProvider({@required this.walletRepo});

  List<Transaction> _transactionList;
  List<String> _offsetList = [];
  int _offset = 1;
  int _pageSize;
  bool _isLoading = false;

  List<Transaction> get transactionList => _transactionList;
  int get popularPageSize => _pageSize;
  bool get isLoading => _isLoading;
  int get offset => _offset;
  bool _paginationLoader = false;
  bool get paginationLoader => _paginationLoader;

  void updatePagination(bool value){
    _paginationLoader = value;
    notifyListeners();
  }


  int selectedTabButtonIndex;

  set setOffset(int offset) {
    _offset = offset;
  }


  Future<void> getLoyaltyTransactionList(String offset, bool reload, bool fromWallet, {bool isEarning = false}) async {

    if(offset == '1' || reload) {
      _offsetList = [];
      _offset = 1;
      _transactionList = null;
      if(reload) {
        notifyListeners();
      }

    }
    if (!_offsetList.contains(offset)) {
      _offsetList.add(offset);
      ApiResponse apiResponse;
      if(fromWallet){
        apiResponse = await walletRepo.getWalletTransactionList(offset);
      }else{
        apiResponse = await walletRepo.getLoyaltyTransactionList(offset, isEarning ? 'earning' : 'converted');
      }



      if (apiResponse.response != null && apiResponse.response.statusCode == 200) {
        if (offset == '1') {
          _transactionList = [];
        }
        _transactionList.addAll(WalletModel.fromJson(apiResponse.response.data).data);
        _pageSize = WalletModel.fromJson(apiResponse.response.data).totalSize;

        _isLoading = false;
        _paginationLoader = false;
        notifyListeners();
      } else {
        ApiChecker.checkApi(apiResponse);
      }
    } else {
      if(isLoading) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  Future<bool> pointToWallet(int point, bool fromWallet) async {
    bool _isSuccess = false;
    _isLoading = true;
    notifyListeners();
    ApiResponse apiResponse = await walletRepo.pointToWallet(point: point);
    if (apiResponse.response != null && apiResponse.response.statusCode == 200) {
      _isSuccess = true;
      Provider.of<ProfileProvider>(Get.context, listen: false).getUserInfo(Get.context);
    } else {
      ApiChecker.checkApi(apiResponse);
    }
    _isLoading = false;
    notifyListeners();
    return _isSuccess;
  }

  void setCurrentTabButton(int index, {bool isUpdate = true}){
    selectedTabButtonIndex = index;
    if(isUpdate) {
      if(index != 0) {
        getLoyaltyTransactionList('1', true, false, isEarning: index == 1);
      }
      notifyListeners();
    }
  }

}

