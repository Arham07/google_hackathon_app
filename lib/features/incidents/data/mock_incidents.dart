import 'package:google_hackathon_app/features/incidents/models/mock_incident.dart';
import 'package:google_hackathon_app/theme/priority_styles.dart';

/// Hardcoded incidents for Phase 1 UI (Karachi / Pakistan disaster theme).
final List<MockIncident> mockIncidents = <MockIncident>[
  MockIncident(
    id: 'evt-1',
    title: 'Korangi Causeway Closure After Malir River Surge',
    category: 'Flood / road closure',
    city: 'Karachi',
    area: 'Korangi',
    latitude: 24.825074,
    longitude: 67.0905973,
    priority: IncidentPriority.high,
    scanDatetime: DateTime(2025, 9, 12, 14, 30),
    summary:
        'Causeway partially submerged after monsoon surge. Traffic diverted via alternate routes.',
    precautions: <String>[
      'Avoid low-lying routes near Malir River belt.',
      'Do not drive through standing water.',
      'Keep emergency kit and charged phone.',
    ],
    resources: <String>[
      'PDMA Sindh helpline: 1099',
      'Nearest relief camp: Korangi Industrial Area',
    ],
    authenticity: AuthenticityTier.verifiedMajorOutlet,
  ),
  MockIncident(
    id: 'evt-2',
    title: 'Shahrah-e-Bhutto Flash Flood Collapse',
    category: 'Infrastructure damage',
    city: 'Karachi',
    area: 'Malir',
    latitude: 24.8923,
    longitude: 67.1984,
    priority: IncidentPriority.critical,
    scanDatetime: DateTime(2025, 9, 11, 9, 15),
    summary:
        'Section of service road collapsed after heavy rainfall. Structural assessment underway.',
    precautions: <String>[
      'Stay clear of damaged roadway and embankments.',
      'Report cracks or new water pooling to local authorities.',
    ],
    resources: <String>[
      'Karachi Metropolitan Corporation emergency line',
      'Use elevated main roads only',
    ],
    authenticity: AuthenticityTier.verifiedMajorOutlet,
  ),
  MockIncident(
    id: 'evt-3',
    title: 'Clifton Sea View high-tide advisory',
    category: 'Coastal / weather',
    city: 'Karachi',
    area: 'Clifton',
    latitude: 24.8138,
    longitude: 67.0299,
    priority: IncidentPriority.medium,
    scanDatetime: DateTime(2025, 9, 10, 18, 0),
    summary: 'High tide expected; minor flooding possible along sea view strip.',
    precautions: <String>[
      'Avoid beachfront during high tide window.',
      'Move vehicles from low parking areas.',
    ],
    resources: <String>['Pakistan Meteorological Department updates'],
    authenticity: AuthenticityTier.establishedAccount,
  ),
  MockIncident(
    id: 'evt-4',
    title: 'Lyari nullah overflow reported',
    category: 'Urban flooding',
    city: 'Karachi',
    area: 'Lyari',
    latitude: 24.8668,
    longitude: 66.9993,
    priority: IncidentPriority.high,
    scanDatetime: DateTime(2025, 9, 13, 6, 45),
    summary: 'Residents report waist-deep water in several lanes after overnight rain.',
    precautions: <String>[
      'Evacuate ground floors if water enters homes.',
      'Turn off main electrical supply if flooding indoors.',
    ],
    resources: <String>['Community rescue volunteers — local UC office'],
    isUserSubmitted: true,
    authenticity: AuthenticityTier.unverifiedCitizen,
  ),
  MockIncident(
    id: 'evt-5',
    title: 'Heatwave advisory — Sindh interior',
    category: 'Heat / health',
    city: 'Hyderabad',
    area: 'Sindh',
    latitude: 25.3960,
    longitude: 68.3578,
    priority: IncidentPriority.medium,
    scanDatetime: DateTime(2025, 6, 1, 11, 0),
    summary: 'Extreme heat index expected; vulnerable groups at risk.',
    precautions: <String>[
      'Stay hydrated; avoid outdoor work 11am–4pm.',
      'Check on elderly neighbours.',
    ],
    resources: <String>['1122 emergency', 'Cooling centres — district admin'],
    authenticity: AuthenticityTier.verifiedMajorOutlet,
  ),
  MockIncident(
    id: 'evt-6',
    title: 'Gulshan-e-Iqbal drainage blockage',
    category: 'Urban flooding',
    city: 'Karachi',
    area: 'Gulshan-e-Iqbal',
    latitude: 24.9239,
    longitude: 67.0881,
    priority: IncidentPriority.low,
    scanDatetime: DateTime(2025, 9, 9, 16, 20),
    summary: 'Localized pooling after rain; KMC teams dispatched.',
    precautions: <String>['Use alternate routes via University Road.'],
    resources: <String>['KMC complaint: 1339'],
    authenticity: AuthenticityTier.establishedAccount,
  ),
];

MockIncident? findMockIncidentById(String id) {
  for (final MockIncident incident in mockIncidents) {
    if (incident.id == id) return incident;
  }
  return null;
}
