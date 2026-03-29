import 'package:flutter/material.dart';
import 'app_translations_en.dart';
import 'app_translations_th.dart';

/// Abstract base class for all app-level translations.
/// Access via: context.watch<LocaleProvider>().t
abstract class AppTranslations {
  // ─── COMMON ───
  String get appName;
  String get ok;
  String get cancel;
  String get confirm;
  String get loading;
  String get error;
  String get close;
  String get language;
  String get thai;
  String get english;
  String get minutes;

  // ─── ONBOARDING ───
  String get onboardingSkip;
  String get onboardingNext;
  String get onboardingStart;
  // Page 1
  String get ob1Title;
  String get ob1Highlight;
  String get ob1Desc;
  String get ob1BadgeLabel;
  String get ob1BadgeValue;
  // Page 2
  String get ob2Title;
  String get ob2Highlight;
  String get ob2Desc;
  String get ob2BadgeLabel;
  String get ob2BadgeValue;
  // Page 3
  String get ob3Title;
  String get ob3Highlight;
  String get ob3Desc;
  String get ob3BadgeLabel;
  String get ob3BadgeValue;

  // ─── LOGIN ───
  String get loginTitle;
  String get loginSubtitle;
  String get loginPhoneLabel;
  String get loginPhonePlaceholder;
  String get loginContinue;
  String get loginAgreementPrefix;
  String get loginTerms;
  String get loginAgreementMid;
  String get loginPrivacy;

  // ─── OTP ───
  String get otpTitle;
  String otpSubtitle(String phone);
  String get otpResend;
  String get otpVerify;
  String get otpResendIn;

  // ─── BOTTOM NAV ───
  String get navHome;
  String get navTrips;
  String get navProfile;

  // ─── HOME TAB ───
  String get homeWhereGoing;
  String get homePlanRide;
  String get homeCurrentLocation;
  String get homeWhereTo;
  String get homeShortcutHome;
  String get homeShortcutWork;
  String get homeShortcutHistory;
  String get homeChooseVehicle;
  String get vehicleTaxi;
  String get vehicleMoto;
  String get vehicleTuktuk;
  String get vehicleFromPrefix; // "เริ่ม" / "From"

  // ─── TRIPS TAB ───
  String get tripsTitle;
  String get tripsEmpty;
  String get tripsEmptyDesc;

  // ─── PROFILE TAB ───
  String get profileEdit;
  String get profileWallet;
  String get profileSavedPlaces;
  String get profilePromotions;
  String get profileSupport;
  String get profileSettings;
  String get profileSignOut;

  // ─── RIDE REQUEST ───
  String get rideRequestTitle;
  String get ridePickupLabel;
  String get rideDropoffLabel;
  String get rideCurrentLocation;
  String get rideSearchingLocation;
  String get rideEstFare;
  String get rideYourOffer;
  String get rideSelectVehicle;
  String get rideConfirmRequest;
  String get rideAdjustOffer;
  String get rideFareRange;
  String get ridePickupMarker;
  String get rideDropoffMarker;

  // ─── MATCHING ───
  String get matchingFindingDrivers;
  String get matchingSearching;
  String matchingDriversFound(int count);
  String get matchingFairPriceTag;
  String get matchingDriversChooseYou;
  String matchingYourOffer(String amount);
  String matchingMinAway(int min);
  String matchingTripsCount(int count);
  String get matchingSearchingForDrivers;
  String get matchingNearbyWillSee;
  String get matchingDecline;
  String get matchingAccept;
  String get matchingBestMatch;

  // ─── TRIP ACTIVE ───
  String get tripStatusAssigned;
  String get tripStatusEnRoute;
  String get tripStatusArrived;
  String get tripStatusPickupConfirmed;
  String get tripStatusInProgress;
  String get tripDriverNearby;
  String get tripPriceLocked;
  String get tripChat;
  String get tripCallDriver;
  String get tripPickupMarker;
  String get tripDropoffMarker;
  String get tripDriverMarker;

  // ─── TRIP SUMMARY ───
  String get summaryArrived;
  String get summaryThankYou;
  String get summaryTotalPaid;
  String get summaryPaymentBreakdown;
  String get summaryAgreedFare;
  String get summaryPlatformFee;
  String get summaryDriverPayout;
  String get summaryPromoDiscount;
  String get summaryTotal;
  String get summaryGoHome;
  String get summaryRateDriver;
  String get summaryFareLabel;
  String get summaryVehicleLabel;
  String get summaryTimeLabel;
  String get summaryDriverLabel;
  String get summaryPassengerLabel;
  String get summaryPickupLabel;
  String get summaryDropoffLabel;

  // ─── RATING ───
  String get ratingAppBarTitle;
  String get ratingHowWas;
  String ratingWith(String name);
  String get ratingChipFairPrice;
  String get ratingChipFriendly;
  String get ratingChipClean;
  String get ratingChipSafe;
  String get ratingChipQuick;
  String get ratingChipMusic;
  String get ratingCommentHint;
  String get ratingAddFavorite;
  String get ratingSubmit;
  String get ratingSkip;

  // ─── FACTORY ───
  factory AppTranslations.fromLocale(Locale locale) {
    switch (locale.languageCode) {
      case 'th':
        return AppTranslationsTh();
      default:
        return AppTranslationsEn();
    }
  }
}
