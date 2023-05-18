

import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_grocery/helper/route_helper.dart';
import 'package:flutter_grocery/localization/language_constrants.dart';
import 'package:flutter_grocery/main.dart';
import 'package:flutter_grocery/utill/dimensions.dart';
import 'package:flutter_grocery/utill/images.dart';
import 'package:flutter_grocery/utill/styles.dart';
import 'package:flutter_grocery/view/base/custom_button.dart';
import 'package:flutter_grocery/view/screens/order/order_details_screen.dart';

class NotificationDialog extends StatefulWidget {
  final String title;
  final String body;
  final int orderId;
  final String image;
  final String type;
  NotificationDialog({@required this.title, @required this.body, @required this.orderId, this.image, this.type});

  @override
  State<NotificationDialog> createState() => _NewRequestDialogState();
}

class _NewRequestDialogState extends State<NotificationDialog> {

  @override
  void initState() {
    super.initState();

    _startAlarm();
  }

  void _startAlarm() async {
    AudioCache _audio = AudioCache();
    _audio.play('notification.wav');
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.RADIUS_SIZE_DEFAULT)),
      //insetPadding: EdgeInsets.all(Dimensions.PADDING_SIZE_LARGE),
      child: Container(
        width: 500,
        padding: EdgeInsets.all(Dimensions.PADDING_SIZE_EXTRA_LARGE),
        child: Column(mainAxisSize: MainAxisSize.min, children: [

          Icon(Icons.notifications_active, size: 60, color: Theme.of(context).primaryColor),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: Dimensions.PADDING_SIZE_LARGE),
            child: Text(
              '${widget.title} ${widget.orderId != null ? '(${widget.orderId})': ''}',
              textAlign: TextAlign.center,
              style: poppinsRegular.copyWith(fontSize: Dimensions.FONT_SIZE_LARGE),
            ),
          ),
          SizedBox(height: Dimensions.PADDING_SIZE_SMALL),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: Dimensions.PADDING_SIZE_LARGE),
            child: Column(
              children: [
                Text(
                  widget.body, textAlign: TextAlign.center,
                  style: poppinsRegular.copyWith(fontSize: Dimensions.FONT_SIZE_LARGE),
                ),
               if(widget.image != null)
                 SizedBox(height: Dimensions.PADDING_SIZE_EXTRA_SMALL,),

                if(widget.image != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: CachedNetworkImage(
                      height: 100,
                      width: 500,
                      imageUrl: widget.image,
                      placeholder: (context, url) => Image.asset(Images.placeholder(context)),
                      errorWidget: (context, url, error) => Image.asset(Images.placeholder(context)),
                    ),
                  ),


              ],
            ),
          ),
          SizedBox(height: Dimensions.PADDING_SIZE_LARGE),

          Row(mainAxisAlignment: MainAxisAlignment.center, children: [

            Flexible(
              child: SizedBox(width: 120, height: 40,child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                style: TextButton.styleFrom(
                  backgroundColor: Theme.of(context).disabledColor.withOpacity(0.3), padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.RADIUS_SIZE_DEFAULT)),
                ),
                child: Text(
                  getTranslated('cancel', context), textAlign: TextAlign.center,
                  style: poppinsRegular.copyWith(color: Theme.of(context).textTheme.bodyText1.color),
                ),
              )),
            ),


            SizedBox(width: 20),

           if(widget.orderId != null || widget.type == 'message') Flexible(
             child: SizedBox(
                width: 120,
                height: 40,
                child: CustomButton(
                  textColor: Colors.white,
                  buttonText: getTranslated('go', context),
                  onPressed: () {
                    Navigator.pop(context);

                    try{
                      if(widget.orderId == null) {
                        Navigator.pushNamed(context, RouteHelper.getChatRoute(orderModel: null));
                      }else{
                        Get.navigator.push(MaterialPageRoute(
                          builder: (context) => OrderDetailsScreen(orderModel: null, orderId: widget.orderId),
                        ));
                      }

                    }catch (e) {}

                  },
                ),
              ),
           ),

          ]),

        ]),
      ),
    );
  }
}
