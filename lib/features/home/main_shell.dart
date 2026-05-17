import 'package:flutter/material.dart';
import 'package:google_hackathon_app/features/incidents/incidents_controller.dart';
import 'package:google_hackathon_app/theme/app_colors.dart';
import 'package:google_hackathon_app/theme/app_dimens.dart';
import 'package:google_hackathon_app/widgets/glass_surface.dart';
import 'package:google_hackathon_app/features/incidents/incidents_list_screen.dart';
import 'package:google_hackathon_app/features/incidents/models/incident.dart';
import 'package:google_hackathon_app/features/map/map_tab_screen.dart';
import 'package:google_hackathon_app/features/status/status_screen.dart';
import 'package:google_hackathon_app/features/submit/submit_incident_screen.dart';
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
      body: IndexedStack(
        index: _index,
        children: [
          IncidentsListScreen(
            onLogout: widget.onLogout,
            onOpenIncidentOnMap: _openIncidentOnMap,
          ),
          const MapTabScreen(),
          const StatusScreen(),
          const SubmitIncidentScreen(),
        ],
      ),
      bottomNavigationBar: ClipRRect(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimens.radiusLg)),
        child: GlassSurface(
          blur: true,
          sigma: GlassDefaults.sigmaChrome,
          color: AppColors.glassFillStrong.withValues(alpha: 0.92),
          borderRadius: 0,
          border: const Border(
            top: BorderSide(color: AppColors.glassBorderHighlight),
          ),
          child: NavigationBar(
            selectedIndex: _index,
            onDestinationSelected: (int i) => setState(() => _index = i),
            destinations: const [
            NavigationDestination(
              icon: Icon(Icons.list_alt_outlined),
              selectedIcon: Icon(Icons.list_alt),
              label: 'Incidents',
            ),
            NavigationDestination(
              icon: Icon(Icons.map_outlined),
              selectedIcon: Icon(Icons.map),
              label: 'Map',
            ),
            NavigationDestination(
              icon: Icon(Icons.bar_chart_outlined),
              selectedIcon: Icon(Icons.bar_chart),
              label: 'Status',
            ),
            NavigationDestination(
              icon: Icon(Icons.add_circle_outline),
              selectedIcon: Icon(Icons.add_circle),
              label: 'Report',
            ),
            ],
          ),
        ),
      ),
    );
  }
}
