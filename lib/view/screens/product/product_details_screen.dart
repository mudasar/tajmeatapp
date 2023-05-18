import 'package:flutter/material.dart';
import 'package:flutter_grocery/data/model/response/cart_model.dart';
import 'package:flutter_grocery/data/model/response/product_model.dart';
import 'package:flutter_grocery/helper/price_converter.dart';
import 'package:flutter_grocery/helper/responsive_helper.dart';
import 'package:flutter_grocery/localization/language_constrants.dart';
import 'package:flutter_grocery/provider/cart_provider.dart';
import 'package:flutter_grocery/provider/localization_provider.dart';
import 'package:flutter_grocery/provider/product_provider.dart';
import 'package:flutter_grocery/provider/splash_provider.dart';
import 'package:flutter_grocery/utill/color_resources.dart';
import 'package:flutter_grocery/utill/dimensions.dart';
import 'package:flutter_grocery/utill/images.dart';
import 'package:flutter_grocery/utill/styles.dart';
import 'package:flutter_grocery/view/base/custom_button.dart';
import 'package:flutter_grocery/view/base/custom_loader.dart';
import 'package:flutter_grocery/view/base/custom_snackbar.dart';
import 'package:flutter_grocery/view/base/footer_view.dart';
import 'package:flutter_grocery/view/base/rating_bar.dart';
import 'package:flutter_grocery/view/base/web_app_bar/web_app_bar.dart';
import 'package:flutter_grocery/view/screens/product/widget/details_app_bar.dart';
import 'package:flutter_grocery/view/screens/product/widget/product_image_view.dart';
import 'package:flutter_grocery/view/screens/product/widget/product_title_view.dart';
import 'package:flutter_grocery/view/screens/product/widget/rating_bar.dart';
import 'package:flutter_grocery/view/screens/product/widget/variation_view.dart';
import 'package:flutter_grocery/view/screens/product/widget/web_product_information.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:provider/provider.dart';
import 'widget/product_review.dart';

class ProductDetailsScreen extends StatefulWidget {
  final Product product;
  final bool fromSearch;
  ProductDetailsScreen({@required this.product, this.fromSearch = false});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen>  with TickerProviderStateMixin {
  TabController _tabController;
  int _tabIndex = 0;

  @override
  void initState() {
    _tabController = TabController(length: 2, initialIndex: 0, vsync: this);

    print('from search --> ${widget.fromSearch}');

    Provider.of<ProductProvider>(context, listen: false).getProductDetails(
      context, '${widget.product.id}',
      Provider.of<LocalizationProvider>(context, listen: false).locale.languageCode,
      searchQuery: widget.fromSearch,
    );
    Provider.of<SplashProvider>(context, listen: false).initSharedData();
    Provider.of<CartProvider>(context, listen: false).getCartData();
    Provider.of<CartProvider>(context, listen: false).setSelect(0, false);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Variations _variation;

    return Scaffold(
      appBar: ResponsiveHelper.isDesktop(context) ? PreferredSize(child: WebAppBar(), preferredSize: Size.fromHeight(120))  : DetailsAppBar(key: UniqueKey()),

      body: Consumer<CartProvider>(builder: (context, cart, child) {
        return  Consumer<ProductProvider>(
          builder: (context, productProvider, child) {
            double price = 0;
            int _stock = 0;
            double priceWithQuantity = 0;
            CartModel _cartModel;

            if(productProvider.product != null) {
              List<String> _variationList = [];
              for (int index = 0; index < productProvider.product.choiceOptions.length; index++) {
                _variationList.add(productProvider.product.choiceOptions[index].options[productProvider.variationIndex[index]].replaceAll(' ', ''));
              }
              String variationType = '';
              bool isFirst = true;
              _variationList.forEach((variation) {
                if (isFirst) {
                  variationType = '$variationType$variation';
                  isFirst = false;
                } else {
                  variationType = '$variationType-$variation';
                }
              });

              price = productProvider.product.price;
              _stock = productProvider.product.totalStock;

              for (Variations variation in productProvider.product.variations) {
                if (variation.type == variationType) {
                  price = variation.price;
                  _variation = variation;
                  _stock = variation.stock;
                  break;
                }
              }
              double priceWithDiscount = 0;
              double categoryDiscountAmount;

              if(productProvider.product.categoryDiscount != null) {
               categoryDiscountAmount = PriceConverter.convertWithDiscount(
                 price, productProvider.product.categoryDiscount.discountAmount, productProvider.product.categoryDiscount.discountType,
                 maxDiscount: productProvider.product.categoryDiscount.maximumAmount,
               );
              }
              priceWithDiscount = PriceConverter.convertWithDiscount(price, productProvider.product.discount, productProvider.product.discountType);

              if(categoryDiscountAmount != null && categoryDiscountAmount > 0
                  && categoryDiscountAmount  < priceWithDiscount) {
                priceWithDiscount = categoryDiscountAmount;
              }







              _cartModel = CartModel(
                productProvider.product.id, productProvider.product.image.length > 0
                  ? productProvider.product.image[0] : '',
                  productProvider.product.name,  price,
                priceWithDiscount,
                productProvider.quantity, _variation,
                (price - priceWithDiscount),
                (price- PriceConverter.convertWithDiscount(price, productProvider.product.tax, productProvider.product.taxType)),
                  productProvider.product.capacity, productProvider.product.unit, _stock,productProvider.product
              );

              productProvider.setExistData(Provider.of<CartProvider>(context).isExistInCart(_cartModel));


              try{
                priceWithQuantity = priceWithDiscount * (productProvider.cartIndex != null ? cart.cartList[productProvider.cartIndex].quantity : productProvider.quantity);
              }catch (e){
                priceWithQuantity = priceWithDiscount;
              }
            }

            return productProvider.product != null ?
            !ResponsiveHelper.isDesktop(context) ? Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    physics: ResponsiveHelper.isMobilePhone()? BouncingScrollPhysics():null,
                    child: Center(
                      child: SizedBox(
                        width: Dimensions.WEB_SCREEN_WIDTH,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Column(children: [
                              ProductImageView(productModel: productProvider.product),

                              ProductTitleView(product: productProvider.product, stock: _stock, cartIndex: productProvider.cartIndex),

                              VariationView(product: productProvider.product),

                              Padding(
                                padding: EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
                                child: Row(children: [
                                  Text('${getTranslated('total_amount', context)}:', style: poppinsMedium.copyWith(fontSize: Dimensions.FONT_SIZE_LARGE)),
                                  SizedBox(width: Dimensions.PADDING_SIZE_EXTRA_SMALL),
                                  Text(PriceConverter.convertPrice(context, priceWithQuantity), style: poppinsBold.copyWith(
                                    color: Theme.of(context).primaryColor, fontSize: Dimensions.FONT_SIZE_LARGE,
                                  )),
                                ]),
                              ),
                              SizedBox(height: Dimensions.PADDING_SIZE_LARGE),

                              // Description

                            ],),

                           _description(context, productProvider),

                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                Center(
                  child: Container(
                    width: 1170,
                    child: CustomButton(
                      margin: Dimensions.PADDING_SIZE_SMALL,
                      buttonText: getTranslated(productProvider.cartIndex != null ? 'already_added' : _stock <= 0 ? 'out_of_stock' : 'add_to_card', context),
                      onPressed: (productProvider.cartIndex == null && _stock > 0) ? () {
                        if (productProvider.cartIndex == null && _stock > 0) {
                          Provider.of<CartProvider>(context, listen: false).addToCart(_cartModel);
                          //   _key.currentState.shake();


                          showCustomSnackBar(getTranslated('added_to_cart', context),context, isError: false);

                        } else {
                          // ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(getTranslated('already_added', context)), backgroundColor: Colors.red,));
                          showCustomSnackBar(getTranslated('already_added', context), context);
                        }
                      } : null,
                    ),
                  ),
                ),

              ],
            )
                : SingleChildScrollView(
              child: Column(
                children: [
                  ConstrainedBox(
                    constraints: BoxConstraints(minHeight: ResponsiveHelper.isDesktop(context) ? MediaQuery.of(context).size.height - 400 : MediaQuery.of(context).size.height),
                    child: Column(children: [
                      const SizedBox(height: Dimensions.PADDING_SIZE_SMALL),
                      Center(
                        child: SizedBox(
                          width: 1170,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                            Expanded(flex: 5, child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                SizedBox(
                                  height: 350,
                                  child: Consumer<CartProvider>(
                                      builder: (context, cartProvider, child) {
                                        return FadeInImage.assetNetwork(
                                          placeholder: Images.placeholder(context),
                                          fit: BoxFit.cover,
                                          image: '${Provider.of<SplashProvider>(context, listen: false).baseUrls.productImageUrl}/${
                                              productProvider.product.image.isNotEmpty ? productProvider.product.image[cartProvider.productSelect] : ''
                                          }',
                                          imageErrorBuilder: (c, o, s) => Image.asset(Images.placeholder(context), fit: BoxFit.cover),
                                        );
                                      }
                                  ),
                                ),
                                const SizedBox(height: Dimensions.PADDING_SIZE_SMALL),
                                Container(height: 100,
                                  child: productProvider.product.image != null ? ListView.builder(
                                      itemCount: productProvider.product.image.length,
                                      scrollDirection: Axis.horizontal,
                                      itemBuilder: (context,index){
                                        return Padding(
                                          padding: const EdgeInsets.only(right: Dimensions.PADDING_SIZE_SMALL),
                                          child: InkWell(
                                            onTap: (){
                                              Provider.of<CartProvider>(context, listen: false).setSelect(index, true);
                                            },
                                            child: Container(
                                              padding: EdgeInsets.all(Provider.of<CartProvider>(context, listen: false).productSelect == index ? 3 : 0),
                                              width: 100,
                                              decoration: BoxDecoration(
                                                  border: Border.all(color: Provider.of<CartProvider>(context, listen: false).productSelect == index ? Theme.of(context).primaryColor : ColorResources.getGreyColor(context),width: 1)
                                              ),
                                              child: FadeInImage.assetNetwork(
                                                placeholder: Images.placeholder(context),
                                                image: '${Provider.of<SplashProvider>(context, listen: false).baseUrls.productImageUrl}/${productProvider.product.image[index]}',
                                                width: 100,
                                                fit: BoxFit.cover,
                                                imageErrorBuilder: (c, o, s) => Image.asset(Images.placeholder(context), width: 100,fit: BoxFit.cover),
                                              ),
                                            ),
                                          ),
                                        );
                                      }) : SizedBox(),)
                              ],
                            ),),
                            const SizedBox(width: 30),
                            Expanded(flex: 6,child: SingleChildScrollView(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  productProvider.product != null
                                      ? WebProductInformation(product: productProvider.product, stock: _stock, cartIndex: productProvider.cartIndex,priceWithQuantity: priceWithQuantity)
                                      : CustomLoader(color: Theme.of(context).primaryColor),
                                  const SizedBox(height: Dimensions.PADDING_SIZE_EXTRA_LARGE),

                                  Builder(
                                    builder: (context) => Center(
                                      child: Container(
                                        width: 1170,
                                        child: CustomButton(
                                          buttonText: getTranslated(productProvider.cartIndex != null ? 'already_added' : _stock <= 0 ? 'out_of_stock' : 'add_to_card', context),
                                          onPressed: (productProvider.cartIndex == null && _stock > 0) ? () {
                                            if (productProvider.cartIndex == null && _stock > 0) {
                                              Provider.of<CartProvider>(context, listen: false).addToCart(_cartModel);

                                              showCustomSnackBar(getTranslated('added_to_cart', context),context, isError: false);

                                            } else {
                                              showCustomSnackBar(getTranslated('already_added', context), context);
                                            }
                                          } : null,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ))
                          ],),
                        ),
                      ),
                      //Description
                      Center(child: SizedBox(width: Dimensions.WEB_SCREEN_WIDTH,child: _description(context, productProvider))),
                      SizedBox(height: Dimensions.PADDING_SIZE_DEFAULT,),
                    ]),
                  ),

                  FooterView(),
                ],
              ),
            )

                : Center(child: CustomLoader(color: Theme.of(context).primaryColor));
          },
        );
      }),
    );
  }

  Widget _description(BuildContext context, ProductProvider productProvider) {
    return Column(children: [
      Center(child: Container(
        width: Dimensions.WEB_SCREEN_WIDTH,
        color: Theme.of(context).cardColor,
        child: TabBar(
          controller: _tabController,
          onTap: (index){
            setState(() {
              _tabIndex = index;
            });
          },
          indicatorColor: Theme.of(context).primaryColor,
          indicatorWeight: 3,
          labelColor: Theme.of(context).primaryColor,
          unselectedLabelColor: Theme.of(context).disabledColor,
          unselectedLabelStyle: poppinsRegular.copyWith(
            color: Theme.of(context).disabledColor,
            fontSize: Dimensions.FONT_SIZE_SMALL,
          ),
          labelStyle: poppinsRegular.copyWith(
            fontSize: Dimensions.FONT_SIZE_SMALL,
            color: Theme.of(context).primaryColor,
          ),
          tabs: [
            Tab(text: getTranslated('description', context)),
            Tab(text: getTranslated('review', context)),
          ],
        ),
      )),


      _tabIndex == 0 ? Container(
        padding: EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
        width: Dimensions.WEB_SCREEN_WIDTH,
        child: HtmlWidget(
          productProvider.product.description ?? '',
          textStyle: poppinsRegular.copyWith(fontSize: Dimensions.FONT_SIZE_SMALL),
        ),
      ) :
      Column(
        children: [
          Container(
            width: 700,
            child: Column(children: [
              SizedBox(height: Dimensions.PADDING_SIZE_EXTRA_LARGE),

              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text('${productProvider.product.rating.length > 0
                      ? double.parse(productProvider.product.rating.first.average).toStringAsFixed(1) : 0.0}',
                      style: poppinsRegular.copyWith(
                        fontSize: Dimensions.FONT_SIZE_MAX_LARGE,
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).primaryColor,
                      )),
                  SizedBox(height: Dimensions.PADDING_SIZE_EXTRA_SMALL),

                  RatingBar(
                    rating: productProvider.product.rating.length > 0
                        ? double.parse(productProvider.product.rating[0].average)
                        : 0.0, size: 25,
                  ),

                  SizedBox(height: Dimensions.PADDING_SIZE_EXTRA_SMALL),

                  Text(
                    '${productProvider.product.activeReviews.length} ${getTranslated('review', context)}',
                    style: poppinsRegular.copyWith(fontSize: Dimensions.FONT_SIZE_DEFAULT,color: Colors.deepOrange),
                  ),


                ],),

              SizedBox(height: Dimensions.PADDING_SIZE_SMALL,),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.PADDING_SIZE_DEFAULT),
                child: RatingLine(),
              ),
              SizedBox(height: Dimensions.PADDING_SIZE_DEFAULT),

            ]),
          ),
          ListView.builder(
            itemCount: productProvider.product.activeReviews.length,
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            padding: EdgeInsets.symmetric(vertical: Dimensions.PADDING_SIZE_DEFAULT, horizontal: Dimensions.PADDING_SIZE_DEFAULT),
            itemBuilder: (context, index) {

              return productProvider.product.activeReviews != null
                  ? ReviewWidget(reviewModel: productProvider.product.activeReviews[index])
                  : ReviewShimmer();
            },

          ),
        ],
      ) ,
    ],);
  }
}

