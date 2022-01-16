import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:hexcolor/hexcolor.dart';

class SizeConfig {
  static MediaQueryData _mediaQueryData;
  static double screenWidth;
  static double screenHeight;
  static double blockSizeHorizontal;
  static double blockSizeVertical;
  static double _safeAreaHorizontal;
  static double _safeAreaVertical;
  static double safeBlockHorizontal;
  static double safeBlockVertical;

  void init(BuildContext context){
    _mediaQueryData = MediaQuery.of(context);
    screenWidth = _mediaQueryData.size.width;
    screenHeight = _mediaQueryData.size.height;
    blockSizeHorizontal = screenWidth/100;
    blockSizeVertical = screenHeight/100;
    _safeAreaHorizontal = _mediaQueryData.padding.left +
        _mediaQueryData.padding.right;
    _safeAreaVertical = _mediaQueryData.padding.top +
        _mediaQueryData.padding.bottom;
    safeBlockHorizontal = (screenWidth - _safeAreaHorizontal)/100;
    safeBlockVertical = (screenHeight - _safeAreaVertical)/100;
  }
}

Color button = HexColor('#ea4435');
Color lightNavy = HexColor('#3939FF');
Color darkNavy = HexColor('#000080');
const Color white = Colors.white;
const Color black = Colors.black;

const String USERS_COLLECTION = "Users";
const String FAVORITES_COLLECTION = "Favorites";
const String MENUS_COLLECTION = "Menus";
const String ADDITIONAL_MENUS_COLLECTION = "Additional Menus";

final GlobalKey<NavigatorState> navigatorKey = GlobalKey(debugLabel: "Main Navigator");
const chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
const APP_LINK = "https://play.google.com/store/apps/details?id=com.outofthebox.taskaty";
const String PRIVACY_POLICY = 'https://pages.flycricket.io/intask/privacy.html';
const String TERMS_COND = 'https://pages.flycricket.io/intask/terms.html';
var connectivityResult;