import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../application/calculator_controller.dart';
import '../domain/coffee_calculator.dart';
import 'widgets/background_orbs.dart';
import 'widgets/brew_method_icon.dart';
import 'widgets/glass_card.dart';
import 'widgets/metric_card.dart';
import 'widgets/quick_summary.dart';
import 'widgets/section_title.dart';

class CalculatorPage extends StatefulWidget {
  const CalculatorPage({super.key});

  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  final controller = CalculatorController();
  final _resultsKey = GlobalKey();
  final _scrollController = ScrollController();
  late final Map<BrewMethod, TextEditingController> _ratioControllers;
  late final Map<BrewMethod, FocusNode> _ratioFocusNodes;
  bool _advancedOpen = false;
  static const _methodIconColor = Color(0xFF7D4D1F);

  @override
  void initState() {
    super.initState();
    _ratioControllers = {
      for (final method in BrewMethod.values)
        method: TextEditingController(
          text: controller.baseRatio[method]!.toStringAsFixed(1),
        ),
    };
    _ratioFocusNodes = {
      for (final method in BrewMethod.values) method: FocusNode(),
    };
    controller.addListener(_syncRatioInputs);
    controller.init();
  }

  @override
  void dispose() {
    controller.removeListener(_syncRatioInputs);
    for (final textController in _ratioControllers.values) {
      textController.dispose();
    }
    for (final focusNode in _ratioFocusNodes.values) {
      focusNode.dispose();
    }
    _scrollController.dispose();
    controller.dispose();
    super.dispose();
  }

  double? _parseRatioInput(String text) {
    final normalized = text.trim().replaceAll(',', '.');
    if (normalized.isEmpty) return null;
    return double.tryParse(normalized);
  }

  void _syncRatioInputs() {
    for (final method in BrewMethod.values) {
      final focusNode = _ratioFocusNodes[method]!;
      if (focusNode.hasFocus) continue;
      final expected = controller.baseRatio[method]!.toStringAsFixed(1);
      final textController = _ratioControllers[method]!;
      if (textController.text == expected) continue;
      textController.value = TextEditingValue(
        text: expected,
        selection: TextSelection.collapsed(offset: expected.length),
      );
    }
  }

  void _commitRatio(BrewMethod method) {
    final textController = _ratioControllers[method]!;
    final parsed = _parseRatioInput(textController.text);
    if (parsed != null) {
      controller.setBaseRatio(method, parsed);
    }
    final normalized = controller.baseRatio[method]!.toStringAsFixed(1);
    if (textController.text != normalized) {
      textController.value = TextEditingValue(
        text: normalized,
        selection: TextSelection.collapsed(offset: normalized.length),
      );
    }
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
            child: QuickSummary(
              coffee: coffee,
              water: waterValue,
              unit: controller.waterUnitLabel,
              onCopy: () async {
                final recipe = 'Receta (${controller.methodLabel})\n'
                    'Tazas: ${controller.cups}\n'
                    'Cafe: $coffee g\n'
                    'Agua: $waterValue ${controller.waterUnitLabel}\n'
                    'Ratio: ${controller.ratioLabel}\n'
                    'Molienda recomendada: ${controller.grindRecommendation}';
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
              const BackgroundOrbs(),
              SafeArea(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  padding: const EdgeInsets.fromLTRB(14, 14, 14, 132),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GlassCard(
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
                      GlassCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SectionTitle('Tipo de cafetera'),
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
                                        BrewMethodIcon(
                                          method: m,
                                          color: _methodIconColor,
                                          size: 28,
                                        ),
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
                      GlassCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SectionTitle('Numero de tazas'),
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
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 7),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(999),
                                color: const Color(0xCCFFF9F0),
                                border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.7)),
                              ),
                              child: Text(
                                controller.strengthLabel,
                                style: const TextStyle(
                                  color: Color(0xFF7C4D1B),
                                  fontWeight: FontWeight.w800,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                activeTrackColor: const Color(0xFFCD7B2C),
                                inactiveTrackColor: const Color(0x44B57941),
                                thumbColor: const Color(0xFF9B5B22),
                                overlayColor: const Color(0x229B5B22),
                                trackHeight: 5.5,
                              ),
                              child: Slider(
                                value:
                                    controller.strengthPresetIndex.toDouble(),
                                min: 0,
                                max: (CoffeeCalculator.strengthPresets.length -
                                        1)
                                    .toDouble(),
                                divisions:
                                    CoffeeCalculator.strengthPresets.length - 1,
                                label: controller.strengthLabel,
                                onChanged: (v) => controller
                                    .setStrengthPresetIndex(v.round()),
                              ),
                            ),
                            Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: CoffeeCalculator.strengthPresets
                                  .asMap()
                                  .entries
                                  .map(
                                (entry) {
                                  final selected =
                                      controller.strengthPresetIndex ==
                                          entry.key;
                                  return ChoiceChip(
                                    label: Text(entry.value.label),
                                    selected: selected,
                                    onSelected: (_) => controller
                                        .setStrengthPresetIndex(entry.key),
                                    labelStyle: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: selected
                                          ? const Color(0xFF7A3F08)
                                          : const Color(0xFF6F5135),
                                    ),
                                    selectedColor: const Color(0xFFFFE3C0),
                                    backgroundColor: const Color(0xCCFFFFFF),
                                    side: BorderSide(
                                      color: selected
                                          ? const Color(0xFFF0A65B)
                                          : Colors.white.withValues(alpha: 0.7),
                                    ),
                                    visualDensity: VisualDensity.compact,
                                  );
                                },
                              ).toList(),
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: DropdownButtonFormField<WaterUnit>(
                                    key: ValueKey(controller.unit),
                                    initialValue: controller.unit,
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
                      GlassCard(
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const SectionTitle('Modo avanzado'),
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
                                          controller: _ratioControllers[m],
                                          focusNode: _ratioFocusNodes[m],
                                          keyboardType: const TextInputType
                                              .numberWithOptions(decimal: true),
                                          textInputAction: TextInputAction.done,
                                          decoration: _inputDecoration('Ratio'),
                                          onEditingComplete: () =>
                                              _commitRatio(m),
                                          onFieldSubmitted: (_) =>
                                              _commitRatio(m),
                                          onTapOutside: (_) => _commitRatio(m),
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
                      GlassCard(
                        key: _resultsKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SectionTitle('Resultado'),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: MetricCard(
                                      label: 'CAFE', value: coffee, unit: 'g'),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: MetricCard(
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
                            const SizedBox(height: 4),
                            Text(
                              'Molienda recomendada: ${controller.grindRecommendation}',
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
                            ...CoffeeCalculator.methodGuides[controller.method]!
                                .asMap()
                                .entries
                                .map(
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
