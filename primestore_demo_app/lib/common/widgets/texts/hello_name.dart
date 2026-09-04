import 'package:demo_project/utils/constants/colors.dart';
import 'package:flutter/material.dart';

class THelloName extends StatelessWidget {
  const THelloName({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Text.rich(
    TextSpan(
    text: 'Hello,',
    style: Theme.of(context).textTheme.headlineMedium,
    children: [
    TextSpan(
    text: 'Muhammad',
    style: Theme.of(context).textTheme.headlineMedium!.apply(color: TColors.primary)
     ),
      ],
     ),
    );
  }
}