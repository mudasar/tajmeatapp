
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_grocery/helper/date_converter.dart';
import 'package:flutter_grocery/helper/price_converter.dart';
import 'package:flutter_grocery/helper/responsive_helper.dart';
import 'package:flutter_grocery/localization/language_constrants.dart';
import 'package:flutter_grocery/provider/auth_provider.dart';
import 'package:flutter_grocery/provider/coupon_provider.dart';
import 'package:flutter_grocery/provider/splash_provider.dart';
import 'package:flutter_grocery/utill/dimensions.dart';
import 'package:flutter_grocery/utill/images.dart';
import 'package:flutter_grocery/utill/styles.dart';
import 'package:flutter_grocery/view/base/app_bar_base.dart';
import 'package:flutter_grocery/view/base/custom_loader.dart';
import 'package:flutter_grocery/view/base/custom_snackbar.dart';
import 'package:flutter_grocery/view/base/no_data_screen.dart';
import 'package:flutter_grocery/view/base/not_login_screen.dart';
import 'package:flutter_grocery/view/base/web_app_bar/web_app_bar.dart';
import 'package:provider/provider.dart';

import '../../../utill/color_resources.dart';
import '../../base/footer_view.dart';

class CouponScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double _width = MediaQuery.of(context).size.width;
    final _height = MediaQuery.of(context).size.height;

    final bool _isLoggedIn = Provider.of<AuthProvider>(context, listen: false).isLoggedIn();
    if(_isLoggedIn) {
      Provider.of<CouponProvider>(context, listen: false).getCouponList(context);
    }

    return Scaffold(
      appBar: ResponsiveHelper.isMobilePhone()? null: ResponsiveHelper.isDesktop(context)? PreferredSize(child: WebAppBar(), preferredSize: Size.fromHeight(120)): AppBarBase(),
      body: _isLoggedIn ? Consumer<CouponProvider>(
        builder: (context, coupon, child) {
          return coupon.couponList != null ? coupon.couponList.length > 0 ? RefreshIndicator(
            onRefresh: () async {
              await Provider.of<CouponProvider>(context, listen: false).getCouponList(context);
            },
            backgroundColor: Theme.of(context).primaryColor,
            child: Scrollbar(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(minHeight: !ResponsiveHelper.isDesktop(context) && _height < 600 ? _height : _height - 400),
                        child: Container(
                          padding: _width > 700 ? EdgeInsets.all(Dimensions.PADDING_SIZE_LARGE) : EdgeInsets.zero,
                          child: Container(
                            width: _width > 700 ? 700 : _width,
                            padding: _width > 700 ? EdgeInsets.all(Dimensions.PADDING_SIZE_DEFAULT) : null,
                            decoration: _width > 700 ? BoxDecoration(
                              color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(10),
                              boxShadow: [BoxShadow(color: Colors.grey[300], blurRadius: 5, spreadRadius: 1)],
                            ) : null,
                            child: ListView.builder(
                              itemCount: coupon.couponList.length,
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              padding: EdgeInsets.all(Dimensions.PADDING_SIZE_LARGE),
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: EdgeInsets.only(bottom: Dimensions.PADDING_SIZE_LARGE),
                                  child: InkWell(
                                    onTap: () {
                                      Clipboard.setData(ClipboardData(text: coupon.couponList[index].code));
                                      showCustomSnackBar(getTranslated('coupon_code_copied', context), context, isError:  false);
                                    },
                                    child: Stack(children: [

                                      Image.asset(Images.coupon_bg, height: 100, width: 1170, fit: BoxFit.fitWidth, color: Theme.of(context).primaryColor),

                                      Container(
                                        height: 100,
                                        alignment: Alignment.center,
                                        child: Row(children: [

                                          SizedBox(width: 50),
                                          Image.asset(Images.percentage, height: 50, width: 50),

                                          Padding(
                                            padding: EdgeInsets.symmetric(horizontal: Dimensions.PADDING_SIZE_LARGE, vertical: Dimensions.PADDING_SIZE_SMALL),
                                            child: Image.asset(Images.line, height: 100, width: 5),
                                          ),

                                          Expanded(
                                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                                              SelectableText(
                                                coupon.couponList[index].code,
                                                style: poppinsRegular.copyWith(color: Colors.white),
                                              ),
                                              SizedBox(height: Dimensions.PADDING_SIZE_EXTRA_SMALL),
                                              Text(
                                                coupon.couponList[index].couponType == 'free_delivery' ? '${getTranslated('free_delivery', context)}' :
                                                    '${coupon.couponList[index].discount}${coupon.couponList[index].discountType == 'percent' ? '%'
                                                    : Provider.of<SplashProvider>(context, listen: false).configModel.currencySymbol} off',
                                                style: poppinsMedium.copyWith(color: Colors.white, fontSize: Dimensions.FONT_SIZE_EXTRA_LARGE),
                                              ),
                                              SizedBox(height: Dimensions.PADDING_SIZE_EXTRA_SMALL),
                                              Text(
                                                '${getTranslated('valid_until', context)} ${DateConverter.isoStringToLocalDateOnly(coupon.couponList[index].expireDate)}',
                                                style: poppinsRegular.copyWith(color: Colors.white, fontSize: Dimensions.FONT_SIZE_SMALL),
                                              ),
                                            ]),
                                          ),

                                        ]),
                                      ),

                                    ]),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                    if(ResponsiveHelper.isDesktop(context))  FooterView()
                  ],
                ),
              ),
            ),
          ) : NoDataScreen() : Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor)));
        },
      ) : NotLoggedInScreen(),
    );
  }
}
