import 'package:e_demand/app/generalImports.dart';

class MyRequestListModel {
  String? id;
  String? userid;
  String? categoryId;
  String? serviceTitle;
  String? serviceShortDescription;
  String? minPrice;
  String? maxPrice;
  String? requestedStartDate;
  String? requestedStartTime;
  String? requestedEndDate;
  String? requestedEndTime;
  String? createdAt;
  String? updatedAt;
  String? status;
  String? categoryName;
  String? categoryParentId;
  String? categoryImage;
  int? totalBids;
  List<Bidder?>? bidders;

  MyRequestListModel(
      {this.id,
      this.userid,
      this.categoryId,
      this.serviceTitle,
      this.serviceShortDescription,
      this.minPrice,
      this.maxPrice,
      this.requestedStartDate,
      this.requestedStartTime,
      this.requestedEndDate,
      this.requestedEndTime,
      this.createdAt,
      this.updatedAt,
      this.status,
      this.categoryName,
      this.categoryParentId,
      this.totalBids,
      this.bidders,
      this.categoryImage,
      });

  MyRequestListModel.fromJson(Map<String, dynamic> json) {

    id = json['id'];
    userid = json['user_id'];
    categoryId = json['category_id'];
    serviceTitle = json['service_title'];
    serviceShortDescription = json['service_short_description'];
    minPrice = json['min_price'];
    maxPrice = json['max_price'];
    requestedStartDate = json['requested_start_date'];
    requestedStartTime = json['requested_start_time'];
    requestedEndDate = json['requested_end_date'];
    requestedEndTime = json['requested_end_time'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    status = json['status'];
    categoryName = json['category_name'];
    categoryParentId = json['category_parent_id'];
    totalBids = json['total_bids'];
    categoryImage = json['category_image'];
    if (json['bidders'] != null) {
      bidders = <Bidder>[];
      json['bidders'].forEach((v) {
        bidders!.add(Bidder.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['id'] = id;
    data['user_id'] = userid;
    data['category_id'] = categoryId;
    data['service_title'] = serviceTitle;
    data['service_short_description'] = serviceShortDescription;
    data['min_price'] = minPrice;
    data['max_price'] = maxPrice;
    data['requested_start_date'] = requestedStartDate;
    data['requested_start_time'] = requestedStartTime;
    data['requested_end_date'] = requestedEndDate;
    data['requested_end_time'] = requestedEndTime;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['status'] = status;
    data['category_name'] = categoryName;
    data['category_parent_id'] = categoryParentId;
    data['total_bids'] = totalBids;
    data['category_image'] = categoryImage;
    data['bidders'] =
        bidders != null ? bidders!.map((v) => v?.toJson()).toList() : null;
    return data;
  }
}
