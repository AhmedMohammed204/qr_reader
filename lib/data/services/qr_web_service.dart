import 'dart:convert';
import 'package:dio/dio.dart';

class QrWebService {
  static const String publicKeyXml =
      "<RSAKeyValue><Modulus>5Q0rPQZFR6oSqzhBK1ck0/kr7dhLpEc+tpl6CACXZO62dNeJWkq/TE7dRDgNwK5R3Jm6jEM9lWaICya+5b9Y2ymJfb6ASyuAVXiaTB0a6ShE+ug5X3/lhGjHrDxsKVI/+YHBgiWL0PNgmATzMVV4Uc7fIG8gF3X/2iC9xwVNBWaNhJxzUkUlXiKycnbhU/YlCdOS2oS14G9n1A8mZ4v7C3G0xHLdCu0atIRAtFoou51tkcBCyTTlkf68VtE6GBh/i8ED/1ww7u53aW89cZlpsOT4a41YFY/T09GpDMphSVpSzVJy4KPx82cowiNizupWeCTljk9l2aYDTnW0GOFXGQ==</Modulus><Exponent>AQAB</Exponent></RSAKeyValue>";

  final String _baseUrl = "http://qr-service-amad-hack.runasp.net/api/qr";
  final Dio _dio = Dio(BaseOptions(contentType: "application/json"));

  Future<String> createQr({
    required String deviceId,
    required double amount,
    required DateTime expiry,
    required String passkey,
  }) async {
    try
    {

    final body = {
      "DeviceId": deviceId,
      "Amount": amount,
      "ExpiryDate": expiry.toIso8601String(),
      "PassKey": passkey,
    };

    final response = await _dio.post("$_baseUrl/create", data: body);

    if (response.statusCode == 200) return response.data;
    return "";
    } catch (e) {
      return "";
    }
  }

  Future<List<dynamic>> getAllQrs({required String deviceId}) async {
    try
    {

    final response = await _dio.get(
      "$_baseUrl/get-all",
      queryParameters: {"deviceId": deviceId},
    );

    if (response.statusCode == 200) return response.data;
    return [];
    } catch (e) {
      return [];
    }
  }

  Future<bool> deactivateQr({
    required int qrId,
    required String deviceId,
  }) async {
    try
    {

    final response = await _dio.post(
      "$_baseUrl/deactivate",
      queryParameters: {"qrId": qrId, "deviceId": deviceId},
    );
    return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<bool> scanQr({
    required String encryptedQr,
    required String deviceId,
    required double amount,
    required String passkey,
  }) async {
    try {
      final response = await _dio.post(
        "$_baseUrl/scan",
        queryParameters: {
          "DeviceId": deviceId,
          "Amount": amount,
          "PassKey": passkey,
        },
        data: jsonEncode({"EncryptedQr": encryptedQr}),
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
