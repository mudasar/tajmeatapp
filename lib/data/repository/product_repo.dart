import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_grocery/data/datasource/remote/dio/dio_client.dart';
import 'package:flutter_grocery/data/datasource/remote/exception/api_error_handler.dart';
import 'package:flutter_grocery/data/model/response/base/api_response.dart';
import 'package:flutter_grocery/helper/product_type.dart';
import 'package:flutter_grocery/utill/app_constants.dart';

class ProductRepo {
  final DioClient dioClient;

  ProductRepo({@required this.dioClient});

  Future<ApiResponse> getPopularProductList(String offset, String languageCode) async {
    try {
      final response = await dioClient.get('${AppConstants.POPULAR_PRODUCT_URI}?limit=10&&offset=$offset',
        options: Options(headers: {'X-localization': languageCode}),
      );
      return ApiResponse.withSuccess(response);

    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  Future<ApiResponse> getLatestProductList(String offset, String languageCode) async {
    try {
      final response = await dioClient.get('${AppConstants.LATEST_PRODUCT_URI}?limit=10&&offset=$offset',
        options: Options(headers: {'X-localization': languageCode}),

      );
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  Future<ApiResponse> getItemList(String offset, String languageCode, String productType) async {
    try {
      String _apiUrl;
      if(productType == ProductType.FEATURED_ITEM){
        _apiUrl = AppConstants.FEATURED_PRODUCT;
      }else if(productType == ProductType.DAILY_ITEM){
        _apiUrl = AppConstants.DAILY_ITEM_URI;
      } else if(productType == ProductType.POPULAR_PRODUCT){
        _apiUrl = AppConstants.POPULAR_PRODUCT_URI;
      }else if(productType == ProductType.MOST_REVIEWED){
        _apiUrl = AppConstants.MOST_REVIEWED_PRODUCT;
      }
      else if(productType == ProductType.RECOMMEND_PRODUCT){
        _apiUrl = AppConstants.RECOMMEND_PRODUCT;
      } else if(productType == ProductType.TRENDING_PRODUCT){
        _apiUrl = AppConstants.TRENDING_PRODUCT;
      }
      //_apiUrl = AppConstants.POPULAR_PRODUCT_URI;

      final response = await dioClient.get('$_apiUrl?limit=10&&offset=$offset',
        options: Options(headers: {'X-localization': languageCode}),
      );
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  Future<ApiResponse> getProductDetails(String productID, String languageCode, bool searchQuery) async {
    try {
      String _params = '$productID';
      if(searchQuery) {
        _params = '$productID?attribute=product';
      }
      final response = await dioClient.get('${AppConstants.PRODUCT_DETAILS_URI}$_params',
        options: Options(headers: {'X-localization': languageCode}),
      );
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  Future<ApiResponse> searchProduct(String productId, String languageCode) async {
    try {
      final response = await dioClient.get(
        '${AppConstants.SEARCH_PRODUCT_URI}$productId',
        options: Options(headers: {'X-localization': languageCode}),
      );
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  Future<ApiResponse> getBrandOrCategoryProductList(String id, String languageCode) async {
    try {
      String uri = '${AppConstants.CATEGORY_PRODUCT_URI}$id';

      final response = await dioClient.get(uri, options: Options(headers: {'X-localization': languageCode}));
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

}
