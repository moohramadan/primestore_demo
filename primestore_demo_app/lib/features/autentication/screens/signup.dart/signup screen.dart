import 'package:demo_project/common/widgets/textfield/textfield_rounded.dart';
import 'package:demo_project/common/widgets/texts/t_create_account_question.dart';
import 'package:demo_project/common/widgets/texts/t_headline.dart';
import 'package:demo_project/features/autentication/controllers/signup_controller.dart';
import 'package:demo_project/features/autentication/screens/login/login%20screen.dart';
import 'package:demo_project/utils/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class SignupScreen extends StatelessWidget {
  SignupScreen({super.key});

  final ValueNotifier<bool> _agreedToTerms = ValueNotifier(false);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SignupController());
    final dark = Theme.of(context).brightness == Brightness.dark;
    final secondaryTextColor = dark
        ? Colors.white.withValues(alpha: 0.6)
        : const Color(0xFF5E6784);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 36),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              THeadline(title: 'Create account', fontsize: TSizes.lg),
              const SizedBox(height: 8),
              Text(
                'Sign up to get started with your account.',
                style: TextStyle(color: secondaryTextColor),
              ),
              const SizedBox(height: 28),
              TTextFieldRounded(
                controller: controller.nameController,
                borderRadius: TSizes.md,
                
                hintText: 'Your full name',
                icon: Icons.person_outline_rounded,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 14),
              TTextFieldRounded(
                controller: controller.emailController,
                borderRadius: TSizes.md,
                
                hintText: 'you@example.com',
                icon: Icons.mail_outline_rounded,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 14),
              TTextFieldRounded(
                controller: controller.phoneController,
                borderRadius: TSizes.md,
                
                hintText: '+234 803 756 6796',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 14),
              TTextFieldRounded(
                controller: controller.passwordController,
                borderRadius: TSizes.md,
                
                hintText: '••••••••',
                icon: Icons.lock_outline_rounded,
                obscureText: true,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 14),
              TTextFieldRounded(
                controller: controller.confirmPasswordController,
                borderRadius: TSizes.md,
                
                hintText: 'Confirm password',
                icon: Icons.check_circle_outline_rounded,
                obscureText: true,
                textInputAction: TextInputAction.done,
              ),
              const SizedBox(height: 16),
              ValueListenableBuilder<bool>(
                valueListenable: _agreedToTerms,
                builder: (context, agreed, _) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: Checkbox(
                          value: agreed,
                          onChanged: (value) {
                            _agreedToTerms.value = value ?? false;
                          },
                          activeColor: const Color(0xFF2F6BFF),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            style: TextStyle(
                              fontSize: 12,
                              height: 1.5,
                              color: secondaryTextColor,
                            ),
                            children: [
                              const TextSpan(text: 'I agree to the '),
                              const TextSpan(
                                text: 'Terms of Service',
                                style: TextStyle(
                                  color: Color(0xFF2F6BFF),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const TextSpan(text: ' and '),
                              const TextSpan(
                                text: 'Privacy Policy',
                                style: TextStyle(
                                  color: Color(0xFF2F6BFF),
                                  fontWeight: FontWeight.w600,
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
              const SizedBox(height: 22),
              Obx(
                () => SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: controller.isLoading.value
                        ? null
                        : controller.signUp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2F6BFF),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: controller.isLoading.value
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Create account',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(width: 9),
                              Icon(Iconsax.verify, size: 20),
                            ],
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: TQuestionTextButton(
                  question: 'Already have an account?',
                  answer: ' Sign in',
                  onTap: () => Get.to(() => const LoginScreen()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
