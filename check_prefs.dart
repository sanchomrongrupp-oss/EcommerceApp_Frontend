import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  final prefs = await SharedPreferences.getInstance();
  print('Keys: ${prefs.getKeys()}');
  for (var key in prefs.getKeys()) {
    print('$key: ${prefs.get(key)}');
  }
}
