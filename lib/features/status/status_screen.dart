import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_hackathon_app/features/incidents/data/mock_incidents.dart';
import 'package:google_hackathon_app/theme/app_colors.dart';
import 'package:google_hackathon_app/theme/priority_styles.dart';

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

    final int totalPakistanDemo = 127; // static nationwide demo figure

    return Scaffold(
      appBar: AppBar(title: const Text('Status')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _StatCard(
            label: 'Incidents tracked (Pakistan — demo)',
            value: '$totalPakistanDemo',
            icon: Icons.public,
            color: AppColors.chart1,
          ),
          const SizedBox(height: 12),
          _StatCard(
            label: 'In this feed',
            value: '${mockIncidents.length}',
            icon: Icons.list_alt,
            color: AppColors.chart2,
          ),
          const SizedBox(height: 24),
          Text(
            'By priority (feed)',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 200,
            child: _PriorityBarChart(counts: byPriority),
          ),
          const SizedBox(height: 24),
          Text(
            'By city (feed)',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 200,
            child: _CityPieChart(counts: byCity),
          ),
          const SizedBox(height: 16),
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.secondary.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(AppColors.radius),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 16),
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
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 28)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (double value, TitleMeta meta) {
                final int i = value.toInt();
                if (i < 0 || i >= order.length) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    order[i].label.substring(0, 1),
                    style: const TextStyle(fontSize: 10, color: AppColors.mutedForeground),
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
                width: 20,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
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
        centerSpaceRadius: 40,
        sections: List.generate(entries.length, (int i) {
          final entry = entries[i];
          return PieChartSectionData(
            value: entry.value.toDouble(),
            title: '${entry.key}\n${entry.value}',
            color: _colors[i % _colors.length],
            radius: 50,
            titleStyle: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          );
        }),
      ),
    );
  }
}
