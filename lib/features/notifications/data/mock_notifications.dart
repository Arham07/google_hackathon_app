import 'package:flutter/material.dart';
import 'package:google_hackathon_app/features/notifications/models/alert_notification.dart';
import 'package:google_hackathon_app/theme/priority_styles.dart';

/// Dummy notifications — content aligned with the BaKhabarAlerts feed screenshot.
List<AlertNotification> createMockNotifications() {
  return <AlertNotification>[
    AlertNotification(
      id: 'notif-001',
      title: 'Factory Fire Breaks Out on Shershah Road',
      body:
          'A fire has been reported at an industrial unit along Shershah Road. '
          'Citizen footage shows smoke rising near the port access corridor. '
          'Avoid the area and follow directions from emergency responders.',
      priority: IncidentPriority.medium,
      timestamp: DateTime(2026, 5, 18, 10, 28),
      relativeTime: '1d ago',
      location: 'shershah rd, Karachi',
      categoryIcon: Icons.local_fire_department_outlined,
      isCitizenReport: true,
      isRead: false,
      headerGradient: const <Color>[
        Color(0xFF4A3828),
        Color(0xFF1E2733),
      ],
    ),
    AlertNotification(
      id: 'notif-002',
      title: 'Gulshan Transformer Blast Triggering Nighttime Traffic Diversions',
      body:
          'A transformer failure in Gulshan-e-Iqbal caused a localized blast and '
          'power flicker. Traffic police have set up diversions on main arteries; '
          'expect delays through the evening peak.',
      priority: IncidentPriority.low,
      timestamp: DateTime(2026, 5, 18, 9, 47),
      relativeTime: '1d ago',
      location: 'Gulshan-e-Iqbal, Karachi, Pakistan',
      categoryIcon: Icons.electric_bolt_outlined,
      isRead: false,
      headerGradient: const <Color>[
        Color(0xFF2E3A4D),
        Color(0xFF1A2430),
      ],
    ),
    AlertNotification(
      id: 'notif-003',
      title: 'Road Blockage Near Five Star Chowrangi',
      body:
          'Multiple reports indicate a partial road blockage at Five Star Chowrangi, '
          'North Nazimabad. Use alternate routes via Hyderi and Sakhi Hasan until '
          'clearance crews arrive.',
      priority: IncidentPriority.high,
      timestamp: DateTime(2026, 5, 19, 5, 30),
      relativeTime: '5h ago',
      location: 'Five Star Chowrangi, North Nazimabad, Karachi',
      categoryIcon: Icons.warning_amber_rounded,
      isRead: true,
      headerGradient: const <Color>[
        Color(0xFF3D3528),
        Color(0xFF1E2733),
      ],
    ),
  ];
}
