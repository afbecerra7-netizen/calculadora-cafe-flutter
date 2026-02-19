# Cafe Flutter App

Base inicial de migracion de la calculadora web a Flutter, en carpeta separada.

## Incluye

- Estructura por feature (`domain`, `application`, `presentation`).
- Logica de calculo portada desde web.
- Persistencia de preferencias con `shared_preferences`.
- UI inicial funcional con resumen fijo inferior y acciones basicas.
- Tests unitarios del dominio + smoke test de app.

## Estructura relevante

- `lib/app.dart`
- `lib/main.dart`
- `lib/features/calculator/domain/coffee_calculator.dart`
- `lib/features/calculator/application/calculator_controller.dart`
- `lib/features/calculator/presentation/calculator_page.dart`
- `test/coffee_calculator_test.dart`

## Ejecutar

```bash
cd /Users/felipebecerra/Proyectos/Cafe/cafe_flutter_app
flutter pub get
flutter run
```

## Tests

```bash
flutter test
```
