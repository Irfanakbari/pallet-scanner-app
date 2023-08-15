import 'package:get/get.dart';

class GlobalController extends GetxController {
  var token = ''.obs;

  void setGlobalVariable(String value) {
    token.value = value;
  }

  void clearGlobalVariable() {
    token.value = '';
  }
}
