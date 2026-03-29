import 'package:flutter/material.dart';
import 'app_translations_en.dart';
import 'app_translations_th.dart';

/// Abstract base class for all driver app translations.
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

  // ─── SPLASH ───
  String get splashTagline;
  String get splashDriverBadge;

  // ─── BOTTOM NAV ───
  String get navJobs;
  String get navOffers;
  String get navEarnings;
  String get navProfile;

  // ─── JOB LIST ───
  String get jobRequestsTitle;
  String get jobOnline;
  String get jobOffline;
  String get jobFilterAll;
  String get jobFilterHighFare;
  String get jobFilterShortTrips;
  String get jobNoRides;
  String get jobNoRidesDesc;
  String get jobPassengerOffer;
  String get jobPickupLabel;
  String get jobDropoffLabel;
  String jobDistance(String km);
  String jobDuration(String min);
  String jobViewDetails;
  String get jobSubmitOffer;
  String get jobYouMarker;
  String get jobPickupMarker;

  // ─── MY OFFERS TAB ───
  String get offersTitle;
  String get offersEmpty;
  String get offersEmptyDesc;
  String get offerStatusPending;
  String get offerStatusAccepted;
  String get offerStatusRejected;

  // ─── EARNINGS TAB ───
  String get earningsTitle;
  String get earningsTodayLabel;
  String get earningsTripsLabel;
  String get earningsAvgLabel;
  String get earningsThisWeek;
  String get earningsEmpty;

  // ─── PROFILE TAB ───
  String get profileTitle;
  String get profileVehicleInfo;
  String get profileDocuments;
  String get profileSettings;
  String get profileSupport;
  String get profileSignOut;

  // ─── SUBMIT OFFER ───
  String get submitOfferTitle;
  String get submitPassengerOffer;
  String get submitFareRange;
  String get submitYourFareOffer;
  String get submitEtaTitle;
  String get submitMessageTitle;
  String get submitMessageHint;
  String submitOfferButton(String amount);
  String get submitOfferSuccess;
  String get submitOfferWaiting;

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
