enum BrewMethod { aeropress, chemex, v60, frenchpress, coldbrew, mokaItaliana }

enum WaterUnit { ml, oz }

class StrengthPreset {
  const StrengthPreset({required this.label, required this.factor});

  final String label;
  final double factor;
}

class CoffeeCalculator {
  static const Map<BrewMethod, String> methodLabels = {
    BrewMethod.aeropress: 'AeroPress',
    BrewMethod.chemex: 'Chemex',
    BrewMethod.v60: 'V60',
    BrewMethod.frenchpress: 'Prensa',
    BrewMethod.coldbrew: 'Cold Brew',
    BrewMethod.mokaItaliana: 'Moka italiana',
  };

  static const Map<BrewMethod, int> waterPerCupMl = {
    BrewMethod.aeropress: 250,
    BrewMethod.chemex: 250,
    BrewMethod.v60: 240,
    BrewMethod.frenchpress: 250,
    BrewMethod.coldbrew: 160,
    BrewMethod.mokaItaliana: 70,
  };

  static const Map<BrewMethod, double> defaultBaseRatio = {
    BrewMethod.aeropress: 15.6,
    BrewMethod.chemex: 16.7,
    BrewMethod.v60: 16.8,
    BrewMethod.frenchpress: 16,
    BrewMethod.coldbrew: 8,
    BrewMethod.mokaItaliana: 9,
  };

  static const Map<BrewMethod, List<int>> suggestedRatioRange = {
    BrewMethod.aeropress: [14, 16],
    BrewMethod.chemex: [15, 17],
    BrewMethod.v60: [15, 18],
    BrewMethod.frenchpress: [15, 18],
    BrewMethod.coldbrew: [6, 10],
    BrewMethod.mokaItaliana: [8, 10],
  };

  static const Map<BrewMethod, String> grindRecommendations = {
    BrewMethod.aeropress: 'Media-fina',
    BrewMethod.chemex: 'Media-gruesa',
    BrewMethod.v60: 'Media',
    BrewMethod.frenchpress: 'Gruesa',
    BrewMethod.coldbrew: 'Gruesa',
    BrewMethod.mokaItaliana: 'Fina a media-fina',
  };

  static const Map<BrewMethod, List<String>> methodGuides = {
    BrewMethod.aeropress: [
      'Enjuaga el filtro y precalienta el equipo.',
      'Para 1 taza usa 16 g de cafe y 250 ml de agua (aprox 1:15.6).',
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
      'Trabaja entre 1:16 y 1:17 con molienda media.',
      'Haz bloom 30-40 s y luego vierte por etapas.',
      'Tiempo objetivo 2:30 a 3:30.',
    ],
    BrewMethod.frenchpress: [
      'Usa cafe molido grueso en rango 1:15 a 1:18.',
      'Vierte agua y remueve.',
      'Infusiona 4 minutos.',
      'Presiona lentamente y sirve.',
    ],
    BrewMethod.coldbrew: [
      'Muele grueso y trabaja como concentrado (1:6 a 1:10).',
      'Incorpora agua fria.',
      'Refrigera 12 a 16 horas.',
      'Filtra. Si queda intenso, diluye 1:1 con agua o leche.',
    ],
    BrewMethod.mokaItaliana: [
      'Llena la base con agua caliente sin pasar la valvula.',
      'Usa cafe molido fino a medio-fino sin compactar (aprox 1:8 a 1:10).',
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
