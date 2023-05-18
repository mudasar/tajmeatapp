import 'package:flutter/material.dart';
import 'package:flutter_grocery/data/model/response/product_model.dart';
import 'package:flutter_grocery/helper/product_type.dart';
import 'package:flutter_grocery/helper/responsive_helper.dart';
import 'package:flutter_grocery/localization/language_constrants.dart';
import 'package:flutter_grocery/provider/flash_deal_provider.dart';
import 'package:flutter_grocery/provider/localization_provider.dart';
import 'package:flutter_grocery/provider/product_provider.dart';
import 'package:flutter_grocery/provider/splash_provider.dart';
import 'package:flutter_grocery/utill/dimensions.dart';
import 'package:flutter_grocery/utill/images.dart';
import 'package:flutter_grocery/view/base/custom_app_bar.dart';
import 'package:flutter_grocery/view/base/custom_loader.dart';
import 'package:flutter_grocery/view/base/footer_view.dart';
import 'package:flutter_grocery/view/base/no_data_screen.dart';
import 'package:flutter_grocery/view/base/product_widget.dart';
import 'package:flutter_grocery/view/base/title_row.dart';
import 'package:flutter_grocery/view/base/title_widget.dart';
import 'package:flutter_grocery/view/base/web_app_bar/web_app_bar.dart';
import 'package:provider/provider.dart';

class HomeItemScreen extends StatefulWidget {
  final String productType;

   HomeItemScreen({Key key, this.productType}) : super(key: key);

  @override
  State<HomeItemScreen> createState() => _HomeItemScreenState();
}

class _HomeItemScreenState extends State<HomeItemScreen> {
  int pageSize;
  final ScrollController scrollController = ScrollController();


  @override
  void initState() {
   if(widget.productType != ProductType.FLASH_SALE){
     Provider.of<ProductProvider>(context, listen: false).popularOffset = 1;
     Provider.of<ProductProvider>(context, listen: false).getItemList(
       context, '1', false, Provider.of<LocalizationProvider>(context, listen: false).locale.languageCode,
       widget.productType,
     );

     final _productProvider = Provider.of<ProductProvider>(context, listen: false);
     scrollController?.addListener(() {
       if (scrollController.position.maxScrollExtent == scrollController.position.pixels &&
           (_productProvider.popularProductList != null || _productProvider.dailyItemList != null) && !_productProvider.isLoading
       ) {
         pageSize = (_productProvider.popularPageSize / 10).ceil();
         if (_productProvider.popularOffset < pageSize) {
           _productProvider.popularOffset++;
           _productProvider.showBottomLoader();

           _productProvider.getItemList(
             context,
             _productProvider.popularOffset.toString(),
             false, Provider.of<LocalizationProvider>(context, listen: false).locale.languageCode,
             widget.productType,
           );
         }
       }
     });
   }

    super.initState();
  }
  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {


    return Scaffold(
      appBar: ResponsiveHelper.isDesktop(context) ? PreferredSize(
          child: WebAppBar(), preferredSize: Size.fromHeight(120))
          : CustomAppBar(title:  getTranslated(widget.productType, context),
      ),
      body: SingleChildScrollView(
        controller: scrollController,
          child: Center(
              child: Column(
                children: [
                  ConstrainedBox(
                    constraints: BoxConstraints(minHeight: ResponsiveHelper.isDesktop(context) ? MediaQuery.of(context).size.height - 400 : MediaQuery.of(context).size.height),
                    child: Column(children: [
                      ResponsiveHelper.isDesktop(context) ? SizedBox(height: 20) : SizedBox.shrink(),

                    if(ResponsiveHelper.isDesktop(context) && widget.productType != ProductType.FLASH_SALE)
                      SizedBox(width: 1170,child: TitleWidget(
                        title:  getTranslated('${widget.productType}', context),
                      )),

                      if(widget.productType == ProductType.FLASH_SALE)
                        SizedBox(width: Dimensions.WEB_SCREEN_WIDTH, child: Column(children: [
                            Consumer<FlashDealProvider>(builder: (context, flashDealProvider, _) {
                                return flashDealProvider.flashDealList != null ? Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(Dimensions.RADIUS_SIZE_DEFAULT),
                                    child: FadeInImage.assetNetwork(
                                      width: double.maxFinite,
                                      height: MediaQuery.of(context).size.height * 0.2,
                                      placeholder: Images.placeholder(context),
                                      image: '${Provider.of<SplashProvider>(context,listen: false).baseUrls.flash_sale_imageUrl}'
                                          '/${flashDealProvider.flashDeal.banner ?? ''}',
                                      fit: BoxFit.fitWidth,
                                      imageErrorBuilder: (c, o, s) => Image.asset(Images.placeholder(context), fit: BoxFit.cover),
                                    ),
                                  ),
                                ) : SizedBox();
                              }),

                          Consumer<FlashDealProvider>(builder: (context, flashDealProvider, _) {
                                return Padding(
                                  padding: EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
                                  child: TitleRow(
                                    isDetailsPage: true,
                                    title: getTranslated('flash_deal', context),
                                    eventDuration: flashDealProvider.duration,
                                  ),
                                );
                              }
                            ),
                          ])),

                      SizedBox(width: 1170, child: Consumer<FlashDealProvider>(
                          builder: (context, flashDealProvider, child) {
                            return Consumer<ProductProvider>(
                              builder: (context, productProvider, child) {
                                List<Product> productList;

                                switch(widget.productType) {
                                  case ProductType.POPULAR_PRODUCT :
                                    productList = productProvider.popularProductList;
                                    break;
                                  case ProductType.DAILY_ITEM :
                                    productList = productProvider.dailyItemList;
                                    break;
                                  case ProductType.FEATURED_ITEM :
                                    productList = productProvider.featuredProductList;
                                    break;
                                  case ProductType.MOST_REVIEWED :
                                    productList = productProvider.mostViewedProductList;
                                    break;
                                  case ProductType.TRENDING_PRODUCT :
                                    productList = productProvider.trendingProduct;
                                    break;
                                  case ProductType.RECOMMEND_PRODUCT :
                                    productList = productProvider.recommendProduct;
                                    break;
                                  case ProductType.FLASH_SALE :
                                    productList = flashDealProvider.flashDealList;
                                    break;
                                }

                                return productList != null ? productList.length > 0 ?
                                Column(children: [
                                  GridView.builder(
                                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: ResponsiveHelper.isDesktop(context) ? 5 : ResponsiveHelper.isMobile(context) ? 2 : 4,
                                      mainAxisSpacing: ResponsiveHelper.isDesktop(context) ? 13 : 10,
                                      crossAxisSpacing: ResponsiveHelper.isDesktop(context) ? 13 : 10,
                                      childAspectRatio: (1/1.4),
                                    ),

                                    padding: EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
                                    physics: NeverScrollableScrollPhysics(),
                                    shrinkWrap: true,
                                    itemCount: productList.length,
                                    itemBuilder: (context ,index) {
                                      return ProductWidget(product: productList[index], isGrid: true);
                                    },
                                  ),

                                  if(productProvider.isLoading) Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Center(child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
                                    )),
                                  )
                                ],) : NoDataScreen() : SizedBox(height: MediaQuery.of(context).size.height*0.5,child: Center(child: CustomLoader(color: Theme.of(context).primaryColor)));
                              },
                            );
                          }
                      )),
                    ]),
                  ),

                  ResponsiveHelper.isDesktop(context) ? FooterView() : SizedBox(),
                ],
              ))),
    );
  }
}
