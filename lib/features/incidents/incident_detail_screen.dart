import 'package:flutter/material.dart';
import 'package:google_hackathon_app/core/api/api_exception.dart';
import 'package:google_hackathon_app/core/api/events_api.dart';
import 'package:google_hackathon_app/features/incidents/models/incident.dart';
import 'package:google_hackathon_app/features/map/incident_map_screen.dart';
import 'package:google_hackathon_app/models/api_event.dart';
import 'package:google_hackathon_app/theme/app_colors.dart';
import 'package:google_hackathon_app/widgets/priority_chip.dart';
import 'package:intl/intl.dart';

class IncidentDetailScreen extends StatefulWidget {
  const IncidentDetailScreen({super.key, required this.incident});

  final Incident incident;

  @override
  State<IncidentDetailScreen> createState() => _IncidentDetailScreenState();
}

class _IncidentDetailScreenState extends State<IncidentDetailScreen> {
  final EventsApi _eventsApi = EventsApi();
  Incident? _incident;
  bool _loadingExtra = false;

  @override
  void initState() {
    super.initState();
    _incident = widget.incident;
    if (widget.incident.precautions.isEmpty && widget.incident.resources.isEmpty) {
      _loadFull();
    }
  }

  Future<void> _loadFull() async {
    setState(() => _loadingExtra = true);
    try {
      final Map<String, dynamic>? full =
          await _eventsApi.fetchById(widget.incident.id);
      if (!mounted || full == null) return;
      setState(() {
        _incident = mergeFullEvent(widget.incident, full);
        _loadingExtra = false;
      });
    } on ApiException {
      if (mounted) setState(() => _loadingExtra = false);
    } catch (_) {
      if (mounted) setState(() => _loadingExtra = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Incident incident = _incident ?? widget.incident;

    return Scaffold(
      appBar: AppBar(title: const Text('Incident details')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(AppColors.radius),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: incident.thumbnailUrl != null
                    ? Image.network(
                        incident.thumbnailUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            _placeholderImage(),
                      )
                    : _placeholderImage(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                PriorityChip(priority: incident.priority),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    incident.authenticity.label,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.chart2,
                          fontStyle: FontStyle.italic,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              incident.title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              incident.locationLabel,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.mutedForeground,
                  ),
            ),
            Text(
              DateFormat('dd MMM yyyy, HH:mm').format(incident.scanDatetime),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.mutedForeground,
                  ),
            ),
            const SizedBox(height: 20),
            if (_loadingExtra)
              const Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: LinearProgressIndicator(minHeight: 2),
              ),
            Text(
              incident.summary,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            if (incident.precautions.isNotEmpty) ...[
              const SizedBox(height: 24),
              _Section(
                title: 'Precautions',
                icon: Icons.warning_amber_rounded,
                items: incident.precautions,
              ),
            ],
            if (incident.resources.isNotEmpty) ...[
              const SizedBox(height: 16),
              _Section(
                title: 'Resources',
                icon: Icons.medical_services_outlined,
                items: incident.resources,
              ),
            ],
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => IncidentMapScreen(
                        latitude: incident.latitude,
                        longitude: incident.longitude,
                        title: incident.title,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.map_outlined),
                label: const Text('Open on map'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholderImage() {
    return Container(
      color: AppColors.secondary,
      child: const Center(
        child: Icon(Icons.image_outlined, size: 48, color: AppColors.mutedForeground),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.icon,
    required this.items,
  });

  final String title;
  final IconData icon;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.secondary.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(AppColors.radius),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: AppColors.mapAccent),
              const SizedBox(width: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...items.map(
            (String item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• ', style: TextStyle(color: AppColors.mutedForeground)),
                  Expanded(child: Text(item)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
