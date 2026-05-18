import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_hackathon_app/features/incidents/models/incident.dart';
import 'package:google_hackathon_app/theme/app_colors.dart';
import 'package:google_hackathon_app/theme/app_dimens.dart';
import 'package:google_hackathon_app/theme/app_text_styles.dart';
import 'package:google_hackathon_app/theme/priority_styles.dart';
import 'package:google_hackathon_app/utils/incident_time_format.dart';
import 'package:intl/intl.dart';

/// Refactored alert incident card for CIRO Alerts list.
class IncidentCard extends StatelessWidget {
  const IncidentCard({super.key, required this.incident, required this.onTap, this.onOpenOnMap});

  final Incident incident;
  final VoidCallback onTap;
  final VoidCallback? onOpenOnMap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppDimens.space16, vertical: AppDimens.space6),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: AppColors.surface,
          border: Border.all(color: AppColors.glassBorder),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              _MapHeader(incident: incident),
              _IncidentDetails(incident: incident, onOpenOnMap: onOpenOnMap),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Map header (~40% visual weight via aspect ratio)
// ---------------------------------------------------------------------------

class _MapHeader extends StatelessWidget {
  const _MapHeader({required this.incident});

  final Incident incident;

  bool get _isActive => IncidentTimeFormat.isWithinLast24Hours(incident.scanDatetime, DateTime.now());

  bool get _isVerified => incident.authenticity == AuthenticityTier.verifiedMajorOutlet;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 2,
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          _MapBackground(thumbnailUrl: incident.thumbnailUrl),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 72,
            child:DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.0, 0.5, 1.0],
                  colors: [
                    AppColors.surface.withValues(alpha: 0.0),
                    AppColors.surface.withValues(alpha: 0.55),
                    AppColors.surface,
                  ],
                ),
              ),
            ),
          ),
          if (_isVerified) Positioned(top: AppDimens.space10, left: AppDimens.space10, child: _AuthorityBadge()),
          Positioned(
            top: AppDimens.space10,
            right: AppDimens.space10,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                _CategoryIcons(category: incident.category),
                if (_isActive) ...<Widget>[SizedBox(width: AppDimens.space8), const _ActiveBadge()],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MapBackground extends StatelessWidget {
  const _MapBackground({this.thumbnailUrl});

  final String? thumbnailUrl;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        if (thumbnailUrl != null)
          Image.network(
            thumbnailUrl!,
            fit: BoxFit.cover,
            errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) => const _VectorMapPattern(),
          )
        else
          Image.asset('assets/images/incident_thumbnail_placeholder.jpeg', fit: BoxFit.cover),
        thumbnailUrl != null
            ? DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 1.1,
                    colors: <Color>[AppColors.surface.withValues(alpha: 0.05), AppColors.surface.withValues(alpha: 0.55)],
                  ),
                ),
              )
            : SizedBox.shrink(),
      ],
    );
  }
}

class _VectorMapPattern extends StatelessWidget {
  const _VectorMapPattern();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _MinimalMapPainter(),
      child: Container(color: const Color(0xFF151D28)),
    );
  }
}

class _MinimalMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint grid = Paint()
      ..color = AppColors.textSecondary.withValues(alpha: 0.12)
      ..strokeWidth = 1;

    const double step = 28;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), grid);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }

    final Paint road = Paint()
      ..color = AppColors.textSecondary.withValues(alpha: 0.22)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    final Path path = Path()
      ..moveTo(size.width * 0.08, size.height * 0.72)
      ..quadraticBezierTo(size.width * 0.42, size.height * 0.38, size.width * 0.92, size.height * 0.58);
    canvas.drawPath(path, road);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ThreatFocalPoint extends StatelessWidget {
  const _ThreatFocalPoint({required this.priority});

  final IncidentPriority priority;

  @override
  Widget build(BuildContext context) {
    final Color core = priority == IncidentPriority.unknown ? AppColors.priorityHigh : priority.color;

    return Container(
      width: 14,
      height: 14,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: core,
        border: Border.all(color: Colors.white.withValues(alpha: 0.9), width: 2),
        boxShadow: <BoxShadow>[BoxShadow(color: core.withValues(alpha: 0.65), blurRadius: 10, spreadRadius: 2)],
      ),
    );
  }
}

class _AuthorityBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 168),
      padding: EdgeInsets.symmetric(horizontal: AppDimens.space8, vertical: AppDimens.space6),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(AppDimens.radiusPill),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Stack(
            clipBehavior: Clip.none,
            children: <Widget>[
              Icon(Icons.shield_outlined, size: 18, color: AppColors.textSecondary),
              Positioned(right: -4, top: -4, child: Icon(Icons.star_rounded, size: 12, color: AppColors.authorityAccent)),
            ],
          ),
          SizedBox(width: AppDimens.space6),
          Flexible(
            child: Text(
              'Authority Verified',
              style: AppTextStyles.authorityLabel.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.w600),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryIcons extends StatelessWidget {
  const _CategoryIcons({required this.category});

  final String category;

  @override
  Widget build(BuildContext context) {
    final String lower = category.toLowerCase();
    final List<IconData> icons = <IconData>[];

    if (lower.contains('flood') || lower.contains('water') || lower.contains('coastal')) {
      icons.add(Icons.water_rounded);
    }
    if (lower.contains('road') || lower.contains('infrastructure') || lower.contains('collapse')) {
      icons.add(Icons.construction_rounded);
    }
    if (icons.isEmpty) {
      icons.add(Icons.warning_amber_rounded);
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: icons
          .map(
            (IconData icon) => Padding(
              padding: EdgeInsets.only(left: AppDimens.space4),
              child: Icon(icon, size: 18, color: AppColors.textPrimary),
            ),
          )
          .toList(),
    );
  }
}

class _ActiveBadge extends StatelessWidget {
  const _ActiveBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: AppDimens.space8, vertical: AppDimens.space4),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(AppDimens.radiusPill),
        border: Border.all(color: AppColors.priorityCritical.withValues(alpha: 0.55)),
      ),
      child: Text('ACTIVE', style: AppTextStyles.activeBadge),
    );
  }
}

// ---------------------------------------------------------------------------
// Core incident details
// ---------------------------------------------------------------------------

class _IncidentDetails extends StatelessWidget {
  const _IncidentDetails({required this.incident, this.onOpenOnMap});

  final Incident incident;
  final VoidCallback? onOpenOnMap;

  @override
  Widget build(BuildContext context) {
    final String dateTime = DateFormat('dd MMM yyyy, hh:mm a').format(incident.scanDatetime);

    return Padding(
      padding: EdgeInsets.fromLTRB(AppDimens.space14, AppDimens.space12, AppDimens.space14, AppDimens.space8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              SizedBox(
                width: 250.w,
                child: Text.rich(
                  TextSpan(
                    children: [TextSpan(text: incident.title, style: AppTextStyles.incidentTitle)],
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              _SeverityBadge(priority: incident.priority),
            ],
          ),
          SizedBox(height: AppDimens.space10),
          Text(
            '$dateTime',
            style: AppTextStyles.incidentTitle.copyWith(
              fontSize: 12, // smaller size
              fontWeight: FontWeight.w400,
            ),
          ),
          SizedBox(height: AppDimens.space10),

          Divider(height: 1, color: AppColors.glassBorder),

          if (incident.isUserSubmitted) ...<Widget>[SizedBox(height: AppDimens.space8), _CitizenReportTag()],
          SizedBox(height: AppDimens.space10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Icon(Icons.location_on_outlined, size: AppDimens.iconSm, color: AppColors.textSecondary),
              SizedBox(width: AppDimens.space6),
              Expanded(
                child: Text(incident.locationLabel, style: AppTextStyles.bodySecondary, maxLines: 3, overflow: TextOverflow.ellipsis),
              ),
              if (onOpenOnMap != null && incident.hasMapCoordinates)
                Column(
                  children: [
                    _ShowOnMapLink(onTap: onOpenOnMap!),
                    SizedBox(height: 5.h),
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 0),
                          child: Icon(Icons.schedule_outlined, size: AppDimens.iconXs, color: const Color(0xFFFCA5A5)),
                        ),
                        SizedBox(width: AppDimens.space4),
                        Text(
                          IncidentTimeFormat.relativeAge(incident.scanDatetime, DateTime.now()),
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(color: const Color(0xFFFCA5A5), fontWeight: FontWeight.w600),
                        ),
                        // _ImpactMetricsGrid(incident: incident),
                      ],
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SeverityBadge extends StatelessWidget {
  const _SeverityBadge({required this.priority});

  final IncidentPriority priority;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: AppDimens.space8, vertical: AppDimens.space4),
      decoration: BoxDecoration(
        color: priority.backgroundColor,
        borderRadius: BorderRadius.circular(AppDimens.radiusPill),
        border: Border.all(color: priority.borderColor, width: 1.5),
      ),
      child: Text(
        priority.badgeLabel,
        style: TextStyle(color: priority.color, fontSize: AppDimens.font10, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _CitizenReportTag extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: AppDimens.space8, vertical: AppDimens.space4),
      decoration: BoxDecoration(
        color: AppColors.userSubmitted.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(AppDimens.radiusSm),
        border: Border.all(color: AppColors.userSubmitted.withValues(alpha: 0.45)),
      ),
      child: Text(
        'Citizen report',
        style: TextStyle(color: AppColors.userSubmitted, fontSize: AppDimens.font10, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _ShowOnMapLink extends StatelessWidget {
  const _ShowOnMapLink({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimens.radiusSm),
      child: Padding(
        padding: EdgeInsets.only(left: AppDimens.space8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text('Show on map', style: AppTextStyles.mapLink),
            SizedBox(width: AppDimens.space4),
            Icon(Icons.map_outlined, size: AppDimens.iconSm, color: AppColors.mapAccent),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Impact metrics grid
// ---------------------------------------------------------------------------

class _ImpactMetricsGrid extends StatelessWidget {
  const _ImpactMetricsGrid({required this.incident});

  final Incident incident;

  @override
  Widget build(BuildContext context) {
    final _ImpactMetrics metrics = _ImpactMetrics.fromIncident(incident);

    return Padding(
      padding: EdgeInsets.fromLTRB(AppDimens.space14, 0, AppDimens.space14, AppDimens.space14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('Impact area details', style: AppTextStyles.metricLabel.copyWith(fontWeight: FontWeight.w600)),
          SizedBox(height: AppDimens.space10),
          Row(
            children: <Widget>[
              Expanded(
                child: _MetricCell(icon: Icons.access_time_rounded, label: 'Estimated duration', value: metrics.estimatedDuration),
              ),
              Expanded(
                child: _MetricCell(icon: Icons.people_outline_rounded, label: 'Population affected', value: metrics.populationAffected),
              ),
              Expanded(
                child: _MetricCell(icon: Icons.engineering_rounded, label: 'Impact type', value: metrics.impactType),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ImpactMetrics {
  const _ImpactMetrics({required this.estimatedDuration, required this.populationAffected, required this.impactType});

  final String estimatedDuration;
  final String populationAffected;
  final String impactType;

  factory _ImpactMetrics.fromIncident(Incident incident) {
    final DateTime now = DateTime.now();
    final String duration = incident.status?.trim().isNotEmpty == true
        ? incident.status!.trim()
        : IncidentTimeFormat.relativeAge(incident.scanDatetime, now);

    String population = 'Monitoring';
    if (incident.eventTags.isNotEmpty) {
      population = incident.eventTags.first;
    } else if (incident.area.isNotEmpty) {
      population = incident.area;
    }

    final String impact = incident.category.isNotEmpty ? incident.category : (incident.type ?? 'Infrastructure');

    return _ImpactMetrics(estimatedDuration: duration, populationAffected: population, impactType: impact);
  }
}

class _MetricCell extends StatelessWidget {
  const _MetricCell({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Icon(icon, size: AppDimens.iconSm, color: AppColors.textSecondary),
        SizedBox(height: AppDimens.space4),
        Text(label, style: AppTextStyles.metricLabel, maxLines: 2, overflow: TextOverflow.ellipsis),
        SizedBox(height: AppDimens.space4),
        Text(value, style: AppTextStyles.metricValue, maxLines: 2, overflow: TextOverflow.ellipsis),
      ],
    );
  }
}
