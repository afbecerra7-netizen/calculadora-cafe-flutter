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
}
