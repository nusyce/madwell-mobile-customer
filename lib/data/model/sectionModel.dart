import 'package:e_demand/app/generalImports.dart';

class Sections {
  Sections({
    required this.id,
    required this.title,
    required this.sectionType,
    required this.partners,
    required this.subCategories,
    required this.previousBookings,
    required this.onGoingBookings,
    this.sliderImage,
  });

  Sections.fromJson(Map<String?, dynamic> json) {
    id = json['id'] ?? "";
    title = json['title'] ?? "";
    sectionType = json['section_type'] ?? "";
    partners = (json['partners'] as List)
        .map((e) => Partners.fromJson(Map.from(e)))
        .toList();

    if ((json["sub_categories"] as List).isNotEmpty) {
      (json["sub_categories"] as List).forEach((final v) {
        subCategories.add(SubCategories.fromJson(v));
      });
    }
    if (json["previous_order"] != null) {
      if ((json["previous_order"] as List).isNotEmpty) {
        (json["previous_order"] as List).forEach((final v) {
          previousBookings.add(Booking.fromJson(v));
        });
      }
    }
    if (json["ongoing_order"] != null) {
      if ((json["ongoing_order"] as List).isNotEmpty) {
        (json["ongoing_order"] as List).forEach((final v) {
          onGoingBookings.add(Booking.fromJson(v));
        });
      }
    }

    if (json["banner"] != null) {
      if ((json["banner"] as List).isNotEmpty) {
        sliderImage = SliderImage.fromJson((json["banner"] as List).first);
      }
    }
  }

  String? id;
  String? title;
  String? sectionType;
  List<Partners> partners = <Partners>[];
  List<SubCategories> subCategories = <SubCategories>[];
  List<Booking> previousBookings = <Booking>[];
  List<Booking> onGoingBookings = <Booking>[];
  SliderImage? sliderImage;
}

class Partners {
  Partners(
      {required this.id,
      required this.username,
      required this.image,
      required this.promoCode,
      required this.discount,
      required this.discountType,
      required this.companyName,
      required this.numberOfRating,
      required this.distance,
      required this.bannerImage,
      required this.totalServices,
      required this.averageRating});

  Partners.fromJson(final Map<String?, dynamic> json) {
    id = json["id"] ?? '';
    username = json["username"] ?? '';
    image = json["image"] ?? '';
    promoCode = json["promo_code"] ?? '';
    discount = json["discount"].toString();
    companyName = json["company_name"].toString();
    discountType = json["discount_type"] ?? '';
    bannerImage = json["banner_image"] ?? '';
    numberOfRating = json["number_of_rating"] ?? '';
    discount = json["distance"] ?? '';
    totalServices = json["total_services"].toString();
    averageRating = (json['average_rating'] ?? "0").toString();
  }

  String? id;
  String? username;
  String? image;
  String? promoCode;
  String? discount;
  String? discountType;
  String? companyName;
  String? bannerImage;
  String? numberOfRating;
  String? distance;
  String? totalServices;
  String? averageRating;
}

class SubCategories {
  SubCategories({
    required this.id,
    required this.parentId,
    required this.name,
    required this.image,
    required this.slug,
    required this.totalProviders,
  });

  SubCategories.fromJson(final Map<String?, dynamic> json) {
    id = json["id"] ?? '';
    parentId = json["parent_id"] ?? '';
    name = json["name"] ?? '';
    image = json["image"] ?? '';
    slug = json["slug"] ?? '';
    totalProviders = json["total_providers"].toString();
  }

  String? id;
  String? parentId;
  String? name;
  String? image;
  String? slug;
  String? totalProviders;
}
