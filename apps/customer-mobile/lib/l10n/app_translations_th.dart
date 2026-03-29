import 'app_translations.dart';

class AppTranslationsTh implements AppTranslations {
  // ─── COMMON ───
  @override String get appName => 'FAIRGO';
  @override String get ok => 'ตกลง';
  @override String get cancel => 'ยกเลิก';
  @override String get confirm => 'ยืนยัน';
  @override String get loading => 'กำลังโหลด...';
  @override String get error => 'เกิดข้อผิดพลาด';
  @override String get close => 'ปิด';
  @override String get language => 'ภาษา';
  @override String get thai => 'ภาษาไทย';
  @override String get english => 'English';
  @override String get minutes => 'นาที';

  // ─── ONBOARDING ───
  @override String get onboardingSkip => 'ข้าม';
  @override String get onboardingNext => 'ต่อไป';
  @override String get onboardingStart => 'เริ่มต้นใช้งาน';
  // Page 1
  @override String get ob1Title => 'ตั้งราคาที่คุณ';
  @override String get ob1Highlight => 'แฟร์';
  @override String get ob1Desc => 'เลือกราคาที่คุณพอใจ เสนอราคาได้เอง คนขับพร้อมรับข้อเสนอของคุณ เดินทางสบายใจในราคาที่คุณกำหนด';
  @override String get ob1BadgeLabel => 'ราคาที่ตกลงกัน';
  @override String get ob1BadgeValue => '฿120.00';
  // Page 2
  @override String get ob2Title => 'คนขับ';
  @override String get ob2Highlight => 'ที่ไว้ใจได้';
  @override String get ob2Desc => 'คนขับที่ผ่านการตรวจสอบ มีคะแนนรีวิวจริง ติดตามการเดินทางแบบ real-time ปลอดภัยทุกเส้นทาง';
  @override String get ob2BadgeLabel => 'คะแนนเฉลี่ย';
  @override String get ob2BadgeValue => '4.9 ★';
  // Page 3
  @override String get ob3Title => 'เดินทางได้ทุก';
  @override String get ob3Highlight => 'ที่ทุกเวลา';
  @override String get ob3Desc => 'เรียกรถได้ทันที ไม่ว่าจะเป็นแท็กซี่ มอเตอร์ไซค์ หรือตุ๊กตุ๊ก มีให้เลือกครบทุกประเภท';
  @override String get ob3BadgeLabel => 'พร้อมให้บริการ';
  @override String get ob3BadgeValue => '24/7';

  // ─── LOGIN ───
  @override String get loginTitle => 'ยินดีต้อนรับ';
  @override String get loginSubtitle => 'เดินทางได้ทุกที่ ในราคาที่แฟร์';
  @override String get loginPhoneLabel => 'เบอร์โทรศัพท์';
  @override String get loginPhonePlaceholder => '0812345678';
  @override String get loginContinue => 'ดำเนินการต่อ';
  @override String get loginAgreementPrefix => 'เมื่อดำเนินการต่อ แสดงว่าคุณยอมรับ';
  @override String get loginTerms => 'ข้อกำหนดการใช้งาน';
  @override String get loginAgreementMid => 'และ';
  @override String get loginPrivacy => 'นโยบายความเป็นส่วนตัว';

  // ─── OTP ───
  @override String get otpTitle => 'ยืนยัน OTP';
  @override String otpSubtitle(String phone) => 'กรุณากรอกรหัส 6 หลักที่ส่งไปยัง $phone';
  @override String get otpResend => 'ส่งรหัสใหม่';
  @override String get otpVerify => 'ยืนยัน';
  @override String get otpResendIn => 'ส่งใหม่ใน';

  // ─── BOTTOM NAV ───
  @override String get navHome => 'หน้าหลัก';
  @override String get navTrips => 'การเดินทาง';
  @override String get navProfile => 'โปรไฟล์';

  // ─── HOME TAB ───
  @override String get homeWhereGoing => 'ไปที่ไหน?';
  @override String get homePlanRide => 'วางแผนการเดินทาง';
  @override String get homeCurrentLocation => 'ตำแหน่งของฉัน';
  @override String get homeWhereTo => 'จะไปที่ไหน?';
  @override String get homeShortcutHome => 'บ้าน';
  @override String get homeShortcutWork => 'ที่ทำงาน';
  @override String get homeShortcutHistory => 'ประวัติ';
  @override String get homeChooseVehicle => 'เลือกประเภทรถ';
  @override String get vehicleTaxi => 'แท็กซี่';
  @override String get vehicleMoto => 'มอเตอร์ไซค์';
  @override String get vehicleTuktuk => 'ตุ๊กตุ๊ก';
  @override String get vehicleFromPrefix => 'เริ่ม';

  // ─── TRIPS TAB ───
  @override String get tripsTitle => 'ประวัติการเดินทาง';
  @override String get tripsEmpty => 'ยังไม่มีการเดินทาง';
  @override String get tripsEmptyDesc => 'ประวัติการเดินทางของคุณจะปรากฏที่นี่';

  // ─── PROFILE TAB ───
  @override String get profileEdit => 'แก้ไขโปรไฟล์';
  @override String get profileWallet => 'กระเป๋าเงิน';
  @override String get profileSavedPlaces => 'สถานที่บันทึก';
  @override String get profilePromotions => 'โปรโมชัน';
  @override String get profileSupport => 'ความช่วยเหลือ';
  @override String get profileSettings => 'การตั้งค่า';
  @override String get profileSignOut => 'ออกจากระบบ';

  // ─── RIDE REQUEST ───
  @override String get rideRequestTitle => 'ต้องการไปที่ไหน?';
  @override String get ridePickupLabel => 'จุดรับ';
  @override String get rideDropoffLabel => 'จุดส่ง';
  @override String get rideCurrentLocation => 'ตำแหน่งของฉัน';
  @override String get rideSearchingLocation => 'กำลังหาตำแหน่ง...';
  @override String get rideEstFare => 'ราคาประมาณ';
  @override String get rideYourOffer => 'ราคาที่เสนอ';
  @override String get rideSelectVehicle => 'เลือกประเภทรถ';
  @override String get rideConfirmRequest => 'ยืนยันการขอเดินทาง';
  @override String get rideAdjustOffer => 'ปรับราคาที่เสนอ';
  @override String get rideFareRange => 'ช่วงราคา';
  @override String get ridePickupMarker => 'จุดรับ';
  @override String get rideDropoffMarker => 'จุดส่ง';

  // ─── MATCHING ───
  @override String get matchingFindingDrivers => 'กำลังค้นหาคนขับ...';
  @override String get matchingSearching => 'กำลังค้นหา...';
  @override String matchingDriversFound(int count) => 'พบคนขับ $count คน';
  @override String get matchingFairPriceTag => 'ราคาแฟร์';
  @override String get matchingDriversChooseYou => 'คนขับเลือกคุณ เพราะราคานี้แฟร์';
  @override String matchingYourOffer(String amount) => 'ราคาที่เสนอ: ฿$amount';
  @override String matchingMinAway(int min) => 'อีก $min นาที';
  @override String matchingTripsCount(int count) => '$count เที่ยว';
  @override String get matchingSearchingForDrivers => 'กำลังค้นหาคนขับ...';
  @override String get matchingNearbyWillSee => 'คนขับบริเวณใกล้เคียงจะเห็นคำขอของคุณ';
  @override String get matchingDecline => 'ปฏิเสธ';
  @override String get matchingAccept => 'รับ';
  @override String get matchingBestMatch => 'BEST MATCH';

  // ─── TRIP ACTIVE ───
  @override String get tripStatusAssigned => 'คนขับได้รับงาน · กำลังมารับ';
  @override String get tripStatusEnRoute => 'กำลังเดินทางมารับ ~5 นาที';
  @override String get tripStatusArrived => 'คนขับมาถึงแล้ว!';
  @override String get tripStatusPickupConfirmed => 'เริ่มการเดินทาง';
  @override String get tripStatusInProgress => 'กำลังเดินทางไปจุดหมาย';
  @override String get tripDriverNearby => 'คนขับมาถึงแล้ว!';
  @override String get tripPriceLocked => 'ล็อกราคาแล้ว สบายใจได้';
  @override String get tripChat => 'แชท';
  @override String get tripCallDriver => 'โทรหาคนขับ';
  @override String get tripPickupMarker => 'จุดรับ';
  @override String get tripDropoffMarker => 'จุดส่ง';
  @override String get tripDriverMarker => 'คนขับ';

  // ─── TRIP SUMMARY ───
  @override String get summaryArrived => 'ถึงจุดหมายแล้ว!';
  @override String get summaryThankYou => 'ขอบคุณที่ใช้บริการ FAIRGO';
  @override String get summaryTotalPaid => 'ชำระแล้ว';
  @override String get summaryPaymentBreakdown => 'รายละเอียดการชำระ';
  @override String get summaryAgreedFare => 'ค่าโดยสารตกลง';
  @override String get summaryPlatformFee => 'ส่วนแบ่งแพลตฟอร์ม (10%)';
  @override String get summaryDriverPayout => 'คนขับได้รับ (90%)';
  @override String get summaryPromoDiscount => 'ส่วนลดโปรโมชัน';
  @override String get summaryTotal => 'รวมทั้งหมด';
  @override String get summaryGoHome => 'กลับหน้าหลัก';
  @override String get summaryRateDriver => 'ให้คะแนนคนขับ';
  @override String get summaryFareLabel => 'ค่าโดยสาร';
  @override String get summaryVehicleLabel => 'ประเภทรถ';
  @override String get summaryTimeLabel => 'เวลา';
  @override String get summaryDriverLabel => 'คนขับ';
  @override String get summaryPassengerLabel => 'ผู้โดยสาร';
  @override String get summaryPickupLabel => 'จุดรับ';
  @override String get summaryDropoffLabel => 'จุดส่ง';

  // ─── RATING ───
  @override String get ratingAppBarTitle => 'การเดินทางสิ้นสุดแล้ว';
  @override String get ratingHowWas => 'การเดินทางเป็นอย่างไรบ้าง?';
  @override String ratingWith(String name) => 'กับ $name';
  @override String get ratingChipFairPrice => 'ราคาแฟร์';
  @override String get ratingChipFriendly => 'คนขับมีมารยาท';
  @override String get ratingChipClean => 'รถสะอาด';
  @override String get ratingChipSafe => 'ขับปลอดภัย';
  @override String get ratingChipQuick => 'เส้นทางรวดเร็ว';
  @override String get ratingChipMusic => 'เพลงเพราะ';
  @override String get ratingCommentHint => 'บอกเพิ่มเติมเกี่ยวกับการเดินทาง...';
  @override String get ratingAddFavorite => 'เพิ่มคนขับเป็นรายการโปรด';
  @override String get ratingSubmit => 'ส่งข้อเสนอแนะ';
  @override String get ratingSkip => 'ข้ามไปก่อน';
}
