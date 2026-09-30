import 'package:get/get.dart';
import '../models/user_model.dart';

class UserController extends GetxController {

  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);
  final RxString accessToken = ''.obs;

  void setSession(UserModel user, String token) {
    currentUser.value = user;
    accessToken.value = token;
  }

  void clearSession() {
    currentUser.value = null;
    accessToken.value = '';
  }
  void updateUser(UserModel user) => currentUser.value = user;
}
