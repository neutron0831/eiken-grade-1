import 'package:eiken_grade_1/model/configuration.dart';
import 'package:eiken_grade_1/model/user.dart';
import 'package:eiken_grade_1/model/word.dart';
import 'package:eiken_grade_1/providers/words_provider.dart';
import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StackedFillColorBarChart extends ConsumerWidget {
  const StackedFillColorBarChart({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider).user;
    final words = ref.watch(wordsProvider);
    final config = ref.watch(configurationProvider).configuration;
    return words.when(
        loading: () => const CircularProgressIndicator(),
        error: (err, stack) => Text('Error: $err'),
        data: (words) {
          return charts.BarChart(
            createChartData(user, words, config),
            animate: false,
            primaryMeasureAxis: charts.NumericAxisSpec(
                viewport:
                    charts.NumericExtents(0, user.wordsNum(words, 'A', 'All')),
                tickProviderSpec: charts.BasicNumericTickProviderSpec(
                    desiredTickCount:
                        (user.wordsNum(words, 'A', 'All') / 100 + 1).toInt())),
            vertical: false,
            defaultRenderer: charts.BarRendererConfig(
                groupingType: charts.BarGroupingType.stacked,
                maxBarWidthPx: 14,
                strokeWidthPx: 1.0),
          );
        });
  }

  List<charts.Series<NumberOfWords, String>> createChartData(
      User user, List<Word> words, Configuration config) {
    final levels = config.levels!;
    final rememberedWords = levels
        .map((level) =>
            NumberOfWords(level, user.wordsNum(words, level, 'Remembered')))
        .toList();
    final forgotWords = levels
        .map((level) =>
            NumberOfWords(level, user.wordsNum(words, level, 'Forgot')))
        .toList();
    final notRememberedWords = levels
        .map((level) =>
            NumberOfWords(level, user.wordsNum(words, level, 'Not remembered')))
        .toList();
    return [rememberedWords, forgotWords, notRememberedWords]
        .asMap()
        .entries
        .map((state) {
      final index = state.key;
      final value = state.value;
      return charts.Series<NumberOfWords, String>(
          id: config.levels![index],
          data: value,
          domainFn: (NumberOfWords words, _) => words.state,
          measureFn: (NumberOfWords words, _) => words.number,
          colorFn: (_, __) => index == 0
              ? charts.MaterialPalette.green.shadeDefault
              : index == 1
                  ? charts.MaterialPalette.red.shadeDefault
                  : charts.MaterialPalette.gray.shade300);
    }).toList();
  }
}

class NumberOfWords {
  final String state;
  final int number;

  NumberOfWords(this.state, this.number);
}
