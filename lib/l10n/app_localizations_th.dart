// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Thai (`th`).
class AppLocalizationsTh extends AppLocalizations {
  AppLocalizationsTh([String locale = 'th']) : super(locale);

  @override
  String get appTitle => 'BahtBuddy';

  @override
  String get navHome => 'หน้าแรก';

  @override
  String get navAdd => 'เพิ่ม';

  @override
  String get navHistory => 'ประวัติ';

  @override
  String get navReports => 'รายงาน';

  @override
  String get navSettings => 'ตั้งค่า';

  @override
  String get today => 'วันนี้';

  @override
  String get thisWeek => 'สัปดาห์นี้';

  @override
  String get thisMonth => 'เดือนนี้';

  @override
  String get income => 'รายรับ';

  @override
  String get expense => 'รายจ่าย';

  @override
  String get balance => 'คงเหลือ';

  @override
  String get recent => 'ล่าสุด';

  @override
  String get seeAll => 'ดูทั้งหมด';

  @override
  String get emptyTransactions => 'ยังไม่มีรายการ';

  @override
  String get scanSlip => 'สแกนสลิป';

  @override
  String get gallery => 'คลังภาพ';

  @override
  String get camera => 'กล้อง';

  @override
  String get manualEntry => 'กรอกเอง';

  @override
  String get amount => 'จำนวนเงิน';

  @override
  String get date => 'วันที่';

  @override
  String get category => 'หมวดหมู่';

  @override
  String get note => 'บันทึก';

  @override
  String get recipient => 'ผู้รับ';

  @override
  String get reference => 'เลขอ้างอิง';

  @override
  String get type => 'ประเภท';

  @override
  String get save => 'บันทึก';

  @override
  String get cancel => 'ยกเลิก';

  @override
  String get delete => 'ลบ';

  @override
  String get edit => 'แก้ไข';

  @override
  String get requiredAmount => 'ใส่จำนวนเงินที่มากกว่า 0';

  @override
  String get reviewSlip => 'ตรวจสอบสลิป';

  @override
  String get parsingSlip => 'กำลังอ่านสลิป…';

  @override
  String get ocrFailed => 'อ่านตัวอักษรจากสลิปไม่สำเร็จ คุณกรอกเองได้';

  @override
  String get duplicateTitle => 'สลิปนี้ถูกบันทึกแล้ว';

  @override
  String get duplicateBody => 'มีรายการที่ใช้เลขอ้างอิงนี้อยู่แล้ว';

  @override
  String get saveWithoutReference => 'บันทึกโดยไม่ใช้เลขอ้างอิง';

  @override
  String get searchHint => 'ค้นหาบันทึก ผู้รับ หรือเลขอ้างอิง';

  @override
  String get filters => 'ตัวกรอง';

  @override
  String get clearFilters => 'ล้างตัวกรอง';

  @override
  String get from => 'ตั้งแต่';

  @override
  String get to => 'ถึง';

  @override
  String get minAmount => 'จำนวนต่ำสุด';

  @override
  String get maxAmount => 'จำนวนสูงสุด';

  @override
  String get allCategories => 'ทุกหมวด';

  @override
  String get deleteTitle => 'ลบรายการนี้?';

  @override
  String get deleteBody => 'รายการนี้จะถูกลบออกจากเครื่อง';

  @override
  String get reportsEmpty => 'ยังไม่มีข้อมูลในช่วงนี้';

  @override
  String get byCategory => 'ตามหมวดหมู่';

  @override
  String get overTime => 'ตามช่วงเวลา';

  @override
  String get incomeVsExpense => 'รายรับเทียบรายจ่าย';

  @override
  String get budgets => 'งบประมาณ';

  @override
  String get monthlyLimit => 'วงเงินต่อเดือน';

  @override
  String get noBudget => 'ยังไม่ได้ตั้งงบ';

  @override
  String get saveBudget => 'บันทึกงบ';

  @override
  String get removeBudget => 'ลบงบ';

  @override
  String get appearance => 'การแสดงผล';

  @override
  String get theme => 'ธีม';

  @override
  String get system => 'ตามระบบ';

  @override
  String get light => 'สว่าง';

  @override
  String get dark => 'มืด';

  @override
  String get language => 'ภาษา';

  @override
  String get english => 'English';

  @override
  String get thai => 'ไทย';

  @override
  String get security => 'ความปลอดภัย';

  @override
  String get setPin => 'ตั้งรหัส PIN';

  @override
  String get changePin => 'เปลี่ยนรหัส PIN';

  @override
  String get removePin => 'ลบรหัส PIN';

  @override
  String get pin => 'รหัส PIN';

  @override
  String get confirmPin => 'ยืนยันรหัส PIN';

  @override
  String get currentPin => 'รหัส PIN ปัจจุบัน';

  @override
  String get pinMismatch => 'รหัสไม่ตรงกัน';

  @override
  String get pinTooShort => 'ใส่รหัส 6 หลัก';

  @override
  String get wrongPin => 'รหัสไม่ถูกต้อง';

  @override
  String get enterPin => 'ใส่รหัส PIN';

  @override
  String get enterCurrentPin => 'ใส่รหัส PIN ปัจจุบัน';

  @override
  String get createPin => 'ตั้งรหัส PIN 6 หลัก';

  @override
  String get confirmNewPin => 'ยืนยันรหัส PIN';

  @override
  String get pinMismatchTryAgain => 'รหัสไม่ตรงกัน ลองใหม่อีกครั้ง';

  @override
  String get unlock => 'ปลดล็อก';

  @override
  String get biometrics => 'Face ID / Touch ID';

  @override
  String get biometricsUnavailable => 'ใช้ไบโอเมตริกซ์บนเครื่องนี้ไม่ได้';

  @override
  String get reminders => 'การแจ้งเตือน';

  @override
  String get dailyReminder => 'เตือนบันทึกรายจ่ายทุกวัน';

  @override
  String get reminderTitle => 'BahtBuddy';

  @override
  String get reminderBody => 'อย่าลืมบันทึกรายจ่ายของวันนี้';

  @override
  String get dataSection => 'ข้อมูล';

  @override
  String get exportCsv => 'ส่งออก CSV';

  @override
  String get backup => 'สำรองข้อมูล';

  @override
  String get restore => 'กู้คืน';

  @override
  String get exportDone => 'พร้อมแชร์ไฟล์แล้ว';

  @override
  String get restoreDone => 'กู้คืนข้อมูลแล้ว';

  @override
  String get restoreFailed => 'อ่านไฟล์สำรองไม่สำเร็จ';

  @override
  String budgetWarning(String category) {
    return '$category ใช้ไป 80% ของงบเดือนนี้';
  }

  @override
  String budgetReached(String category) {
    return '$category ใช้งบเดือนนี้ครบแล้ว';
  }

  @override
  String get optionalPhoto => 'รูปใบเสร็จ (ไม่บังคับ)';

  @override
  String get removePhoto => 'เอารูปออก';

  @override
  String get saved => 'บันทึกแล้ว';

  @override
  String get cashHint => 'รายจ่ายเงินสดและรายรับที่ไม่มีสลิป';

  @override
  String get suggested => 'แนะนำจากชื่อผู้รับ';

  @override
  String spentOf(String spent, String limit) {
    return '$spent จาก $limit';
  }

  @override
  String get apply => 'ใช้';

  @override
  String get lockedTitle => 'BahtBuddy ถูกล็อก';

  @override
  String get addRecord => 'เพิ่ม';

  @override
  String get emptyAddCta => 'เพิ่มรายการ';

  @override
  String remainingOf(String remaining) {
    return 'เหลือ $remaining';
  }

  @override
  String percentValue(String value) {
    return '$value%';
  }

  @override
  String get lockSubtitle => 'ใส่รหัส PIN เพื่อดูรายการ';

  @override
  String get filterCategoryChip => 'หมวดหมู่';

  @override
  String get overBudget => 'เกินงบ';

  @override
  String get monthBalance => 'เดือนนี้';
}
