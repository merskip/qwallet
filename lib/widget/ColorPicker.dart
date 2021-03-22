import 'package:flutter/material.dart';

class ColorPicker extends StatelessWidget {
  final List<MaterialColor> colors;
  final MaterialColor selectedColor;
  final Function(MaterialColor) onChangeColor;

  const ColorPicker({
    Key? key,
    required this.colors,
    required this.selectedColor,
    required this.onChangeColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: [
        ...colors.map(
          (color) => _CircleColorButton(
            color: color,
            isSelected: color == selectedColor,
            onPressed: () => onChangeColor(color),
          ),
        )
      ],
    );
  }
}

class _CircleColorButton extends StatelessWidget {
  final Color color;
  final bool isSelected;
  final VoidCallback onPressed;

  const _CircleColorButton({
    Key? key,
    required this.color,
    required this.isSelected,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final brightness = ThemeData.estimateBrightnessForColor(color);
    final iconColor =
        brightness == Brightness.light ? Colors.black : Colors.white;

    return RawMaterialButton(
      elevation: 4,
      constraints: BoxConstraints(),
      shape: const CircleBorder(),
      fillColor: color,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      child: SizedBox(
        width: 44,
        height: 44,
        child: isSelected ? Icon(Icons.check, color: iconColor) : null,
      ),
      onPressed: onPressed,
    );
  }
}
