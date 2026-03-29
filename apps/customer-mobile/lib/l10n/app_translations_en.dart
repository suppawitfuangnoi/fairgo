import 'app_translations.dart';

class AppTranslationsEn implements AppTranslations {
  // ─── COMMON ───
  @override String get appName => 'FAIRGO';
  @override String get ok => 'OK';
  @override String get cancel => 'Cancel';
  @override String get confirm => 'Confirm';
  @override String get loading => 'Loading...';
  @override String get error => 'Something went wrong';
  @override String get close => 'Close';
  @override String get language => 'Language';
  @override String get thai => 'ภาษาไทย';
  @override String get english => 'English';
  @override String get minutes => 'min';

  // ─── ONBOARDING ───
  @override String get onboardingSkip => 'Skip';
  @override String get onboardingNext => 'Next';
  @override String get onboardingStart => 'Get Started';
  // Page 1
  @override String get ob1Title => 'Set Your Own';
  @override String get ob1Highlight => 'Fair Price';
  @override String get ob1Desc => 'Name your price and let drivers accept your offer. Travel comfortably at the fare you set.';
  @override String get ob1BadgeLabel => 'Agreed Price';
  @override String get ob1BadgeValue => '฿120.00';
  // Page 2
  @override String get ob2Title => 'Trusted';
  @override String get ob2Highlight => 'Drivers';
  @override String get ob2Desc => 'Verified drivers with real ratings. Track your trip in real-time. Safe on every route.';
  @override String get ob2BadgeLabel => 'Avg. Rating';
  @override String get ob2BadgeValue => '4.9 ★';
  // Page 3
  @override String get ob3Title => 'Ride Anytime,';
  @override String get ob3Highlight => 'Anywhere';
  @override String get ob3Desc => 'Instant booking — Taxi, Motorcycle, or Tuk-Tuk. Every vehicle type available for you.';
  @override String get ob3BadgeLabel => 'Available';
  @override String get ob3BadgeValue => '24/7';

  // ─── LOGIN ───
  @override String get loginTitle => 'Welcome';
  @override String get loginSubtitle => 'Ride anywhere, at a fair price';
  @override String get loginPhoneLabel => 'Phone Number';
  @override String get loginPhonePlaceholder => '0812345678';
  @override String get loginContinue => 'Continue';
  @override String get loginAgreementPrefix => 'By continuing, you agree to our';
  @override String get loginTerms => 'Terms of Service';
  @override String get loginAgreementMid => 'and';
  @override String get loginPrivacy => 'Privacy Policy';

  // ─── OTP ───
  @override String get otpTitle => 'Verify OTP';
  @override String otpSubtitle(String phone) => 'Enter the 6-digit code sent to $phone';
  @override String get otpResend => 'Resend Code';
  @override String get otpVerify => 'Verify';
  @override String get otpResendIn => 'Resend in';

  // ─── BOTTOM NAV ───
  @override String get navHome => 'Home';
  @override String get navTrips => 'Trips';
  @override String get navProfile => 'Profile';

  // ─── HOME TAB ───
  @override String get homeWhereGoing => 'Where to?';
  @override String get homePlanRide => 'Plan your ride';
  @override String get homeCurrentLocation => 'Current location';
  @override String get homeWhereTo => 'Where to?';
  @override String get homeShortcutHome => 'Home';
  @override String get homeShortcutWork => 'Work';
  @override String get homeShortcutHistory => 'History';
  @override String get homeChooseVehicle => 'Choose Vehicle';
  @override String get vehicleTaxi => 'Taxi';
  @override String get vehicleMoto => 'Moto';
  @override String get vehicleTuktuk => 'Tuk-Tuk';
  @override String get vehicleFromPrefix => 'From';

  // ─── TRIPS TAB ───
  @override String get tripsTitle => 'Trip History';
  @override String get tripsEmpty => 'No trips yet';
  @override String get tripsEmptyDesc => 'Your trip history will appear here';

  // ─── PROFILE TAB ───
  @override String get profileEdit => 'Edit Profile';
  @override String get profileWallet => 'Wallet';
  @override String get profileSavedPlaces => 'Saved Places';
  @override String get profilePromotions => 'Promotions';
  @override String get profileSupport => 'Support';
  @override String get profileSettings => 'Settings';
  @override String get profileSignOut => 'Sign Out';

  // ─── RIDE REQUEST ───
  @override String get rideRequestTitle => 'Where are you going?';
  @override String get ridePickupLabel => 'Pickup';
  @override String get rideDropoffLabel => 'Drop-off';
  @override String get rideCurrentLocation => 'My location';
  @override String get rideSearchingLocation => 'Getting location...';
  @override String get rideEstFare => 'Estimated Fare';
  @override String get rideYourOffer => 'Your Offer';
  @override String get rideSelectVehicle => 'Select Vehicle';
  @override String get rideConfirmRequest => 'Confirm Request';
  @override String get rideAdjustOffer => 'Adjust your offer';
  @override String get rideFareRange => 'Fare Range';
  @override String get ridePickupMarker => 'Pickup';
  @override String get rideDropoffMarker => 'Drop-off';

  // ─── MATCHING ───
  @override String get matchingFindingDrivers => 'Finding drivers...';
  @override String get matchingSearching => 'Searching...';
  @override String matchingDriversFound(int count) => '$count Driver${count > 1 ? 's' : ''} found';
  @override String get matchingFairPriceTag => 'Fair Price';
  @override String get matchingDriversChooseYou => 'Drivers chose you for your fair price';
  @override String matchingYourOffer(String amount) => 'Your offer: ฿$amount';
  @override String matchingMinAway(int min) => '$min min away';
  @override String matchingTripsCount(int count) => '$count trips';
  @override String get matchingSearchingForDrivers => 'Searching for drivers...';
  @override String get matchingNearbyWillSee => 'Nearby drivers will see your request';
  @override String get matchingDecline => 'Decline';
  @override String get matchingAccept => 'Accept';
  @override String get matchingBestMatch => 'BEST MATCH';

  // ─── TRIP ACTIVE ───
  @override String get tripStatusAssigned => 'Driver assigned · Arriving soon';
  @override String get tripStatusEnRoute => 'Arriving in ~5 mins';
  @override String get tripStatusArrived => 'Driver has arrived!';
  @override String get tripStatusPickupConfirmed => 'Trip started';
  @override String get tripStatusInProgress => 'On the way to destination';
  @override String get tripDriverNearby => 'Driver is nearby!';
  @override String get tripPriceLocked => 'Price locked. You\'re all good!';
  @override String get tripChat => 'Chat';
  @override String get tripCallDriver => 'Call Driver';
  @override String get tripPickupMarker => 'Pickup';
  @override String get tripDropoffMarker => 'Drop-off';
  @override String get tripDriverMarker => 'Driver';

  // ─── TRIP SUMMARY ───
  @override String get summaryArrived => 'You\'ve Arrived!';
  @override String get summaryThankYou => 'Thank you for riding with FAIRGO';
  @override String get summaryTotalPaid => 'Total Paid';
  @override String get summaryPaymentBreakdown => 'Payment Breakdown';
  @override String get summaryAgreedFare => 'Agreed fare';
  @override String get summaryPlatformFee => 'Platform fee (10%)';
  @override String get summaryDriverPayout => 'Driver payout (90%)';
  @override String get summaryPromoDiscount => 'Promo discount';
  @override String get summaryTotal => 'Total';
  @override String get summaryGoHome => 'Go Home';
  @override String get summaryRateDriver => 'Rate Your Driver';
  @override String get summaryFareLabel => 'Fare';
  @override String get summaryVehicleLabel => 'Vehicle';
  @override String get summaryTimeLabel => 'Time';
  @override String get summaryDriverLabel => 'Driver';
  @override String get summaryPassengerLabel => 'Passenger';
  @override String get summaryPickupLabel => 'Pickup';
  @override String get summaryDropoffLabel => 'Drop-off';

  // ─── RATING ───
  @override String get ratingAppBarTitle => 'RIDE COMPLETED';
  @override String get ratingHowWas => 'How was your ride?';
  @override String ratingWith(String name) => 'with $name';
  @override String get ratingChipFairPrice => 'Fair price';
  @override String get ratingChipFriendly => 'Friendly driver';
  @override String get ratingChipClean => 'Clean car';
  @override String get ratingChipSafe => 'Safe driving';
  @override String get ratingChipQuick => 'Quick route';
  @override String get ratingChipMusic => 'Great music';
  @override String get ratingCommentHint => 'Tell us more about your ride...';
  @override String get ratingAddFavorite => 'Add driver to favorites';
  @override String get ratingSubmit => 'Submit Feedback';
  @override String get ratingSkip => 'Skip for now';
}
