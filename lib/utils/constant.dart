import 'package:e_demand/app/generalImports.dart';
import 'package:e_demand/config/environment_config.dart';

const String appName = "Maddwell";

// domainURL should look like:- your_web_domain or your_panel_domain
const String domain = 'app.maddwell.pro'; 

//Add your baseURL - This will be overridden by environment config
String baseUrl = EnvironmentConfig.apiBaseUrl; 

const bool isDemoMode = false;

//*******Add Your Language code and name here */
//by default language of the app
const String defaultLanguageCode = "fr";
const String defaultLanguageName = "Francais";

//add your default country code here
///https://www.att.com/support_media/images/pdf/Country_Code_List.pdf
String defaultCountryCode = "CM";

//if you do not want user to select another country rather than default country,
//then make below variable true
bool allowOnlySingleCountry = false;

const int resendOTPCountDownTime = 30; //in seconds

//OTP hint CustomText
const String otpHintText = "123456"; /* MUST BE 6 CHARACTER REQUIRED */

Map<String, dynamic> dateAndTimeSetting = {
  "dateFormat": "dd/MM/yyyy",
  "use24HourFormat": false
};

//Add language code in this list
//visit this to find languageCode for your respective language
//https://developers.google.com/admin-sdk/directory/v1/languages
const List<AppLanguage> appLanguages = [
  //Please add language code here and language name
  AppLanguage(
      languageCode: "fr",
      languageName: "Francais",
      imageURL: AppAssets.englishAu),
  AppLanguage(
      languageCode: "en",
      languageName: "English",
      imageURL: AppAssets.englishAu),
];

//slider on home screen
const Map sliderAnimationDurationSettings = {
  "sliderAnimationDuration": 3000, // in milliseconds
  "changeSliderAnimationDuration": 300, //in milliseconds
};

/* INTRO SLIDER LIST*/
List<IntroScreen> introScreenList = [
  IntroScreen(
    introScreenTitle: "onboarding_heading_one",
    introScreenSubTitle: "onboarding_body_one",
    imagePath: AppAssets.introSliderImageFirst,
    animationDuration: 3, /* DURATION IS IN SECONDS*/
  ),
  IntroScreen(
    introScreenTitle: "onboarding_heading_two",
    introScreenSubTitle: "onboarding_body_two",
    imagePath: AppAssets.introSliderImageSecond,
    animationDuration: 3, /* DURATION IS IN SECONDS*/
  ),
  IntroScreen(
    introScreenTitle: "onboarding_heading_three",
    introScreenSubTitle: "onboarding_body_three",
    imagePath: AppAssets.introSliderImageThird,
    animationDuration: 3, /* DURATION IS IN SECONDS*/
  ),
  IntroScreen(
    introScreenTitle: "onboarding_heading_four",
    introScreenSubTitle: "onboarding_body_four",
    imagePath: AppAssets.introSliderImageFourth,
    animationDuration: 3, /* DURATION IS IN SECONDS*/
  ),
];

enum LogInType { google, apple, phone }
