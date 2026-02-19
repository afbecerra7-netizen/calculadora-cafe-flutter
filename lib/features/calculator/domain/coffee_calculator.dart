enum BrewMethod { aeropress, chemex, v60, frenchpress, coldbrew }

enum WaterUnit { ml, oz }

class CoffeeCalculator {
  static const Map<BrewMethod, String> methodLabels = {
    BrewMethod.aeropress: 'AeroPress',
    BrewMethod.chemex: 'Chemex',
    BrewMethod.v60: 'V60',
    BrewMethod.frenchpress: 'Prensa',
    BrewMethod.coldbrew: 'Cold Brew',
  };

  static const Map<BrewMethod, int> waterPerCupMl = {
    BrewMethod.aeropress: 100,
    BrewMethod.chemex: 165,
    BrewMethod.v60: 175,
    BrewMethod.frenchpress: 250,
    BrewMethod.coldbrew: 160,
  };

  static const Map<BrewMethod, double> defaultBaseRatio = {
    BrewMethod.aeropress: 15,
    BrewMethod.chemex: 16,
    BrewMethod.v60: 16,
    BrewMethod.frenchpress: 14,
    BrewMethod.coldbrew: 8,
  };

  static const Map<BrewMethod, List<int>> suggestedRatioRange = {
    BrewMethod.aeropress: [13, 17],
    BrewMethod.chemex: [15, 17],
    BrewMethod.v60: [15, 17],
    BrewMethod.frenchpress: [12, 15],
    BrewMethod.coldbrew: [6, 10],
  };

  static double clamp(double value, double min, double max) {
    if (value < min) return min;
    if (value > max) return max;
    return value;
  }

  static double roundTo(double value, int decimals) {
    final factor = MathPow.pow10(decimals);
    return (value * factor).round() / factor;
  }

  static double adjustedRatio(double baseRatio, double strength) {
    return clamp(baseRatio / strength, 6, 25);
  }

  static double waterMl(BrewMethod method, int cups) {
    return (cups * (waterPerCupMl[method] ?? 0)).toDouble();
  }

  static double coffeeGrams(double water, double ratio) {
    return water / ratio;
  }

  static double mlToOz(double ml) => ml / 29.5735;

  static String methodKey(BrewMethod method) => method.name;

  static BrewMethod methodFromKey(String key) {
    return BrewMethod.values.firstWhere(
      (m) => m.name == key,
      orElse: () => BrewMethod.aeropress,
    );
  }
}

class MathPow {
  static double pow10(int exp) {
    var value = 1.0;
    for (var i = 0; i < exp; i++) {
      value *= 10;
    }
    return value;
  }
}
