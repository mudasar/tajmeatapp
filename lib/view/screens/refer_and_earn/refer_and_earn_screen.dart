import 'package:dotted_border/dotted_border.dart';
import 'package:expandable_bottom_sheet/expandable_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_grocery/helper/responsive_helper.dart';
import 'package:flutter_grocery/localization/language_constrants.dart';
import 'package:flutter_grocery/main.dart';
import 'package:flutter_grocery/provider/auth_provider.dart';
import 'package:flutter_grocery/provider/profile_provider.dart';
import 'package:flutter_grocery/utill/app_constants.dart';
import 'package:flutter_grocery/utill/dimensions.dart';
import 'package:flutter_grocery/utill/images.dart';
import 'package:flutter_grocery/utill/styles.dart';
import 'package:flutter_grocery/view/base/custom_loader.dart';
import 'package:flutter_grocery/view/base/custom_snackbar.dart';
import 'package:flutter_grocery/view/base/footer_view.dart';
import 'package:flutter_grocery/view/base/not_login_screen.dart';
import 'package:flutter_grocery/view/base/web_app_bar/web_app_bar.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import 'widget/refer_hint_view.dart';


class ReferAndEarnScreen extends StatefulWidget {
  const ReferAndEarnScreen({Key key}) : super(key: key);

  @override
  State<ReferAndEarnScreen> createState() => _ReferAndEarnScreenState();
}

class _ReferAndEarnScreenState extends State<ReferAndEarnScreen> {
  final List<String> shareItem = ['messenger', 'whatsapp', 'gmail', 'viber', 'share' ];
  final List<String> hintList = [
    getTranslated('invite_your_friends', Get.context),
    '${getTranslated('they_register', Get.context)} ${AppConstants.APP_NAME} ${getTranslated('with_special_offer', Get.context)}',
    getTranslated('you_made_your_earning', Get.context),
  ];
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _isLoggedIn = Provider.of<AuthProvider>(context, listen: false).isLoggedIn();
  }

  @override
  Widget build(BuildContext context) {
    final _size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: ResponsiveHelper.isDesktop(context)
          ? PreferredSize(child: WebAppBar(), preferredSize: Size.fromHeight(100))
          : null,

      body: _isLoggedIn ? Consumer<ProfileProvider>(
          builder: (context, profileProvider, _) {
          return profileProvider.userInfoModel != null ? Center(child: ExpandableBottomSheet(
            background: SingleChildScrollView(
              padding: ResponsiveHelper.isDesktop(context) ? EdgeInsets.zero : EdgeInsets.symmetric(
                horizontal: Dimensions.PADDING_SIZE_DEFAULT,
                vertical: Dimensions.PADDING_SIZE_EXTRA_SMALL,
              ),
              child: Column(
                children: [
                  Container(
                    constraints: ResponsiveHelper.isDesktop(context) ? BoxConstraints() :
                    BoxConstraints(maxHeight: ResponsiveHelper.isDesktop(context)
                        ? MediaQuery.of(context).size.height : MediaQuery.of(context).size.height * 0.7),
                    width: ResponsiveHelper.isDesktop(context) ?  750 : double.maxFinite,
                    child: !ResponsiveHelper.isDesktop(context) ? SingleChildScrollView(
                      child: DetailsView(size: _size, shareItem: shareItem, hintList: hintList),
                    ) : DetailsView(size: _size, shareItem: shareItem, hintList: hintList),
                  ),

                  if(ResponsiveHelper.isDesktop(context)) FooterView(),
                ],
              ),
            ),
            persistentContentHeight: MediaQuery.of(context).size.height * 0.18,
            expandableContent: ResponsiveHelper.isDesktop(context)
                ? SizedBox() : ReferHintView(hintList: hintList),
          ))
              : CustomLoader(color: Theme.of(context).primaryColor);
        }
      ) : NotLoggedInScreen(),
    );
  }
}

class DetailsView extends StatelessWidget {
  const DetailsView({
    Key key,
    @required Size size,
    @required this.shareItem,
    @required this.hintList,
  }) : _size = size, super(key: key);

  final Size _size;
  final List<String> shareItem;
  final List<String> hintList;

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileProvider>(
        builder: (context, profileProvider, _) {
          return profileProvider.userInfoModel != null ? Column(
            children: [
              Image.asset(Images.refer_banner, height: _size.height * 0.3),
              SizedBox(height: Dimensions.PADDING_SIZE_DEFAULT,),

              Text(
                getTranslated('invite_friend_and_businesses', context),
                textAlign: TextAlign.center,
                style: poppinsMedium.copyWith(
                  fontSize: Dimensions.FONT_SIZE_OVER_LARGE,
                  color: Theme.of(context).textTheme.bodyLarge.color,
                ),
              ),
              SizedBox(height: Dimensions.PADDING_SIZE_SMALL,),

              Text(
                getTranslated('copy_your_code', context),
                textAlign: TextAlign.center,
                style: poppinsRegular.copyWith(
                  fontSize: Dimensions.FONT_SIZE_DEFAULT,
                ),
              ),
              SizedBox(height: Dimensions.PADDING_SIZE_DEFAULT,),

              Text(
                getTranslated('your_personal_code', context),
                textAlign: TextAlign.center,
                style: poppinsRegular.copyWith(
                  fontSize: Dimensions.FONT_SIZE_DEFAULT,
                  fontWeight: FontWeight.w200,
                  color: Theme.of(context).hintColor,
                ),
              ),
              SizedBox(height: Dimensions.PADDING_SIZE_LARGE,),

              DottedBorder(
                padding: EdgeInsets.all(4),
                borderType: BorderType.RRect,
                radius: Radius.circular(20),
                dashPattern: [5, 5],
                color: Theme.of(context).primaryColor.withOpacity(0.5),
                strokeWidth: 2,
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: Dimensions.PADDING_SIZE_DEFAULT),
                        child: Text('${profileProvider.userInfoModel.referCode ?? ''}',
                          style: poppinsRegular.copyWith(fontSize: Dimensions.FONT_SIZE_LARGE),
                        ),
                      ),

                      InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: () {

                          if(profileProvider.userInfoModel.referCode != null && profileProvider.userInfoModel.referCode  != ''){
                            Clipboard.setData(ClipboardData(text: '${profileProvider.userInfoModel != null ? profileProvider.userInfoModel.referCode : ''}'));
                            showCustomSnackBar(getTranslated('referral_code_copied', context), context, isError: false);
                          }
                        },
                        child: Container(
                          width: 85,
                          height: 40,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor, borderRadius: BorderRadius.circular(60),
                          ),
                          child: Text(getTranslated('copy', context),style: poppinsRegular.copyWith(
                            fontSize: Dimensions.FONT_SIZE_EXTRA_LARGE, color: Colors.white.withOpacity(0.9),
                          )),
                        ),
                      ),

                    ]),
              ),
              SizedBox(height: Dimensions.PADDING_SIZE_EXTRA_LARGE,),

              Text(
                getTranslated('or_share', context),
                style: poppinsRegular.copyWith(fontSize: Dimensions.FONT_SIZE_LARGE),
              ),

              SizedBox(height: Dimensions.PADDING_SIZE_EXTRA_LARGE,),

              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: shareItem.map((_item) => InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () => Share.share(profileProvider.userInfoModel.referCode),
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: Dimensions.PADDING_SIZE_EXTRA_SMALL),
                      child: Image.asset(
                        Images.getShareIcon(_item), height: 50, width: 50,
                      ),
                    ),
                  )).toList(),),
              ),

              if(ResponsiveHelper.isDesktop(context))
                Column(children: [
                  SizedBox(height: Dimensions.PADDING_SIZE_DEFAULT),
                  ReferHintView(hintList: hintList),
                  SizedBox(height: Dimensions.PADDING_SIZE_DEFAULT),
                ]),


            ],
          ) : SizedBox();
        }
    );
  }
}
