import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_hackathon_app/features/incidents/data/mock_incidents.dart';
import 'package:google_hackathon_app/theme/app_colors.dart';
import 'package:google_hackathon_app/theme/app_dimens.dart';
import 'package:google_hackathon_app/theme/priority_styles.dart';
import 'package:google_hackathon_app/widgets/glass_surface.dart';

class StatusScreen extends StatelessWidget {
  const StatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Map<IncidentPriority, int> byPriority = {};
    final Map<String, int> byCity = {};

    for (final incident in mockIncidents) {
      byPriority[incident.priority] = (byPriority[incident.priority] ?? 0) + 1;
      byCity[incident.city] = (byCity[incident.city] ?? 0) + 1;
    }

    const int totalPakistanDemo = 127;

    return Scaffold(
      appBar: AppBar(title: const Text('Status')),
      body: ListView(
        padding: EdgeInsets.all(AppDimens.space16),
        children: [
          _StatCard(
            label: 'Incidents tracked (Pakistan — demo)',
            value: '$totalPakistanDemo',
            icon: Icons.public,
            color: AppColors.chart1,
          ),
          SizedBox(height: AppDimens.space12),
          _StatCard(
            label: 'In this feed',
            value: '${mockIncidents.length}',
            icon: Icons.list_alt,
            color: AppColors.chart2,
          ),
          SizedBox(height: AppDimens.space24),
          Text(
            'By priority (feed)',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          SizedBox(height: AppDimens.space12),
          SizedBox(
            height: AppDimens.chartHeight,
            child: _PriorityBarChart(counts: byPriority),
          ),
          SizedBox(height: AppDimens.space24),
          Text(
            'By city (feed)',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          SizedBox(height: AppDimens.space12),
          SizedBox(
            height: AppDimens.chartHeight,
            child: _CityPieChart(counts: byCity),
          ),
          SizedBox(height: AppDimens.space16),
          Text(
            'Demo data only — connect API in a later phase for live aggregates.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.mutedForeground,
                  fontStyle: FontStyle.italic,
                ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      blur: false,
      padding: EdgeInsets.all(AppDimens.space16),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(AppDimens.space12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(AppDimens.radiusSm),
            ),
            child: Icon(icon, color: color),
          ),
          SizedBox(width: AppDimens.space16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.mutedForeground,
                      ),
                ),
                Text(
                  value,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PriorityBarChart extends StatelessWidget {
  const _PriorityBarChart({required this.counts});

  final Map<IncidentPriority, int> counts;

  @override
  Widget build(BuildContext context) {
    final List<IncidentPriority> order = [
      IncidentPriority.critical,
      IncidentPriority.high,
      IncidentPriority.medium,
      IncidentPriority.low,
    ];

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: (counts.values.fold<int>(0, (a, b) => a > b ? a : b) + 1).toDouble(),
        barTouchData: BarTouchData(enabled: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true, reservedSize: 28.w),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (double value, TitleMeta meta) {
                final int i = value.toInt();
                if (i < 0 || i >= order.length) return const SizedBox.shrink();
                return Padding(
                  padding: EdgeInsets.only(top: AppDimens.space8),
                  child: Text(
                    order[i].label.substring(0, 1),
                    style: TextStyle(
                      fontSize: AppDimens.font10,
                      color: AppColors.mutedForeground,
                    ),
                  ),
                );
              },
            ),
          ),
          topTitles: const AxisTitles(),
          rightTitles: const AxisTitles(),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (_) => FlLine(
            color: AppColors.border,
            strokeWidth: 1,
          ),
        ),
        borderData: FlBorderData(show: false),
        barGroups: List.generate(order.length, (int i) {
          final IncidentPriority p = order[i];
          return BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: (counts[p] ?? 0).toDouble(),
                color: p.color,
                width: 20.w,
                borderRadius: BorderRadius.vertical(top: Radius.circular(4.r)),
              ),
            ],
          );
        }),
      ),
    );
  }
}

class _CityPieChart extends StatelessWidget {
  const _CityPieChart({required this.counts});

  final Map<String, int> counts;

  static const List<Color> _colors = [
    AppColors.chart1,
    AppColors.chart2,
    AppColors.chart3,
    AppColors.chart4,
    AppColors.chart5,
  ];

  @override
  Widget build(BuildContext context) {
    final List<MapEntry<String, int>> entries = counts.entries.toList();

    return PieChart(
      PieChartData(
        sectionsSpace: 2,
        centerSpaceRadius: 40.r,
        sections: List.generate(entries.length, (int i) {
          final entry = entries[i];
          return PieChartSectionData(
            value: entry.value.toDouble(),
            title: '${entry.key}\n${entry.value}',
            color: _colors[i % _colors.length],
            radius: 50.r,
            titleStyle: TextStyle(
              fontSize: AppDimens.font10,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          );
        }),
      ),
    );
  }
}
