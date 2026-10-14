import 'package:demo_project/common/widgets/images/t_rounded_image.dart';
import 'package:demo_project/common/widgets/textfield/textfield_rounded.dart';
import 'package:demo_project/common/widgets/texts/t_create_account_question.dart';
import 'package:demo_project/common/widgets/texts/t_headline.dart';
import 'package:demo_project/data/repositories/auth_repository.dart';
import 'package:demo_project/data/services/google_auth_service.dart';
import 'package:demo_project/features/autentication/controllers/login_controller.dart';
import 'package:demo_project/features/autentication/controllers/user_controller.dart';
import 'package:demo_project/features/autentication/screens/login/widgets/glass_login_slider.dart';
import 'package:demo_project/features/autentication/screens/signup.dart/signup%20screen.dart';
import 'package:demo_project/navigation/navigation%20menu.dart';
import 'package:demo_project/utils/constants/colors.dart';
import 'package:demo_project/utils/constants/image_strings.dart';
import 'package:demo_project/utils/constants/sizes.dart';
import 'package:demo_project/utils/constants/text_strings.dart';
import 'package:demo_project/utils/local_storage/secure_storage_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    Get.put(GlassSlideController());
    Get.put(LoginController());
    //final slideController = Get.find<GlassSlideController>();
    final loginController = Get.find<LoginController>();
    return Scaffold(
      body: Stack(
        children: [
          Container(),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  THeadline(title: 'Login', fontsize: TSizes.lg,),
                  SizedBox(height: TSizes.spaceBtwInputFields),
            
                 // const SizedBox(height: 26),

                  Column(
                    children: [
                      //GlassLoginSlider(),
                      const SizedBox(height: 12),
                          TTextFieldRounded(
                            controller: loginController.emailController,
                            //dark: dark,
                            borderRadius: TSizes.md,
                           // labelText: 'Email address',
                            hintText: 'Email or phone',
                            icon: Icons.mail_outline_rounded,
                          ),
                        
                      const SizedBox(height: 12),
                      TTextFieldRounded(
                        borderRadius: TSizes.md,
                        controller: loginController.passwordController,
                       // labelText: 'Password',
                        hintText: '••••••••',
                        icon: Icons.lock_outline_rounded,
                      ),

                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Row(
                            children: [
                              
                            ],
                          ),

                          TextButton(
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.red,
                            ),
                            onPressed: () {},
                            child: const Text(
                              TTexts.forgetPassword,
                              style: TextStyle(
                                fontSize: TSizes.md - 2,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        height: 60,
                        child: Obx(
                          () => ElevatedButton(
                            onPressed: loginController.isLoading.value
                                ? null
                                : loginController.login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2F6BFF),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: loginController.isLoading.value
                                ? const SizedBox(
                                    height: 22,
                                    width: 22,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: const [
                                      Text(
                                        'Sign',
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
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          Expanded(
                            child: Divider(
                              color: dark
                                  ? Colors.white.withValues(alpha: 0.15)
                                  : const Color(
                                      0xFF5E6784,
                                    ).withValues(alpha: 0.2),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Text(
                              'or continue with',
                              style: TextStyle(
                                fontSize: 11,
                                color: dark
                                    ? Colors.white.withValues(alpha: 0.4)
                                    : const Color(0xFF9CA3BB),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Divider(
                              color: dark
                                  ? Colors.white.withValues(alpha: 0.15)
                                  : const Color(
                                      0xFF5E6784,
                                    ).withValues(alpha: 0.2),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _SocialSignInTile(
                            dark: dark,
                            icon: Icons.g_mobiledata_rounded,
                            label: 'Continue with Google',
                            onTap: () async {
                              try {
                                final googleAuth = GoogleAuthService();
                                final idToken = await googleAuth.signIn();

                                if (idToken == null) return;

                                final authController = AuthController();
                                final result = await authController
                                    .googleSignIn(idToken);

                                Get.find<UserController>().setSession(
                                  result.user,
                                  result.accessToken,
                                );
                                await SecureStorageService.saveTokens(
                                  accessToken: result.accessToken,
                                  refreshToken: result.refreshToken,
                                );

                                Get.snackbar('Success', 'Logged in!');
                                Get.to(() => NavigationMenu());
                              } catch (e) {
                                Get.snackbar('Error', e.toString());
                              }
                            },
                          ),
                          const SizedBox(height: 10),
                          _SocialSignInTile(
                            dark: dark,
                            icon: Icons.apple_rounded,
                            label: 'Continue with Apple',
                          ),
                          const SizedBox(height: 10),
                          _SocialSignInTile(
                            dark: dark,
                            icon: Icons.facebook_rounded,
                            label: 'Continue with Facebook',
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  Center(
                    child: TQuestionTextButton(
                      question: "Don't have an account?",
                      answer: ' Sign Up',
                      onTap: () => Get.to(() => SignupScreen()),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SocialSignInTile extends StatelessWidget {
  const _SocialSignInTile({
    required this.dark,
    required this.icon,
    required this.label,
    this.onTap,
  });

  final bool dark;
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final foregroundColor = dark ? Colors.white : const Color(0xFF1A2033);

    return Container(
      decoration: BoxDecoration(
        color: dark
            ? Colors.white.withValues(alpha: 0.08)
            : const Color(0xFFF5F6FA),
        border: Border.all(
          color: dark
              ? Colors.white.withValues(alpha: 0.15)
              : const Color(0xFF5E6784).withValues(alpha: 0.2),
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: ListTile(
        leading: Icon(icon, color: foregroundColor),
        title: Text(label, style: TextStyle(color: foregroundColor)),
        onTap: onTap,
      ),
    );
  }
}
