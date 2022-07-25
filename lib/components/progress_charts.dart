import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';

class ProgressChart extends StatelessWidget {
  final List words;
  final bool animate;

  const ProgressChart(this.words, {Key? key, required this.animate})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return charts.TimeSeriesChart(
      createChartData(words),
      animate: animate,
      dateTimeFactory: const charts.LocalDateTimeFactory(),
    );
  }

  static List<charts.Series<TimeSeriesWords, DateTime>> createChartData(
      List words) {
    final List rememberedWords =
        words.where((word) => word['remembered']).toList();
    final List dates = rememberedWords
        .map((word) => DateUtils.dateOnly(word['updatedAt']))
        .toSet()
        .toList();
    dates.sort();
    List<TimeSeriesWords> data = dates
        .map((date) => TimeSeriesWords(
            date,
            rememberedWords
                .where((word) => DateUtils.dateOnly(word['updatedAt']) == date)
                .length))
        .toList();
    for (int i = 1; i < data.length; i++) {
      data[i].number += data[i - 1].number;
    }

    return [
      charts.Series<TimeSeriesWords, DateTime>(
        id: 'Progress',
        colorFn: (_, __) => charts.MaterialPalette.green.shadeDefault,
        domainFn: (TimeSeriesWords words, _) => words.date,
        measureFn: (TimeSeriesWords words, _) => words.number,
        data: data,
      )
    ];
  }
}

class TimeSeriesWords {
  DateTime date;
  int number;

  TimeSeriesWords(this.date, this.number);
}
