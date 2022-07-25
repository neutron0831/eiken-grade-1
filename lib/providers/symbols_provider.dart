import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final symbolsProvider = FutureProvider<Map<String, String>>((ref) async {
  var symbols = json.decode(await rootBundle.loadString('assets/symbols.json'));
  final ipaSymbols =
      List<String>.from(symbols.map((symbol) => symbol['ipa_symbol']));
  final obsSymbols =
      List<String>.from(symbols.map((symbol) => symbol['obs_symbol']));
  symbols = Map.fromIterables(obsSymbols, ipaSymbols);
  return symbols;
});
