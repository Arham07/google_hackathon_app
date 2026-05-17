import 'package:flutter/material.dart';
import 'package:google_hackathon_app/core/auth_service.dart';
import 'package:google_hackathon_app/features/incidents/data/mock_incidents.dart';
import 'package:google_hackathon_app/features/incidents/incident_detail_screen.dart';
import 'package:google_hackathon_app/widgets/incident_card.dart';

class IncidentsListScreen extends StatelessWidget {
  const IncidentsListScreen({super.key, this.onLogout});

  final VoidCallback? onLogout;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CIRO Alerts'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Filters — demo only')),
              );
            },
          ),
          if (onLogout != null)
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                await AuthService().logout();
                onLogout!();
              },
            ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.only(top: 8, bottom: 24),
        itemCount: mockIncidents.length,
        itemBuilder: (BuildContext context, int index) {
          final incident = mockIncidents[index];
          return IncidentCard(
            incident: incident,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => IncidentDetailScreen(incident: incident),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
