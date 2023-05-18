import 'package:flutter/material.dart';
import 'package:flutter_grocery/helper/responsive_helper.dart';
import 'package:flutter_grocery/helper/route_helper.dart';
import 'package:flutter_grocery/localization/language_constrants.dart';
import 'package:flutter_grocery/provider/order_provider.dart';
import 'package:flutter_grocery/provider/splash_provider.dart';
import 'package:flutter_grocery/provider/theme_provider.dart';
import 'package:flutter_grocery/utill/color_resources.dart';
import 'package:flutter_grocery/utill/dimensions.dart';
import 'package:flutter_grocery/utill/images.dart';
import 'package:flutter_grocery/utill/styles.dart';
import 'package:flutter_grocery/view/base/custom_button.dart';
import 'package:flutter_grocery/view/base/custom_loader.dart';
import 'package:flutter_grocery/view/base/footer_view.dart';
import 'package:flutter_grocery/view/base/web_app_bar/web_app_bar.dart';
import 'package:flutter_grocery/view/screens/menu/menu_screen.dart';
import 'package:flutter_grocery/view/screens/order/track_order_screen.dart';
import 'package:provider/provider.dart';

class OrderSuccessfulScreen extends StatefulWidget {
  final String orderID;
  final int status;

  OrderSuccessfulScreen({@required this.orderID, this.status,});

  @override
  State<OrderSuccessfulScreen> createState() => _OrderSuccessfulScreenState();

}

class _OrderSuccessfulScreenState extends State<OrderSuccessfulScreen> {
  // bool _isReload = true;
  @override
  void initState() {
    if(widget.status == 0) {
      Provider.of<OrderProvider>(context, listen: false).trackOrder(widget.orderID, null, context, false);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Theme.of(context).cardColor,
      appBar: ResponsiveHelper.isDesktop(context)? PreferredSize(child: WebAppBar(), preferredSize: Size.fromHeight(120)):null,
      body: Consumer<OrderProvider>(
          builder: (context, orderProvider, _) {
            double total = 0;
            bool success = true;



            if(orderProvider.trackModel != null && Provider.of<SplashProvider>(context, listen: false).configModel.loyaltyPointItemPurchasePoint != null) {
              total = ((orderProvider.trackModel.orderAmount / 100
              ) * Provider.of<SplashProvider>(context, listen: false).configModel.loyaltyPointItemPurchasePoint ?? 0);

            }

            return orderProvider.isLoading ? CustomLoader(color: Theme.of(context).primaryColor) :
            SingleChildScrollView(child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: ResponsiveHelper.isDesktop(context) ? MediaQuery.of(context).size.height - 560 : MediaQuery.of(context).size.height),
                    child: Container(
                      width: ResponsiveHelper.isDesktop(context) ? MediaQuery.of(context).size.width * 0.3 : 1170,
                      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Image.asset(Images.order_placed, width: 150, height: 150, color: Theme.of(context).primaryColor),
                        SizedBox(height: Dimensions.PADDING_SIZE_LARGE),
                        Text(
                          getTranslated(
                              widget.status == 0
                                  ? 'order_placed_successfully'
                                  : widget.status == 1
                                      ? 'payment_failed'
                                      : 'payment_cancelled',
                              context),
                          style: poppinsMedium.copyWith(fontSize: Dimensions.FONT_SIZE_LARGE, color: Theme.of(context).primaryColor),
                        ),
                        SizedBox(height: Dimensions.PADDING_SIZE_SMALL),
                        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                          Text('${getTranslated('order_id', context)}:  #${widget.orderID}',
                              style: poppinsRegular.copyWith(fontSize: Dimensions.FONT_SIZE_LARGE, color: ColorResources.getTextColor(context))),
                        ]),
                        SizedBox(height: 30),

                        (success && Provider.of<SplashProvider>(context).configModel.loyaltyPointStatus  && total.floor() > 0 )  ? Column(children: [

                          Image.asset(
                            Provider.of<ThemeProvider>(context, listen: false).darkTheme
                                ? Images.gif_box_dark : Images.gif_box,
                            width: 150, height: 150,
                          ),

                          Text(getTranslated('congratulations', context) , style: poppinsMedium.copyWith(fontSize: Dimensions.FONT_SIZE_LARGE)),
                          SizedBox(height: Dimensions.PADDING_SIZE_SMALL),

                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: Dimensions.PADDING_SIZE_LARGE),
                            child: Text(
                              getTranslated('you_have_earned', context) + ' ${total.floor().toString()} ' + getTranslated('points_it_will_add_to', context),
                              style: poppinsRegular.copyWith(fontSize: Dimensions.FONT_SIZE_LARGE,color: Theme.of(context).disabledColor),
                              textAlign: TextAlign.center,
                            ),
                          ),

                        ]) : SizedBox.shrink() ,
                        SizedBox(height: Dimensions.PADDING_SIZE_DEFAULT),

                        Container(
                          width: MediaQuery.of(context).size.width,
                          child: Padding(
                            padding: EdgeInsets.all(Dimensions.PADDING_SIZE_LARGE),
                            child: CustomButton(
                                buttonText: getTranslated(widget.status == 0 ? 'track_order' : 'back_home', context),
                                onPressed: () {
                                  if (widget.status == 0) {
                                    Navigator.pushReplacementNamed(context, RouteHelper.getOrderTrackingRoute(int.parse(widget.orderID)), arguments: TrackOrderScreen(orderID: widget.orderID, isBackButton: true));
                                  } else {
                                    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => MenuScreen()), (route) => false);
                                  }
                                }),
                          ),
                        ),
                      ]),
                    ),
                  ),
                ),
                ResponsiveHelper.isDesktop(context) ? FooterView() : SizedBox(),
              ],
            ),
          );
        }
      ),
    );
  }
}
