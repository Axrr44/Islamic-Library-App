import 'dart:io';

import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdmobService {
  static final BannerAdListener bannerListener = BannerAdListener(
      onAdLoaded: (ad) => print('Banner loaded'),
      onAdFailedToLoad: (ad, error) {
        ad.dispose();
        print('Banner Failed to load');
      },);

  static String bannerAdUnitId(bool isTest) {
    if (Platform.isAndroid) {
      return isTest
          ? "ca-app-pub-3940256099942544/6300978111"
          : "ca-app-pub-3819163654340613/9545229552";
    } else if (Platform.isIOS) {
      return isTest
          ? "ca-app-pub-3940256099942544/2934735716"
          : "ca-app-pub-3819163654340613/9628990038";
    } else {
      throw UnsupportedError("Unsupported platform");
    }
  }

  static String interstitialAdUnitId(bool isTest) {
    if (Platform.isAndroid) {
      return isTest
          ? "ca-app-pub-3940256099942544/1033173712"
          : "ca-app-pub-3819163654340613/2105723236";
    } else if (Platform.isIOS) {
      return isTest
          ? "ca-app-pub-3940256099942544/4411468910"
          : "ca-app-pub-3819163654340613/1914151540";
    } else {
      throw UnsupportedError("Unsupported platform");
    }
  }

  static String nativeAdUnitId(bool isTest) {
    if (Platform.isAndroid) {
      return isTest
          ? "ca-app-pub-3940256099942544/2247696110"
          : "ca-app-pub-3940256099942544/2247696110";
    } else if (Platform.isIOS) {
      return isTest
          ? "ca-app-pub-3940256099942544/3986624511"
          : "ca-app-pub-3940256099942544/3986624511";
    } else {
      throw UnsupportedError("Unsupported platform");
    }
  }

}
