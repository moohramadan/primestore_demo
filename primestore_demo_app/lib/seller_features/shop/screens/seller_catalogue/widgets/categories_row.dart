import 'package:demo_project/common/widgets/texts/rounded_text.dart';
import 'package:demo_project/utils/constants/colors.dart';
import 'package:demo_project/utils/constants/sizes.dart';
import 'package:flutter/material.dart';

class TCatalogueCategories extends StatelessWidget {
  const TCatalogueCategories({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
    children: [
      TRoundedText(text: 'All', darkBackgroundColor: TColors.dark,),
      SizedBox(width: TSizes.sm, ),
      TRoundedText(text: 'Active', backgroundColor: TColors.grey, darkBackgroundColor: TColors.darkerGrey, lightTextColor: TColors.black,),
      SizedBox(width: TSizes.sm,),
      TRoundedText(text: 'Draft', backgroundColor: TColors.grey, darkBackgroundColor: TColors.darkerGrey, lightTextColor: TColors.black,),
    ],
    );
  }
}