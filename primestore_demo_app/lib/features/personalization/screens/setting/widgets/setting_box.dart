import 'package:demo_project/utils/constants/colors.dart';
import 'package:demo_project/utils/constants/sizes.dart';
import 'package:demo_project/utils/helpers/helper_functions.dart';
import 'package:flutter/material.dart';

class TSettingBox extends StatelessWidget {
  const TSettingBox({
    super.key,
    required this.icon,
    required this.text,
    this.subText,
    this.showSubText = true,
    this.onTap,
    this.trailingIcon = Icons.chevron_right,
  });

  final IconData icon;
  final String text;
  final String? subText;
  final bool showSubText;
  final VoidCallback? onTap;
  final IconData? trailingIcon;

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);
    return Column(
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          onTap: onTap,
          leading: Icon(
            icon,
            size: 25,
            color: dark ? TColors.white : TColors.black,
          ),
          trailing: trailingIcon == null
              ? null
              : Icon(
                  trailingIcon,
                  color: dark ? TColors.white : TColors.darkGrey,
                ),
          title: Text(
            text,
            style: Theme.of(context).textTheme.titleMedium!.apply(
                  fontSizeDelta: 2,
                ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
          subtitle: showSubText && subText != null
              ? Text(
                  subText!,
                  style: Theme.of(context).textTheme.bodySmall,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                )
              : null,
        ),
        
      ],
    );
  }
}
