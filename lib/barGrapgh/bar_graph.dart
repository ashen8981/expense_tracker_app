import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'individual_bar.dart';

class MyBarGraph extends StatefulWidget {
  final List<double> monthlySummary; //[25, 500, 100]
  final int startMonth; //0 JAN, 1 FEB

  const MyBarGraph({
    super.key,
    required this.monthlySummary,
    required this.startMonth,
  });

  @override
  State<MyBarGraph> createState() => _MyBarGraphState();
}

class _MyBarGraphState extends State<MyBarGraph> {
  // This list will hold the data for each bar
  List<IndividualBar> barData = [];

  @override
  void initState() {
    super.initState();
    //we need to scroll latest month automatically
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) => scrollToEnd());
  }

  // Initialize bar data
  void initializeBarData() {
    barData = List.generate(
      widget.monthlySummary.length,
      (index) => IndividualBar(
        x: index,
        y: widget.monthlySummary[index],
      ),
    );
  }

  //calculate max for upper limit of graph
  double calculateMax() {
    //initially 500,but adjust if spending more than that
    double max = 500;

    //get the month with the highest amount
    widget.monthlySummary.sort();

    //increase the upper limit by a bit
    max = widget.monthlySummary.last * 1.05;

    if (max < 500) {
      return max;
    }

    return max;
  }

  //scroll controller to make sure it scrolls to the end/ last month
  final ScrollController _scrollController = ScrollController();
  void scrollToEnd() {
    _scrollController.animateTo(_scrollController.position.maxScrollExtent,
        duration: const Duration(seconds: 1), curve: Curves.fastOutSlowIn);
  }

  @override
  Widget build(BuildContext context) {
    //initialize upon build
    initializeBarData();

    //bar dimension sizes
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
                              backDrawRodData:
                                  BackgroundBarChartRodData(show: true, toY: calculateMax(), color: Colors.white)),
                        ],
                      ),
                    )
                    .toList(),
                alignment: BarChartAlignment.center,
                groupsSpace: spaceBetweenBars),
          ),
        ),
      ),
    );
  }
}

//bottom titles
Widget getBottomTitles(double value, TitleMeta meta) {
  const textstyle = TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 14);
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
      text = ''; // Default case if no match is found
  }

  return SideTitleWidget(
      meta: meta,
      child: Text(
        text,
        style: textstyle,
      ));
}
