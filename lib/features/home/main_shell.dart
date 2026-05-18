import 'package:flutter/material.dart';
import 'package:google_hackathon_app/features/incidents/incidents_controller.dart';
import 'package:google_hackathon_app/features/incidents/incidents_list_screen.dart';
import 'package:google_hackathon_app/features/incidents/models/incident.dart';
import 'package:google_hackathon_app/features/map/map_tab_screen.dart';
import 'package:google_hackathon_app/features/status/status_screen.dart';
import 'package:google_hackathon_app/features/submit/submit_incident_screen.dart';
import 'package:google_hackathon_app/theme/app_colors.dart';
import 'package:google_hackathon_app/widgets/ciro_bottom_nav.dart';
import 'package:provider/provider.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key, required this.onLogout});

  final VoidCallback onLogout;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;
  IncidentsController? _incidents;

  static const List<({IconData icon, IconData selectedIcon, String label})> _destinations =
      <({IconData icon, IconData selectedIcon, String label})>[
    (icon: Icons.list_alt_outlined, selectedIcon: Icons.list_alt, label: 'Incidents'),
    (icon: Icons.map_outlined, selectedIcon: Icons.map, label: 'Map'),
    (icon: Icons.bar_chart_outlined, selectedIcon: Icons.bar_chart, label: 'Status'),
    (icon: Icons.add_circle_outline, selectedIcon: Icons.add_circle, label: 'Report'),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final IncidentsController c = context.read<IncidentsController>();
      _incidents = c;
      c.addListener(_onIncidentsChanged);
    });
  }

  @override
  void dispose() {
    _incidents?.removeListener(_onIncidentsChanged);
    super.dispose();
  }

  void _onIncidentsChanged() {
    if (!mounted) return;
    final IncidentsController c = context.read<IncidentsController>();
    if (c.switchToMapTabPending) {
      c.clearSwitchToMapTabPending();
      setState(() => _index = 1);
    }
  }

  void _openIncidentOnMap(Incident incident) {
    context.read<IncidentsController>().requestMapFocus(incident, switchToMapTab: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: _index,
        children: <Widget>[
          IncidentsListScreen(
            onLogout: widget.onLogout,
            onOpenIncidentOnMap: _openIncidentOnMap,
          ),
          const MapTabScreen(),
          const StatusScreen(),
          const SubmitIncidentScreen(),
        ],
      ),
      bottomNavigationBar: CiroBottomNav(
        selectedIndex: _index,
        onSelected: (int i) => setState(() => _index = i),
        destinations: _destinations,
      ),
    );
  }
}
