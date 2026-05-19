import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:google_hackathon_app/theme/app_colors.dart';
import 'package:google_hackathon_app/theme/app_text_styles.dart';
import 'package:google_hackathon_app/theme/app_dimens.dart';

// ============================================================================
// ======================== DATA MODELS & ENUMS =============================
// ============================================================================

enum IncidentPriority { critical, high, medium, low, unknown }

extension IncidentPriorityX on IncidentPriority {
  String get label {
    switch (this) {
      case IncidentPriority.critical:
        return 'CRITICAL';
      case IncidentPriority.high:
        return 'HIGH';
      case IncidentPriority.medium:
        return 'MEDIUM';
      case IncidentPriority.low:
        return 'LOW';
      case IncidentPriority.unknown:
        return 'UNKNOWN';
    }
  }

  String get badgeLabel {
    switch (this) {
      case IncidentPriority.critical:
        return 'Critical';
      case IncidentPriority.high:
        return 'High Priority';
      case IncidentPriority.medium:
        return 'Medium';
      case IncidentPriority.low:
        return 'Low';
      case IncidentPriority.unknown:
        return 'Unknown';
    }
  }

  Color get color {
    switch (this) {
      case IncidentPriority.critical:
        return AppColors.priorityCritical;
      case IncidentPriority.high:
        return AppColors.priorityHigh;
      case IncidentPriority.medium:
        return AppColors.priorityMedium;
      case IncidentPriority.low:
        return AppColors.priorityLow;
      case IncidentPriority.unknown:
        return AppColors.mutedForeground;
    }
  }

  Color get borderColor {
    switch (this) {
      case IncidentPriority.critical:
        return AppColors.priorityCriticalBorder;
      case IncidentPriority.high:
        return AppColors.priorityHighBorder;
      case IncidentPriority.medium:
        return AppColors.priorityMediumBorder;
      case IncidentPriority.low:
        return AppColors.priorityLowBorder;
      case IncidentPriority.unknown:
        return AppColors.glassBorder;
    }
  }

  Color get backgroundColor => color.withValues(alpha: 0.12);

  static IncidentPriority fromString(String? value) {
    switch (value?.toUpperCase()) {
      case 'CRITICAL':
        return IncidentPriority.critical;
      case 'HIGH':
        return IncidentPriority.high;
      case 'MEDIUM':
        return IncidentPriority.medium;
      case 'LOW':
        return IncidentPriority.low;
      default:
        return IncidentPriority.unknown;
    }
  }
}

class IncidentRecord {
  final String id;
  final String city;
  final String title;
  final String description;
  final IncidentPriority priority;
  final DateTime dateTime;
  final int month;
  final int day;
  final int year;

  IncidentRecord({
    required this.id,
    required this.city,
    required this.title,
    required this.description,
    required this.priority,
    required this.dateTime,
    required this.month,
    required this.day,
    required this.year,
  });

  String get timeString =>
      '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  String get dateString =>
      '$day/${month.toString().padLeft(2, '0')}/$year';
  String get monthName {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }
}

// ============================================================================
// ======================== HARDCODED MOCK DATA ==============================
// ============================================================================

final List<IncidentRecord> mockIncidentsData = [
  // ===== JANUARY =====
  IncidentRecord(
    id: 'INC001',
    city: 'Lahore',
    title: 'Severe Traffic Congestion',
    description: 'Major traffic jam on GT Road during peak hours',
    priority: IncidentPriority.high,
    dateTime: DateTime(2024, 1, 5, 14, 30),
    month: 1,
    day: 5,
    year: 2024,
  ),
  IncidentRecord(
    id: 'INC002',
    city: 'Karachi',
    title: 'Flooding Alert',
    description: 'Flash flooding in low-lying areas',
    priority: IncidentPriority.critical,
    dateTime: DateTime(2024, 1, 8, 11, 15),
    month: 1,
    day: 8,
    year: 2024,
  ),
  IncidentRecord(
    id: 'INC003',
    city: 'Islamabad',
    title: 'Power Outage',
    description: 'Partial power outage in Sector F',
    priority: IncidentPriority.medium,
    dateTime: DateTime(2024, 1, 12, 9, 45),
    month: 1,
    day: 12,
    year: 2024,
  ),
  IncidentRecord(
    id: 'INC004',
    city: 'Lahore',
    title: 'Minor Road Damage',
    description: 'Pothole on Mall Road affecting traffic',
    priority: IncidentPriority.low,
    dateTime: DateTime(2024, 1, 15, 16, 20),
    month: 1,
    day: 15,
    year: 2024,
  ),
  IncidentRecord(
    id: 'INC005',
    city: 'Karachi',
    title: 'Gas Leak',
    description: 'Minor gas leak detected in residential area',
    priority: IncidentPriority.high,
    dateTime: DateTime(2024, 1, 18, 13, 0),
    month: 1,
    day: 18,
    year: 2024,
  ),
  IncidentRecord(
    id: 'INC006',
    city: 'Islamabad',
    title: 'Water Supply Disruption',
    description: 'Scheduled water supply maintenance',
    priority: IncidentPriority.medium,
    dateTime: DateTime(2024, 1, 22, 8, 30),
    month: 1,
    day: 22,
    year: 2024,
  ),
  IncidentRecord(
    id: 'INC007',
    city: 'Lahore',
    title: 'Air Quality Alert',
    description: 'AQI exceeds hazardous levels',
    priority: IncidentPriority.critical,
    dateTime: DateTime(2024, 1, 25, 10, 0),
    month: 1,
    day: 25,
    year: 2024,
  ),

  // ===== FEBRUARY =====
  IncidentRecord(
    id: 'INC008',
    city: 'Karachi',
    title: 'Sewage Overflow',
    description: 'Sewage line blockage causing overflow',
    priority: IncidentPriority.critical,
    dateTime: DateTime(2024, 2, 3, 15, 45),
    month: 2,
    day: 3,
    year: 2024,
  ),
  IncidentRecord(
    id: 'INC009',
    city: 'Islamabad',
    title: 'Road Closure',
    description: 'Construction work causing partial road closure',
    priority: IncidentPriority.medium,
    dateTime: DateTime(2024, 2, 7, 11, 20),
    month: 2,
    day: 7,
    year: 2024,
  ),
  IncidentRecord(
    id: 'INC010',
    city: 'Lahore',
    title: 'Fire Incident',
    description: 'Minor fire in commercial area',
    priority: IncidentPriority.high,
    dateTime: DateTime(2024, 2, 10, 18, 0),
    month: 2,
    day: 10,
    year: 2024,
  ),
  IncidentRecord(
    id: 'INC011',
    city: 'Lahore',
    title: 'Broken Traffic Light',
    description: 'Traffic signal malfunction at busy intersection',
    priority: IncidentPriority.low,
    dateTime: DateTime(2024, 2, 14, 9, 15),
    month: 2,
    day: 14,
    year: 2024,
  ),
  IncidentRecord(
    id: 'INC012',
    city: 'Karachi',
    title: 'Heavy Rain Warning',
    description: 'Meteorological department issues heavy rain alert',
    priority: IncidentPriority.high,
    dateTime: DateTime(2024, 2, 17, 12, 30),
    month: 2,
    day: 17,
    year: 2024,
  ),
  IncidentRecord(
    id: 'INC013',
    city: 'Islamabad',
    title: 'Bridge Maintenance',
    description: 'Structural assessment and repair work',
    priority: IncidentPriority.low,
    dateTime: DateTime(2024, 2, 21, 10, 45),
    month: 2,
    day: 21,
    year: 2024,
  ),
  IncidentRecord(
    id: 'INC014',
    city: 'Lahore',
    title: 'Public Transport Strike',
    description: 'Bus operators strike affecting city transport',
    priority: IncidentPriority.high,
    dateTime: DateTime(2024, 2, 24, 7, 0),
    month: 2,
    day: 24,
    year: 2024,
  ),
  IncidentRecord(
    id: 'INC015',
    city: 'Karachi',
    title: 'Port Operations Disrupted',
    description: 'High winds affecting port operations',
    priority: IncidentPriority.medium,
    dateTime: DateTime(2024, 2, 28, 14, 0),
    month: 2,
    day: 28,
    year: 2024,
  ),

  // ===== MARCH =====
  IncidentRecord(
    id: 'INC016',
    city: 'Islamabad',
    title: 'Heat Wave Alert',
    description: 'Extreme temperature warning issued',
    priority: IncidentPriority.critical,
    dateTime: DateTime(2024, 3, 2, 14, 0),
    month: 3,
    day: 2,
    year: 2024,
  ),
  IncidentRecord(
    id: 'INC017',
    city: 'Lahore',
    title: 'School Closure',
    description: 'Schools closed due to poor air quality',
    priority: IncidentPriority.high,
    dateTime: DateTime(2024, 3, 9, 8, 0),
    month: 3,
    day: 9,
    year: 2024,
  ),
  IncidentRecord(
    id: 'INC018',
    city: 'Lahore',
    title: 'Pipeline Rupture',
    description: 'Water pipeline burst in DHA',
    priority: IncidentPriority.critical,
    dateTime: DateTime(2024, 3, 13, 16, 15),
    month: 3,
    day: 13,
    year: 2024,
  ),
  IncidentRecord(
    id: 'INC019',
    city: 'Karachi',
    title: 'Market Disruption',
    description: 'Security alert at fish market',
    priority: IncidentPriority.low,
    dateTime: DateTime(2024, 3, 17, 11, 0),
    month: 3,
    day: 17,
    year: 2024,
  ),
  IncidentRecord(
    id: 'INC020',
    city: 'Islamabad',
    title: 'IT System Outage',
    description: 'Government IT infrastructure outage',
    priority: IncidentPriority.high,
    dateTime: DateTime(2024, 3, 21, 9, 30),
    month: 3,
    day: 21,
    year: 2024,
  ),
  IncidentRecord(
    id: 'INC021',
    city: 'Lahore',
    title: 'Noise Pollution',
    description: 'Construction noise exceeding limits',
    priority: IncidentPriority.low,
    dateTime: DateTime(2024, 3, 25, 17, 45),
    month: 3,
    day: 25,
    year: 2024,
  ),
  IncidentRecord(
    id: 'INC022',
    city: 'Karachi',
    title: 'Disease Alert',
    description: 'Health department alerts on disease outbreak',
    priority: IncidentPriority.critical,
    dateTime: DateTime(2024, 3, 28, 10, 20),
    month: 3,
    day: 28,
    year: 2024,
  ),
  IncidentRecord(
    id: 'INC023',
    city: 'Islamabad',
    title: 'Flooding in Streets',
    description: 'Heavy rain causes street flooding',
    priority: IncidentPriority.medium,
    dateTime: DateTime(2024, 3, 31, 13, 0),
    month: 3,
    day: 31,
    year: 2024,
  ),

  // ===== APRIL =====
  IncidentRecord(
    id: 'INC024',
    city: 'Islamabad',
    title: 'Heatwave Extension',
    description: 'Continued extreme heat warning',
    priority: IncidentPriority.high,
    dateTime: DateTime(2024, 4, 1, 15, 0),
    month: 4,
    day: 1,
    year: 2024,
  ),
  IncidentRecord(
    id: 'INC025',
    city: 'Lahore',
    title: 'Power Supply Crisis',
    description: 'Rolling blackouts across the city',
    priority: IncidentPriority.critical,
    dateTime: DateTime(2024, 4, 5, 12, 0),
    month: 4,
    day: 5,
    year: 2024,
  ),
  IncidentRecord(
    id: 'INC026',
    city: 'Karachi',
    title: 'Water Shortage',
    description: 'Severe water shortage in residential areas',
    priority: IncidentPriority.critical,
    dateTime: DateTime(2024, 4, 8, 8, 45),
    month: 4,
    day: 8,
    year: 2024,
  ),
  IncidentRecord(
    id: 'INC027',
    city: 'Lahore',
    title: 'Road Accident',
    description: 'Major accident on M2 motorway',
    priority: IncidentPriority.high,
    dateTime: DateTime(2024, 4, 12, 14, 30),
    month: 4,
    day: 12,
    year: 2024,
  ),
  IncidentRecord(
    id: 'INC028',
    city: 'Islamabad',
    title: 'Park Closure',
    description: 'Public parks closed for maintenance',
    priority: IncidentPriority.low,
    dateTime: DateTime(2024, 4, 16, 10, 0),
    month: 4,
    day: 16,
    year: 2024,
  ),
  IncidentRecord(
    id: 'INC029',
    city: 'Karachi',
    title: 'Air Pollution Spike',
    description: 'Air quality deteriorates due to industrial emissions',
    priority: IncidentPriority.high,
    dateTime: DateTime(2024, 4, 20, 13, 15),
    month: 4,
    day: 20,
    year: 2024,
  ),
  IncidentRecord(
    id: 'INC030',
    city: 'Lahore',
    title: 'Hospital Congestion',
    description: 'Emergency ward overflow due to heat-related illnesses',
    priority: IncidentPriority.high,
    dateTime: DateTime(2024, 4, 24, 11, 30),
    month: 4,
    day: 24,
    year: 2024,
  ),
];

// ============================================================================
// ======================== DATA AGGREGATION HELPER ==========================
// ============================================================================

class IncidentDataAggregator {
  static Map<String, int> getIncidentsByCity(List<IncidentRecord> records) {
    final Map<String, int> counts = {};
    for (final record in records) {
      counts[record.city] = (counts[record.city] ?? 0) + 1;
    }
    return counts;
  }

  static Map<IncidentPriority, int> getIncidentsByPriorityForMonth(
      List<IncidentRecord> records,
      int month,
      ) {
    final Map<IncidentPriority, int> counts = {};
    for (final record in records.where((r) => r.month == month)) {
      counts[record.priority] = (counts[record.priority] ?? 0) + 1;
    }
    return counts;
  }

  static Map<String, Map<int, int>> getIncidentsByMonthAndCity(
      List<IncidentRecord> records,
      ) {
    final Map<String, Map<int, int>> data = {};
    for (final record in records) {
      if (!data.containsKey(record.city)) {
        data[record.city] = {};
      }
      data[record.city]![record.month] =
          (data[record.city]![record.month] ?? 0) + 1;
    }
    return data;
  }

  static Map<int, Map<IncidentPriority, int>> getIncidentsByMonthAndPriority(
      List<IncidentRecord> records,
      ) {
    final Map<int, Map<IncidentPriority, int>> data = {};
    for (final record in records) {
      if (!data.containsKey(record.month)) {
        data[record.month] = {};
      }
      data[record.month]![record.priority] =
          (data[record.month]![record.priority] ?? 0) + 1;
    }
    return data;
  }
}

// ============================================================================
// ======================== CHART DATA MODELS ================================
// ============================================================================

class _AreaChartData {
  final String month;
  final double lahore;
  final double karachi;
  final double islamabad;

  _AreaChartData({
    required this.month,
    required this.lahore,
    required this.karachi,
    required this.islamabad,
  });
}

class _BarChartData {
  final String month;
  final double critical;
  final double high;
  final double medium;
  final double low;

  _BarChartData({
    required this.month,
    required this.critical,
    required this.high,
    required this.medium,
    required this.low,
  });
}

class _DoughnutChartData {
  final String city;
  final int count;
  final Color color;

  _DoughnutChartData({
    required this.city,
    required this.count,
    required this.color,
  });
}

// ============================================================================
// ======================== LEGEND ITEM WIDGET ===============================
// ============================================================================

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        SizedBox(width: 6),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// ======================== STACKED AREA CHART ===============================
// ============================================================================

class CityWiseStackedAreaChart extends StatelessWidget {
  final List<IncidentRecord> incidents;

  const CityWiseStackedAreaChart({
    Key? key,
    required this.incidents,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final chartData = _prepareAreaChartData();

    return Container(
      padding: EdgeInsets.all(AppDimens.space16),
      decoration: BoxDecoration(
        color: AppColors.glassPanel,
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Incidents by City (Monthly Trend)',
            style: AppTextStyles.sectionTitle,
          ),
          SizedBox(height: AppDimens.space8),
          // City Legend
          Wrap(
            spacing: AppDimens.space16,
            runSpacing: AppDimens.space8,
            children: [
              _LegendItem(
                color: AppColors.chart1,
                label: 'Lahore',
              ),
              _LegendItem(
                color: AppColors.chart5,
                label: 'Karachi',
              ),
              _LegendItem(
                color: AppColors.chart2,
                label: 'Islamabad',
              ),
            ],
          ),
          SizedBox(height: AppDimens.space12),
          SizedBox(
            height: 300,
            child: SfCartesianChart(
              plotAreaBorderColor: Colors.transparent,
              tooltipBehavior: TooltipBehavior(enable: true),
              legend: Legend(
                isVisible: false,
              ),
              primaryXAxis: CategoryAxis(
                labelStyle: AppTextStyles.chartAxis,
                majorGridLines: const MajorGridLines(width: 0),
                axisLine: const AxisLine(color: AppColors.glassBorder),
                labelAlignment: LabelAlignment.start,
              ),
              primaryYAxis: NumericAxis(
                labelStyle: AppTextStyles.chartAxis,
                majorTickLines: const MajorTickLines(size: 0),
                axisLine: const AxisLine(color: AppColors.glassBorder),
                majorGridLines: const MajorGridLines(
                  color: AppColors.border,
                  dashArray: <double>[5, 5],
                ),
              ),
              series: <CartesianSeries>[
                StackedAreaSeries<_AreaChartData, String>(
                  dataSource: chartData,
                  xValueMapper: (_AreaChartData data, _) => data.month,
                  yValueMapper: (_AreaChartData data, _) => data.lahore,
                  name: 'Lahore',
                  color: AppColors.chart1,
                  opacity: 0.8,
                ),
                StackedAreaSeries<_AreaChartData, String>(
                  dataSource: chartData,
                  xValueMapper: (_AreaChartData data, _) => data.month,
                  yValueMapper: (_AreaChartData data, _) => data.karachi,
                  name: 'Karachi',
                  color: AppColors.chart5,
                  opacity: 0.8,
                ),
                StackedAreaSeries<_AreaChartData, String>(
                  dataSource: chartData,
                  xValueMapper: (_AreaChartData data, _) => data.month,
                  yValueMapper: (_AreaChartData data, _) => data.islamabad,
                  name: 'Islamabad',
                  color: AppColors.chart2,
                  opacity: 0.8,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<_AreaChartData> _prepareAreaChartData() {
    final byMonthAndCity =
    IncidentDataAggregator.getIncidentsByMonthAndCity(incidents);
    final List<_AreaChartData> data = [];

    const months = ['Jan', 'Feb', 'Mar', 'Apr'];

    for (int i = 1; i <= 4; i++) {
      data.add(
        _AreaChartData(
          month: months[i - 1],
          lahore: (byMonthAndCity['Lahore']?[i] ?? 0).toDouble(),
          karachi: (byMonthAndCity['Karachi']?[i] ?? 0).toDouble(),
          islamabad: (byMonthAndCity['Islamabad']?[i] ?? 0).toDouble(),
        ),
      );
    }

    return data;
  }
}

// ============================================================================
// ======================== 100% STACKED BAR CHART ===========================
// ============================================================================

class PriorityStackedBarChart extends StatelessWidget {
  final List<IncidentRecord> incidents;

  const PriorityStackedBarChart({
    Key? key,
    required this.incidents,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final chartData = _prepareBarChartData();

    return Container(
      padding: EdgeInsets.all(AppDimens.space16),
      decoration: BoxDecoration(
        color: AppColors.glassPanel,
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Priority Distribution by Month (100% Stacked)',
            style: AppTextStyles.sectionTitle,
          ),
          SizedBox(height: AppDimens.space12),
          SizedBox(
            height: 280,
            child: SfCartesianChart(
              plotAreaBorderColor: Colors.transparent,
              tooltipBehavior: TooltipBehavior(enable: true),
              primaryXAxis: CategoryAxis(
                labelStyle: AppTextStyles.chartAxis,
                majorGridLines: const MajorGridLines(width: 0),
                axisLine: const AxisLine(color: AppColors.glassBorder),
              ),
              primaryYAxis: NumericAxis(
                labelStyle: AppTextStyles.chartAxis,
                majorTickLines: const MajorTickLines(size: 0),
                axisLine: const AxisLine(color: AppColors.glassBorder),
                majorGridLines: const MajorGridLines(
                  color: AppColors.border,
                  dashArray: <double>[5, 5],
                ),
                title: AxisTitle(text: '%', textStyle: AppTextStyles.chartAxis),
              ),
              series: <CartesianSeries>[
                StackedBar100Series<_BarChartData, String>(
                  dataSource: chartData,
                  xValueMapper: (_BarChartData data, _) => data.month,
                  yValueMapper: (_BarChartData data, _) => data.critical,
                  name: 'Critical',
                  color: IncidentPriority.critical.color,
                ),
                StackedBar100Series<_BarChartData, String>(
                  dataSource: chartData,
                  xValueMapper: (_BarChartData data, _) => data.month,
                  yValueMapper: (_BarChartData data, _) => data.high,
                  name: 'High',
                  color: IncidentPriority.high.color,
                ),
                StackedBar100Series<_BarChartData, String>(
                  dataSource: chartData,
                  xValueMapper: (_BarChartData data, _) => data.month,
                  yValueMapper: (_BarChartData data, _) => data.medium,
                  name: 'Medium',
                  color: IncidentPriority.medium.color,
                ),
                StackedBar100Series<_BarChartData, String>(
                  dataSource: chartData,
                  xValueMapper: (_BarChartData data, _) => data.month,
                  yValueMapper: (_BarChartData data, _) => data.low,
                  name: 'Low',
                  color: IncidentPriority.low.color,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<_BarChartData> _prepareBarChartData() {
    final byMonthAndPriority =
    IncidentDataAggregator.getIncidentsByMonthAndPriority(incidents);
    final List<_BarChartData> data = [];

    const months = ['January', 'February', 'March', 'April'];

    for (int i = 1; i <= 4; i++) {
      final priorityData = byMonthAndPriority[i] ?? {};
      data.add(
        _BarChartData(
          month: months[i - 1],
          critical: (priorityData[IncidentPriority.critical] ?? 0).toDouble(),
          high: (priorityData[IncidentPriority.high] ?? 0).toDouble(),
          medium: (priorityData[IncidentPriority.medium] ?? 0).toDouble(),
          low: (priorityData[IncidentPriority.low] ?? 0).toDouble(),
        ),
      );
    }

    return data;
  }
}

// ============================================================================
// ======================== DOUGHNUT CHART ===================================
// ============================================================================

class CityDistributionDoughnutChart extends StatelessWidget {
  final List<IncidentRecord> incidents;

  const CityDistributionDoughnutChart({
    Key? key,
    required this.incidents,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final chartData = _prepareDoughnutChartData();
    final total = chartData.fold<int>(0, (sum, item) => sum + item.count);

    return Container(
      padding: EdgeInsets.all(AppDimens.space16),
      decoration: BoxDecoration(
        color: AppColors.glassPanel,
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Incident Distribution by City',
            style: AppTextStyles.sectionTitle,
          ),
          SizedBox(height: AppDimens.space12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: SizedBox(
                  height: 280,
                  child: SfCircularChart(
                    tooltipBehavior: TooltipBehavior(enable: true),
                    series: <CircularSeries>[
                      DoughnutSeries<_DoughnutChartData, String>(
                        dataSource: chartData,
                        xValueMapper: (_DoughnutChartData data, _) => data.city,
                        yValueMapper: (_DoughnutChartData data, _) => data.count,
                        name: 'Incidents',
                        innerRadius: '60%',
                        dataLabelMapper: (_DoughnutChartData data, _) => data.city,
                        dataLabelSettings: DataLabelSettings(
                          isVisible: true,
                          labelPosition: ChartDataLabelPosition.outside,
                          textStyle: AppTextStyles.chartAxis.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                        pointColorMapper: (_DoughnutChartData data, _) => data.color,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: AppDimens.space16),
              Expanded(
                flex: 1,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: chartData.map((item) {
                    final percentage =
                    (item.count / total * 100).toStringAsFixed(1);
                    return Padding(
                      padding: EdgeInsets.only(bottom: AppDimens.space12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: item.color,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              SizedBox(width: AppDimens.space8),
                              Text(
                                item.city,
                                style: AppTextStyles.metricLabel.copyWith(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 18),
                            child: Text(
                              '${item.count} incidents ($percentage%)',
                              style: AppTextStyles.caption.copyWith(
                                fontSize: 10.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<_DoughnutChartData> _prepareDoughnutChartData() {
    final cityCounts = IncidentDataAggregator.getIncidentsByCity(incidents);
    final List<_DoughnutChartData> data = [];

    final colorMap = {
      'Lahore': AppColors.chart1,
      'Karachi': AppColors.chart5,
      'Islamabad': AppColors.chart2,
    };

    cityCounts.forEach((city, count) {
      data.add(
        _DoughnutChartData(
          city: city,
          count: count,
          color: colorMap[city] ?? AppColors.chart3,
        ),
      );
    });

    return data;
  }
}

// ============================================================================
// ======================== PRIORITY BREAKDOWN ROW ============================
// ============================================================================

class _PriorityBreakdownRow extends StatelessWidget {
  final List<IncidentRecord> incidents;

  const _PriorityBreakdownRow({required this.incidents});

  @override
  Widget build(BuildContext context) {
    final priorityCounts = <IncidentPriority, int>{};
    for (final incident in incidents) {
      priorityCounts[incident.priority] =
          (priorityCounts[incident.priority] ?? 0) + 1;
    }

    final priorities = [
      IncidentPriority.critical,
      IncidentPriority.high,
      IncidentPriority.medium,
      IncidentPriority.low,
    ];

    return Container(
      padding: EdgeInsets.all(AppDimens.space16),
      decoration: BoxDecoration(
        color: AppColors.glassPanel,
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Priority Breakdown',
            style: AppTextStyles.sectionTitle,
          ),
          SizedBox(height: AppDimens.space12),
          ...priorities.map((priority) {
            final count = priorityCounts[priority] ?? 0;
            final percentage = count > 0
                ? (count / incidents.length * 100).toStringAsFixed(1)
                : '0.0';

            return Padding(
              padding: EdgeInsets.only(bottom: AppDimens.space8),
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: priority.color,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  SizedBox(width: AppDimens.space8),
                  Expanded(
                    child: Text(
                      priority.label,
                      style: AppTextStyles.metricLabel,
                    ),
                  ),
                  Text(
                    '$count ($percentage%)',
                    style: AppTextStyles.metricValue,
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ============================================================================
// ======================== STAT CARD WIDGET ==================================
// ============================================================================

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
      padding: EdgeInsets.all(AppDimens.space12),
      decoration: BoxDecoration(
        color: AppColors.glassPanel,
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(AppDimens.space8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(AppDimens.radiusSm),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          SizedBox(height: AppDimens.space8),
          Text(
            label,
            style: AppTextStyles.statLabel,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            value,
            style: AppTextStyles.statValue.copyWith(fontSize: 18),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// ======================== STATUS SCREEN MAIN ===============================
// ============================================================================

class StatusScreen extends StatelessWidget {
  const StatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final incidents = mockIncidentsData;

    final cityCounts = IncidentDataAggregator.getIncidentsByCity(incidents);
    final totalIncidents = incidents.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Status & Analytics'),
        elevation: 0,
        backgroundColor: AppColors.surface,
      ),
      body: ListView(
        padding: EdgeInsets.all(AppDimens.space16),
        children: [
          // ==== KEY METRICS ROW 1 ====
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  label: 'Total Incidents',
                  value: '$totalIncidents',
                  icon: Icons.warning_amber,
                  color: AppColors.chart1,
                ),
              ),
              SizedBox(width: AppDimens.space12),
              Expanded(
                child: _StatCard(
                  label: 'Cities Monitored',
                  value: '${cityCounts.length}',
                  icon: Icons.location_city,
                  color: AppColors.chart2,
                ),
              ),
            ],
          ),
          SizedBox(height: AppDimens.space12),

          // ==== KEY METRICS ROW 2 (City breakdown) ====
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  label: 'Lahore',
                  value: '${cityCounts['Lahore'] ?? 0}',
                  icon: Icons.public,
                  color: AppColors.chart1,
                ),
              ),
              SizedBox(width: AppDimens.space12),
              Expanded(
                child: _StatCard(
                  label: 'Karachi',
                  value: '${cityCounts['Karachi'] ?? 0}',
                  icon: Icons.public,
                  color: AppColors.chart5,
                ),
              ),
              SizedBox(width: AppDimens.space12),
              Expanded(
                child: _StatCard(
                  label: 'Islamabad',
                  value: '${cityCounts['Islamabad'] ?? 0}',
                  icon: Icons.public,
                  color: AppColors.chart2,
                ),
              ),
            ],
          ),

          SizedBox(height: AppDimens.space24),

          // ==== PRIORITY BREAKDOWN ====
          _PriorityBreakdownRow(incidents: incidents),

          SizedBox(height: AppDimens.space24),

          // ==== CHARTS ====
          CityWiseStackedAreaChart(incidents: incidents),
          SizedBox(height: AppDimens.space16),

          PriorityStackedBarChart(incidents: incidents),
          SizedBox(height: AppDimens.space16),

          CityDistributionDoughnutChart(incidents: incidents),

          SizedBox(height: AppDimens.space16),
        ],
      ),
    );
  }
}