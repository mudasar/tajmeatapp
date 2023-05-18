import 'package:flutter/material.dart';
import 'package:flutter_grocery/helper/price_converter.dart';
import 'package:flutter_grocery/localization/language_constrants.dart';
import 'package:flutter_grocery/provider/order_provider.dart';
import 'package:flutter_grocery/utill/dimensions.dart';
import 'package:flutter_grocery/utill/styles.dart';
import 'package:flutter_grocery/view/base/custom_divider.dart';
import 'package:flutter_grocery/view/base/custom_text_field.dart';
import 'package:flutter_grocery/view/screens/checkout/widget/digital_payment_view.dart';
import 'package:provider/provider.dart';

class DetailsView extends StatelessWidget {
  const DetailsView({
    Key key,
    @required List<String> paymentList,
    @required double amount,
    @required TextEditingController noteController,
    @required bool kmWiseCharge,
    @required bool selfPickup,
    @required double deliveryCharge,
    @required bool freeDelivery,
  }) : _amount = amount,  _paymentList = paymentList, _freeDelivery = freeDelivery, _noteController = noteController, _kmWiseCharge = kmWiseCharge, _selfPickup = selfPickup, _deliveryCharge = deliveryCharge, super(key: key);

  final List<String> _paymentList;
  final TextEditingController _noteController;
  final bool _kmWiseCharge;
  final bool _selfPickup;
  final double _deliveryCharge;
  final double _amount;
  final bool _freeDelivery;

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: EdgeInsets.symmetric(horizontal: Dimensions.PADDING_SIZE_SMALL),
        child: Text(getTranslated('payment_method', context), style: poppinsMedium.copyWith(fontSize: Dimensions.FONT_SIZE_LARGE)),
      ),
      SizedBox(height: Dimensions.PADDING_SIZE_SMALL),

      DigitalPaymentView(paymentList: _paymentList),

      Padding(
        padding: EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
        child: CustomTextField(
          controller: _noteController,
          hintText: getTranslated('additional_note', context),
          maxLines: 5,
          inputType: TextInputType.multiline,
          inputAction: TextInputAction.newline,
          capitalization: TextCapitalization.sentences,
        ),
      ),

      _kmWiseCharge ? Padding(
        padding: EdgeInsets.symmetric(horizontal: Dimensions.PADDING_SIZE_SMALL),
        child: Column(children: [
          SizedBox(height: Dimensions.PADDING_SIZE_LARGE),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(getTranslated('subtotal', context), style: poppinsMedium.copyWith(fontSize: Dimensions.FONT_SIZE_LARGE)),
            Text(PriceConverter.convertPrice(context, _amount), style: poppinsMedium.copyWith(fontSize: Dimensions.FONT_SIZE_LARGE)),
          ]),
          SizedBox(height: 10),

          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(
              getTranslated('delivery_fee', context),
              style: poppinsRegular.copyWith(fontSize: Dimensions.FONT_SIZE_LARGE),
            ),
            Consumer<OrderProvider>(builder: (context, orderProvider, _) {
              return Text(_freeDelivery ? getTranslated('free', context) : (_selfPickup ||  orderProvider.distance != -1)
                  ? '(+) ${PriceConverter.convertPrice(context, _selfPickup
                  ? 0 : _deliveryCharge)}'
                  : getTranslated('not_found', context),
                style: poppinsRegular.copyWith(fontSize: Dimensions.FONT_SIZE_LARGE),
              );
            }),
          ]),

          Padding(
            padding: EdgeInsets.symmetric(vertical: Dimensions.PADDING_SIZE_SMALL),
            child: CustomDivider(),
          ),

          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(getTranslated('total_amount', context), style: poppinsMedium.copyWith(
              fontSize: Dimensions.FONT_SIZE_EXTRA_LARGE, color: Theme.of(context).primaryColor,
            )),
            Text(
              PriceConverter.convertPrice(context, _amount + (_freeDelivery ? 0:  _deliveryCharge)),
              style: poppinsMedium.copyWith(fontSize: Dimensions.FONT_SIZE_EXTRA_LARGE, color: Theme.of(context).primaryColor),
            ),
          ]),
        ]),
      ) : SizedBox(),

    ]);
  }
}