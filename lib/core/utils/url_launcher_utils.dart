import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/foundation.dart';

/// Utility for launching external URLs.
class UrlLauncherUtils {
  UrlLauncherUtils._();

  static Future<bool> openUrl(String url) async {
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'https://$url';
    }
    final uri = Uri.tryParse(url);
    if (uri == null) return false;

    try {
      if (await canLaunchUrl(uri)) {
        return await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        // Fallback: try launching anyway, as canLaunchUrl can fail on Android 11+ without proper <queries>
        return await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint("Could not launch url: $e");
      return false;
    }
  }

  /// Validate if a string is a valid URL.
  static bool isValidUrl(String url) {
    final uri = Uri.tryParse(url);
    return uri != null && (uri.isScheme('http') || uri.isScheme('https'));
  }
}
