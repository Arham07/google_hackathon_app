import 'package:flutter/material.dart';
import 'package:google_hackathon_app/core/api/api_exception.dart';
import 'package:google_hackathon_app/core/api/events_api.dart';
import 'package:google_hackathon_app/features/incidents/models/incident.dart';
import 'package:google_hackathon_app/features/incidents/models/incident_source.dart';
import 'package:google_hackathon_app/features/map/incident_map_screen.dart';
import 'package:google_hackathon_app/models/api_event.dart';
import 'package:google_hackathon_app/theme/app_colors.dart';
import 'package:google_hackathon_app/utils/external_url.dart';
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
  late Incident _incident;
  bool _loadingExtra = false;

  static const List<String> _placeholderPrecautions = <String>[
    'No specific precautions have been published for this incident yet.',
    'Stay alert and follow guidance from local authorities and emergency services.',
  ];

  static const List<String> _placeholderResources = <String>[
    'No dedicated resources are listed for this incident.',
    'For emergencies in Pakistan, call 1122 or PDMA Sindh helpline 1099.',
  ];

  @override
  void initState() {
    super.initState();
    _incident = widget.incident;
    _loadFull();
  }

  Future<void> _loadFull() async {
    setState(() => _loadingExtra = true);
    try {
      final Map<String, dynamic>? full =
          await _eventsApi.fetchById(widget.incident.id);
      if (!mounted) return;
      if (full != null) {
        _incident = mergeFullEvent(widget.incident, full);
      }
    } on ApiException {
      // Keep list-row data.
    } catch (_) {
      // Ignore — list payload is sufficient for CIRO events API.
    } finally {
      if (mounted) setState(() => _loadingExtra = false);
    }
  }

  List<String> get _precautionsToShow => _incident.precautions.isNotEmpty
      ? _incident.precautions
      : _placeholderPrecautions;

  List<String> get _resourcesToShow =>
      _incident.resources.isNotEmpty ? _incident.resources : _placeholderResources;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

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
                child: _incident.thumbnailUrl != null
                    ? Image.network(
                        _incident.thumbnailUrl!,
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
                PriorityChip(priority: _incident.priority),
                const SizedBox(width: 8),
                if (_incident.status != null && _incident.status!.isNotEmpty)
                  _StatusChip(status: _incident.status!),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _incident.authenticity.label,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: AppColors.chart2,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
            if (_incident.eventTags.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _incident.eventTags
                    .map((String tag) => _TagChip(label: _formatTag(tag)))
                    .toList(),
              ),
            ],
            const SizedBox(height: 12),
            Text(
              _incident.title,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _incident.locationLabel,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.mutedForeground,
              ),
            ),
            if (_incident.area.isNotEmpty)
              Text(
                '${_incident.area}, ${_incident.city}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.mutedForeground,
                ),
              ),
            const SizedBox(height: 4),
            Text(
              DateFormat('dd MMM yyyy, HH:mm').format(_incident.scanDatetime),
              style: theme.textTheme.labelSmall?.copyWith(
                color: AppColors.mutedForeground,
              ),
            ),
            if (_incident.hasMapCoordinates) ...[
              const SizedBox(height: 6),
              Text(
                'Coordinates: ${_incident.mapLatitude.toStringAsFixed(6)}, '
                '${_incident.mapLongitude.toStringAsFixed(6)}',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: AppColors.mapAccent,
                  fontFeatures: const <FontFeature>[
                    FontFeature.tabularFigures(),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 20),
            if (_loadingExtra)
              const Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: LinearProgressIndicator(minHeight: 2),
              ),
            Text(
              _incident.summary,
              style: theme.textTheme.bodyLarge,
            ),
            if (_incident.sourceTrail.isNotEmpty) ...[
              const SizedBox(height: 24),
              ..._incident.sourceTrail.map(_buildSourceTrailSection),
            ],
            _Section(
              title: 'Precautions',
              icon: Icons.warning_amber_rounded,
              items: _precautionsToShow,
              isPlaceholder: _incident.precautions.isEmpty,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _incident.hasMapCoordinates
                    ? () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => IncidentMapScreen(
                              latitude: _incident.mapLatitude,
                              longitude: _incident.mapLongitude,
                              title: _incident.title,
                            ),
                          ),
                        );
                      }
                    : null,
                icon: const Icon(Icons.map_outlined),
                label: const Text('Open on map'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSourceTrailSection(IncidentSourceTrail trail) {
    if (trail.isWeather && trail.weather != null) {
      return _WeatherSection(weather: trail.weather!);
    }
    if (trail.isNews) {
      return _NewsSection(articles: trail.newsArticles);
    }
    return const SizedBox.shrink();
  }

  Widget _placeholderImage() {
    return Container(
      color: AppColors.secondary,
      child: const Center(
        child: Icon(Icons.image_outlined, size: 48, color: AppColors.mutedForeground),
      ),
    );
  }

  String _formatTag(String tag) {
    if (tag.isEmpty) return tag;
    final String spaced = tag.replaceAllMapped(
      RegExp(r'([a-z])([A-Z])'),
      (Match m) => '${m[1]} ${m[2]}',
    );
    return spaced[0].toUpperCase() + spaced.substring(1);
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.mapAccent.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.mapAccent.withValues(alpha: 0.4)),
      ),
      child: Text(
        status,
        style: const TextStyle(
          color: AppColors.mapAccent,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  const _TagChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w500,
            ),
      ),
    );
  }
}

class _WeatherSection extends StatelessWidget {
  const _WeatherSection({required this.weather});

  final IncidentWeatherSnapshot weather;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final List<String> lines = <String>[
      if (weather.condition != null) 'Now: ${weather.condition}',
      if (weather.tempC != null) 'Temperature: ${weather.tempC!.toStringAsFixed(1)} °C',
      if (weather.humidity != null) 'Humidity: ${weather.humidity}%',
      if (weather.windKph != null) 'Wind: ${weather.windKph!.toStringAsFixed(1)} km/h',
      if (weather.day1Condition != null) 'Tomorrow: ${weather.day1Condition}',
      if (weather.day1PrecipMm != null)
        'Expected rain: ${weather.day1PrecipMm!.toStringAsFixed(1)} mm',
      if (weather.day1RainChance != null)
        'Rain chance: ${weather.day1RainChance}%',
    ];

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: _InfoCard(
        title: 'Weather intel',
        icon: Icons.cloud_outlined,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: lines
              .map(
                (String line) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(line, style: theme.textTheme.bodyMedium),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

class _NewsSection extends StatelessWidget {
  const _NewsSection({required this.articles});

  final List<IncidentNewsArticle> articles;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: _InfoCard(
        title: 'Related news',
        icon: Icons.newspaper_outlined,
        child: Column(
          children: articles.map((IncidentNewsArticle article) {
            final String? url = article.url?.trim();
            final bool canOpen = url != null && url.isNotEmpty;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: canOpen
                      ? () => openExternalUrl(context, url)
                      : null,
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (article.thumbnailUrl != null)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              article.thumbnailUrl!,
                              height: 120,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  const SizedBox.shrink(),
                            ),
                          ),
                        if (article.thumbnailUrl != null)
                          const SizedBox(height: 8),
                        Text(
                          article.headline,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: canOpen ? AppColors.mapAccent : null,
                            decoration:
                                canOpen ? TextDecoration.underline : null,
                            decorationColor: AppColors.mapAccent,
                          ),
                        ),
                        if (article.publishedAt != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            article.publishedAt!,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: AppColors.mutedForeground,
                            ),
                          ),
                        ],
                        if (canOpen) ...[
                          const SizedBox(height: 8),
                          TextButton.icon(
                            onPressed: () => openExternalUrl(context, url),
                            icon: const Icon(Icons.open_in_new, size: 16),
                            label: const Text('Read article'),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  final String title;
  final IconData icon;
  final Widget child;

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
          child,
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.icon,
    required this.items,
    this.isPlaceholder = false,
  });

  final String title;
  final IconData icon;
  final List<String> items;
  final bool isPlaceholder;

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
                  if (!isPlaceholder)
                    const Text('• ', style: TextStyle(color: AppColors.mutedForeground)),
                  Expanded(
                    child: Text(
                      item,
                      style: isPlaceholder
                          ? Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.mutedForeground,
                                fontStyle: FontStyle.italic,
                              )
                          : null,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
