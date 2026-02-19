import 'package:cafe_flutter_app/features/calculator/domain/coffee_calculator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('adjusted ratio decreases when strength increases', () {
    final ratio = CoffeeCalculator.adjustedRatio(16, 2);
    expect(ratio, 8);
  });

  test('water and coffee calculation for chemex', () {
    final water = CoffeeCalculator.waterMl(BrewMethod.chemex, 2);
    final coffee = CoffeeCalculator.coffeeGrams(water, 16);

    expect(water, 330);
    expect(CoffeeCalculator.roundTo(coffee, 0), 21);
  });

  test('ml to oz conversion', () {
    final oz = CoffeeCalculator.mlToOz(300);
    expect(CoffeeCalculator.roundTo(oz, 1), 10.1);
  });

  test('moka italiana defaults are available', () {
    expect(CoffeeCalculator.methodFromKey('mokaItaliana'),
        BrewMethod.mokaItaliana);
    expect(CoffeeCalculator.waterMl(BrewMethod.mokaItaliana, 2), 140);
    expect(CoffeeCalculator.defaultBaseRatio[BrewMethod.mokaItaliana], 9);
  });

  test('every brew method has grind recommendation', () {
    expect(
      CoffeeCalculator.grindRecommendations.keys.toSet(),
      BrewMethod.values.toSet(),
    );
  });

  test('every brew method has a quick guide', () {
    expect(
      CoffeeCalculator.methodGuides.keys.toSet(),
      BrewMethod.values.toSet(),
    );
  });
}
