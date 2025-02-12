import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'individual_bar.dart';

class MyBarGraph extends StatefulWidget {
  final List<double> monthlySummary; // Example: [25, 500, 100]
  final int startMonth; // 0 = JAN, 1 = FEB

  const MyBarGraph({
    super.key,
    required this.monthlySummary,
    required this.startMonth,
  });

  @override
  State<MyBarGraph> createState() => _MyBarGraphState();
}

class _MyBarGraphState extends State<MyBarGraph> {
  // List to hold bar data
  List<IndividualBar> barData = [];
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => scrollToEnd());
    initializeBarData();
  }

  // Initialize bar data
  void initializeBarData() {
    int currentMonthIndex = DateTime.now().month - 1; // 0-based index for months
    int totalMonths = (DateTime.now().year - 2024) * 12 + (currentMonthIndex - widget.startMonth + 1);
    totalMonths = totalMonths < 12 ? 12 : totalMonths; // Ensure at least 12 months are shown

    barData = List.generate(
      totalMonths,
      (index) {
        double yValue = 0;
        if (index < widget.monthlySummary.length) {
          yValue = widget.monthlySummary[index]; // Use existing data
        }
        return IndividualBar(
          x: index,
          y: yValue,
        );
      },
    );
  }

  // Calculate maximum Y value for the graph
  double calculateMax() {
    //initially 500,but adjust if spending more than that
    double max = 500;
    if (widget.monthlySummary.isNotEmpty) {
      double maxData = widget.monthlySummary.reduce((a, b) => a > b ? a : b);
      max = maxData * 1.05; // Slightly increase the limit
    }
    return max < 500 ? 500 : max;
  }

  // Scroll to the end of the graph
  void scrollToEnd() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(seconds: 1),
      curve: Curves.fastOutSlowIn,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Bar dimensions
    double barWidth = 20;
    double spaceBetweenBars = 15;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      controller: _scrollController,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25.0),
        child: SizedBox(
          width: barWidth * barData.length + spaceBetweenBars * (barData.length - 1),
          child: BarChart(
            BarChartData(
              minY: 0,
              maxY: calculateMax(),
              gridData: const FlGridData(show: false),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                show: true,
                topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: getBottomTitles,
                  ),
                ),
              ),
              barGroups: barData
                  .map(
                    (data) => BarChartGroupData(
                      x: data.x,
                      barRods: [
                        BarChartRodData(
                          toY: data.y,
                          width: barWidth,
                          borderRadius: BorderRadius.circular(4),
                          color: Colors.grey.shade800,
                          backDrawRodData: BackgroundBarChartRodData(
                            show: true,
                            toY: calculateMax(),
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  )
                  .toList(),
              alignment: BarChartAlignment.center,
              groupsSpace: spaceBetweenBars,
            ),
          ),
        ),
      ),
    );
  }
}

// Bottom titles widget
Widget getBottomTitles(double value, TitleMeta meta) {
  const textStyle = TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 14);
  String text;
  switch (value.toInt() % 12) {
    case 0:
      text = 'J'; // January
      break;
    case 1:
      text = 'F'; // February
      break;
    case 2:
      text = 'M'; // March
      break;
    case 3:
      text = 'A'; // April
      break;
    case 4:
      text = 'M'; // May
      break;
    case 5:
      text = 'J'; // June
      break;
    case 6:
      text = 'J'; // July
      break;
    case 7:
      text = 'A'; // August
      break;
    case 8:
      text = 'S'; // September
      break;
    case 9:
      text = 'O'; // October
      break;
    case 10:
      text = 'N'; // November
      break;
    case 11:
      text = 'D'; // December
      break;
    default:
      text = ''; // Default
  }

  return SideTitleWidget(
    meta: meta,
    child: Text(
      text,
      style: textStyle,
    ),
  );
}
