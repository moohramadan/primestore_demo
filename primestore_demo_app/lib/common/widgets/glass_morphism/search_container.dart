
import 'package:demo_project/common/widgets/glass_morphism/glass_morphism_container.dart';
import 'package:demo_project/utils/constants/colors.dart';
import 'package:flutter/material.dart';

class TGlassSearchContainer extends StatelessWidget {
  const TGlassSearchContainer({
    super.key,
    this.hintText = 'Search',
    this.onChanged,
    this.onTap,
    this.controller,
    this.readOnly = false,
    this.showFilterIcon = false,
    this.onFilterTap,
  });

  final String hintText;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final TextEditingController? controller;
  final bool readOnly;
  final bool showFilterIcon;
  final VoidCallback? onFilterTap;

  @override
  Widget build(BuildContext context) {
    return TGlassMorphism(
      lightcolor: TColors.white,
      borderColorLight: TColors.white,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      borderRadius: 12,
      child: Row(
        children: [
          const Icon(Icons.search, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              onTap: onTap,
              readOnly: readOnly,
              style: const TextStyle(fontSize: 14),
              decoration: InputDecoration(
                hintText: hintText,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
               focusedBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          if (showFilterIcon) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onFilterTap,
              child: const Icon(Icons.tune, size: 20),
            ),
          ],
        ],
      ),
    );
  }
}
