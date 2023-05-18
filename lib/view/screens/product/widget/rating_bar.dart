import 'package:flutter/material.dart';
import 'package:flutter_grocery/helper/responsive_helper.dart';
import 'package:flutter_grocery/provider/product_provider.dart';
import 'package:flutter_grocery/utill/dimensions.dart';
import 'package:flutter_grocery/utill/styles.dart';
import 'package:provider/provider.dart';
class RatingLine extends StatelessWidget {
  const RatingLine({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Consumer<ProductProvider>(
      builder: (context, productProvider, child) {
        int _fiveStar = 0;
        int _fourStar = 0;
        int _threeStar = 0;
        int _twoStar = 0;
        int _oneStar = 0;

        productProvider.product.activeReviews.forEach((review) {
          if(review.rating >= 4.5){
            _fiveStar++;
          }else if(review.rating >= 3.5 && review.rating < 4.5) {
            _fourStar++;
          }else if(review.rating >= 2.5 && review.rating < 3.5) {
            _threeStar++;
          }else if(review.rating >= 1.5 && review.rating < 12.5){
            _twoStar++;
          }else{
            _oneStar++;
          }
        });


        double five = (_fiveStar * 100) / 5;
        double four = (_fourStar * 100) / 4;
        double three = (_threeStar * 100) / 3;
        double two = (_twoStar * 100) / 2;
        double one = (_oneStar * 100) / 1;

        return Column(children: [
          
          Row(children: [
            Expanded(flex: ResponsiveHelper.isDesktop(context) ? 3 : 4,child: Text('Excellent',style: poppinsRegular.copyWith(color: Theme.of(context).hintColor,fontSize: Dimensions.FONT_SIZE_DEFAULT))),
            Expanded(flex:ResponsiveHelper.isDesktop(context) ? 8 : 9,child: Stack(
              children: [
                Container(
                  height: Dimensions.PADDING_SIZE_SMALL,width: 300,
                  decoration: BoxDecoration(color: Theme.of(context).hintColor.withOpacity(0.3),borderRadius: BorderRadius.circular(20)),
                ),
                Container(
                  height: Dimensions.PADDING_SIZE_SMALL,width: 300 *(five /100),
                  decoration: BoxDecoration(color: Colors.green,borderRadius: BorderRadius.circular(20)),
                ),
              ],
            ),),
          ]),
          SizedBox(height: Dimensions.PADDING_SIZE_SMALL),
          Row(children: [
            Expanded(flex:ResponsiveHelper.isDesktop(context) ? 3 : 4,child: Text('Good',style: poppinsRegular.copyWith(color: Theme.of(context).hintColor,fontSize: Dimensions.FONT_SIZE_DEFAULT))),
            Expanded(flex:ResponsiveHelper.isDesktop(context) ? 8 : 9,child: Stack(
              children: [
                Container(
                  height: Dimensions.PADDING_SIZE_SMALL,width: 300,
                  decoration: BoxDecoration(color: Theme.of(context).hintColor.withOpacity(0.3),borderRadius: BorderRadius.circular(20)),
                ),
                Container(
                  height: Dimensions.PADDING_SIZE_SMALL,width: 300 *(four/100),
                  decoration: BoxDecoration(color: Colors.greenAccent,borderRadius: BorderRadius.circular(20)),
                ),
              ],
            ),),
          ]),
          SizedBox(height: Dimensions.PADDING_SIZE_SMALL),
          Row(children: [
            Expanded(flex:ResponsiveHelper.isDesktop(context) ? 3 : 4,child: Text('Average',style: poppinsRegular.copyWith(color: Theme.of(context).hintColor,fontSize: Dimensions.FONT_SIZE_DEFAULT))),
            Expanded(flex:ResponsiveHelper.isDesktop(context) ? 8 : 9,child: Stack(
              children: [
                Container(
                  height: Dimensions.PADDING_SIZE_SMALL,width: 300,
                  decoration: BoxDecoration(color: Theme.of(context).hintColor.withOpacity(0.3),borderRadius: BorderRadius.circular(20)),
                ),
                Container(
                  height: Dimensions.PADDING_SIZE_SMALL,width: 300 *(three /100),
                  decoration: BoxDecoration(color: Colors.orange,borderRadius: BorderRadius.circular(20)),
                ),
              ],
            ),),
          ]),
          SizedBox(height: Dimensions.PADDING_SIZE_SMALL),
          Row(children: [
            Expanded(flex:ResponsiveHelper.isDesktop(context) ? 3 : 4,child: Text('Below Average',style: poppinsRegular.copyWith(color: Theme.of(context).hintColor,fontSize: Dimensions.FONT_SIZE_DEFAULT))),
            Expanded(flex:ResponsiveHelper.isDesktop(context) ? 8 : 9,child: Stack(
              children: [
                Container(
                  height: Dimensions.PADDING_SIZE_SMALL,width: 300,
                  decoration: BoxDecoration(color: Theme.of(context).hintColor.withOpacity(0.3),borderRadius: BorderRadius.circular(20)),
                ),
                Container(
                  height: Dimensions.PADDING_SIZE_SMALL,width: 300 *(two /100),
                  decoration: BoxDecoration(color: Colors.deepOrange,borderRadius: BorderRadius.circular(20)),
                ),
              ],
            ),),
          ]),
          SizedBox(height: Dimensions.PADDING_SIZE_SMALL),
          Row(children: [
            Expanded(flex:ResponsiveHelper.isDesktop(context) ? 3 : 4,child: Text('Poor',style: poppinsRegular.copyWith(color: Theme.of(context).hintColor,fontSize: Dimensions.FONT_SIZE_DEFAULT))),
            Expanded(flex:ResponsiveHelper.isDesktop(context) ? 8 : 9,child: Stack(
              children: [
                Container(
                  height: Dimensions.PADDING_SIZE_SMALL,width: 300,
                  decoration: BoxDecoration(color: Theme.of(context).hintColor.withOpacity(0.3),borderRadius: BorderRadius.circular(20)),
                ),
                Container(
                  height: Dimensions.PADDING_SIZE_SMALL,width: 300 *(one /100),
                  decoration: BoxDecoration(color: Colors.red,borderRadius: BorderRadius.circular(20)),
                ),
              ],
            ),),
          ]),
        ],);
      }
    );
  }
}
