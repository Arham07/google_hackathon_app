import 'package:flutter/material.dart';
import 'package:google_hackathon_app/theme/priority_styles.dart';

/// In-app alert pushed to the user (distinct from platform push notifications).
class AlertNotification {
  AlertNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.priority,
    required this.timestamp,
    required this.relativeTime,
    required this.location,
    required this.categoryIcon,
    this.isCitizenReport = false,
    this.isRead = false,
    this.headerGradient = const <Color>[
      Color(0xFF2A3548),
      Color(0xFF1A2433),
    ],
  });

  final String id;
  final String title;
  final String body;
  final IncidentPriority priority;
  final DateTime timestamp;
  final String relativeTime;
  final String location;
  final IconData categoryIcon;
  final bool isCitizenReport;
  bool isRead;
  final List<Color> headerGradient;

}
