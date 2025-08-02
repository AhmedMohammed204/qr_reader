import 'dart:convert';

import 'package:qr_reader/data/services/device_service.dart';
import 'package:qr_reader/data/services/qr_web_service.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:pointycastle/asymmetric/api.dart';
import 'package:xml/xml.dart';

class QrRepository {
  static final QrWebService _service = QrWebService();

  static Future<String> createQr({
    required double amount,
    required DateTime expiry,
    required String passkey,
  }) async {
    final deviceId = await DeviceService.getDeviceId();
    return await _service.createQr(
      deviceId: deviceId,
      amount: amount,
      expiry: expiry,
      passkey: passkey,
    );
  }

  static Future<List<dynamic>> getAllQrs() async {
    final deviceId = await DeviceService.getDeviceId();
    return await _service.getAllQrs(deviceId: deviceId);
  }

  static Future<bool> deactivateQr(int qrId) async {
    final deviceId = await DeviceService.getDeviceId();
    return await _service.deactivateQr(qrId: qrId, deviceId: deviceId);
  }

  static Future<bool> scanQr({
    required String encryptedQr,
    required double amount,
    required String passkey,
  }) async {
    return _service.scanQr(
      deviceId: await DeviceService.getDeviceId(),
      encryptedQr: encryptedQr,
      amount: amount,
      passkey: passkey,
    );
  }

  static Future<String> generateQrData({
    required double amount,
    required DateTime expiresAt,
    required String passkey,
  }) async {
    final payload = {
      "Amount": amount,
      "ExpiresAt": expiresAt.toIso8601String(),
      "PassKey": passkey,
      "UserDevice": await DeviceService.getDeviceId(),
      "IsMainQr": true,
    };

    final xml = XmlDocument.parse(QrWebService.publicKeyXml);
    final modulusBase64 = xml.findAllElements('Modulus').first.innerText;
    final exponentBase64 = xml.findAllElements('Exponent').first.innerText;

    final modulus = _base64ToBigInt(modulusBase64);
    final exponent = _base64ToBigInt(exponentBase64);

    final publicKey = RSAPublicKey(modulus, exponent);

    final encrypter = encrypt.Encrypter(
      encrypt.RSA(publicKey: publicKey, encoding: encrypt.RSAEncoding.PKCS1),
    );

    final encrypted = encrypter.encrypt(jsonEncode(payload));
    return encrypted.base64;
  }

  static BigInt _base64ToBigInt(String base64Str) {
    final bytes = base64Decode(base64Str);
    return BigInt.parse(
      bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join(),
      radix: 16,
    );
  }
}
