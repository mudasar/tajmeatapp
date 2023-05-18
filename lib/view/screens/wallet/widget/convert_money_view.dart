import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_grocery/helper/price_converter.dart';
import 'package:flutter_grocery/helper/responsive_helper.dart';
import 'package:flutter_grocery/utill/dimensions.dart';
import 'package:flutter_grocery/localization/language_constrants.dart';
import 'package:flutter_grocery/provider/splash_provider.dart';
import 'package:flutter_grocery/provider/wallet_provider.dart';
import 'package:flutter_grocery/utill/dimensions.dart';
import 'package:flutter_grocery/utill/images.dart';
import 'package:flutter_grocery/utill/styles.dart';
import 'package:flutter_grocery/view/base/custom_button.dart';
import 'package:flutter_grocery/view/base/custom_dialog.dart';
import 'package:flutter_grocery/view/base/custom_loader.dart';
import 'package:flutter_grocery/view/base/custom_snackbar.dart';
import 'package:provider/provider.dart';

class ConvertMoneyView extends StatefulWidget {
  const ConvertMoneyView({Key key}) : super(key: key);

  @override
  State<ConvertMoneyView> createState() => _ConvertMoneyViewState();
}

class _ConvertMoneyViewState extends State<ConvertMoneyView> {
  final TextEditingController _pointController = TextEditingController();


  @override
  void initState() {

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final _size = MediaQuery.of(context).size;
    
    final List<String>  _noteList = [
      getTranslated('only_earning_point_can_converted', context),

      '${Provider.of<SplashProvider>(context, listen: false).configModel.loyaltyPointExchangeRate
      } ${getTranslated('point', context)} ${getTranslated('remain', context)} ${PriceConverter.convertPrice(context, 1)}',
      getTranslated('once_you_convert_the_point', context),
      getTranslated('point_can_use_for_get_bonus_money', context),

    ];
    final _configModel = Provider.of<SplashProvider>(context, listen: false).configModel;
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: Dimensions.PADDING_SIZE_LARGE,
          vertical: Dimensions.PADDING_SIZE_SMALL,
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start,children: [
          SizedBox(height: Dimensions.PADDING_SIZE_DEFAULT,),
          Text(
            getTranslated('enters_point_amount', context),
            style: poppinsMedium.copyWith(
              fontSize: Dimensions.FONT_SIZE_DEFAULT,
            ),
          ),
          SizedBox(height: Dimensions.PADDING_SIZE_DEFAULT,),

          Container(
            padding: EdgeInsets.symmetric(vertical: Dimensions.PADDING_SIZE_LARGE).copyWith(bottom: Dimensions.PADDING_SIZE_LARGE),
            width: Dimensions.WEB_SCREEN_WIDTH,
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(5),
              boxShadow: [BoxShadow(
                color: Theme.of(context).textTheme.bodyLarge.color.withOpacity(0.1),
                offset: Offset(-1, 1),
                blurRadius: 10,
                spreadRadius: -3,
              )]
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [

                Text(getTranslated('convert_point_to_wallet_money', context),style: poppinsBold.copyWith(
                  fontSize: Dimensions.FONT_SIZE_DEFAULT, color: Theme.of(context).primaryColor,
                )),

                Container( width: MediaQuery.of(context).size.width * 0.6,
                  padding: const EdgeInsets.symmetric(vertical: Dimensions.PADDING_SIZE_LARGE),
                  child: TextField(
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                      FilteringTextInputFormatter.digitsOnly

                    ],
                    controller: _pointController,
                    textAlignVertical: TextAlignVertical.center,
                    textAlign: TextAlign.center,
                    style: poppinsMedium.copyWith(fontSize: Dimensions.FONT_SIZE_MAX_LARGE),
                    decoration: InputDecoration(
                      isCollapsed : true,
                      hintText:'ex: 300',
                      border : InputBorder.none, focusedBorder: UnderlineInputBorder(),
                      hintStyle: poppinsMedium.copyWith(
                        fontSize: Dimensions.FONT_SIZE_EXTRA_LARGE, color: Theme.of(context).hintColor.withOpacity(0.4),
                      ),

                    ),

                  ),
                ),


              ],
            ),
          ),
          SizedBox(height: Dimensions.PADDING_SIZE_DEFAULT,),
          
          Container(
            padding: EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('${getTranslated('note', context)}:', style: poppinsRegular.copyWith(fontSize: Dimensions.FONT_SIZE_DEFAULT),),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(children: _noteList.map((note) => Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Icon(Icons.circle,  size: 6, color: Theme.of(context).textTheme.bodyLarge.color.withOpacity(0.5)),
                  ),
                  SizedBox(width: Dimensions.PADDING_SIZE_SMALL,),

                  Flexible(
                    child: Text(note, style: poppinsRegular.copyWith(
                      color: Theme.of(context).textTheme.bodyLarge.color.withOpacity(0.5),
                      fontSize: Dimensions.FONT_SIZE_DEFAULT,
                    ), maxLines: 3, overflow: TextOverflow.ellipsis),
                  ),
                ],)).toList()),
              )
            ]),
            
          ),
          SizedBox(height: Dimensions.PADDING_SIZE_DEFAULT,),




          Consumer<WalletProvider>(
            builder: (context, walletProvider, _) {
              return walletProvider.isLoading ? Center(child: CustomLoader(color: Theme.of(context).primaryColor)) : CustomButton(
                borderRadius: 30,
                buttonText: getTranslated('convert_point', context), onPressed: (){
                if(_pointController.text.isEmpty) {
                  showCustomSnackBar(getTranslated('please_enter_your_point', context), context);
                }else{
                  int _point = int.parse(_pointController.text.trim());

                  if(_point < _configModel.loyaltyPointMinimumPoint){
                    showCustomSnackBar(getTranslated('please_exchange_more_then', context) + ' ${_configModel.loyaltyPointMinimumPoint} ' + getTranslated('points', context), context);
                  } else {

                    walletProvider.pointToWallet(_point, false).then((isSuccess) => openDialog(Stack(
                      children: [
                        Container(
                          padding: EdgeInsets.all(Dimensions.PADDING_SIZE_DEFAULT),
                          width: ResponsiveHelper.isDesktop(context) ? 600 : _size.width * 0.9,
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.all(Radius.circular(Dimensions.RADIUS_SIZE_DEFAULT)),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Image.asset(Images.converted_image, color: Theme.of(context).primaryColor),
                              SizedBox(height: Dimensions.PADDING_SIZE_DEFAULT,),

                              Text(getTranslated('loyalty_point_converted_to', context), style: poppinsMedium),
                              Text(
                                getTranslated(isSuccess ?  'successfully' : 'failed', context),
                                style: poppinsMedium.copyWith(color:isSuccess ?  Theme.of(context).primaryColor : Theme.of(context).colorScheme.error),
                              ),
                              SizedBox(height: Dimensions.PADDING_SIZE_DEFAULT,),

                              TextButton(
                                onPressed: () {
                                  if(isSuccess) {
                                    walletProvider.setCurrentTabButton(2);
                                  }
                                  Navigator.of(context).pop();
                                },
                                child: Text(getTranslated(isSuccess ? 'check_history' : 'go_back', context), style: poppinsRegular.copyWith(
                                  decoration: TextDecoration.underline,
                                  color: isSuccess ?  Theme.of(context).primaryColor : Theme.of(context).colorScheme.error,
                                )),
                              ),

                            ],
                          ),
                        ),

                        Positioned.fill(child: Align(alignment: Alignment.topRight,child: InkWell(
                          onTap: (){
                            _pointController.clear();
                            Navigator.of(context).pop();
                            },
                          child: Icon(Icons.cancel_rounded, color: Theme.of(context).primaryColor.withOpacity(0.7)),
                        )))
                      ],
                    ), isDismissible: false, willPop: false),
                    );
                  }
                }

              },
              );
            }
          ),
        ],),
      ),
    );
  }
}
