import 'package:url_launcher/url_launcher.dart';

/// Utility for launching external URLs.
class UrlLauncherUtils {
  UrlLauncherUtils._();

  /// Open a URL in the device's default browser.
  /// Returns true if successful, false otherwise.
  static Future<bool> openUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return false;

    if (await canLaunchUrl(uri)) {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
    return false;
  }

  /// Validate if a string is a valid URL.
  static bool isValidUrl(String url) {
    final uri = Uri.tryParse(url);
    return uri != null && (uri.isScheme('http') || uri.isScheme('https'));
  }
}
