import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/trend_analysis.dart';

class TrendChartWidget extends StatelessWidget {
  final TrendAnalysis data;

  const TrendChartWidget({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.dataPoints.isEmpty) {
      return const Center(child: Text("No hay datos para mostrar"));
    }

    return AspectRatio(
      aspectRatio: 1.7,
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        color: Theme.of(context).colorScheme.surface,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Frecuencia Semanal',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Prom: ${data.averageFrequency.toStringAsFixed(1)} / día',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: (data.maxFrequency * 1.2).toDouble(), // Add some headroom
                    barTouchData: BarTouchData(
                      enabled: true,
                      touchTooltipData: BarTouchTooltipData(
                        tooltipBgColor: Theme.of(context).colorScheme.tertiary,
                        tooltipPadding: const EdgeInsets.all(8),
                        tooltipMargin: 8,
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          return BarTooltipItem(
                            rod.toY.round().toString(),
                            const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        },
                      ),
                    ),
                    titlesData: FlTitlesData(
                      show: true,
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 30,
                          getTitlesWidget: (value, meta) {
                            if (value.toInt() >= 0 && value.toInt() < data.dataPoints.length) {
                              final date = data.dataPoints[value.toInt()].date;
                              return Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  DateFormat('E').format(date), // M, T, W, T...
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              );
                            }
                            return const Text('');
                          },
                        ),
                      ),
                      leftTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                    gridData: const FlGridData(show: false),
                    borderData: FlBorderData(show: false),
                    extraLinesData: ExtraLinesData(
                      verticalLines: data.phaseChanges.map((change) {
                        // Find the closest index for this date
                        double x = -1;
                        for (int i = 0; i < data.dataPoints.length; i++) {
                          if (data.dataPoints[i].date.year == change.date.year &&
                              data.dataPoints[i].date.month == change.date.month &&
                              data.dataPoints[i].date.day == change.date.day) {
                            x = i.toDouble();
                            break;
                          }
                          // If it's between points, we could interpolate, but for bar chart, 
                          // matching the day is usually what's expected.
                        }
                        
                        // If no exact match found but it's within range, find the insertion point
                        if (x == -1 && data.dataPoints.isNotEmpty) {
                           if (change.date.isAfter(data.dataPoints.first.date) && 
                               change.date.isBefore(data.dataPoints.last.date)) {
                             for (int i = 0; i < data.dataPoints.length - 1; i++) {
                               if (change.date.isAfter(data.dataPoints[i].date) && 
                                   change.date.isBefore(data.dataPoints[i+1].date)) {
                                 x = i + 0.5;
                                 break;
                               }
                             }
                           }
                        }

                        return VerticalLine(
                          x: x,
                          color: change.newStatus == 'active' ? Colors.green : Colors.orange,
                          strokeWidth: 2,
                          dashArray: [5, 5],
                          label: VerticalLineLabel(
                            show: true,
                            alignment: Alignment.topRight,
                            style: TextStyle(
                              color: change.newStatus == 'active' ? Colors.green : Colors.orange,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                            labelResolver: (line) => change.newStatus.toUpperCase(),
                          ),
                        );
                      }).where((line) => line.x != -1).toList(),
                    ),
                    barGroups: data.dataPoints.asMap().entries.map((e) {
                      final index = e.key;
                      final point = e.value;
                      return BarChartGroupData(
                        x: index,
                        barRods: [
                          BarChartRodData(
                            toY: point.count.toDouble(),
                            color: Theme.of(context).colorScheme.primary, // Terracotta
                            width: 16,
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                            backDrawRodData: BackgroundBarChartRodData(
                              show: true,
                              toY: (data.maxFrequency * 1.2).toDouble(),
                              color: Theme.of(context).colorScheme.surfaceContainerHighest.withAlpha(50),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
