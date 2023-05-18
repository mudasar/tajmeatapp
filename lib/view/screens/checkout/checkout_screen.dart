import 'dart:collection';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_grocery/data/model/response/address_model.dart';
import 'package:flutter_grocery/data/model/response/config_model.dart';
import 'package:flutter_grocery/data/model/response/coupon_model.dart';
import 'package:flutter_grocery/helper/date_converter.dart';
import 'package:flutter_grocery/helper/responsive_helper.dart';
import 'package:flutter_grocery/helper/route_helper.dart';
import 'package:flutter_grocery/localization/language_constrants.dart';
import 'package:flutter_grocery/provider/auth_provider.dart';
import 'package:flutter_grocery/provider/cart_provider.dart';
import 'package:flutter_grocery/provider/coupon_provider.dart';
import 'package:flutter_grocery/provider/localization_provider.dart';
import 'package:flutter_grocery/provider/location_provider.dart';
import 'package:flutter_grocery/provider/order_provider.dart';
import 'package:flutter_grocery/provider/splash_provider.dart';
import 'package:flutter_grocery/provider/theme_provider.dart';
import 'package:flutter_grocery/utill/color_resources.dart';
import 'package:flutter_grocery/utill/dimensions.dart';
import 'package:flutter_grocery/utill/images.dart';
import 'package:flutter_grocery/utill/styles.dart';
import 'package:flutter_grocery/view/base/custom_app_bar.dart';
import 'package:flutter_grocery/view/base/custom_loader.dart';
import 'package:flutter_grocery/view/base/custom_snackbar.dart';
import 'package:flutter_grocery/view/base/not_login_screen.dart';
import 'package:flutter_grocery/view/base/web_app_bar/web_app_bar.dart';
import 'package:flutter_grocery/view/screens/address/add_new_address_screen.dart';
import 'package:flutter_grocery/view/screens/checkout/widget/delivery_fee_dialog.dart';
import 'package:flutter_grocery/view/screens/checkout/widget/details_view.dart';
import 'package:flutter_grocery/view/screens/checkout/widget/placeOrderButtonView.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

class CheckoutScreen extends StatefulWidget {
  final double amount;
  final String orderType;
  final double discount;
  final String couponCode;
  final String freeDeliveryType;
  CheckoutScreen({@required this.amount, @required this.orderType, @required this.discount, @required this.couponCode,@required this.freeDeliveryType});

  @override
  _CheckoutScreenState createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final GlobalKey<ScaffoldMessengerState> _scaffoldKey = GlobalKey();
  final TextEditingController _noteController = TextEditingController();
  GoogleMapController _mapController;
  List<Branches> _branches = [];
  bool _loading = true;
  Set<Marker> _markers = HashSet<Marker>();
  bool _isLoggedIn;
  List<String> _paymentList = [];

  @override
  void initState() {
    super.initState();

    // print('free delivery is  : ${widget.freeDeliveryType} ${Provider.of<CartProvider>(context, listen: false).}');

    Provider.of<OrderProvider>(context, listen: false).clearPrevData();

    _isLoggedIn = Provider.of<AuthProvider>(context, listen: false).isLoggedIn();
    if(_isLoggedIn ) {
      Provider.of<OrderProvider>(context, listen: false).setAddressIndex(-1, notify: false);
      Provider.of<OrderProvider>(context, listen: false).initializeTimeSlot(context);
      Provider.of<LocationProvider>(context, listen: false).initAddressList(context);
      _branches = Provider.of<SplashProvider>(context, listen: false).configModel.branches;
    }

    if(Provider.of<SplashProvider>(context, listen: false).configModel.cashOnDelivery == 'true') {
      _paymentList.add('cash_on_delivery');
    }

    if(Provider.of<SplashProvider>(context, listen: false).configModel.offlinePayment) {
      _paymentList.add('offline_payment');
    }

    if(Provider.of<SplashProvider>(context, listen: false).configModel.walletStatus) {
      _paymentList.add('wallet_payment');
    }

    Provider.of<SplashProvider>(context, listen: false).configModel.activePaymentMethodList.forEach((_method){
      if(!_paymentList.contains(_method)) {
        _paymentList.add(_method);
      }

    });
  }

  double setDeliveryCharge(double charge){
    return charge;

  }

  @override
  Widget build(BuildContext context) {
    bool _kmWiseCharge = Provider.of<SplashProvider>(context, listen: false).configModel.deliveryManagement.status == 1;
    bool _selfPickup = widget.orderType == 'self_pickup';

    return Scaffold(
      key: _scaffoldKey,
      appBar: ResponsiveHelper.isDesktop(context)? PreferredSize(child: WebAppBar(), preferredSize: Size.fromHeight(120))  : CustomAppBar(title: getTranslated('checkout', context)),
      body:  _isLoggedIn ? Consumer<OrderProvider>(
        builder: (context, order, child) {
          double _deliveryCharge = order.distance
              * Provider.of<SplashProvider>(context, listen: false).configModel.deliveryManagement.shippingPerKm;
          if(_deliveryCharge < Provider.of<SplashProvider>(context, listen: false).configModel.deliveryManagement.minShippingCharge) {
            _deliveryCharge = Provider.of<SplashProvider>(context, listen: false).configModel.deliveryManagement.minShippingCharge;
          }
          if(!_kmWiseCharge || order.distance == -1
              || (widget.amount + widget.discount) > Provider.of<SplashProvider>(context, listen: false).configModel.freeDeliveryOverAmount) {
            _deliveryCharge = 0;
          }

          return Consumer<LocationProvider>(
            builder: (context, address, child) {
              return Column(
                children: [

                  Expanded(child: SingleChildScrollView(
                    physics: BouncingScrollPhysics(),
                    child: Center(child: SizedBox(width: 1170, child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Expanded(flex: 4, child: Container(
                            margin: ResponsiveHelper.isDesktop(context) ?  EdgeInsets.symmetric(
                              horizontal: Dimensions.PADDING_SIZE_SMALL,
                              vertical: Dimensions.PADDING_SIZE_LARGE,
                            ) : EdgeInsets.all(0),

                            decoration:ResponsiveHelper.isDesktop(context) ? BoxDecoration(
                                color: Theme.of(context).cardColor,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color:ColorResources.CARD_SHADOW_COLOR.withOpacity(0.2),
                                    blurRadius: 10,
                                  )
                                ]
                            ) : BoxDecoration(),
                            child: Column(children: [
                              //Branch
                              _branches.length > 0 ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Padding(
                                  padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                                  child: Text(getTranslated('select_branch', context), style: poppinsMedium.copyWith(fontSize: Dimensions.FONT_SIZE_LARGE)),
                                ),

                                SizedBox(
                                  height: 50,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    padding: EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
                                    physics: BouncingScrollPhysics(),
                                    itemCount: _branches.length,
                                    itemBuilder: (context, index) {
                                      return Padding(
                                        padding: EdgeInsets.only(right: Dimensions.PADDING_SIZE_SMALL),
                                        child: InkWell(
                                          onTap: () {
                                            try {
                                              order.setBranchIndex(index);
                                              double.parse(_branches[index].latitude);
                                              _setMarkers(index);
                                            }catch(e) {}
                                          },
                                          child: Container(
                                            padding: EdgeInsets.symmetric(vertical: Dimensions.PADDING_SIZE_EXTRA_SMALL, horizontal: Dimensions.PADDING_SIZE_SMALL),
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(
                                              color: index == order.branchIndex ? Theme.of(context).primaryColor : ColorResources.getBackgroundColor(context),
                                              borderRadius: BorderRadius.circular(5),
                                            ),
                                            child: Text(_branches[index].name, maxLines: 1, overflow: TextOverflow.ellipsis, style: poppinsMedium.copyWith(
                                              color: index == order.branchIndex ? Colors.white : Theme.of(context).textTheme.bodyLarge.color,
                                            )),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),

                                Container(
                                  height: 200,
                                  padding: EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
                                  margin: EdgeInsets.symmetric(horizontal: Dimensions.PADDING_SIZE_SMALL),
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: Theme.of(context).cardColor,
                                  ),
                                  child: Stack(children: [
                                    GoogleMap(
                                      minMaxZoomPreference: MinMaxZoomPreference(0, 16),
                                      mapType: MapType.normal,
                                      initialCameraPosition: CameraPosition(target: LatLng(
                                        double.parse(_branches[0].latitude),
                                        double.parse(_branches[0].longitude),
                                      ), zoom: 8),
                                      zoomControlsEnabled: true,
                                      markers: _markers,
                                      onMapCreated: (GoogleMapController controller) async {
                                        await Geolocator.requestPermission();
                                        _mapController = controller;
                                        _loading = false;
                                        _setMarkers(0);
                                      },
                                    ),
                                    _loading ? Center(child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
                                    )) : SizedBox(),
                                  ]),
                                ),
                              ]) : SizedBox(),

                              // Address
                              !_selfPickup ? Column(children: [
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: Dimensions.PADDING_SIZE_SMALL),
                                  child: Row(children: [
                                    Text(getTranslated('delivery_address', context), style: poppinsMedium.copyWith(fontSize: Dimensions.FONT_SIZE_LARGE)),
                                    Expanded(child: SizedBox()),
                                    TextButton.icon(
                                      onPressed: () => Navigator.pushNamed(context, RouteHelper.getAddAddressRoute('checkout', 'add', AddressModel()), arguments: AddNewAddressScreen(fromCheckout: true)),
                                      icon: Icon(Icons.add),
                                      label: Text(getTranslated('add', context), style: poppinsRegular),
                                    ),
                                  ]),
                                ),

                                address.addressList != null ? address.addressList.length > 0 ? ListView.builder(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  padding: EdgeInsets.symmetric(horizontal: Dimensions.PADDING_SIZE_SMALL),
                                  itemCount: address.addressList.length,
                                  itemBuilder: (context, index) {
                                    bool _isAvailable = _branches.length == 1 && (_branches[0].latitude == null || _branches[0].latitude.isEmpty);
                                    if(!_isAvailable) {
                                      double _distance = Geolocator.distanceBetween(
                                        double.parse(_branches[order.branchIndex].latitude), double.parse(_branches[order.branchIndex].longitude),
                                        double.parse(address.addressList[index].latitude), double.parse(address.addressList[index].longitude),
                                      ) / 1000;
                                      _isAvailable = _distance < _branches[order.branchIndex].coverage;
                                    }

                                    return Padding(
                                      padding: EdgeInsets.only(bottom: Dimensions.PADDING_SIZE_SMALL),
                                      child: InkWell(
                                        onTap: () async {
                                          if(_isAvailable) {
                                            order.setAddressIndex(index);
                                            if(_kmWiseCharge) {
                                              showDialog(context: context, builder: (context) => Center(child: Container(
                                                height: 100, width: 100, decoration: BoxDecoration(
                                                color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(10),
                                              ),
                                                alignment: Alignment.center,
                                                child: CustomLoader(color: Theme.of(context).primaryColor),
                                              )), barrierDismissible: false);
                                              bool _isSuccess = await order.getDistanceInMeter(
                                                LatLng(
                                                  double.parse(_branches[order.branchIndex].latitude),
                                                  double.parse(_branches[order.branchIndex].longitude),
                                                ),
                                                LatLng(
                                                  double.parse(address.addressList[index].latitude),
                                                  double.parse(address.addressList[index].longitude),
                                                ),
                                              );
                                              Navigator.pop(context);
                                              if(_isSuccess) {
                                                showDialog(context: context, builder: (context) => DeliveryFeeDialog(
                                                  freeDelivery: widget.freeDeliveryType == 'free_delivery',
                                                  amount: widget.amount, distance: order.distance,
                                                  callBack: (deliveryChargeAmount){
                                                    print('delivery ch----> $deliveryChargeAmount');
                                                    _deliveryCharge = deliveryChargeAmount;
                                                  }
                                                  //=> _deliveryCharge = deliveryChargeAmount,
                                                ));
                                              }else {
                                                showCustomSnackBar(getTranslated('failed_to_fetch_distance', context), context);
                                              }
                                            }
                                          }
                                        },
                                        child: Stack(
                                          children: [
                                            Container(
                                              padding: EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
                                              decoration: BoxDecoration(
                                                color: ColorResources.getCardBgColor(context),
                                                borderRadius: BorderRadius.circular(10),
                                                boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.2), spreadRadius: .5, blurRadius: .5)],
                                              ),
                                              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                                Padding(
                                                  padding: EdgeInsets.symmetric(horizontal: Dimensions.PADDING_SIZE_EXTRA_SMALL),
                                                  child: Container(
                                                    width: 20, height: 20,
                                                    decoration: BoxDecoration(
                                                      color: Theme.of(context).cardColor,
                                                      border: Border.all(
                                                        color: index == order.addressIndex ? Theme.of(context).primaryColor
                                                            : ColorResources.getHintColor(context).withOpacity(0.6),
                                                        width: index == order.addressIndex ? 7 : 5,
                                                      ),
                                                      shape: BoxShape.circle,
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(width: 10),
                                                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                                                  Text(address.addressList[index].addressType, style: poppinsBold.copyWith(
                                                    fontSize: Dimensions.FONT_SIZE_SMALL,
                                                    color: index == order.addressIndex ? ColorResources.getTextColor(context)
                                                        : ColorResources.getHintColor(context).withOpacity(.8),
                                                  )),
                                                  Text(address.addressList[index].address, style: poppinsRegular.copyWith(
                                                    color: index == order.addressIndex ? ColorResources.getTextColor(context)
                                                        : ColorResources.getHintColor(context).withOpacity(.8),
                                                  ), maxLines: 2, overflow: TextOverflow.ellipsis),
                                                ])),
                                              ]),
                                            ),

                                            !_isAvailable ? Positioned(
                                              top: 0, left: 0, bottom: 10, right: 0,
                                              child: Container(
                                                alignment: Alignment.center,
                                                decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: Colors.black.withOpacity(0.6)),
                                                child: Text(
                                                  getTranslated('out_of_coverage_for_this_branch', context),
                                                  textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis,
                                                  style: poppinsRegular.copyWith(color: Colors.white, fontSize: 10),
                                                ),
                                              ),
                                            ) : SizedBox(),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ) : Center(child: Text(getTranslated('no_address_found', context)))
                                    : Center(child: CustomLoader(color: Theme.of(context).primaryColor)),
                                SizedBox(height: 20),
                              ]) : SizedBox(),

                              // Time Slot
                              Align(
                                alignment: Provider.of<LocalizationProvider>(context, listen: false).isLtr
                                    ? Alignment.topLeft : Alignment.topRight,
                                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  Padding(
                                    padding: EdgeInsets.symmetric(horizontal: Dimensions.PADDING_SIZE_SMALL),
                                    child: Text(getTranslated('preference_time', context), style: poppinsMedium.copyWith(fontSize: Dimensions.FONT_SIZE_LARGE)),
                                  ),
                                  SizedBox(height: 10),

                                  Container(
                                    height: 52,
                                    child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      shrinkWrap: true,
                                      padding: EdgeInsets.symmetric(horizontal: 15),
                                      physics: BouncingScrollPhysics(),
                                      itemCount: 3,
                                      itemBuilder: (context, index) {
                                        return Padding(
                                          padding: EdgeInsets.only(right: 18, bottom: 2, top: 2),
                                          child: InkWell(
                                            onTap: () => order.updateDateSlot(index),
                                            child: Container(
                                              padding: EdgeInsets.symmetric(vertical: 13, horizontal: 20),
                                              alignment: Alignment.center,
                                              decoration: BoxDecoration(
                                                color: order.selectDateSlot == index ? Theme.of(context).primaryColor
                                                    : ColorResources.getTimeColor(context),
                                                borderRadius: BorderRadius.circular(7),
                                                boxShadow: [ BoxShadow(color: Colors.grey[Provider.of<ThemeProvider>(context).darkTheme ? 800 : 100], spreadRadius: .5, blurRadius: .5)],),
                                              child: Text(
                                                index == 0 ? getTranslated('today', context) : index == 1 ? getTranslated('tomorrow', context)
                                                    : DateConverter.estimatedDate(DateTime.now().add(Duration(days: 2))),
                                                style: poppinsRegular.copyWith(
                                                    fontSize: Dimensions.FONT_SIZE_LARGE,
                                                    color: order.selectDateSlot == index ? Colors.white : Colors.grey[500]
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  SizedBox(height: 12),

                                  order.timeSlots != null ? SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(
                                    children: order.timeSlots.map((timeSlotModel) {
                                      int index = order.timeSlots.indexOf(timeSlotModel);
                                      return Padding(
                                        padding: EdgeInsets.symmetric(horizontal: Dimensions.PADDING_SIZE_DEFAULT),
                                        child: InkWell(
                                          onTap: () => order.updateTimeSlot(index),
                                          child: Container(
                                            padding: EdgeInsets.symmetric(vertical: 13, horizontal: 20),
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(
                                              color: order.selectTimeSlot == index
                                                  ? Theme.of(context).primaryColor
                                                  : ColorResources.getTimeColor(context),
                                              borderRadius: BorderRadius.circular(7),
                                              boxShadow: [BoxShadow(
                                                color: Colors.grey[Provider.of<ThemeProvider>(context).darkTheme ? 800 : 100],
                                                spreadRadius: .5, blurRadius: .5,
                                              )],
                                            ),
                                            child: Text(
                                              '${DateConverter.stringToStringTime(order.timeSlots[index].startTime, context)} '
                                                  '- ${DateConverter.stringToStringTime(order.timeSlots[index].endTime, context)}',
                                              style: poppinsRegular.copyWith(
                                                fontSize: Dimensions.FONT_SIZE_LARGE,
                                                color: order.selectTimeSlot == index
                                                    ? Colors.white : Colors.grey[500],
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  )) : Center(child: CustomLoader(color: Theme.of(context).primaryColor)),


                                  SizedBox(height: 20),
                                ]),
                              ),

                              if(!ResponsiveHelper.isDesktop(context))
                                DetailsView(
                                  freeDelivery: widget.freeDeliveryType == 'free_delivery',
                                  amount: widget.amount,
                                  paymentList: _paymentList,
                                  noteController: _noteController,
                                  kmWiseCharge: _kmWiseCharge,
                                  selfPickup: _selfPickup,
                                  deliveryCharge: _deliveryCharge,
                                ),

                            ]),
                          )),

                          if(ResponsiveHelper.isDesktop(context))
                            Expanded(flex: 4, child: Container(
                              margin: EdgeInsets.symmetric(
                                horizontal: Dimensions.PADDING_SIZE_SMALL,
                                vertical: Dimensions.PADDING_SIZE_LARGE,
                              ),
                              decoration: BoxDecoration(
                                color: Theme.of(context).cardColor,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color:ColorResources.CARD_SHADOW_COLOR.withOpacity(0.2),
                                    blurRadius: 10,
                                  )
                                ],
                              ),
                              child: Column(children: [
                                SizedBox(height: Dimensions.PADDING_SIZE_SMALL),

                                Builder(
                                  builder: (context) {

                                    return DetailsView(
                                      freeDelivery: widget.freeDeliveryType == 'free_delivery',
                                      amount: widget.amount,
                                      paymentList: _paymentList,
                                      noteController: _noteController,
                                      kmWiseCharge: _kmWiseCharge,
                                      selfPickup: _selfPickup,
                                      deliveryCharge: _deliveryCharge,
                                    );
                                  }
                                ),
                                SizedBox(height: Dimensions.PADDING_SIZE_EXTRA_LARGE),

                                PlaceOrderButtonView(
                                  amount: widget.amount, couponCode: widget.couponCode, deliveryCharge: _deliveryCharge,
                                  kmWiseCharge: _kmWiseCharge, noteController: _noteController, orderType: widget.orderType,
                                  selfPickUp: _selfPickup,
                                )


                              ]),
                            )),


                        ]))),
                  )),

                 if(!ResponsiveHelper.isDesktop(context))
                   Center(child: PlaceOrderButtonView(
                     amount: widget.amount, couponCode: widget.couponCode, deliveryCharge: _deliveryCharge,
                     kmWiseCharge: _kmWiseCharge, noteController: _noteController, orderType: widget.orderType,
                     selfPickUp: _selfPickup,
                  )),

                ],
              );
            },
          );
        },
      ) : NotLoggedInScreen()
    );
  }

  void _setMarkers(int selectedIndex) async {
    BitmapDescriptor _bitmapDescriptor;
    BitmapDescriptor _bitmapDescriptorUnSelect;
    await BitmapDescriptor.fromAssetImage(ImageConfiguration(size: Size(25, 30)), Images.restaurant_marker).then((_marker) {
      _bitmapDescriptor = _marker;
    });
    await BitmapDescriptor.fromAssetImage(ImageConfiguration(size: Size(20, 20)), Images.unselected_restaurant_marker).then((_marker) {
      _bitmapDescriptorUnSelect = _marker;
    });
    // Marker
    _markers = HashSet<Marker>();
    for(int index=0; index<_branches.length; index++) {
      _markers.add(Marker(
        markerId: MarkerId('branch_$index'),
        position: LatLng(double.tryParse(_branches[index].latitude), double.tryParse(_branches[index].longitude)),
        infoWindow: InfoWindow(title: _branches[index].name, snippet: _branches[index].address),
        icon: selectedIndex == index ? _bitmapDescriptor : _bitmapDescriptorUnSelect,
      ));
    }

    _mapController.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target: LatLng(
      double.tryParse(_branches[selectedIndex].latitude),
      double.tryParse(_branches[selectedIndex].longitude),
    ), zoom: ResponsiveHelper.isMobile(context) ? 12 : 16)));

    setState(() {});
  }

  Future<Uint8List> convertAssetToUnit8List(String imagePath, {int width = 50}) async {
    ByteData data = await rootBundle.load(imagePath);
    Codec codec = await instantiateImageCodec(data.buffer.asUint8List(), targetWidth: width);
    FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ImageByteFormat.png)).buffer.asUint8List();
  }

}


