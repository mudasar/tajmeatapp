
import 'package:flutter/material.dart';
import 'package:flutter_grocery/data/model/response/address_model.dart';
import 'package:flutter_grocery/helper/responsive_helper.dart';
import 'package:flutter_grocery/helper/route_helper.dart';
import 'package:flutter_grocery/localization/language_constrants.dart';
import 'package:flutter_grocery/provider/location_provider.dart';
import 'package:flutter_grocery/provider/profile_provider.dart';
import 'package:flutter_grocery/provider/splash_provider.dart';
import 'package:flutter_grocery/utill/color_resources.dart';
import 'package:flutter_grocery/utill/dimensions.dart';
import 'package:flutter_grocery/utill/styles.dart';
import 'package:flutter_grocery/view/base/custom_app_bar.dart';
import 'package:flutter_grocery/view/base/footer_view.dart';
import 'package:flutter_grocery/view/base/web_app_bar/web_app_bar.dart';
import 'package:flutter_grocery/view/screens/address/select_location_screen.dart';
import 'package:flutter_grocery/view/screens/address/widget/buttons_view.dart';
import 'package:flutter_grocery/view/screens/address/widget/details_view.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import 'widget/permission_dialog.dart';

class AddNewAddressScreen extends StatefulWidget {
  final bool isEnableUpdate;
  final bool fromCheckout;
  final AddressModel address;
  AddNewAddressScreen({this.isEnableUpdate = true, this.address, this.fromCheckout = false});

  @override
  State<AddNewAddressScreen> createState() => _AddNewAddressScreenState();
}

class _AddNewAddressScreenState extends State<AddNewAddressScreen> {
  final TextEditingController _contactPersonNameController = TextEditingController();
  final TextEditingController _contactPersonNumberController = TextEditingController();
  final TextEditingController _locationTextController = TextEditingController();
  final TextEditingController _streetNumberController = TextEditingController();
  final TextEditingController _houseNumberController = TextEditingController();
  final TextEditingController _florNumberController = TextEditingController();
  final FocusNode _addressNode = FocusNode();
  final FocusNode _nameNode = FocusNode();
  final FocusNode _numberNode = FocusNode();
  final FocusNode _stateNode = FocusNode();
  final FocusNode _houseNode = FocusNode();
  final FocusNode _floorNode = FocusNode();
  GoogleMapController _controller;
  CameraPosition _cameraPosition;
  bool _updateAddress = true;
  _initLoading() async {
    final _userModel =  Provider.of<ProfileProvider>(context, listen: false).userInfoModel ;
    if(widget.address == null) {
      Provider.of<LocationProvider>(context, listen: false).setAddAddressData(false);
    }


    await Provider.of<LocationProvider>(context, listen: false).initializeAllAddressType(context: context);
    Provider.of<LocationProvider>(context, listen: false).updateAddressStatusMessage(message: '');
    Provider.of<LocationProvider>(context, listen: false).updateErrorMessage(message: '');

    if (widget.isEnableUpdate && widget.address != null) {
      _updateAddress = false;

      Provider.of<LocationProvider>(context, listen: false).updatePosition(
        CameraPosition(target: LatLng(double.parse(widget.address.latitude),
          double.parse(widget.address.longitude))), true, widget.address.address, context, false,
      );
      _contactPersonNameController.text = '${widget.address.contactPersonName}';
      _contactPersonNumberController.text = '${widget.address.contactPersonNumber}';
      _streetNumberController.text = '${widget.address.streetNumber ?? ''}';
      _houseNumberController.text = '${widget.address.houseNumber ?? ''}';
      _florNumberController.text = '${widget.address.floorNumber ?? ''}';

      if (widget.address.addressType == 'Home') {
        Provider.of<LocationProvider>(context, listen: false).updateAddressIndex(0, false);
      } else if (widget.address.addressType == 'Workplace') {
        Provider.of<LocationProvider>(context, listen: false).updateAddressIndex(1, false);
      } else {
        Provider.of<LocationProvider>(context, listen: false).updateAddressIndex(2, false);
      }
    }else {
      _contactPersonNameController.text = _userModel == null ? '' : '${_userModel.fName}' ' ${_userModel.lName}';
      _contactPersonNumberController.text =  _userModel == null ? '' : _userModel.phone;
    }


  }

  @override
  void initState() {
    super.initState();

    _initLoading();

    if(widget.address != null && !widget.fromCheckout) {
      _locationTextController.text = widget.address.address;
    }



  }

  @override
  Widget build(BuildContext context) {
    final _height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: ResponsiveHelper.isDesktop(context)
          ? PreferredSize(child: WebAppBar(), preferredSize: Size.fromHeight(120))
          : CustomAppBar(title: widget.isEnableUpdate
          ? getTranslated('update_address', context)
          : getTranslated('add_new_address', context),
      ),

      body: Consumer<LocationProvider>(
        builder: (context, locationProvider, child) {
          return Column(
            children: [
              Expanded(
                child: Scrollbar(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        ConstrainedBox(
                          constraints: BoxConstraints(
                              minHeight: !ResponsiveHelper.isDesktop(context) && _height < 600 ? _height : _height - 400),
                          child: Padding(
                            padding: EdgeInsets.all(Dimensions.PADDING_SIZE_LARGE),
                            child: Center(
                              child: SizedBox(
                                width: 1170,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if(!ResponsiveHelper.isDesktop(context)) mapView(context, locationProvider),
                                    // for label us
                                    if(!ResponsiveHelper.isDesktop(context)) DetailsView(
                                      locationProvider: locationProvider,
                                      contactPersonNameController: _contactPersonNameController,
                                      contactPersonNumberController: _contactPersonNumberController,
                                      addressNode: _addressNode, nameNode: _nameNode,
                                      numberNode: _numberNode, fromCheckout: widget.fromCheckout,
                                      address: widget.address, isEnableUpdate: widget.isEnableUpdate,
                                      locationTextController: _locationTextController,
                                      streetNumberController: _streetNumberController,
                                      houseNumberController: _houseNumberController,
                                      houseNode: _houseNode,
                                      stateNode: _stateNode,
                                      florNumberController: _florNumberController,
                                      florNode: _floorNode,
                                    ),

                                    // if(!ResponsiveHelper.isDesktop(context)) detailsWidget(context),

                                    if(ResponsiveHelper.isDesktop(context))IntrinsicHeight(
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            flex : 6,
                                            child: mapView(context, locationProvider),
                                          ),

                                          SizedBox(width: Dimensions.PADDING_SIZE_DEFAULT),

                                          Expanded(
                                            flex: 4,
                                            child: DetailsView(
                                              locationProvider: locationProvider,
                                              contactPersonNameController: _contactPersonNameController,
                                              contactPersonNumberController: _contactPersonNumberController,
                                              addressNode: _addressNode, nameNode: _nameNode,
                                              numberNode: _numberNode, isEnableUpdate: widget.isEnableUpdate,
                                              address: widget.address, fromCheckout: widget.fromCheckout,
                                              locationTextController: _locationTextController,
                                              streetNumberController: _streetNumberController,
                                              houseNumberController: _houseNumberController,
                                              houseNode: _houseNode,
                                              stateNode: _stateNode,
                                              florNumberController: _florNumberController,
                                              florNode: _floorNode,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        if(ResponsiveHelper.isDesktop(context)) FooterView(),
                      ],
                    ),
                  ),
                ),
              ),
              if(!ResponsiveHelper.isDesktop(context)) ButtonsView(
                locationProvider: locationProvider,
                isEnableUpdate: widget.isEnableUpdate,
                fromCheckout: widget.fromCheckout,
                contactPersonNumberController:
                _contactPersonNumberController,
                contactPersonNameController: _contactPersonNameController,
                address: widget.address,
                location: _locationTextController.text,
                streetNumberController: _streetNumberController,
                houseNumberController: _houseNumberController,
                floorNumberController: _florNumberController,
              ),

            ],
          );
        },
      ),
    );
  }

  Widget mapView(BuildContext context, LocationProvider locationProvider) {
    return Container(
      decoration: ResponsiveHelper.isDesktop(context) ?  BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color:ColorResources.CARD_SHADOW_COLOR.withOpacity(0.2),
              blurRadius: 10,
            )
          ]
      ) : BoxDecoration(),
      
      padding: ResponsiveHelper.isDesktop(context) ?  EdgeInsets.symmetric(
        horizontal: Dimensions.PADDING_SIZE_LARGE,vertical: Dimensions.PADDING_SIZE_LARGE,
      ) : EdgeInsets.zero,
      
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

         if(ResponsiveHelper.isDesktop(context)) Expanded(
            child: _map(context, locationProvider),
          ),

          if(!ResponsiveHelper.isDesktop(context)) _map(context, locationProvider),

          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Center(
                child: Text(
                  getTranslated('add_the_location_correctly', context),
                  style: poppinsRegular.copyWith(
                    color: Theme.of(context).textTheme.bodyText1.color,
                    fontSize: Dimensions.FONT_SIZE_SMALL,
                  ),
                )),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24.0),
            child: Text(
              getTranslated('label_us', context),
              style: poppinsRegular.copyWith(
                color: Theme.of(context).hintColor, fontSize: Dimensions.FONT_SIZE_LARGE,
              ),

            ),
          ),

          Container(
            height: 50,
            child: ListView.builder(
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              physics: BouncingScrollPhysics(),
              itemCount: locationProvider.getAllAddressType.length,
              itemBuilder: (context, index) => InkWell(
                onTap: () {
                  locationProvider.updateAddressIndex(index, true);
                },
                child: Container(
                  padding: EdgeInsets.symmetric(
                    vertical: Dimensions.PADDING_SIZE_DEFAULT,
                    horizontal: Dimensions.PADDING_SIZE_LARGE,
                  ),
                  margin: EdgeInsets.only(right: 17),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(Dimensions.PADDING_SIZE_SMALL),
                    border: Border.all(color: locationProvider.selectAddressIndex == index
                        ? Theme.of(context).primaryColor : ColorResources.BORDER_COLOR
                    ),
                    color: locationProvider.selectAddressIndex == index
                        ? Theme.of(context).primaryColor : ColorResources.SEARCH_BG,
                  ),
                  child: Text(
                    getTranslated(locationProvider.getAllAddressType[index].toLowerCase(), context),
                    style: poppinsRegular.copyWith(
                      color: locationProvider.selectAddressIndex == index
                          ? Theme.of(context).cardColor
                          : ColorResources.getHintColor(context),
                    ),

                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _map(BuildContext context, LocationProvider locationProvider) {
    final _branch = Provider.of<SplashProvider>(context, listen: false).configModel.branches[0];
    return Container(
            height: ResponsiveHelper.isMobile(context) ? 130 : 250,
            width: MediaQuery.of(context).size.width,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(Dimensions.PADDING_SIZE_SMALL),
              child: Stack(
                clipBehavior: Clip.none, children: [
                GoogleMap(
                  minMaxZoomPreference: MinMaxZoomPreference(0, 16),
                  mapType: MapType.normal,
                  initialCameraPosition: CameraPosition(
                    target: widget.isEnableUpdate
                        ? LatLng(double.parse(widget.address.latitude)
                        ?? double.parse(_branch.latitude), double.parse(widget.address.longitude)
                        ?? double.parse(_branch.longitude))
                        : LatLng(locationProvider.position.latitude.toInt()  == 0
                        ? double.parse(_branch.latitude)
                        : locationProvider.position.latitude, locationProvider.position.longitude.toInt() == 0
                        ? double.parse(_branch.longitude)
                        : locationProvider.position.longitude,
                    ),
                    zoom: 8,
                  ),
                  zoomControlsEnabled: false,
                  compassEnabled: false,
                  indoorViewEnabled: true,
                  mapToolbarEnabled: false,
                  onCameraIdle: () {
                    if(widget.address != null && !widget.fromCheckout) {
                      locationProvider.updatePosition(_cameraPosition, true, null, context, true);
                      _updateAddress = true;
                    }else {
                      if(_updateAddress) {
                        locationProvider.updatePosition(_cameraPosition, true, null, context, true);
                      }else {
                        _updateAddress = true;
                      }
                    }

                  },
                  onCameraMove: ((_position) => _cameraPosition = _position),
                  onMapCreated: (GoogleMapController controller) {
                    _controller = controller;
                    if (!widget.isEnableUpdate && _controller != null) {
                      _checkPermission(() {
                        locationProvider.getCurrentLocation(context, true, mapController: _controller);
                      }, context);
                    }
                  },
                ),
                locationProvider.loading ? Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
                  )) : SizedBox(),

                Container(
                    width: MediaQuery.of(context).size.width,
                    alignment: Alignment.center,
                    height: MediaQuery.of(context).size.height,
                    child:Icon(
                      Icons.location_on,
                      color: Theme.of(context).primaryColor,
                      size: 35,
                    )
                ),

                Positioned(
                  bottom: 10,
                  right: 0,
                  child: InkWell(
                    onTap: () => _checkPermission(() {
                      locationProvider.getCurrentLocation(context, true, mapController: _controller);
                    }, context),
                    child: Container(
                      width: ResponsiveHelper.isDesktop(context) ? 40 : 30,
                      height: ResponsiveHelper.isDesktop(context) ? 40 : 30,
                      margin: EdgeInsets.only(right: Dimensions.PADDING_SIZE_LARGE),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(Dimensions.PADDING_SIZE_SMALL),
                        color: ColorResources.WHITE_COL0R,
                      ),
                      child: Icon(
                        Icons.my_location,
                        color: Theme.of(context).primaryColor,
                        size: 20,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 0,
                  child: InkWell(
                    onTap: () {
                      Navigator.pushNamed(
                        context, RouteHelper.getSelectLocationRoute(),
                        arguments: SelectLocationScreen(googleMapController: _controller),
                      );
                    },
                    child: Container(
                      width: ResponsiveHelper.isDesktop(context) ? 40 : 30,
                      height: ResponsiveHelper.isDesktop(context) ? 40 : 30,
                      margin: EdgeInsets.only(right: Dimensions.PADDING_SIZE_LARGE),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(Dimensions.PADDING_SIZE_SMALL),
                        color: ColorResources.WHITE_COL0R,
                      ),
                      child: Icon(
                        Icons.fullscreen,
                        color: Theme.of(context).primaryColor,
                        size: 20,
                      ),
                    ),
                  ),
                ),

              ],
              ),
            ),
          );
  }

  void _checkPermission(Function callback, BuildContext context) async {
    LocationPermission permission = await Geolocator.requestPermission();
    if(permission == LocationPermission.denied) {
      _locationTextController.text = '';
      permission = await Geolocator.requestPermission();
    }else if(permission == LocationPermission.deniedForever) {
      _locationTextController.text = '';
      showDialog(context: context, barrierDismissible: false, builder: (context) => PermissionDialog());
    }else {
      callback();
    }
  }

}








