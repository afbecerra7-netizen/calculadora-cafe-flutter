import 'dart:convert';

import 'package:cafe_flutter_app/features/calculator/application/calculator_controller.dart';
import 'package:cafe_flutter_app/features/calculator/domain/coffee_calculator.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Map<String, dynamic> _buildPayload({
  required BrewMethod method,
  required int cups,
  required double strength,
  required WaterUnit unit,
  required Map<BrewMethod, double> baseRatio,
}) {
  return {
    'method': method.name,
    'cups': cups,
    'strength': strength,
    'unit': unit.name,
    'baseRatio': {
      for (final entry in baseRatio.entries) entry.key.name: entry.value,
    },
  };
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('init loads state from v2 prefs key', () async {
    final ratios = {
      ...CoffeeCalculator.defaultBaseRatio,
      BrewMethod.v60: 18.0,
    };
    final payload = _buildPayload(
      method: BrewMethod.v60,
      cups: 3,
      strength: 1.5,
      unit: WaterUnit.oz,
      baseRatio: ratios,
    );

    SharedPreferences.setMockInitialValues({
      'coffee_calc_prefs_v2': jsonEncode(payload),
    });

    final calcController = CalculatorController();
    await calcController.init();

    expect(calcController.method, BrewMethod.v60);
    expect(calcController.cups, 3);
    expect(calcController.unit, WaterUnit.oz);
    expect(calcController.strength, 1.5);
    expect(calcController.baseRatio[BrewMethod.v60], 18.0);
  });

  test('init falls back to legacy v1 prefs key', () async {
    final ratios = {
      ...CoffeeCalculator.defaultBaseRatio,
      BrewMethod.chemex: 17.2,
    };
    final payload = _buildPayload(
      method: BrewMethod.chemex,
      cups: 2,
      strength: 1.2,
      unit: WaterUnit.ml,
      baseRatio: ratios,
    );

    SharedPreferences.setMockInitialValues({
      'coffee_calc_prefs_v1': jsonEncode(payload),
    });

    final calcController = CalculatorController();
    await calcController.init();

    expect(calcController.method, BrewMethod.chemex);
    expect(calcController.baseRatio[BrewMethod.chemex], 17.2);
  });

  test('legacy default ratios are replaced by current defaults', () async {
    final legacyRatios = {
      BrewMethod.aeropress: 16.0,
      BrewMethod.chemex: 16.0,
      BrewMethod.v60: 17.0,
      BrewMethod.frenchpress: 14.0,
      BrewMethod.coldbrew: 6.0,
      BrewMethod.mokaItaliana: 10.0,
    };
    final payload = _buildPayload(
      method: BrewMethod.v60,
      cups: 1,
      strength: 1.0,
      unit: WaterUnit.ml,
      baseRatio: legacyRatios,
    );

    SharedPreferences.setMockInitialValues({
      'coffee_calc_prefs_v1': jsonEncode(payload),
    });

    final calcController = CalculatorController();
    await calcController.init();

    for (final method in BrewMethod.values) {
      expect(
        calcController.baseRatio[method],
        CoffeeCalculator.defaultBaseRatio[method],
      );
    }
  });

  test('custom stored ratios are preserved and clamped', () async {
    final customRatios = {
      BrewMethod.aeropress: 16.0,
      BrewMethod.chemex: 16.0,
      BrewMethod.v60: 30.0,
      BrewMethod.frenchpress: 14.0,
      BrewMethod.coldbrew: 6.0,
      BrewMethod.mokaItaliana: 10.0,
    };
    final payload = _buildPayload(
      method: BrewMethod.v60,
      cups: 1,
      strength: 1.0,
      unit: WaterUnit.ml,
      baseRatio: customRatios,
    );

    SharedPreferences.setMockInitialValues({
      'coffee_calc_prefs_v1': jsonEncode(payload),
    });

    final calcController = CalculatorController();
    await calcController.init();

    expect(calcController.baseRatio[BrewMethod.v60], 25.0);
  });

  test('cold brew stored ratio is clamped to method minimum', () async {
    final customRatios = {
      BrewMethod.aeropress: 16.0,
      BrewMethod.chemex: 16.0,
      BrewMethod.v60: 16.0,
      BrewMethod.frenchpress: 14.0,
      BrewMethod.coldbrew: 3.5,
      BrewMethod.mokaItaliana: 10.0,
    };
    final payload = _buildPayload(
      method: BrewMethod.coldbrew,
      cups: 1,
      strength: 1.0,
      unit: WaterUnit.ml,
      baseRatio: customRatios,
    );

    SharedPreferences.setMockInitialValues({
      'coffee_calc_prefs_v1': jsonEncode(payload),
    });

    final calcController = CalculatorController();
    await calcController.init();

    expect(calcController.baseRatio[BrewMethod.coldbrew], 4.0);
  });

  test('init exits safely when controller is disposed early', () async {
    final calcController = CalculatorController();
    calcController.dispose();

    await calcController.init();

    expect(calcController.isLoading, true);
  });
}
