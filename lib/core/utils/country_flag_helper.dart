import 'package:flutter/material.dart';
import 'package:country_flags/country_flags.dart';
// no additional imports

class CountryFlagHelper {
  /// Extracts the country code from a flag URL.
  /// Returns uppercase 2-letter code (eg. 'UA') or null.
  static String? extractCountryCode(String? flagUrl) {
    if (flagUrl == null || flagUrl.isEmpty) return null;

    try {
      // Support urls like .../ua.svg or .../flags/ua.svg
      final uri = Uri.parse(flagUrl);
      final segments = uri.pathSegments;
      if (segments.isEmpty) return null;
      final last = segments.last; // e.g. ua.svg
      final dotIndex = last.lastIndexOf('.');
      final code = dotIndex > 0 ? last.substring(0, dotIndex) : last;
      if (code.isEmpty) return null;
      return code.toUpperCase();
    } catch (_) {
      // Fallback: try simple regex
      final match = RegExp(r"([a-zA-Z]{2,3})(?:\.[a-zA-Z]{2,4})?$").firstMatch(flagUrl);
      if (match != null) return match.group(1)?.toUpperCase();
      return null;
    }
  }

  /// Builds a small country flag widget using `country_flags` package.
  /// If extraction fails, returns an Icon fallback.
  static Widget buildCountryFlag(String? flagUrl, {double size = 20}) {
    final code = extractCountryCode(flagUrl);
    if (code == null || code.isEmpty) {
      return Icon(
        Icons.flag,
        size: size,
        color: Colors.grey.shade700,
      );
    }

    // Build an image flag using the `country_flags` package.
    // Render the packaged vector flag as a circular image at the requested
    // size. This avoids network SVGs and does not rely on `flutter_svg`.
    return CountryFlag.fromCountryCode(
      code,
      theme: ImageTheme(width: size, height: size, shape: const Circle()),
    );
  }
}
