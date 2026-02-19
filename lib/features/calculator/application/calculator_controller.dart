import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/coffee_calculator.dart';

class CalculatorController extends ChangeNotifier {
  static const _prefsKey = 'coffee_calc_prefs_v2';
  static const _legacyPrefsKey = 'coffee_calc_prefs_v1';
  static const _prefsSchemaVersion = 2;
  static const _persistDebounceDelay = Duration(milliseconds: 250);
  static const _legacyBaseRatioV0 = {
    BrewMethod.aeropress: 15.0,
    BrewMethod.chemex: 16.0,
    BrewMethod.v60: 16.0,
    BrewMethod.frenchpress: 14.0,
    BrewMethod.coldbrew: 8.0,
    BrewMethod.mokaItaliana: 9.0,
  };
  static const _legacyBaseRatioV1 = {
    BrewMethod.aeropress: 15.6,
    BrewMethod.chemex: 16.7,
    BrewMethod.v60: 16.8,
    BrewMethod.frenchpress: 16.0,
    BrewMethod.coldbrew: 8.0,
    BrewMethod.mokaItaliana: 9.0,
  };
  static const _legacyBaseRatioV2 = {
    BrewMethod.aeropress: 16.0,
    BrewMethod.chemex: 16.0,
    BrewMethod.v60: 17.0,
    BrewMethod.frenchpress: 14.0,
    BrewMethod.coldbrew: 6.0,
    BrewMethod.mokaItaliana: 10.0,
  };

  BrewMethod method = BrewMethod.aeropress;
  int cups = 1;
  double strength = 1.0;
  WaterUnit unit = WaterUnit.ml;
  late Map<BrewMethod, double> baseRatio;

  bool isLoading = true;
  Timer? _persistDebounce;
  bool _persistInProgress = false;
  bool _isDisposed = false;
  int _stateVersion = 0;
  int _persistedVersion = 0;

  CalculatorController() {
    baseRatio = {...CoffeeCalculator.defaultBaseRatio};
  }

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey) ?? prefs.getString(_legacyPrefsKey);

    if (raw != null) {
      try {
        final map = jsonDecode(raw) as Map<String, dynamic>;
        method = CoffeeCalculator.methodFromKey(
          map['method'] as String? ?? 'aeropress',
        );
        cups = (map['cups'] as num?)?.toInt() ?? 1;
        strength = (map['strength'] as num?)?.toDouble() ?? 1.0;
        unit = (map['unit'] == 'oz') ? WaterUnit.oz : WaterUnit.ml;

        final ratios = map['baseRatio'] as Map<String, dynamic>?;
        if (ratios != null && !_isLegacyDefaultRatios(ratios)) {
          for (final m in BrewMethod.values) {
            final v = (ratios[m.name] as num?)?.toDouble();
            if (v != null) {
              baseRatio[m] = CoffeeCalculator.clampRatioForMethod(m, v);
            }
          }
        }
      } catch (_) {
        baseRatio = {...CoffeeCalculator.defaultBaseRatio};
      }
    }

    cups = cups.clamp(1, 12);
    strength = CoffeeCalculator.nearestStrengthPresetValue(strength);
    if (_isDisposed) return;
    isLoading = false;
    notifyListeners();
  }

  bool _isLegacyDefaultRatios(Map<String, dynamic> ratios) {
    return _matchesLegacyDefaults(ratios, _legacyBaseRatioV0) ||
        _matchesLegacyDefaults(ratios, _legacyBaseRatioV1) ||
        _matchesLegacyDefaults(ratios, _legacyBaseRatioV2);
  }

  bool _matchesLegacyDefaults(
    Map<String, dynamic> ratios,
    Map<BrewMethod, double> defaults,
  ) {
    for (final m in BrewMethod.values) {
      final value = (ratios[m.name] as num?)?.toDouble();
      final expected = defaults[m];
      if (value == null || expected == null) return false;
      if ((value - expected).abs() > 0.001) return false;
    }
    return true;
  }

  Map<String, dynamic> _buildPayload() {
    return {
      'method': method.name,
      'cups': cups,
      'strength': strength,
      'unit': unit.name,
      'version': _prefsSchemaVersion,
      'baseRatio': {
        for (final entry in baseRatio.entries) entry.key.name: entry.value,
      },
    };
  }

  void _schedulePersist(Duration delay) {
    if (_isDisposed) return;
    _persistDebounce?.cancel();
    _persistDebounce = Timer(delay, () {
      unawaited(_flushPersist());
    });
  }

  void _markDirty({bool persistImmediately = false}) {
    _stateVersion++;
    if (persistImmediately) {
      _persistDebounce?.cancel();
      unawaited(_flushPersist());
      return;
    }
    _schedulePersist(_persistDebounceDelay);
  }

  Future<void> _flushPersist() async {
    if (_isDisposed || _persistInProgress) return;
    _persistInProgress = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      while (!_isDisposed && _persistedVersion < _stateVersion) {
        final targetVersion = _stateVersion;
        await prefs.setString(_prefsKey, jsonEncode(_buildPayload()));
        _persistedVersion = targetVersion;
      }
    } catch (error, stackTrace) {
      debugPrint('Failed to persist calculator state: $error');
      debugPrintStack(stackTrace: stackTrace);
    } finally {
      _persistInProgress = false;
      if (!_isDisposed && _persistedVersion < _stateVersion) {
        _schedulePersist(const Duration(milliseconds: 100));
      }
    }
  }

  void setMethod(BrewMethod value) {
    method = value;
    notifyListeners();
    _markDirty();
  }

  void setCups(int value) {
    cups = value.clamp(1, 12);
    notifyListeners();
    _markDirty();
  }

  void setStrength(double value) {
    strength = CoffeeCalculator.nearestStrengthPresetValue(value);
    notifyListeners();
    _markDirty();
  }

  void setStrengthPresetIndex(int index) {
    final safeIndex =
        index.clamp(0, CoffeeCalculator.strengthPresets.length - 1);
    setStrength(CoffeeCalculator.strengthPresets[safeIndex].factor);
  }

  void setUnit(WaterUnit value) {
    unit = value;
    notifyListeners();
    _markDirty();
  }

  void setBaseRatio(BrewMethod m, double ratio) {
    baseRatio[m] = CoffeeCalculator.clampRatioForMethod(m, ratio);
    notifyListeners();
    _markDirty();
  }

  void reset() {
    method = BrewMethod.aeropress;
    cups = 1;
    strength = 1.0;
    unit = WaterUnit.ml;
    baseRatio = {...CoffeeCalculator.defaultBaseRatio};
    notifyListeners();
    _markDirty(persistImmediately: true);
  }

  @override
  void dispose() {
    _isDisposed = true;
    _persistDebounce?.cancel();
    super.dispose();
  }

  double get adjustedRatio =>
      CoffeeCalculator.adjustedRatio(method, baseRatio[method]!, strength);
  double get waterMl => CoffeeCalculator.waterMl(method, cups);
  double get coffeeGrams =>
      CoffeeCalculator.coffeeGrams(waterMl, adjustedRatio);

  double get shownWater =>
      unit == WaterUnit.ml ? waterMl : CoffeeCalculator.mlToOz(waterMl);
  String get waterUnitLabel => unit == WaterUnit.ml ? 'ml' : 'oz';

  String get ratioLabel => '1:${CoffeeCalculator.roundTo(adjustedRatio, 1)}';
  String get methodLabel => CoffeeCalculator.methodLabels[method]!;
  int get strengthPresetIndex =>
      CoffeeCalculator.nearestStrengthPresetIndex(strength);
  String get strengthLabel =>
      CoffeeCalculator.strengthPresets[strengthPresetIndex].label;
  String get grindRecommendation =>
      CoffeeCalculator.grindRecommendations[method]!;
  String get rangeLabel {
    final range = CoffeeCalculator.suggestedRatioRange[method]!;
    return '1:${range.first} a 1:${range.last}';
  }
}
