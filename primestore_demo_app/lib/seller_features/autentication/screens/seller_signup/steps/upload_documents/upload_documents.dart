import 'package:demo_project/common/widgets/buttons/elevevated_button.dart';
import 'package:demo_project/common/widgets/texts/t_headline.dart';
import 'package:demo_project/common/widgets/texts/t_subtitle.dart';
import 'package:demo_project/navigation/seller_nav.dart';
import 'package:demo_project/seller_features/autentication/screens/seller_signup/steps/upload_documents/controllers/upload_documents_controller.dart';
import 'package:demo_project/seller_features/autentication/screens/seller_signup/steps/upload_documents/widgets/upload_image.dart';
import 'package:demo_project/utils/constants/colors.dart';
import 'package:demo_project/utils/constants/sizes.dart';
import 'package:demo_project/utils/helpers/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UploadVerificationDocuments extends StatelessWidget {
  const UploadVerificationDocuments({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(UploadDocumentsController());
    final dark = THelperFunctions.isDarkMode(context);
    return Scaffold(
      backgroundColor: dark ? TColors.dark : TColors.white,
      appBar: AppBar(
        automaticallyImplyLeading: true,
        iconTheme: IconThemeData(color: dark ? TColors.white : TColors.black),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: TSizes.defaultSpace),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const THeadline(title: 'Upload your ID'),
              const SizedBox(height: TSizes.sm),
              const TSubtitle(
                title:
                    'Take a clear photo of your government-issued ID. Make sure all details are visible and in focus.',
              ),
              const SizedBox(height: TSizes.spaceBtwSections),
              UploadImage(controller: controller),
              const Spacer(),
              TRoundedElevatedButton(onPressed: () => Get.to(() => SellerNavigationMenu()), text: "Skip"),
              const SizedBox(height: TSizes.sm),
              Obx(
                () => TRoundedElevatedButton(
                  onPressed: controller.selectedImage.value == null
                      ? null
                      : () => ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Document upload is not connected yet.',
                            ),
                          ),
                        ),
                  text: 'Continue',
                  
                ),
              ),

              const SizedBox(height: TSizes.spaceBtwItems),
            ],
          ),
        ),
      ),
    );
  }
}
