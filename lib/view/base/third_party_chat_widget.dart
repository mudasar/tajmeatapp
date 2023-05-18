import 'package:flutter/material.dart';
import 'package:flutter_grocery/provider/splash_provider.dart';
import 'package:flutter_grocery/utill/dimensions.dart';
import 'package:flutter_grocery/utill/images.dart';
import 'package:provider/provider.dart';
import 'package:simple_speed_dial/simple_speed_dial.dart';
import 'package:url_launcher/url_launcher.dart';

class ThirdPartyChatWidget extends StatefulWidget {
  const ThirdPartyChatWidget({
    Key key,
  }) : super(key: key);

  @override
  State<ThirdPartyChatWidget> createState() => _ThirdPartyChatWidgetState();
}

class _ThirdPartyChatWidgetState extends State<ThirdPartyChatWidget> {


  @override
  Widget build(BuildContext context) {
    List<SpeedDialChild> _dialList = [];
    return Consumer<SplashProvider>(
      builder: (context, splashProvider, _) {
        if(splashProvider.configModel != null && (splashProvider.configModel.whatsapp != null
            && splashProvider.configModel.whatsapp.status
            && splashProvider.configModel.whatsapp.number != null)){

          _dialList.add(SpeedDialChild(
            backgroundColor: Colors.transparent,
            child: Container(
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(vertical: Dimensions.PADDING_SIZE_EXTRA_SMALL, horizontal: Dimensions.PADDING_SIZE_SMALL),
              height: 35, width: 55,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), color: Theme.of(context).primaryColor),
              child: Image.asset(Images.whatsapp),
            ),
            onPressed: () async {
              final String whatsapp = splashProvider.configModel.whatsapp.number;
              final Uri whatsappMobile = Uri.parse("whatsapp://send?phone=$whatsapp");
              if (await canLaunchUrl(whatsappMobile)) {
                await launchUrl(whatsappMobile, mode: LaunchMode.externalApplication);
              } else {
                await launchUrl( Uri.parse("https://web.whatsapp.com/send?phone=$whatsapp"), mode: LaunchMode.externalApplication);
              }
            },
          ));




        }


        if(splashProvider.configModel != null && (splashProvider.configModel.telegram != null
            && splashProvider.configModel.telegram.status
            && splashProvider.configModel.telegram.userName != null)){


          _dialList.add(SpeedDialChild(backgroundColor: Colors.transparent,child: Container(
            padding: EdgeInsets.symmetric(
              vertical: Dimensions.PADDING_SIZE_EXTRA_SMALL,
              horizontal: Dimensions.PADDING_SIZE_SMALL,
            ),
            height: 35, width: 55,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), color: Colors.white),
            child: Image.asset(Images.telegram),
          ),
            onPressed: () async {
              final String userName = splashProvider.configModel.telegram.userName;
              final Uri whatsappMobile = Uri.parse("https://t.me/$userName");
              if (await canLaunchUrl(whatsappMobile)) {
                await launchUrl(whatsappMobile, mode: LaunchMode.externalApplication);
              } else {
                //await launchUrl( Uri.parse("https://web.whatsapp.com/send?phone=$whatsapp"), mode: LaunchMode.externalApplication);
              }
            },)

          );




        }

        if(splashProvider.configModel != null && (splashProvider.configModel.messenger != null
            && splashProvider.configModel.messenger.status
            && splashProvider.configModel.messenger.userName != null)){

          _dialList.add(SpeedDialChild(
            backgroundColor: Colors.transparent,
            child: Container(
              padding: EdgeInsets.symmetric(
                vertical: Dimensions.PADDING_SIZE_EXTRA_SMALL,
                horizontal: Dimensions.PADDING_SIZE_SMALL,
              ),
              height: 35, width: 55,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), color: Colors.white),
              child: Image.asset(Images.messenger),
            ),
            onPressed: () async {
              final String userId = splashProvider.configModel.messenger.userName;
              final Uri messengerUrl = Uri.parse("https://m.me/$userId");
              if (await canLaunchUrl(messengerUrl)) {
                await launchUrl(messengerUrl, mode: LaunchMode.externalApplication);
              } else {
                print('cannot --- $userId');
                //await launchUrl( Uri.parse("https://web.whatsapp.com/send?phone=$whatsapp"), mode: LaunchMode.externalApplication);
              }
            },
          ));





        }

        return _dialList.isEmpty ? SizedBox() : _dialList.length > 1 ?  SpeedDial(
          child: Icon(Icons.message),
          closedForegroundColor: Colors.white,
          openForegroundColor: Colors.white,
          closedBackgroundColor: Theme.of(context).primaryColor,
          openBackgroundColor: Theme.of(context).primaryColor.withOpacity(0.3),
          labelsBackgroundColor: Colors.white,
          speedDialChildren: _dialList,
        ) : InkWell(child: _dialList.first.child, onTap: _dialList.first.onPressed);
      }
    );
  }
}
