class CouponModel {
  int id;
  String title;
  String code;
  String startDate;
  String expireDate;
  double minPurchase;
  double maxDiscount;
  double discount;
  String discountType;
  int status;
  String createdAt;
  String updatedAt;
  String couponType;

  CouponModel(
      {this.id,
        this.title,
        this.code,
        this.startDate,
        this.expireDate,
        this.minPurchase,
        this.maxDiscount,
        this.discount,
        this.discountType,
        this.status,
        this.createdAt,
        this.updatedAt,
        this.couponType,
      });

  CouponModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    code = json['code'];
    startDate = json['start_date'];
    expireDate = json['expire_date'];
    minPurchase = json['min_purchase'].toDouble();
    maxDiscount = json['max_discount'].toDouble();
    discount = json['discount'].toDouble();
    discountType = json['discount_type'];
    status = json['status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    couponType = json['coupon_type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['title'] = this.title;
    data['code'] = this.code;
    data['start_date'] = this.startDate;
    data['expire_date'] = this.expireDate;
    data['min_purchase'] = this.minPurchase;
    data['max_discount'] = this.maxDiscount;
    data['discount'] = this.discount;
    data['discount_type'] = this.discountType;
    data['status'] = this.status;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['coupon_type'] = this.couponType;
    return data;
  }
}

class CouponApplyModel {
  final double  discount;
  final String  discountType;

  CouponApplyModel(this.discount, this.discountType);
}
