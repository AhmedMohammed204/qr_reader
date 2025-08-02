// ignore: camel_case_types
import 'package:qr_reader/data/repository/balance_repo.dart';
import 'package:qr_reader/data/services/device_service.dart';

// ignore: camel_case_types
class clsGeneral {
  static Future<double> get balance => BalanceRepo.getBalance();
  static Future<String> get deviceId => DeviceService.getDeviceId();
}
