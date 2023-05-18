import 'package:flutter/material.dart';
import 'package:flutter_grocery/data/model/response/product_model.dart';
import 'package:flutter_grocery/helper/price_converter.dart';
import 'package:flutter_grocery/helper/responsive_helper.dart';
import 'package:flutter_grocery/localization/language_constrants.dart';
import 'package:flutter_grocery/provider/cart_provider.dart';
import 'package:flutter_grocery/provider/product_provider.dart';
import 'package:flutter_grocery/utill/color_resources.dart';
import 'package:flutter_grocery/utill/dimensions.dart';
import 'package:flutter_grocery/utill/styles.dart';
import 'package:flutter_grocery/view/base/custom_snackbar.dart';
import 'package:flutter_grocery/view/base/rating_bar.dart';
import 'package:flutter_grocery/view/base/wish_button.dart';
import 'package:provider/provider.dart';

class ProductTitleView extends StatelessWidget {
  final Product product;
  final int stock;
  final int cartIndex;
  ProductTitleView({@required this.product, @required this.stock,@required this.cartIndex});

  @override
  Widget build(BuildContext context) {
    double _startingPrice;
    double _startingPriceWithDiscount;
    double _startingPriceWithCategoryDiscount;
    double _endingPrice;
    double _endingPriceWithDiscount;
    double _endingPriceWithCategoryDiscount;
    if(product.variations.length != 0) {
      List<double> _priceList = [];
      product.variations.forEach((variation) => _priceList.add(variation.price));
      _priceList.sort((a, b) => a.compareTo(b));
      _startingPrice = _priceList[0];
      if(_priceList[0] < _priceList[_priceList.length-1]) {
        _endingPrice = _priceList[_priceList.length-1];
      }
    }else {
      _startingPrice = product.price;
    }


    if(product.categoryDiscount != null) {
      _startingPriceWithCategoryDiscount = PriceConverter.convertWithDiscount(
        _startingPrice, product.categoryDiscount.discountAmount, product.categoryDiscount.discountType,
        maxDiscount: product.categoryDiscount.maximumAmount,
      );

      if(_endingPrice != null){
        _endingPriceWithCategoryDiscount = PriceConverter.convertWithDiscount(
          _endingPrice, product.categoryDiscount.discountAmount, product.categoryDiscount.discountType,
          maxDiscount: product.categoryDiscount.maximumAmount,
        );
      }
    }
    _startingPriceWithDiscount = PriceConverter.convertWithDiscount(_startingPrice, product.discount, product.discountType);

    if(_endingPrice != null) {
      _endingPriceWithDiscount = PriceConverter.convertWithDiscount(_endingPrice, product.discount, product.discountType);
    }

    if(_startingPriceWithCategoryDiscount != null &&
        _startingPriceWithCategoryDiscount > 0 &&
        _startingPriceWithCategoryDiscount < _startingPriceWithDiscount) {
      _startingPriceWithDiscount = _startingPriceWithCategoryDiscount;
      _endingPriceWithDiscount = _endingPriceWithCategoryDiscount;
    }




    return Container(
      padding: EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(Dimensions.PADDING_SIZE_DEFAULT),
          topRight: Radius.circular(Dimensions.PADDING_SIZE_DEFAULT),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 3,
            offset: Offset(0, 3), // changes position of shadow
          ),
        ],
      ),
      child: Consumer<ProductProvider>(
        builder: (context, productProvider, child) {
          return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(child: Text(
                    product.name ?? '',
                      style: poppinsMedium.copyWith(fontSize: Dimensions.FONT_SIZE_LARGE, color: ColorResources.getTextColor(context)),
                      maxLines: 1, overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  WishButton(product: product),

                ],
              ),
            ),

            product.rating != null ? Padding(
              padding: const EdgeInsets.symmetric(vertical: Dimensions.PADDING_SIZE_EXTRA_SMALL),
              child: RatingBar(
                rating: product.rating.length > 0 ? double.parse(product.rating[0].average) : 0.0, size: Dimensions.PADDING_SIZE_DEFAULT,
              ),
            ) : SizedBox(),

            //Product Price
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(
                  '${PriceConverter.convertPrice(context, _startingPriceWithDiscount, )}'
                      '${_endingPriceWithDiscount!= null ? ' - ${PriceConverter.convertPrice(context, _endingPriceWithDiscount)}' : ''}',
                  style: poppinsBold.copyWith(color: ColorResources.getTextColor(context), fontSize: Dimensions.FONT_SIZE_LARGE),
                ),

              Container(
                padding: EdgeInsets.symmetric(horizontal: Dimensions.PADDING_SIZE_SMALL, vertical: 2),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(Dimensions.RADIUS_SIZE_LARGE),
                  color: product.totalStock > 0
                      ?  Theme.of(context).primaryColor
                      : Theme.of(context).primaryColor.withOpacity(0.3),
                ),
                child: Text(
                  '${ getTranslated(product.totalStock > 0
                      ? 'in_stock' : 'stock_out', context)}',
                  style: poppinsMedium.copyWith(color: Colors.white),
                ),
              ),
            ]),
            SizedBox(height: Dimensions.PADDING_SIZE_SMALL),



            _startingPriceWithDiscount < _startingPrice  ? Text(
              '${PriceConverter.convertPrice(context, _startingPrice)}'
                  '${_endingPrice != null ? ' - ${PriceConverter.convertPrice(context, _endingPrice)}' : ''}',
              style: poppinsBold.copyWith(
                color: ColorResources.getHintColor(context),
                fontSize: Dimensions.FONT_SIZE_SMALL, decoration: TextDecoration.lineThrough,
              ),
            ): SizedBox(),

            Row(children: [

              Text(
                '${product.capacity} ${product.unit}',
                style: poppinsRegular.copyWith(color: Theme.of(context).hintColor, fontSize: Dimensions.FONT_SIZE_SMALL),
              ),

              Expanded(child: SizedBox.shrink()),

              Builder(
                builder: (context) {
                  return Row(children: [
                    QuantityButton(
                      isIncrement: false, quantity: productProvider.quantity,
                      stock: stock,cartIndex: cartIndex,
                      maxOrderQuantity: product.maximumOrderQuantity,
                    ),
                    SizedBox(width: 15),

                    Consumer<CartProvider>(builder: (context, cart, child) {
                      return Text(cartIndex != null ? cart.cartList[cartIndex].quantity.toString()
                          : productProvider.quantity.toString(), style: poppinsSemiBold,
                      );
                    }),
                    SizedBox(width: 15),

                    QuantityButton(
                      isIncrement: true, quantity: productProvider.quantity,
                      stock: stock, cartIndex: cartIndex,
                      maxOrderQuantity: product.maximumOrderQuantity,
                    ),
                  ]);
                }
              ),
            ]),
          ]);
        },
      ),
    );
  }
}

class QuantityButton extends StatelessWidget {
  final bool isIncrement;
  final int quantity;
  final bool isCartWidget;
  final int stock;
  final int maxOrderQuantity;
  final int cartIndex;

  QuantityButton({
    @required this.isIncrement,
    @required this.quantity,
    @required this.stock,
    @required this.maxOrderQuantity,
    this.isCartWidget = false,
    @required this.cartIndex,
  });

  @override
  Widget build(BuildContext context) {
    final _cartProvider = Provider.of<CartProvider>(context, listen: false);
    return InkWell(
      onTap: () {
        if(cartIndex != null) {
          if(isIncrement) {
            if(maxOrderQuantity == null || _cartProvider.cartList[cartIndex].quantity < maxOrderQuantity){
              if (_cartProvider.cartList[cartIndex].quantity < _cartProvider.cartList[cartIndex].stock) {
                _cartProvider.setQuantity(true, cartIndex, showMessage: true, context: context);
              } else {
                showCustomSnackBar(getTranslated('out_of_stock', context), context);
              }
            }else{
              showCustomSnackBar('${getTranslated('you_can_add_max', context)} $maxOrderQuantity ${
                  getTranslated(maxOrderQuantity > 1 ? 'items' : 'item', context)} ${getTranslated('only', context)}', context);
            }

          }else {
            if (Provider.of<CartProvider>(context, listen: false).cartList[cartIndex].quantity > 1) {
              Provider.of<CartProvider>(context, listen: false).setQuantity(false, cartIndex, showMessage: true, context: context);
            } else {
              Provider.of<ProductProvider>(context, listen: false).setExistData(null);
              _cartProvider.removeFromCart(cartIndex, context);
            }
          }
        }else {
          if (!isIncrement && quantity > 1) {
            Provider.of<ProductProvider>(context, listen: false).setQuantity(false);
          } else if (isIncrement) {
            if(maxOrderQuantity == null || quantity < maxOrderQuantity) {
              if(quantity < stock) {
                Provider.of<ProductProvider>(context, listen: false).setQuantity(true);
              }else {
                showCustomSnackBar(getTranslated('out_of_stock', context), context);
              }
            }else{
              showCustomSnackBar('${getTranslated('you_can_add_max', context)} $maxOrderQuantity ${
                  getTranslated(maxOrderQuantity > 1 ? 'items' : 'item', context)} ${getTranslated('only', context)}', context);
            }
          }
        }
      },
      child: ResponsiveHelper.isDesktop(context)  ? Container(
        // padding: EdgeInsets.all(3),
        height: 50,width: 50,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(5),color: Theme.of(context).primaryColor),
        child: Center(
          child: Icon(
            isIncrement ? Icons.add : Icons.remove,
            color: isIncrement
                ? ColorResources.getWhiteColor(context)
                : quantity > 1
                ? ColorResources.getWhiteColor(context)
                : ColorResources.getWhiteColor(context),
            size: isCartWidget ? 26 : 20,
          ),
        ),
      ) : Container(
        padding: EdgeInsets.all(3),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), border: Border.all(color:  ColorResources.getGreyColor(context))),
        child: Icon(
          isIncrement ? Icons.add : Icons.remove,
          color: isIncrement
              ?  Theme.of(context).primaryColor
              : quantity > 1
                  ?  Theme.of(context).primaryColor
                  :  Theme.of(context).primaryColor,
          size: isCartWidget ? 26 : 20,
        ),
      ),
    );
  }
}
