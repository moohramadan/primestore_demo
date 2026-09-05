// reuses Blob and GlassTextField from here

import 'package:demo_project/common/widgets/glass_morphism/glass_morphism_container.dart';
import 'package:demo_project/common/widgets/texts/t_create_account_question.dart';
import 'package:demo_project/features/autentication/controllers/signup_controller.dart';
import 'package:demo_project/features/autentication/screens/login/login%20screen.dart';
import 'package:demo_project/features/autentication/screens/login/widgets/blob.dart';
import 'package:demo_project/features/autentication/screens/login/widgets/glass_text_fied.dart';
import 'package:demo_project/utils/constants/colors.dart';
import 'package:demo_project/utils/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:iconsax/iconsax.dart';

class SignupScreen extends StatelessWidget {
  SignupScreen({super.key});

  // Same pattern as LoginScreen: keep the widget stateless, drive the
  // checkbox's on/off visual with a ValueNotifier + ValueListenableBuilder.
  final ValueNotifier<bool> _agreedToTerms = ValueNotifier(false);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SignupController());
    final dark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            color: dark ? const Color(0xFF0B0F1A) : const Color(0xFFEEF1F7),
          ),

          Positioned(
            top: -50,
            right: -60,
            child: Blob(
              size: 230,
              color: dark ?  TColors.primary:  TColors.primary,
              opacity: dark ? 0.5 : 0.55,
            ),
          ),
          Positioned(
            bottom: -30,
            left: -60,
            child: Blob(
              size: 220,
              color: dark ?  TColors.primary:  TColors.primary,
              opacity: dark ? 0.4 : 0.5,
            ),
          ),
          Positioned(
            top: 420,
            left: 60,
            child: Blob(
              size: 150,
              color: dark ?  TColors.secondary:  TColors.secondary,
              opacity: dark ? 0.22 : 0.4,
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 36),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    
                    child: Column(
                      children: [
                        TGlassMorphism(
                          borderRadius: 15,
                          height: 80,
                          width: 80,
                          child: Icon(Iconsax.personalcard, size: 40,)
                          ),
                          SizedBox(height: TSizes.sm,),
                          TGlassMorphism(borderRadius: 10,  child: Text('Create your account', style: Theme.of(context).textTheme.headlineLarge!.apply(color: TColors.primary),)),
                      ],
                    ),
                      
                  ),
                  
                  
                   
                   
                  const SizedBox(height: TSizes.spaceBtwSections),

                  TGlassMorphism(
                    padding: const EdgeInsets.all(20),
                    borderRadius: 26,
                    child: Form(
                      child: Column(
                        children: [
                          GlassTextField(
                        dark: dark,
                        label: 'Full name',
                        hint: 'Fullname',
                        icon: Icons.person_outline_rounded,
                        controller: controller.nameController,
                      ),
                      const SizedBox(height: 12),
                      GlassTextField(
                        dark: dark,
                        label: 'Email address',
                        hint: 'you@example.com',
                        icon: Icons.mail_outline_rounded,
                        controller: controller.emailController,
                      ),
                      const SizedBox(height: 12),
                      GlassTextField(
                        dark: dark,
                        label: 'Phone number',
                        hint: '+234 8037566796',
                        icon: Icons.phone,
                        controller: controller.phoneController,
                        // obscure removed — this was the bug, phone shouldn't be hidden
                      ),
                      const SizedBox(height: 12),
                      GlassTextField(
                        dark: dark,
                        label: 'Password',
                        hint: '••••••••',
                        icon: Icons.lock_outline_rounded,
                        obscure: true,
                        controller: controller.passwordController,
                      ),
                      const SizedBox(height: 12),
                      GlassTextField(
                        dark: dark,
                        label: 'Confirm password',
                        hint: '••••••••',
                        icon: Icons.check_circle_outline_rounded,
                        obscure: true,
                        controller: controller.confirmPasswordController,
                      ),
                      
                          const SizedBox(height: 16),
                      
                          // Only the checkbox + its border/fill rebuild on tap.
                          ValueListenableBuilder<bool>(
                            valueListenable: _agreedToTerms,
                            builder: (context, agreed, _) {
                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  GestureDetector(
                                    onTap: () => _agreedToTerms.value = !agreed,
                                    child: Container(
                                      width: 17,
                                      height: 17,
                                      margin: const EdgeInsets.only(top: 1),
                                      decoration: BoxDecoration(
                                        color: agreed
                                            ? const Color(0xFF2F6BFF)
                                            : (dark
                                                ? Colors.white.withValues(alpha: 0.08)
                                                : Colors.white.withValues(alpha: 0.6)),
                                        borderRadius: BorderRadius.circular(5),
                                        border: Border.all(
                                          color: agreed
                                              ? const Color(0xFF2F6BFF)
                                              : (dark
                                                  ? Colors.white.withValues(alpha: 0.3)
                                                  : const Color(0xFF9CA3BB)),
                                        ),
                                      ),
                                      child: agreed
                                          ? const Icon(Icons.check, size: 11, color: Colors.white)
                                          : null,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: RichText(
                                      text: TextSpan(
                                        style: TextStyle(
                                          fontSize: 11.5,
                                          height: 1.5,
                                          color: dark
                                              ? Colors.white.withValues(alpha: 0.55)
                                              : const Color(0xFF5E6784),
                                        ),
                                        children: [
                                          const TextSpan(text: 'I agree to the '),
                                          TextSpan(
                                            text: 'Terms of Service',
                                            style: TextStyle(
                                              color: dark
                                                  ? const Color(0xFF85B7EB)
                                                  : const Color(0xFF2F6BFF),
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          const TextSpan(text: ' and '),
                                          TextSpan(
                                            text: 'Privacy Policy',
                                            style: TextStyle(
                                              color: dark
                                                  ? const Color(0xFF85B7EB)
                                                  : const Color(0xFF2F6BFF),
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                      
                          const SizedBox(height: 18),
                         Obx(() => SizedBox(
                        width: double.infinity,
                        height: 60,
                        child: ElevatedButton(
                          onPressed: controller.isLoading.value ? null : controller.signUp,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2F6BFF),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: controller.isLoading.value
                              ? const CircularProgressIndicator(color: Colors.white)
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Create account',
                                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                                    ),
                                    SizedBox(width: 9),
                                    Icon(Iconsax.verify, size: 20),
                                  ],
                                ),
                        ),
                      )),
                      
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(child: TQuestionTextButton(question: 'Already have an account', answer: ' Sign in', onTap: () => Get.to(() =>LoginScreen()))),
                  
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
