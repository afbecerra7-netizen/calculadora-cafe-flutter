import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/coffee_calculator.dart';

class CalculatorController extends ChangeNotifier {
  static const _prefsKey = 'coffee_calc_prefs_v1';

  BrewMethod method = BrewMethod.aeropress;
  int cups = 1;
  double strength = 1.0;
  WaterUnit unit = WaterUnit.ml;
  late Map<BrewMethod, double> baseRatio;

  bool isLoading = true;

  CalculatorController() {
    baseRatio = {...CoffeeCalculator.defaultBaseRatio};
  }

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);

    if (raw != null) {
      try {
        final map = jsonDecode(raw) as Map<String, dynamic>;
        method = CoffeeCalculator.methodFromKey(
            map['method'] as String? ?? 'aeropress');
        cups = (map['cups'] as num?)?.toInt() ?? 1;
        strength = (map['strength'] as num?)?.toDouble() ?? 1.0;
        unit = (map['unit'] == 'oz') ? WaterUnit.oz : WaterUnit.ml;

        final ratios = map['baseRatio'] as Map<String, dynamic>?;
        if (ratios != null) {
          for (final m in BrewMethod.values) {
            final v = (ratios[m.name] as num?)?.toDouble();
            if (v != null) {
              baseRatio[m] = CoffeeCalculator.clamp(v, 6, 25);
            }
          }
        }
      } catch (_) {
        baseRatio = {...CoffeeCalculator.defaultBaseRatio};
      }
    }

    cups = cups.clamp(1, 12);
    strength = CoffeeCalculator.clamp(strength, 0.75, 2);
    isLoading = false;
    notifyListeners();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    final payload = {
      'method': method.name,
      'cups': cups,
      'strength': strength,
      'unit': unit.name,
      'baseRatio': {
        for (final entry in baseRatio.entries) entry.key.name: entry.value,
      },
    };

    await prefs.setString(_prefsKey, jsonEncode(payload));
  }

  Future<void> setMethod(BrewMethod value) async {
    method = value;
    notifyListeners();
    await _persist();
  }

  Future<void> setCups(int value) async {
    cups = value.clamp(1, 12);
    notifyListeners();
    await _persist();
  }

  Future<void> setStrength(double value) async {
    strength = CoffeeCalculator.clamp(value, 0.75, 2);
    notifyListeners();
    await _persist();
  }

  Future<void> setUnit(WaterUnit value) async {
    unit = value;
    notifyListeners();
    await _persist();
  }

  Future<void> setBaseRatio(BrewMethod m, double ratio) async {
    baseRatio[m] = CoffeeCalculator.clamp(ratio, 6, 25);
    notifyListeners();
    await _persist();
  }

  Future<void> reset() async {
    method = BrewMethod.aeropress;
    cups = 1;
    strength = 1.0;
    unit = WaterUnit.ml;
    baseRatio = {...CoffeeCalculator.defaultBaseRatio};
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefsKey);
  }

  double get adjustedRatio =>
      CoffeeCalculator.adjustedRatio(baseRatio[method]!, strength);
  double get waterMl => CoffeeCalculator.waterMl(method, cups);
  double get coffeeGrams =>
      CoffeeCalculator.coffeeGrams(waterMl, adjustedRatio);

  double get shownWater =>
      unit == WaterUnit.ml ? waterMl : CoffeeCalculator.mlToOz(waterMl);
  String get waterUnitLabel => unit == WaterUnit.ml ? 'ml' : 'oz';

  String get ratioLabel => '1:${CoffeeCalculator.roundTo(adjustedRatio, 1)}';
  String get methodLabel => CoffeeCalculator.methodLabels[method]!;
  String get rangeLabel {
    final range = CoffeeCalculator.suggestedRatioRange[method]!;
    return '1:${range.first} a 1:${range.last}';
  }
}
