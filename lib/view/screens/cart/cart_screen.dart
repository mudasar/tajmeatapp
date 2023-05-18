import 'package:flutter/material.dart';
import 'package:flutter_grocery/data/model/response/config_model.dart';
import 'package:flutter_grocery/helper/price_converter.dart';
import 'package:flutter_grocery/helper/responsive_helper.dart';
import 'package:flutter_grocery/helper/route_helper.dart';
import 'package:flutter_grocery/localization/language_constrants.dart';
import 'package:flutter_grocery/provider/cart_provider.dart';
import 'package:flutter_grocery/provider/coupon_provider.dart';
import 'package:flutter_grocery/provider/order_provider.dart';
import 'package:flutter_grocery/provider/splash_provider.dart';
import 'package:flutter_grocery/provider/theme_provider.dart';
import 'package:flutter_grocery/utill/dimensions.dart';
import 'package:flutter_grocery/view/base/app_bar_base.dart';
import 'package:flutter_grocery/view/base/custom_button.dart';
import 'package:flutter_grocery/view/base/custom_snackbar.dart';
import 'package:flutter_grocery/view/base/footer_view.dart';
import 'package:flutter_grocery/view/base/no_data_screen.dart';
import 'package:flutter_grocery/view/base/web_app_bar/web_app_bar.dart';
import 'package:flutter_grocery/view/screens/cart/widget/cart_product_widget.dart';
import 'package:flutter_grocery/view/screens/checkout/checkout_screen.dart';
import 'package:provider/provider.dart';

import 'widget/cart_details_view.dart';

class CartScreen extends StatelessWidget {
  final TextEditingController _couponController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final _configModel = Provider.of<SplashProvider>(context, listen: false).configModel;

    Provider.of<CouponProvider>(context, listen: false).removeCouponData(false);
    Provider.of<OrderProvider>(context, listen: false).setOrderType('delivery', notify: false);
    bool _isSelfPickupActive = _configModel.selfPickup == 1;
    bool _kmWiseCharge = _configModel.deliveryManagement.status == 1;

    return Scaffold(
      appBar: ResponsiveHelper.isMobilePhone() ? null: ResponsiveHelper.isDesktop(context)? PreferredSize(child: WebAppBar(), preferredSize: Size.fromHeight(120)) : AppBarBase(),
      body: Center(
        child: Consumer<CouponProvider>(builder: (context, couponProvider, _) {
            return Consumer<CartProvider>(
              builder: (context, cart, child) {
                double deliveryCharge = 0;
                (Provider.of<OrderProvider>(context).orderType == 'delivery' && !_kmWiseCharge)
                    ? deliveryCharge = _configModel.deliveryCharge : deliveryCharge = 0;

                if(couponProvider.couponType == 'free_delivery') {
                  deliveryCharge = 0;
                }

                double _itemPrice = 0;
                double _discount = 0;
                double _tax = 0;
                cart.cartList.forEach((cartModel) {
                  _itemPrice = _itemPrice + (cartModel.price * cartModel.quantity);
                  _discount = _discount + (cartModel.discount * cartModel.quantity);
                  _tax = _tax + (cartModel.tax * cartModel.quantity);
                });

                double _subTotal = _itemPrice + (_configModel.isVatTexInclude ? 0 : _tax);
                bool _isFreeDelivery = _subTotal >= _configModel.freeDeliveryOverAmount && _configModel.freeDeliveryStatus
                    || couponProvider.couponType == 'free_delivery';

                double _total = _subTotal - _discount - Provider.of<CouponProvider>(context).discount + (_isFreeDelivery ? 0 : deliveryCharge);

                return cart.cartList.length > 0
                    ? !ResponsiveHelper.isDesktop(context) ? Column(children: [
                      Expanded(child: SingleChildScrollView(
                        padding: EdgeInsets.symmetric(
                          horizontal: Dimensions.PADDING_SIZE_DEFAULT,
                          vertical: Dimensions.PADDING_SIZE_SMALL,
                        ),
                        child: Center(child: SizedBox(width: Dimensions.WEB_SCREEN_WIDTH, child: Column(
                         crossAxisAlignment: CrossAxisAlignment.start,
                         children: [
                          // Product
                           CartProductListView(),
                           SizedBox(height: Dimensions.PADDING_SIZE_LARGE),


                           CartDetailsView(
                            couponController: _couponController, total: _total,
                            isSelfPickupActive: _isSelfPickupActive,
                            kmWiseCharge: _kmWiseCharge, isFreeDelivery: _isFreeDelivery,
                            itemPrice: _itemPrice, tax: _tax,
                            discount: _discount, deliveryCharge: deliveryCharge,
                          ),
                           SizedBox(height: 40),
                         ]),
                        )),
                      )),

                      CartButtonView(
                        subTotal: _subTotal,
                        configModel: _configModel,
                        itemPrice: _itemPrice,
                        total: _total,
                        isFreeDelivery: _isFreeDelivery,
                      ),
                    ])
                    : SingleChildScrollView(child: Column(children: [
                      Center(child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: ResponsiveHelper.isDesktop(context)
                              ? MediaQuery.of(context).size.height - 560 : MediaQuery.of(context).size.height,
                        ),
                        child: SizedBox(width: 1170, child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: Dimensions.PADDING_SIZE_LARGE),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(child: CartProductListView()),
                              SizedBox(width: 10),

                              Expanded(child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
                                Container(
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).cardColor,
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey[Provider.of<ThemeProvider>(context).darkTheme ? 900 : 300],
                                        blurRadius: 5,
                                        spreadRadius: 1,
                                      )
                                    ],
                                  ),
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: Dimensions.PADDING_SIZE_SMALL,
                                  ).copyWith(bottom: Dimensions.PADDING_SIZE_LARGE),

                                  padding: const EdgeInsets.symmetric(
                                    horizontal: Dimensions.PADDING_SIZE_LARGE,
                                    vertical: Dimensions.PADDING_SIZE_LARGE,
                                  ),
                                  child: CartDetailsView(
                                    couponController: _couponController, total: _total,
                                    isSelfPickupActive: _isSelfPickupActive,
                                    kmWiseCharge: _kmWiseCharge, isFreeDelivery: _isFreeDelivery,
                                    itemPrice: _itemPrice, tax: _tax,
                                    discount: _discount, deliveryCharge: deliveryCharge,
                                  ),
                                ),

                                CartButtonView(
                                  subTotal: _subTotal,
                                  configModel: _configModel,
                                  itemPrice: _itemPrice,
                                  total: _total,
                                  isFreeDelivery: _isFreeDelivery,
                                ),
                              ]))

                            ],
                          ),
                        )),
                      )),

                      FooterView(),
                ]))
                    : NoDataScreen(isCart: true);
              },
            );
          }
        ),
      ),
    );
  }
}

class CartButtonView extends StatelessWidget {
  const CartButtonView({
    Key key,
    @required double subTotal,
    @required ConfigModel configModel,
    @required double itemPrice,
    @required double total,
    @required bool isFreeDelivery,
  }) : _subTotal = subTotal, _configModel = configModel, _isFreeDelivery = isFreeDelivery, _itemPrice = itemPrice,  _total = total, super(key: key);

  final double _subTotal;
  final ConfigModel _configModel;
  final double _itemPrice;
  final double _total;
  final bool _isFreeDelivery;

  @override
  Widget build(BuildContext context) {
    

    return SafeArea(child: Container(
      width: 1170,
      padding: EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
      child: Column(children: [

        Consumer<CouponProvider>(
          builder: (context, couponProvider, _) {
            return couponProvider.couponType == 'free_delivery'
                ? SizedBox() :
            FreeDeliveryProgressBar(subTotal: _subTotal, configModel: _configModel);
          }
        ),

        CustomButton(
          buttonText: getTranslated('continue_checkout', context),
          onPressed: () {
            if(_itemPrice < _configModel.minimumOrderValue) {
              showCustomSnackBar(' ${getTranslated('minimum_order_amount_is', context)} ${PriceConverter.convertPrice(context, _configModel.minimumOrderValue)
              }, ${getTranslated('you_have', context)} ${PriceConverter.convertPrice(context, _itemPrice)} ${getTranslated('in_your_cart_please_add_more_item', context)}', context,isError: true);
            } else {
              String _orderType = Provider.of<OrderProvider>(context, listen: false).orderType;
              double _discount = Provider.of<CouponProvider>(context, listen: false).discount;
              Navigator.pushNamed(
                context, RouteHelper.getCheckoutRoute(
                _total, _discount, _orderType,
                Provider.of<CouponProvider>(context, listen: false).code,
                 _isFreeDelivery ? 'free_delivery' : '',
              ),
                arguments: CheckoutScreen(
                  amount: _total, orderType: _orderType, discount: _discount,
                  couponCode: Provider.of<CouponProvider>(context, listen: false).code,
                  freeDeliveryType:  _isFreeDelivery ? 'free_delivery' : '',

                ),
              );
            }
          },
        ),
      ]),
    ));
  }
}



class FreeDeliveryProgressBar extends StatelessWidget {
  const FreeDeliveryProgressBar({
    Key key,
    @required double subTotal,
    @required ConfigModel configModel,
  }) : _subTotal = subTotal, super(key: key);

  final double _subTotal;

  @override
  Widget build(BuildContext context) {
    final _configModel = Provider.of<SplashProvider>(context, listen: false).configModel;

    return _configModel.freeDeliveryStatus ? Container(
        margin: EdgeInsets.symmetric(horizontal: Dimensions.PADDING_SIZE_DEFAULT),
        child: Column(children: [
          Row(children: [
            Icon(Icons.discount_outlined, color: Theme.of(context).primaryColor),
            SizedBox(width: Dimensions.PADDING_SIZE_EXTRA_SMALL),
            (_subTotal / _configModel.freeDeliveryOverAmount)  < 1 ?
            Text('${PriceConverter.convertPrice(context, _configModel.freeDeliveryOverAmount - _subTotal)} ${getTranslated('more_to_free_delivery', context)}')
            : Text(getTranslated('enjoy_free_delivery', context)),
          ]),
          SizedBox(height: Dimensions.PADDING_SIZE_SMALL),

          LinearProgressIndicator(
            value: (_subTotal / _configModel.freeDeliveryOverAmount),
            color: Theme.of(context).primaryColor,
          ),
          SizedBox(height: Dimensions.PADDING_SIZE_SMALL),
        ]),
      ) : SizedBox();
  }
}


