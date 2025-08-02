import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:qr_reader/data/services/device_service.dart';
import 'package:qr_reader/data/services/users_service.dart';

class BalanceRepo {


  static Future<File> _getBalanceFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/balance.txt');
  }

  static Future<void> setBalance(double newBalance) async {
    final file = await _getBalanceFile();
    final sink = file.openWrite(mode: FileMode.write); // overwrite mode
    sink.write(newBalance.toString());
    await sink.close();
  }

  static Future<void> addToBalance(double amount) async {
    final currentBalance = await getBalance();
    final newBalance = currentBalance + amount;
    await setBalance(newBalance);
  }

    static final UsersService _service = UsersService();

  static Future<double> getBalance() async {
    final deviceId = await DeviceService.getDeviceId();
    return await _service.getBalance(deviceId: deviceId);
  }
}

