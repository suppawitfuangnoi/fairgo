import 'app_translations.dart';

class AppTranslationsEn implements AppTranslations {
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

  // ─── LOGIN ───
  @override String get loginTitle => 'FAIRGO Driver';
  @override String get loginSubtitle => 'Drive Well. Earn Fair.';
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

  // ─── SPLASH ───
  @override String get splashTagline => 'Drive Well. Earn Fair.';
  @override String get splashDriverBadge => 'DRIVER';

  // ─── BOTTOM NAV ───
  @override String get navJobs => 'Jobs';
  @override String get navOffers => 'Offers';
  @override String get navEarnings => 'Earnings';
  @override String get navProfile => 'Profile';

  // ─── JOB LIST ───
  @override String get jobRequestsTitle => 'Job Requests';
  @override String get jobOnline => 'Online · Finding rides';
  @override String get jobOffline => 'Offline';
  @override String get jobFilterAll => 'All Jobs';
  @override String get jobFilterHighFare => 'High Fare';
  @override String get jobFilterShortTrips => 'Short Trips';
  @override String get jobNoRides => 'No ride requests';
  @override String get jobNoRidesDesc => 'Go online to receive new requests';
  @override String get jobPassengerOffer => 'Passenger offer';
  @override String get jobPickupLabel => 'Pickup';
  @override String get jobDropoffLabel => 'Drop-off';
  @override String jobDistance(String km) => '$km km';
  @override String jobDuration(String min) => '~$min min';
  @override String get jobViewDetails => 'View Details';
  @override String get jobSubmitOffer => 'Submit Offer';
  @override String get jobSkip => 'Skip';
  @override String get jobYouMarker => 'You';
  @override String get jobPickupMarker => 'Pickup';

  // ─── MY OFFERS TAB ───
  @override String get offersTitle => 'My Offers';
  @override String get offersEmpty => 'No offers yet';
  @override String get offersEmptyDesc => 'Offers you submit will appear here';
  @override String get offerStatusPending => 'Pending';
  @override String get offerStatusAccepted => 'Accepted';
  @override String get offerStatusRejected => 'Rejected';

  // ─── EARNINGS TAB ───
  @override String get earningsTitle => 'Earnings';
  @override String get earningsTodayLabel => 'Today';
  @override String get earningsTripsLabel => 'Completed Trips';
  @override String get earningsAvgLabel => 'Avg. per Trip';
  @override String get earningsThisWeek => 'This Week';
  @override String get earningsEmpty => 'No earnings data yet';
  @override String get earningsRecentTrips => 'Recent Trips';
  @override String get earningsViewAll => 'View All';
  @override String get earningsNoTripsYet => 'No trips completed yet';

  // ─── PROFILE TAB ───
  @override String get profileTitle => 'Driver Profile';
  @override String get profileVehicleInfo => 'Vehicle Info';
  @override String get profileDocuments => 'Documents';
  @override String get profileSettings => 'Settings';
  @override String get profileSupport => 'Support';
  @override String get profileSignOut => 'Sign Out';

  // ─── SUBMIT OFFER ───
  @override String get submitOfferTitle => 'Submit Offer';
  @override String get submitPassengerOffer => 'Passenger offer';
  @override String get submitFareRange => 'Range';
  @override String get submitYourFareOffer => 'Your Fare Offer';
  @override String get submitEtaTitle => 'Estimated Pickup Time';
  @override String get submitMessageTitle => 'Message (Optional)';
  @override String get submitMessageHint => 'e.g., "I\'m nearby, can pick you up quickly!"';
  @override String submitOfferButton(String amount) => 'Submit Offer · ฿$amount';
  @override String get submitOfferSuccess => 'Offer submitted! Waiting for passenger response.';
  @override String get submitOfferWaiting => 'Waiting for response...';
}
