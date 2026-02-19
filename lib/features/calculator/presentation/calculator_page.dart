import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../application/calculator_controller.dart';
import '../domain/coffee_calculator.dart';

class CalculatorPage extends StatefulWidget {
  const CalculatorPage({super.key});

  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  final controller = CalculatorController();
  final _resultsKey = GlobalKey();
  final _scrollController = ScrollController();
  bool _advancedOpen = false;

  static const Map<BrewMethod, IconData> _methodIcons = {
    BrewMethod.aeropress: Icons.coffee_maker_outlined,
    BrewMethod.chemex: Icons.science_outlined,
    BrewMethod.v60: Icons.filter_alt_outlined,
    BrewMethod.frenchpress: Icons.local_cafe_outlined,
    BrewMethod.coldbrew: Icons.ac_unit_outlined,
  };

  static const Map<BrewMethod, List<String>> _guides = {
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
  };

  @override
  void initState() {
    super.initState();
    controller.init();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        if (controller.isLoading) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }

        final coffee = CoffeeCalculator.roundTo(controller.coffeeGrams, 0)
            .toStringAsFixed(0);
        final waterValue = controller.unit == WaterUnit.ml
            ? CoffeeCalculator.roundTo(controller.shownWater, 0)
                .toStringAsFixed(0)
            : CoffeeCalculator.roundTo(controller.shownWater, 1)
                .toStringAsFixed(1);

        return Scaffold(
          backgroundColor: const Color(0xFFF5EEE4),
          bottomNavigationBar: SafeArea(
            minimum: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: _QuickSummary(
              coffee: coffee,
              water: waterValue,
              unit: controller.waterUnitLabel,
              onCopy: () async {
                final recipe = 'Receta (${controller.methodLabel})\n'
                    'Tazas: ${controller.cups}\n'
                    'Cafe: $coffee g\n'
                    'Agua: $waterValue ${controller.waterUnitLabel}\n'
                    'Ratio: ${controller.ratioLabel}';
                await Clipboard.setData(ClipboardData(text: recipe));
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Receta copiada')),
                  );
                }
              },
              onViewDetail: () {
                final ctx = _resultsKey.currentContext;
                if (ctx != null) {
                  Scrollable.ensureVisible(
                    ctx,
                    duration: const Duration(milliseconds: 350),
                    curve: Curves.easeOutCubic,
                  );
                }
              },
            ),
          ),
          body: Stack(
            children: [
              const _BackgroundOrbs(),
              SafeArea(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  padding: const EdgeInsets.fromLTRB(14, 14, 14, 132),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _GlassCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'COFFEE RATIO STUDIO',
                              style: TextStyle(
                                letterSpacing: 1.1,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF7C5A37),
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Calculadora de Cafe',
                              style: TextStyle(
                                fontSize: 30,
                                height: 1.05,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF2F2417),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Metodo actual: ${controller.methodLabel}',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF6A4A2F),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      _GlassCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const _SectionTitle('Tipo de cafetera'),
                            const SizedBox(height: 8),
                            GridView.count(
                              crossAxisCount: 3,
                              mainAxisSpacing: 8,
                              crossAxisSpacing: 8,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              childAspectRatio: 1.08,
                              children: BrewMethod.values.map((m) {
                                final selected = controller.method == m;
                                return InkWell(
                                  onTap: () => controller.setMethod(m),
                                  borderRadius: BorderRadius.circular(14),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 180),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                        color: selected
                                            ? const Color(0xFFF0A65B)
                                            : Colors.white
                                                .withValues(alpha: 0.72),
                                      ),
                                      boxShadow: selected
                                          ? const [
                                              BoxShadow(
                                                blurRadius: 18,
                                                offset: Offset(0, 6),
                                                color: Color(0x33B46A1A),
                                              ),
                                            ]
                                          : null,
                                      gradient: LinearGradient(
                                        colors: selected
                                            ? const [
                                                Color(0xFFFFF4E8),
                                                Color(0xFFFFE4C3)
                                              ]
                                            : const [
                                                Color(0xCCFFFFFF),
                                                Color(0xAAFFF0DC)
                                              ],
                                      ),
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(_methodIcons[m],
                                            color: const Color(0xFF7D4D1F)),
                                        const SizedBox(height: 6),
                                        Text(
                                          CoffeeCalculator.methodLabels[m]!,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFF5B3B21),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      _GlassCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const _SectionTitle('Numero de tazas'),
                            Row(
                              children: [
                                Expanded(
                                  child: Slider(
                                    value: controller.cups.toDouble(),
                                    min: 1,
                                    max: 12,
                                    divisions: 11,
                                    onChanged: (v) =>
                                        controller.setCups(v.round()),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(999),
                                    color: const Color(0xCCFFF9F0),
                                    border: Border.all(
                                        color: Colors.white
                                            .withValues(alpha: 0.7)),
                                  ),
                                  child: Text(
                                    '${controller.cups} tazas',
                                    style: const TextStyle(
                                      color: Color(0xFFB56514),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Intensidad',
                              style: TextStyle(
                                fontSize: 12,
                                letterSpacing: 0.8,
                                color: Color(0xFF6F5135),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Slider(
                              value: controller.strength,
                              min: 0.75,
                              max: 2,
                              divisions: 25,
                              onChanged: controller.setStrength,
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: DropdownButtonFormField<WaterUnit>(
                                    value: controller.unit,
                                    decoration:
                                        _inputDecoration('Unidad de agua'),
                                    items: const [
                                      DropdownMenuItem(
                                          value: WaterUnit.ml,
                                          child: Text('Mililitros (ml)')),
                                      DropdownMenuItem(
                                          value: WaterUnit.oz,
                                          child: Text('Onzas (oz)')),
                                    ],
                                    onChanged: (v) {
                                      if (v != null) controller.setUnit(v);
                                    },
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 10),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(999),
                                    border: Border.all(
                                        color: Colors.white
                                            .withValues(alpha: 0.8)),
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xE6FFFFFF),
                                        Color(0xD7FFECD4)
                                      ],
                                    ),
                                  ),
                                  child: Text(
                                    'Ratio ${controller.ratioLabel}',
                                    style: const TextStyle(
                                      color: Color(0xFF7C4D1B),
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      _GlassCard(
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const _SectionTitle('Modo avanzado'),
                                TextButton(
                                  onPressed: () => setState(
                                      () => _advancedOpen = !_advancedOpen),
                                  child: Text(_advancedOpen
                                      ? 'Cerrar'
                                      : 'Editar ratios'),
                                ),
                              ],
                            ),
                            if (_advancedOpen)
                              ...BrewMethod.values.map(
                                (m) => Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          CoffeeCalculator.methodLabels[m]!,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 86,
                                        child: TextFormField(
                                          initialValue: controller.baseRatio[m]!
                                              .toStringAsFixed(1),
                                          keyboardType: const TextInputType
                                              .numberWithOptions(decimal: true),
                                          decoration: _inputDecoration('Ratio'),
                                          onFieldSubmitted: (text) {
                                            final parsed =
                                                double.tryParse(text);
                                            if (parsed != null) {
                                              controller.setBaseRatio(
                                                  m, parsed);
                                            }
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      _GlassCard(
                        key: _resultsKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const _SectionTitle('Resultado'),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: _MetricCard(
                                      label: 'CAFE', value: coffee, unit: 'g'),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _MetricCard(
                                    label: 'AGUA',
                                    value: waterValue,
                                    unit: controller.waterUnitLabel,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Metodo: ${controller.methodLabel} | Base 1:${controller.baseRatio[controller.method]!.toStringAsFixed(1)} | Ajustado ${controller.ratioLabel} | Fuerza x${controller.strength.toStringAsFixed(2)}',
                              style: const TextStyle(
                                  color: Color(0xFF644629), fontSize: 13.5),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Rango sugerido para ${controller.methodLabel}: ${controller.rangeLabel}',
                              style: const TextStyle(
                                  color: Color(0xFF6B4D31),
                                  fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Guia rapida',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 18,
                                color: Color(0xFF4F331A),
                              ),
                            ),
                            const SizedBox(height: 8),
                            ..._guides[controller.method]!.asMap().entries.map(
                                  (entry) => Padding(
                                    padding: const EdgeInsets.only(bottom: 7),
                                    child: Text(
                                      '${entry.key + 1}. ${entry.value}',
                                      style: const TextStyle(
                                        fontSize: 15,
                                        height: 1.28,
                                        color: Color(0xFF5F4329),
                                      ),
                                    ),
                                  ),
                                ),
                            const SizedBox(height: 8),
                            OutlinedButton(
                              onPressed: controller.reset,
                              child: const Text('Restablecer'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

InputDecoration _inputDecoration(String label) {
  return InputDecoration(
    labelText: label,
    labelStyle: const TextStyle(fontSize: 12),
    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.7)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.7)),
    ),
    filled: true,
    fillColor: const Color(0xCFFFFFF8),
  );
}

class _BackgroundOrbs extends StatelessWidget {
  const _BackgroundOrbs();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: const [
        Positioned(
          right: -80,
          top: -80,
          child: _Orb(size: 260, color: Color(0x55F1B97A)),
        ),
        Positioned(
          left: -70,
          bottom: -100,
          child: _Orb(size: 230, color: Color(0x3AD48D52)),
        ),
      ],
    );
  }
}

class _Orb extends StatelessWidget {
  const _Orb({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }
}

class _GlassCard extends StatelessWidget {
  const _GlassCard({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withValues(alpha: 0.67)),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xCFFFFFFF), Color(0x8EFFF4E7)],
            ),
            boxShadow: const [
              BoxShadow(
                blurRadius: 22,
                offset: Offset(0, 10),
                color: Color(0x1C4D2D10),
              )
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w800,
        color: Color(0xFF3F2C1A),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard(
      {required this.label, required this.value, required this.unit});

  final String label;
  final String value;
  final String unit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.75)),
        gradient: const LinearGradient(
          colors: [Color(0xE8FFFFFF), Color(0xCCFFF2E1)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              letterSpacing: 1.1,
              fontWeight: FontWeight.w800,
              color: Color(0xFF7A593A),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 36,
                  height: 0.92,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFFBD6A15),
                ),
              ),
              const SizedBox(width: 6),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  unit.toUpperCase(),
                  style: const TextStyle(
                    letterSpacing: 0.8,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF815B36),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickSummary extends StatelessWidget {
  const _QuickSummary({
    required this.coffee,
    required this.water,
    required this.unit,
    required this.onCopy,
    required this.onViewDetail,
  });

  final String coffee;
  final String water;
  final String unit;
  final VoidCallback onCopy;
  final VoidCallback onViewDetail;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.fromLTRB(12, 10, 10, 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withValues(alpha: 0.82)),
            gradient: const LinearGradient(
              colors: [Color(0xEEFFFFFF), Color(0xE6FFEEDA)],
            ),
            boxShadow: const [
              BoxShadow(
                blurRadius: 20,
                offset: Offset(0, 8),
                color: Color(0x265C3816),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Cafe $coffee g\nAgua $water ${unit.toUpperCase()}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    color: Color(0xFF4D361F),
                    height: 1.35,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              FilledButton.tonal(
                onPressed: onViewDetail,
                child: const Text('Detalle'),
              ),
              const SizedBox(width: 6),
              FilledButton(
                onPressed: onCopy,
                child: const Text('Copiar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
