import 'app_translations.dart';

class AppTranslationsTh implements AppTranslations {
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

  // ─── LOGIN ───
  @override String get loginTitle => 'FAIRGO คนขับ';
  @override String get loginSubtitle => 'ขับดี ได้ราคาที่แฟร์';
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

  // ─── SPLASH ───
  @override String get splashTagline => 'ขับดี ได้ราคาที่แฟร์';
  @override String get splashDriverBadge => 'DRIVER';

  // ─── BOTTOM NAV ───
  @override String get navJobs => 'งาน';
  @override String get navOffers => 'ข้อเสนอ';
  @override String get navEarnings => 'รายได้';
  @override String get navProfile => 'โปรไฟล์';

  // ─── JOB LIST ───
  @override String get jobRequestsTitle => 'คำขอเดินทาง';
  @override String get jobOnline => 'ออนไลน์ · กำลังหางาน';
  @override String get jobOffline => 'ออฟไลน์';
  @override String get jobFilterAll => 'งานทั้งหมด';
  @override String get jobFilterHighFare => 'ค่าโดยสารสูง';
  @override String get jobFilterShortTrips => 'ทางใกล้';
  @override String get jobNoRides => 'ไม่มีคำขอในขณะนี้';
  @override String get jobNoRidesDesc => 'เปิดออนไลน์เพื่อรับคำขอใหม่';
  @override String get jobPassengerOffer => 'ราคาที่ผู้โดยสารเสนอ';
  @override String get jobPickupLabel => 'จุดรับ';
  @override String get jobDropoffLabel => 'จุดส่ง';
  @override String jobDistance(String km) => '$km กม.';
  @override String jobDuration(String min) => '~$min นาที';
  @override String get jobViewDetails => 'ดูรายละเอียด';
  @override String get jobSubmitOffer => 'เสนอราคา';
  @override String get jobYouMarker => 'คุณ';
  @override String get jobPickupMarker => 'จุดรับ';

  // ─── MY OFFERS TAB ───
  @override String get offersTitle => 'ข้อเสนอของฉัน';
  @override String get offersEmpty => 'ยังไม่มีข้อเสนอ';
  @override String get offersEmptyDesc => 'ข้อเสนอที่คุณส่งจะปรากฏที่นี่';
  @override String get offerStatusPending => 'รอการตอบรับ';
  @override String get offerStatusAccepted => 'ได้รับการยอมรับ';
  @override String get offerStatusRejected => 'ถูกปฏิเสธ';

  // ─── EARNINGS TAB ───
  @override String get earningsTitle => 'รายได้';
  @override String get earningsTodayLabel => 'วันนี้';
  @override String get earningsTripsLabel => 'เที่ยวที่สำเร็จ';
  @override String get earningsAvgLabel => 'เฉลี่ยต่อเที่ยว';
  @override String get earningsThisWeek => 'สัปดาห์นี้';
  @override String get earningsEmpty => 'ยังไม่มีข้อมูลรายได้';

  // ─── PROFILE TAB ───
  @override String get profileTitle => 'โปรไฟล์คนขับ';
  @override String get profileVehicleInfo => 'ข้อมูลรถ';
  @override String get profileDocuments => 'เอกสาร';
  @override String get profileSettings => 'การตั้งค่า';
  @override String get profileSupport => 'ความช่วยเหลือ';
  @override String get profileSignOut => 'ออกจากระบบ';

  // ─── SUBMIT OFFER ───
  @override String get submitOfferTitle => 'เสนอราคา';
  @override String get submitPassengerOffer => 'ราคาที่ผู้โดยสารเสนอ';
  @override String get submitFareRange => 'ช่วงราคา';
  @override String get submitYourFareOffer => 'ราคาที่คุณเสนอ';
  @override String get submitEtaTitle => 'เวลาประมาณที่จะไปถึง';
  @override String get submitMessageTitle => 'ข้อความ (ไม่บังคับ)';
  @override String get submitMessageHint => 'เช่น "อยู่ใกล้ๆ รับได้ทันที!"';
  @override String submitOfferButton(String amount) => 'ส่งข้อเสนอ · ฿$amount';
  @override String get submitOfferSuccess => 'ส่งข้อเสนอแล้ว! รอผู้โดยสารตอบรับ';
  @override String get submitOfferWaiting => 'รอการตอบรับ...';
}
