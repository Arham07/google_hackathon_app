import 'package:flutter_test/flutter_test.dart';
import 'package:google_hackathon_app/features/incidents/models/incident.dart';
import 'package:google_hackathon_app/models/api_event.dart';

void main() {
  group('incidentFromApiJson', () {
    test('maps compact event fields', () {
      final Incident incident = incidentFromApiJson(<String, dynamic>{
        'event_id': 'EVT-1',
        'category': 'Flood on M-9',
        'priority': 'HIGH',
        'city': 'Karachi',
        'area': 'Malir',
        'address': 'Malir Cantonment, Karachi',
        'lat': 24.98,
        'lng': 67.21,
        'ai_summary': 'Water logging reported',
        'scan_datetime': '2026-05-17T11:54:56.242+00:00',
        'is_user_submitted': true,
      });

      expect(incident.id, 'EVT-1');
      expect(incident.title, 'Flood on M-9');
      expect(incident.priority, IncidentPriority.high);
      expect(incident.summary, 'Water logging reported');
      expect(incident.isUserSubmitted, isTrue);
      expect(incident.locationLabel, contains('Malir Cantonment'));
    });
  });

  group('priority helpers', () {
    test('sorts CRITICAL before LOW', () {
      final List<Incident> list = <Incident>[
        _fake(priority: IncidentPriority.low, id: 'a'),
        _fake(priority: IncidentPriority.critical, id: 'b'),
        _fake(priority: IncidentPriority.high, id: 'c'),
      ];
      sortIncidentsByPriority(list);
      expect(list.first.priority, IncidentPriority.critical);
      expect(list.last.priority, IncidentPriority.low);
    });

    test('filters by selected priorities', () {
      final List<Incident> list = <Incident>[
        _fake(priority: IncidentPriority.low, id: 'a'),
        _fake(priority: IncidentPriority.high, id: 'b'),
      ];
      final List<Incident> filtered = filterIncidentsByPriorities(
        list,
        <IncidentPriority>{IncidentPriority.high},
      );
      expect(filtered, hasLength(1));
      expect(filtered.first.id, 'b');
    });
  });
}

Incident _fake({required IncidentPriority priority, required String id}) {
  return Incident(
    id: id,
    title: 't',
    category: 'c',
    city: 'Karachi',
    area: 'a',
    latitude: 0,
    longitude: 0,
    priority: priority,
    scanDatetime: DateTime(2026, 5, 17),
    summary: 's',
    precautions: const <String>[],
    resources: const <String>[],
  );
}
