import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'dart:developer';
import '../network/api_endponts.dart';
import '../services/shared_pref.dart';

class AuthController extends GetxController {
  RxBool isLoading = false.obs;

  Future<String?> login(String email, String password) async {
    try {
      isLoading.value = true;
      log("Attempting login at: ${ApiEndPoint.login}");

      var response = await Dio().post(
        ApiEndPoint.login,
        data: {
          "email": email,
          "password": password,
        },
      );

      log("Response Status: ${response.statusCode}");
      log("Response Data: ${response.data}");

      if (response.statusCode == 200 && response.data != null) {
        if (response.data is Map) {
          String? token = response.data["xval"]?.toString();
          if (token != null && token.isNotEmpty) {
            await SharedPrefServices.saveToken(token);
            return token;
          }
        }
      }
      
      Get.snackbar("Login Failed", "Invalid response format from server");
      return null;
      
    } on DioException catch (e) {
      log("Dio Error: ${e.message}");
      
      String errorMsg = "Login Failed";
      
      if (e.response?.data != null && e.response?.data is Map) {
        errorMsg = e.response?.data["Message"] ?? "Invalid Credentials";
      } else if (e.response?.statusCode == 404) {
        errorMsg = "URL Not Found (404). Please check ApiEndPoint.login";
      } else {
        errorMsg = "Server Error: ${e.response?.statusCode}";
      }
      
      Get.snackbar("Error", errorMsg, snackPosition: SnackPosition.BOTTOM);
      return null;
    } catch (e) {
      log("Unexpected Error: $e");
      Get.snackbar("Error", "Something went wrong");
      return null;
    } finally {
      isLoading.value = false;
    }
  }
}
