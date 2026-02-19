enum BrewMethod { aeropress, chemex, v60, frenchpress, coldbrew, mokaItaliana }

enum WaterUnit { ml, oz }

class StrengthPreset {
  const StrengthPreset({required this.label, required this.factor});

  final String label;
  final double factor;
}

class CoffeeCalculator {
  static const double maxRatio = 25;

  static const Map<BrewMethod, String> methodLabels = {
    BrewMethod.aeropress: 'AeroPress',
    BrewMethod.chemex: 'Chemex',
    BrewMethod.v60: 'V60',
    BrewMethod.frenchpress: 'Prensa',
    BrewMethod.coldbrew: 'Cold Brew',
    BrewMethod.mokaItaliana: 'Moka italiana',
  };

  static const Map<BrewMethod, int> waterPerCupMl = {
    BrewMethod.aeropress: 280,
    BrewMethod.chemex: 150,
    BrewMethod.v60: 170,
    BrewMethod.frenchpress: 180,
    BrewMethod.coldbrew: 160,
    BrewMethod.mokaItaliana: 60,
  };

  static const Map<BrewMethod, double> defaultBaseRatio = {
    BrewMethod.aeropress: 16,
    BrewMethod.chemex: 16,
    BrewMethod.v60: 16,
    BrewMethod.frenchpress: 14,
    BrewMethod.coldbrew: 6,
    BrewMethod.mokaItaliana: 10,
  };

  static const Map<BrewMethod, List<int>> suggestedRatioRange = {
    BrewMethod.aeropress: [15, 17],
    BrewMethod.chemex: [15, 17],
    BrewMethod.v60: [16, 18],
    BrewMethod.frenchpress: [12, 15],
    BrewMethod.coldbrew: [4, 8],
    BrewMethod.mokaItaliana: [8, 12],
  };

  static const Map<BrewMethod, String> grindRecommendations = {
    BrewMethod.aeropress: 'Media-fina',
    BrewMethod.chemex: 'Media-gruesa',
    BrewMethod.v60: 'Media-fina',
    BrewMethod.frenchpress: 'Gruesa',
    BrewMethod.coldbrew: 'Gruesa',
    BrewMethod.mokaItaliana: 'Fina a media-fina',
  };

  static const Map<BrewMethod, List<String>> methodGuides = {
    BrewMethod.aeropress: [
      'Enjuaga el filtro y precalienta el equipo.',
      'Usa molienda media-fina y trabaja cerca de 1:16.',
      'Vierte el agua en 2 etapas y remueve.',
      'Presiona suave despues de 1:30.',
    ],
    BrewMethod.chemex: [
      'Enjuaga el filtro y descarta el agua.',
      'Usa una base de 1:16 a 1:17 con molienda media-gruesa.',
      'Vierte en circulos hasta completar.',
      'Sirve cuando termine el goteo.',
    ],
    BrewMethod.v60: [
      'Enjuaga el filtro y precalienta el servidor.',
      'Trabaja entre 1:16 y 1:18 con molienda media-fina.',
      'Haz bloom 30-40 s y luego vierte por etapas.',
      'Tiempo objetivo 2:30 a 3:30.',
    ],
    BrewMethod.frenchpress: [
      'Usa cafe molido grueso en rango 1:12 a 1:15.',
      'Vierte agua y remueve.',
      'Infusiona 4 minutos.',
      'Presiona lentamente y sirve.',
    ],
    BrewMethod.coldbrew: [
      'Muele grueso y trabaja como concentrado (1:4 a 1:8).',
      'Incorpora agua fria.',
      'Refrigera 12 a 16 horas.',
      'Filtra. Si queda intenso, diluye 1:1 con agua o leche.',
    ],
    BrewMethod.mokaItaliana: [
      'Llena la base con agua caliente sin pasar la valvula.',
      'Usa cafe molido fino a medio-fino sin compactar (aprox 1:8 a 1:12).',
      'Arma la moka y calienta a fuego medio-bajo.',
      'Retira cuando el flujo aclare para evitar amargor.',
    ],
  };

  static const List<StrengthPreset> strengthPresets = [
    StrengthPreset(label: 'Muy suave', factor: 0.75),
    StrengthPreset(label: 'Suave', factor: 0.9),
    StrengthPreset(label: 'Normal', factor: 1.0),
    StrengthPreset(label: 'Un poco fuerte', factor: 1.2),
    StrengthPreset(label: 'Fuerte', factor: 1.5),
    StrengthPreset(label: 'Muy fuerte', factor: 2.0),
  ];

  static int nearestStrengthPresetIndex(double value) {
    var bestIndex = 0;
    var bestDistance = (strengthPresets.first.factor - value).abs();
    for (var i = 1; i < strengthPresets.length; i++) {
      final distance = (strengthPresets[i].factor - value).abs();
      if (distance < bestDistance) {
        bestDistance = distance;
        bestIndex = i;
      }
    }
    return bestIndex;
  }

  static double nearestStrengthPresetValue(double value) {
    return strengthPresets[nearestStrengthPresetIndex(value)].factor;
  }

  static double clamp(double value, double min, double max) {
    if (value < min) return min;
    if (value > max) return max;
    return value;
  }

  static double roundTo(double value, int decimals) {
    final factor = MathPow.pow10(decimals);
    return (value * factor).round() / factor;
  }

  static double minRatioForMethod(BrewMethod method) {
    if (method == BrewMethod.coldbrew) return 4;
    return 6;
  }

  static double clampRatioForMethod(BrewMethod method, double ratio) {
    return clamp(ratio, minRatioForMethod(method), maxRatio);
  }

  static double adjustedRatio(
    BrewMethod method,
    double baseRatio,
    double strength,
  ) {
    return clampRatioForMethod(method, baseRatio / strength);
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
