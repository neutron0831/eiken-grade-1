import 'package:charts_flutter/flutter.dart' as charts;
import 'package:eiken_grade_1/model/user.dart';
import 'package:eiken_grade_1/model/word.dart';
import 'package:eiken_grade_1/providers/words_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProgressChart extends ConsumerWidget {
  const ProgressChart({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider).user;
    final words = ref.watch(wordsProvider);
    return words.when(
        loading: () => const CircularProgressIndicator(),
        error: (err, stack) => Text('Error: $err'),
        data: (words) {
          return charts.TimeSeriesChart(
            createChartData(user, words),
            defaultRenderer:
                charts.LineRendererConfig(includeArea: true, stacked: true),
            animate: false,
            primaryMeasureAxis: charts.NumericAxisSpec(
                viewport: charts.NumericExtents(0, words.length),
                tickProviderSpec: charts.BasicNumericTickProviderSpec(
                    desiredTickCount: (words.length / 400 + 1).toInt())),
            dateTimeFactory: const charts.LocalDateTimeFactory(),
            behaviors: [
              charts.SeriesLegend(
                desiredMaxColumns: 2,
                cellPadding: const EdgeInsets.all(0),
              )
            ],
          );
        });
  }

  static List<charts.Series<TimeSeriesWords, DateTime>> createChartData(
      User user, List<Word> words) {
    final List dates = user.words
        .map((word) => DateUtils.dateOnly(word['updatedAt']))
        .toSet()
        .toList();
    dates.sort();
    final rememberedWords = dates
        .map((date) => TimeSeriesWords(
            date,
            user.words
                .where((word) => word['remembered'])
                .where((word) => DateUtils.dateOnly(word['updatedAt']) == date)
                .length))
        .toList();
    final forgotWords = dates
        .map((date) => TimeSeriesWords(
            date,
            user.words
                .where((word) => !word['remembered'])
                .where((word) => DateUtils.dateOnly(word['updatedAt']) == date)
                .length))
        .toList();
    final List<TimeSeriesWords> notRememberedWords = [
      TimeSeriesWords(rememberedWords[0].date,
          words.length - rememberedWords[0].number - forgotWords[0].number)
    ];
    for (int i = 1; i < dates.length; i++) {
      rememberedWords[i].number += rememberedWords[i - 1].number;
      forgotWords[i].number += forgotWords[i - 1].number;
      notRememberedWords.add(TimeSeriesWords(rememberedWords[i].date,
          words.length - rememberedWords[i].number - forgotWords[i].number));
    }

    return [forgotWords, rememberedWords, notRememberedWords]
        .asMap()
        .entries
        .map((state) {
      final index = state.key;
      final value = state.value;
      return charts.Series<TimeSeriesWords, DateTime>(
        id: index == 0
            ? 'Forgot'
            : index == 1
                ? 'Remembered'
                : 'Not remembered',
        data: value,
        domainFn: (TimeSeriesWords words, _) => words.date,
        measureFn: (TimeSeriesWords words, _) => words.number,
        colorFn: (_, __) => index == 0
            ? charts.MaterialPalette.red.shadeDefault
            : index == 1
                ? charts.MaterialPalette.green.shadeDefault
                : charts.MaterialPalette.gray.shadeDefault,
      );
    }).toList();
  }
}

class TimeSeriesWords {
  DateTime date;
  int number;

  TimeSeriesWords(this.date, this.number);
}
