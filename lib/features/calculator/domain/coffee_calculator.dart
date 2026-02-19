enum BrewMethod { aeropress, chemex, v60, frenchpress, coldbrew, mokaItaliana }

enum WaterUnit { ml, oz }

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
    BrewMethod.aeropress: 100,
    BrewMethod.chemex: 165,
    BrewMethod.v60: 175,
    BrewMethod.frenchpress: 250,
    BrewMethod.coldbrew: 160,
    BrewMethod.mokaItaliana: 70,
  };

  static const Map<BrewMethod, double> defaultBaseRatio = {
    BrewMethod.aeropress: 15,
    BrewMethod.chemex: 16,
    BrewMethod.v60: 16,
    BrewMethod.frenchpress: 14,
    BrewMethod.coldbrew: 8,
    BrewMethod.mokaItaliana: 9,
  };

  static const Map<BrewMethod, List<int>> suggestedRatioRange = {
    BrewMethod.aeropress: [13, 17],
    BrewMethod.chemex: [15, 17],
    BrewMethod.v60: [15, 17],
    BrewMethod.frenchpress: [12, 15],
    BrewMethod.coldbrew: [6, 10],
    BrewMethod.mokaItaliana: [7, 10],
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
      'Agrega el cafe molido medio-fino.',
      'Vierte el agua en 2 etapas y remueve.',
      'Presiona suave despues de 1:30.',
    ],
    BrewMethod.chemex: [
      'Enjuaga el filtro y descarta el agua.',
      'Agrega cafe molido medio.',
      'Vierte en circulos hasta completar.',
      'Sirve cuando termine el goteo.',
    ],
    BrewMethod.v60: [
      'Enjuaga el filtro y precalienta el servidor.',
      'Agrega cafe molido medio-fino.',
      'Haz bloom 30-40 s y luego vierte por etapas.',
      'Tiempo objetivo 2:30 a 3:30.',
    ],
    BrewMethod.frenchpress: [
      'Agrega cafe molido grueso.',
      'Vierte agua y remueve.',
      'Infusiona 4 minutos.',
      'Presiona lentamente y sirve.',
    ],
    BrewMethod.coldbrew: [
      'Agrega cafe molido grueso.',
      'Incorpora agua fria.',
      'Refrigera 12 a 16 horas.',
      'Filtra y sirve con hielo o diluye.',
    ],
    BrewMethod.mokaItaliana: [
      'Llena la base con agua caliente sin pasar la valvula.',
      'Usa cafe molido fino a medio-fino sin compactar.',
      'Arma la moka y calienta a fuego medio-bajo.',
      'Retira cuando el flujo aclare para evitar amargor.',
    ],
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
