import 'package:flutter/material.dart';
import 'package:country_flags/country_flags.dart';
// no additional imports

class CountryFlagHelper {
  static const Map<String, String> _countryNameToCode = {
    'argentina': 'AR',
    'australia': 'AU',
    'spain': 'ES',
    'germany': 'DE',
    'france': 'FR',
    'england': 'GB',
    'united kingdom': 'GB',
    'uk': 'GB',
    'great britain': 'GB',
  };

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
      final match = RegExp(
        r"([a-zA-Z]{2,3})(?:\.[a-zA-Z]{2,4})?$",
      ).firstMatch(flagUrl);
      if (match != null) return match.group(1)?.toUpperCase();
      return null;
    }
  }

  static String? normalizeCountryCode(String? countryCode) {
    if (countryCode == null) return null;

    final trimmed = countryCode.trim();
    if (trimmed.isEmpty) return null;

    final upper = trimmed.toUpperCase();
    final parts = upper.split('-');
    return parts.length > 1 ? parts.first : upper;
  }

  static String? countryCodeFromName(String? countryName) {
    if (countryName == null || countryName.trim().isEmpty) return null;

    final normalized = countryName.trim().toLowerCase();
    final direct = _countryNameToCode[normalized];
    if (direct != null) return direct;

    if (RegExp(
      r'^[a-z]{2}$',
      caseSensitive: false,
    ).hasMatch(countryName.trim())) {
      return countryName.trim().toUpperCase();
    }

    return null;
  }

  /// Builds a small country flag widget using `country_flags` package.
  /// If extraction fails, returns an Icon fallback.
  static Widget buildCountryFlag(String? flagUrl, {double size = 20}) {
    final code = extractCountryCode(flagUrl);
    if (code == null || code.isEmpty) {
      return Icon(Icons.flag, size: size, color: Colors.grey.shade700);
    }

    return CountryFlag.fromCountryCode(
      code,
      theme: ImageTheme(width: size, height: size, shape: const Circle()),
    );
  }

  static Widget buildCountryFlagFromCode(
    String? countryCode, {
    double size = 20,
  }) {
    final code = normalizeCountryCode(countryCode);
    if (code == null || code.isEmpty) {
      return Icon(Icons.flag, size: size, color: Colors.grey.shade700);
    }

    return CountryFlag.fromCountryCode(
      code,
      theme: ImageTheme(width: size, height: size, shape: const Circle()),
    );
  }

  static Widget buildCountryFlagFromName(
    String? countryName, {
    double size = 20,
  }) {
    final code = countryCodeFromName(countryName);
    if (code == null || code.isEmpty) {
      return Icon(Icons.flag, size: size, color: Colors.grey.shade700);
    }

    return CountryFlag.fromCountryCode(
      code,
      theme: ImageTheme(width: size, height: size, shape: const Circle()),
    );
  }
}
