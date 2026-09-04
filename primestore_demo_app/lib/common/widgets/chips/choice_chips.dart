
import 'package:demo_project/common/widgets/custom_shapes/containers/circular_container.dart';
import 'package:demo_project/utils/constants/colors.dart';
import 'package:demo_project/utils/helpers/helper_functions.dart';
import 'package:flutter/material.dart';

/// -- Most of the Styling is already defined in the Utils -> Themes -> ChipTheme.dart
class  TChoiceChip extends StatelessWidget {
  const TChoiceChip({
    super.key,
    required this.text,
    required this.selected,
    this.onSelected,
  });

  final String text;
  final bool selected;
  final void Function(bool)? onSelected;

  @override
  Widget build(BuildContext context) {
    final isColor = THelperFunctions.getColor(text) != null;

    return ChoiceChip(
      label: isColor ? const SizedBox() :  Text(text),
      selected: selected,
      onSelected: onSelected,
      labelStyle: TextStyle(
        color: selected ? TColors.white : null,
      ),
      avatar: isColor
          ? TCircularContainer(
              width: 50,
              height: 50,
              backgroundColor: THelperFunctions.getColor(text)!,
            )
          : null,
      labelPadding: isColor
          ? const EdgeInsets.all(0)
          : null,

      // Make icon in the center
      padding: isColor
          ? const EdgeInsets.all(0)
          : null,

      shape: isColor
          ? const CircleBorder()
          : null,

      backgroundColor: isColor
          ? THelperFunctions.getColor(text)!
          : null,

    selectedColor: isColor ? THelperFunctions.getColor(text)! : null,
    );
  }
}