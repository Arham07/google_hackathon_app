import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Opens [url] in the device browser or news app.
Future<bool> openExternalUrl(
  BuildContext context,
  String url, {
  String failureMessage = 'Could not open link',
}) async {
  final Uri? uri = normalizeExternalUrl(url);
  if (uri == null) {
    if (context.mounted) {
      _showSnackBar(context, 'Invalid link');
    }
    return false;
  }

  try {
    final bool launched = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );
    if (!launched && context.mounted) {
      _showSnackBar(context, failureMessage);
    }
    return launched;
  } catch (_) {
    if (context.mounted) {
      _showSnackBar(context, failureMessage);
    }
    return false;
  }
}

Uri? normalizeExternalUrl(String url) {
  final String trimmed = url.trim();
  if (trimmed.isEmpty) return null;

  final String withScheme =
      trimmed.startsWith('http://') || trimmed.startsWith('https://')
          ? trimmed
          : 'https://$trimmed';

  final Uri parsed = Uri.parse(withScheme);
  if (parsed.scheme != 'http' && parsed.scheme != 'https') return null;
  if (!parsed.hasAuthority) return null;
  return parsed;
}

void _showSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message)),
  );
}
