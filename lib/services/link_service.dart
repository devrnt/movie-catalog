import 'package:url_launcher/url_launcher.dart';

class LinkService {
  static Future<bool> launchLink(String link) async {
    if (await canLaunch(link)) {
      await launch(link);
      return true;
    } else {
      return false;
    }
  }
}
