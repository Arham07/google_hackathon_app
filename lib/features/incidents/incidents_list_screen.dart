import 'package:flutter/material.dart';
import 'package:google_hackathon_app/core/auth_service.dart';
import 'package:google_hackathon_app/features/incidents/incident_detail_screen.dart';
import 'package:google_hackathon_app/features/incidents/incidents_controller.dart';
import 'package:google_hackathon_app/features/incidents/models/incident.dart';
import 'package:google_hackathon_app/theme/app_colors.dart';
import 'package:google_hackathon_app/theme/app_dimens.dart';
import 'package:google_hackathon_app/theme/priority_styles.dart';
import 'package:google_hackathon_app/widgets/glass_surface.dart';
import 'package:google_hackathon_app/widgets/incident_card.dart';
import 'package:provider/provider.dart';

class IncidentsListScreen extends StatefulWidget {
  const IncidentsListScreen({super.key, this.onLogout, this.onOpenIncidentOnMap});

  final VoidCallback? onLogout;
  final void Function(Incident incident)? onOpenIncidentOnMap;

  @override
  State<IncidentsListScreen> createState() => _IncidentsListScreenState();
}

class _IncidentsListScreenState extends State<IncidentsListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<IncidentsController>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final IncidentsController controller = context.watch<IncidentsController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('CIRO Alerts'),
        actions: [
          if (controller.activePriorityFilters.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.filter_alt_off),
              tooltip: 'Clear priority filters',
              onPressed: controller.clearPriorityFilters,
            ),
          if (widget.onLogout != null)
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                await AuthService().logout();
                widget.onLogout!();
              },
            ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
              AppDimens.space16,
              AppDimens.space8,
              AppDimens.space16,
              0,
            ),
            child: GlassCard(
              blur: false,
              padding: EdgeInsets.all(AppDimens.space8),
              child: SegmentedButton<IncidentListMode>(
              segments: const [
                ButtonSegment(
                  value: IncidentListMode.nearby,
                  label: Text('Nearby'),
                  icon: Icon(Icons.near_me_outlined),
                ),
                ButtonSegment(
                  value: IncidentListMode.priority,
                  label: Text('Priority'),
                  icon: Icon(Icons.priority_high),
                ),
                ButtonSegment(
                  value: IncidentListMode.all,
                  label: Text('All'),
                  icon: Icon(Icons.list),
                ),
              ],
              selected: <IncidentListMode>{controller.mode},
              onSelectionChanged: (Set<IncidentListMode> selected) {
                if (selected.isEmpty) return;
                controller.setMode(selected.first);
              },
            ),
            ),
          ),
          SizedBox(height: AppDimens.space8),
          SizedBox(
            height: AppDimens.chipRowHeight,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: AppDimens.space12),
              children: IncidentPriority.values
                  .where((IncidentPriority p) => p != IncidentPriority.unknown)
                  .map((IncidentPriority priority) {
                final bool selected =
                    controller.activePriorityFilters.contains(priority);
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppDimens.space4),
                  child: FilterChip(
                    label: Text(
                      priority.label,
                      style: TextStyle(
                        color: selected ? priority.color : null,
                        fontWeight: FontWeight.w600,
                        fontSize: AppDimens.font11,
                      ),
                    ),
                    selected: selected,
                    onSelected: (_) => controller.togglePriorityFilter(priority),
                    selectedColor: priority.color.withValues(alpha: 0.2),
                    checkmarkColor: priority.color,
                  ),
                );
              }).toList(),
            ),
          ),
          if (controller.mode == IncidentListMode.nearby &&
              controller.nearestArea?.area != null)
            Padding(
              padding: EdgeInsets.fromLTRB(
                AppDimens.space16,
                AppDimens.space8,
                AppDimens.space16,
                0,
              ),
              child: Text(
                _nearestBanner(controller),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.mapAccent,
                    ),
              ),
            ),
          Expanded(child: _buildBody(context, controller)),
        ],
      ),
    );
  }

  String _nearestBanner(IncidentsController controller) {
    final String area = controller.nearestArea?.area ?? 'your area';
    final double? km = controller.nearestArea?.distanceKm;
    if (km != null) {
      return 'Showing incidents near $area (${km.toStringAsFixed(1)} km away)';
    }
    return 'Showing incidents near $area';
  }

  Widget _buildBody(BuildContext context, IncidentsController controller) {
    if (controller.isLoading && controller.visibleIncidents.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (controller.errorMessage != null && controller.visibleIncidents.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(AppDimens.space24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.cloud_off,
                size: AppDimens.iconXl,
                color: AppColors.mutedForeground,
              ),
              SizedBox(height: AppDimens.space16),
              Text(
                controller.errorMessage!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              SizedBox(height: AppDimens.space16),
              FilledButton.icon(
                onPressed: controller.load,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final List<Incident> incidents = controller.visibleIncidents;

    if (incidents.isEmpty) {
      return Center(
        child: Text(
          controller.activePriorityFilters.isNotEmpty
              ? 'No incidents match selected priorities'
              : 'No incidents found',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.mutedForeground,
              ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: controller.load,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.only(top: AppDimens.space8, bottom: AppDimens.space24),
        itemCount: incidents.length,
        itemBuilder: (BuildContext context, int index) {
          final Incident incident = incidents[index];
          return IncidentCard(
            incident: incident,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => IncidentDetailScreen(incident: incident),
                ),
              );
            },
            onOpenOnMap: widget.onOpenIncidentOnMap == null || !incident.hasMapCoordinates
                ? null
                : () => widget.onOpenIncidentOnMap!(incident),
          );
        },
      ),
    );
  }
}
