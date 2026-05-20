import 'package:flutter/material.dart';
import 'package:google_hackathon_app/features/incidents/incident_detail_screen.dart';
import 'package:google_hackathon_app/services/location_service.dart';
import 'package:google_hackathon_app/features/incidents/incidents_controller.dart';
import 'package:google_hackathon_app/features/incidents/models/incident.dart';
import 'package:google_hackathon_app/features/notifications/notification_routes.dart';
import 'package:google_hackathon_app/features/notifications/notifications_screen.dart';
import 'package:google_hackathon_app/features/notifications/notifications_store.dart';
import 'package:google_hackathon_app/theme/app_colors.dart';
import 'package:google_hackathon_app/theme/app_dimens.dart';
import 'package:google_hackathon_app/theme/app_text_styles.dart';
import 'package:google_hackathon_app/widgets/account_menu_sheet.dart';
import 'package:google_hackathon_app/widgets/alerts_mode_selector.dart';
import 'package:google_hackathon_app/widgets/incident_card.dart';
import 'package:google_hackathon_app/widgets/severity_filter_chip.dart';
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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        leading: widget.onLogout != null
            ? IconButton(
                tooltip: 'Account',
                onPressed: () => showAccountMenuSheet(
                  context,
                  onLogout: widget.onLogout!,
                ),
                icon: CircleAvatar(
                  radius: 16,
                  backgroundColor: AppColors.surfaceElevated,
                  child: Icon(
                    Icons.person_outline,
                    size: AppDimens.iconMd,
                    color: AppColors.mapAccent,
                  ),
                ),
              )
            : null,
        title: const Text('BaKhabar Alerts', style: AppTextStyles.alertsTitle),
        actions: <Widget>[
          if (controller.activePriorityFilters.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.filter_alt_off),
              tooltip: 'Clear priority filters',
              onPressed: controller.clearPriorityFilters,
            ),
          _NotificationsAppBarAction(
            unreadCount: NotificationsStore.instance.unreadCount,
            onReturn: () {
              if (mounted) setState(() {});
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.fromLTRB(
              AppDimens.space16,
              AppDimens.space8,
              AppDimens.space16,
              0,
            ),
            child: AlertsModeSelector(
              mode: controller.mode,
              onModeChanged: controller.setMode,
            ),
          ),
          SizedBox(height: AppDimens.space10),
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
                  child: SeverityFilterChip(
                    priority: priority,
                    selected: selected,
                    onSelected: (_) => controller.togglePriorityFilter(priority),
                  ),
                );
              }).toList(),
            ),
          ),
          Expanded(child: _buildBody(context, controller)),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context, IncidentsController controller) {
    if (controller.isLoading && controller.visibleIncidents.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: AppColors.mapAccent));
    }

    if (controller.isNearbyLocationBlocked) {
      return _NearbyLocationPrompt(
        message: controller.errorMessage ?? 'Enable location to see nearby alerts.',
        onRetry: controller.load,
      );
    }

    if (controller.errorMessage != null && controller.visibleIncidents.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(AppDimens.space24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                Icons.cloud_off,
                size: AppDimens.iconXl,
                color: AppColors.textSecondary,
              ),
              SizedBox(height: AppDimens.space16),
              Text(
                controller.errorMessage!,
                textAlign: TextAlign.center,
                style: AppTextStyles.emptyState,
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
        child: Padding(
          padding: EdgeInsets.all(AppDimens.space24),
          child: Text(
            controller.activePriorityFilters.isNotEmpty
                ? 'No incidents match selected priorities'
                : controller.mode == IncidentListMode.priority
                    ? 'No critical, high, or medium priority incidents'
                    : 'No incidents found',
            textAlign: TextAlign.center,
            style: AppTextStyles.emptyState,
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: controller.load,
      color: AppColors.mapAccent,
      backgroundColor: AppColors.surface,
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

class _NearbyLocationPrompt extends StatelessWidget {
  const _NearbyLocationPrompt({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppDimens.space24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              Icons.location_off_outlined,
              size: AppDimens.iconXl,
              color: AppColors.textSecondary,
            ),
            SizedBox(height: AppDimens.space16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.emptyState,
            ),
            SizedBox(height: AppDimens.space20),
            FilledButton.icon(
              onPressed: () async {
                final bool opened = await LocationService.openAppSettings();
                if (!opened) {
                  await LocationService.openLocationSettings();
                }
              },
              icon: const Icon(Icons.settings_outlined),
              label: const Text('Enable location'),
            ),
            SizedBox(height: AppDimens.space10),
            OutlinedButton.icon(
              onPressed: () async {
                await onRetry();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationsAppBarAction extends StatelessWidget {
  const _NotificationsAppBarAction({
    required this.unreadCount,
    required this.onReturn,
  });

  final int unreadCount;
  final VoidCallback onReturn;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Notifications',
      onPressed: () async {
        await Navigator.of(context).push<void>(
          notificationFadeSlideRoute<void>(const NotificationsScreen()),
        );
        onReturn();
      },
      icon: Badge(
        isLabelVisible: unreadCount > 0,
        label: Text('$unreadCount'),
        backgroundColor: AppColors.destructive,
        child: const Icon(Icons.notifications_outlined),
      ),
    );
  }
}
