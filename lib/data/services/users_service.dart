import 'package:dio/dio.dart';

class UsersService {
  final Dio _dio = Dio(BaseOptions(contentType: "application/json"));
  final String _baseUrl = "http://qr-service-amad-hack.runasp.net/api/users";

  Future<double> getBalance({required String deviceId}) async {
    try {
      final response = await _dio.get(
        "$_baseUrl/balance",
        queryParameters: {"deviceId": deviceId},
      );

      if (response.statusCode == 200) {
        return (response.data as num).toDouble();
      }
      return -1;
    } catch (e) {
      return -1;
    }
  }
}
