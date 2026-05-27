import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../models/product_model.dart';

// Renders one attribute selector row per variation attribute.
// e.g. "Version" → chips: [SHOWNU ver.] [HYUNGWON ver.]
class VariationSelector extends StatelessWidget {
  final Product product;
  final Map<String, String> selectedOptions;
  final ValueChanged<Map<String, String>> onSelectionChanged;

  const VariationSelector({
    super.key,
    required this.product,
    required this.selectedOptions,
    required this.onSelectionChanged,
  });

  @override
  Widget build(BuildContext context) {
    final attrs = product.variationAttributes;
    if (attrs.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: attrs.map((attr) => _AttributeRow(
        attribute: attr,
        selectedValue: selectedOptions[attr.key],
        // Check which options are actually in stock
        // by looking at variants with this option
        availableOptions: _getAvailableOptions(attr),
        onOptionSelected: (value) {
          final updated = Map<String, String>.from(selectedOptions);
          updated[attr.key] = value;
          onSelectionChanged(updated);
        },
      )).toList(),
    );
  }

  // Returns options that have at least one instock variant
  Set<String> _getAvailableOptions(ProductAttribute attr) {
    return product.variants
        .where((v) => v.inStock)
        .map((v) => v.selectedOptions[attr.key] ?? '')
        .where((v) => v.isNotEmpty)
        .toSet();
  }
}

class _AttributeRow extends StatelessWidget {
  final ProductAttribute attribute;
  final String? selectedValue;
  final Set<String> availableOptions;
  final ValueChanged<String> onOptionSelected;

  const _AttributeRow({
    required this.attribute,
    required this.selectedValue,
    required this.availableOptions,
    required this.onOptionSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Attribute label — "Version" + selected value
          Row(
            children: [
              Text(
                attribute.name,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              if (selectedValue != null) ...[
                const SizedBox(width: 8),
                Text(
                  ': $selectedValue',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),

          const SizedBox(height: 10),

          // Option chips
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: attribute.options.map((option) {
              final isSelected = selectedValue == option;
              final isAvailable = availableOptions.contains(option);

              return GestureDetector(
                onTap: isAvailable
                    ? () => onOptionSelected(option)
                    : null,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary
                        : isAvailable
                            ? AppColors.background
                            : AppColors.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : isAvailable
                              ? AppColors.border
                              : AppColors.border,
                      width: isSelected ? 1.5 : 0.5,
                    ),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Text(
                        option,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w400,
                          color: isSelected
                              ? Colors.white
                              : isAvailable
                                  ? AppColors.textPrimary
                                  : AppColors.textHint,
                        ),
                      ),
                      // Strikethrough line for out of stock options
                      if (!isAvailable)
                        Positioned.fill(
                          child: CustomPaint(
                            painter: _StrikethroughPainter(),
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
    );
  }
}

// Draws a diagonal line through out-of-stock option chips
class _StrikethroughPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawLine(
      Offset(0, size.height),
      Offset(size.width, 0),
      Paint()
        ..color = AppColors.textHint
        ..strokeWidth = 1,
    );
  }

  @override
  bool shouldRepaint(_) => false;
}