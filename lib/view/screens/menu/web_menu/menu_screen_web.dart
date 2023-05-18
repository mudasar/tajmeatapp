
import 'package:flutter/material.dart';
import 'package:flutter_grocery/helper/responsive_helper.dart';
import 'package:flutter_grocery/helper/route_helper.dart';
import 'package:flutter_grocery/localization/language_constrants.dart';
import 'package:flutter_grocery/provider/auth_provider.dart';
import 'package:flutter_grocery/provider/profile_provider.dart';
import 'package:flutter_grocery/provider/splash_provider.dart';
import 'package:flutter_grocery/utill/color_resources.dart';
import 'package:flutter_grocery/utill/dimensions.dart';
import 'package:flutter_grocery/utill/images.dart';
import 'package:flutter_grocery/utill/styles.dart';
import 'package:flutter_grocery/view/base/footer_view.dart';
import 'package:flutter_grocery/view/screens/menu/widget/sign_out_confirmation_dialog.dart';
import 'package:flutter_grocery/view/screens/notification/notification_screen.dart';
import 'package:provider/provider.dart';

import '../../../base/custom_dialog.dart';
import '../widget/acount_delete_dialog.dart';
import 'menu_item_web.dart';

class MenuScreenWeb extends StatelessWidget {
  final bool isLoggedIn;
  const MenuScreenWeb({Key key, @required this.isLoggedIn}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _isLoggedIn = Provider.of<AuthProvider>(context, listen: false).isLoggedIn();
    final _splashProvider =  Provider.of<SplashProvider>(context, listen: false);
    final _profileProvider =  Provider.of<ProfileProvider>(context, listen: false);


    final List<MenuModel> _menuList = [
      MenuModel(icon: Images.order_list, title: getTranslated('my_order', context), route:  RouteHelper.myOrder),
      MenuModel(icon: Images.profile, title: getTranslated('profile', context), route: _isLoggedIn
          ? null : RouteHelper.getLoginRoute()),
      MenuModel(icon: Images.location, title: getTranslated('address', context), route: RouteHelper.address),
      MenuModel(icon: Images.chat, title: getTranslated('live_chat', context), route: RouteHelper.getChatRoute(orderModel: null)),
      MenuModel(icon: Images.coupon, title: getTranslated('coupon', context), route: RouteHelper.coupon),
      MenuModel(icon: Images.notification, title: getTranslated('notification', context), route: RouteHelper.notification),

      if(_splashProvider.configModel.walletStatus)
        MenuModel(icon: Images.wallet, title: getTranslated('wallet', context), route: RouteHelper.getWalletRoute(true)),
      if(_splashProvider.configModel.loyaltyPointStatus)
        MenuModel(icon: Images.loyalty_icon, title: getTranslated('loyalty_point', context), route: RouteHelper.getWalletRoute(false)),

      MenuModel(icon: Images.language, title: getTranslated('contact_us', context), route: RouteHelper.getContactRoute()),
      MenuModel(icon: Images.privacy_policy, title: getTranslated('privacy_policy', context), route: RouteHelper.getPolicyRoute()),
      MenuModel(icon: Images.terms_and_conditions, title: getTranslated('terms_and_condition', context), route: RouteHelper.getTermsRoute()),

      if(_splashProvider.configModel.returnPolicyStatus)
      MenuModel(icon: Images.return_policy, title: getTranslated('return_policy', context), route: RouteHelper.getReturnPolicyRoute()),

      if(_splashProvider.configModel.refundPolicyStatus)
      MenuModel(icon: Images.refund_policy, title: getTranslated('refund_policy', context), route: RouteHelper.getRefundPolicyRoute()),

      if(_splashProvider.configModel.cancellationPolicyStatus)
      MenuModel(icon: Images.cancellation_policy, title: getTranslated('cancellation_policy', context), route: RouteHelper.getCancellationPolicyRoute()),

      MenuModel(icon: Images.about_us, title: getTranslated('about_us', context), route: RouteHelper.getAboutUsRoute()),

      MenuModel(icon: Images.login, title: getTranslated(_isLoggedIn ? 'log_out' : 'login', context), route: 'auth'),

    ];


    return SingleChildScrollView(child: Column(children: [
      Center(child: Consumer<ProfileProvider>(builder: (context, profileProvider, child) {

        if(_splashProvider.configModel.referEarnStatus
            && profileProvider.userInfoModel != null
            && _profileProvider.userInfoModel.referCode != null) {
         final MenuModel _referMenu = MenuModel(
            icon: Images.referral_icon,
            title: getTranslated('refer_and_earn', context),
            route: RouteHelper.getReferAndEarnRoute(),
          );
         _menuList.removeWhere((menu) => menu.route == _referMenu.route);
         _menuList.insert(6, _referMenu);

          if(!_menuList.contains(_referMenu)){

          }
        }

        return ConstrainedBox(
          constraints: BoxConstraints(minHeight: ResponsiveHelper.isDesktop(context)
              ? MediaQuery.of(context).size.height - 400 : MediaQuery.of(context).size.height),
          child: SizedBox(width: 1170, child: Stack(children: [
            Column(children: [
              Container(
                height: 150,  color:  Theme.of(context).primaryColor.withOpacity(0.5),
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.symmetric(horizontal: 240.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    isLoggedIn ? profileProvider.userInfoModel != null ? Text(
                      '${profileProvider.userInfoModel.fName ?? ''} ${profileProvider.userInfoModel.lName ?? ''}',
                      style: poppinsRegular.copyWith(fontSize: Dimensions.FONT_SIZE_EXTRA_LARGE, color: ColorResources.getTextColor(context)),
                    ) : SizedBox(height: Dimensions.PADDING_SIZE_DEFAULT, width: 150) : Text(
                      getTranslated('guest', context),
                      style: poppinsRegular.copyWith(fontSize: Dimensions.FONT_SIZE_EXTRA_LARGE, color: ColorResources.getTextColor(context)),
                    ),
                    SizedBox(height: Dimensions.PADDING_SIZE_SMALL),
                    isLoggedIn ? profileProvider.userInfoModel != null ? Text(
                      '${profileProvider.userInfoModel.email ?? ''}',
                      style: poppinsRegular.copyWith(color: ColorResources.getTextColor(context)),
                    ) : SizedBox(height: 15, width: 100) : Text(
                      'demo@demo.com',
                      style: poppinsRegular.copyWith(fontSize: Dimensions.FONT_SIZE_EXTRA_LARGE, color: ColorResources.getTextColor(context)),
                    ),


                  ],
                ),

              ),
              SizedBox(height: 100),

              Builder(
                builder: (context) {
                  return GridView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 6,
                      crossAxisSpacing: Dimensions.PADDING_SIZE_EXTRA_LARGE,
                      mainAxisSpacing: Dimensions.PADDING_SIZE_EXTRA_LARGE,
                    ),
                    itemCount: _menuList.length,
                    itemBuilder: (context, index) => MenuItemWeb(menu: _menuList[index]),
                  );
                }
              ),
              SizedBox(height: Dimensions.PADDING_SIZE_EXTRA_LARGE),
            ]),

            Positioned(left: 30, top: 45, child: Container(
              height: 180, width: 180,
              decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 4),
                  boxShadow: [BoxShadow(color: Colors.white.withOpacity(0.1), blurRadius: 22, offset: Offset(0, 8.8) )]),
              child: ClipOval(
                child: isLoggedIn ? FadeInImage.assetNetwork(
                  placeholder: Images.placeholder(context), height: 170, width: 170, fit: BoxFit.cover,
                  image: '${Provider.of<SplashProvider>(context, listen: false).baseUrls.customerImageUrl}/'
                      '${profileProvider.userInfoModel != null ? profileProvider.userInfoModel.image : ''}',
                  imageErrorBuilder: (c, o, s) => Image.asset(Images.placeholder(context), height: 170, width: 170, fit: BoxFit.cover),
                ) : Image.asset(Images.placeholder(context), height: 170, width: 170, fit: BoxFit.cover),
              ),
            )),

            Positioned(right: 0, top: 140, child: _isLoggedIn ? Padding(
              padding: const EdgeInsets.all(Dimensions.PADDING_SIZE_DEFAULT),
              child: InkWell(
                onTap: (){
                  showAnimatedDialog(context,
                      AccountDeleteDialog(
                        icon: Icons.question_mark_sharp,
                        title: getTranslated('are_you_sure_to_delete_account', context),
                        description: getTranslated('it_will_remove_your_all_information', context),
                        onTapFalseText:getTranslated('no', context),
                        onTapTrueText: getTranslated('yes', context),
                        isFailed: true,
                        onTapFalse: () => Navigator.of(context).pop(),
                        onTapTrue: () => Provider.of<AuthProvider>(context, listen: false).deleteUser(context),
                      ),
                      dismissible: false,
                      isFlip: true);
                },
                child: Row(children: [
                  Padding(padding: const EdgeInsets.symmetric(horizontal: Dimensions.PADDING_SIZE_EXTRA_SMALL),
                    child: Icon(Icons.delete, color: Theme.of(context).primaryColor, size: 16),
                  ),

                  Padding(padding: const EdgeInsets.symmetric(horizontal: Dimensions.PADDING_SIZE_EXTRA_SMALL),
                    child: Text(getTranslated('delete_account', context)),
                  ),

                ],),
              ),
            ) : SizedBox()),

          ])),
        );
      })),

      FooterView(),
    ]));
  }
}


class MenuModel {
  String icon;
  String title;
  String route;
  Widget iconWidget;

  MenuModel({@required this.icon, @required this.title, @required this.route, this.iconWidget});
}