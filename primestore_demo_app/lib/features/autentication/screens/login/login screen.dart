import 'package:demo_project/common/widgets/glass_morphism/glass_morphism_container.dart';
import 'package:demo_project/common/widgets/images/t_rounded_image.dart';
import 'package:demo_project/common/widgets/texts/t_create_account_question.dart';
import 'package:demo_project/data/repositories/auth_repository.dart';
import 'package:demo_project/data/services/google_auth_service.dart';
import 'package:demo_project/features/autentication/controllers/login_controller.dart';
import 'package:demo_project/features/autentication/controllers/user_controller.dart';
import 'package:demo_project/features/autentication/screens/login/widgets/blob.dart';
import 'package:demo_project/features/autentication/screens/login/widgets/glass_login_slider.dart';
import 'package:demo_project/features/autentication/screens/login/widgets/glass_social_buttons.dart';
import 'package:demo_project/features/autentication/screens/login/widgets/glass_text_fied.dart';
import 'package:demo_project/features/autentication/screens/signup.dart/signup%20screen.dart';
import 'package:demo_project/features/shop/screens/navigation%20menu.dart';
import 'package:demo_project/utils/constants/colors.dart';
import 'package:demo_project/utils/constants/image_strings.dart';
import 'package:demo_project/utils/constants/sizes.dart';
import 'package:demo_project/utils/constants/text_strings.dart';
import 'package:demo_project/utils/local_storage/secure_storage_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

// ^ adjust this import path to wherever TGlassMorphism actually lives in your project

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  // A ValueNotifier lets us keep this widget stateless while still driving
  // small, local UI state (here: password obscure/reveal) via
  // ValueListenableBuilder, which rebuilds only the field that needs it.


  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
  Get.put(GlassSlideController());
Get.put(LoginController());
final slideController = Get.find<GlassSlideController>();
final loginController = Get.find<LoginController>();
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
              color: dark ? TColors.secondary : TColors.secondary,
              opacity: dark ? 0.22 : 0.4,
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  TRoundedImage(imageUrl: TImages.brandImage3, height: 100, width: 100,),
                 SizedBox(height: TSizes.spaceBtwInputFields,),
                  Row(
                    children: [
                      const SizedBox(width: 110),
                      TGlassMorphism(borderRadius: 10,  child: Text('Sign In', style: Theme.of(context).textTheme.headlineLarge!.apply(color: TColors.primary),)),
                      const SizedBox(width: 4),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const SizedBox(height: 26),

                  TGlassMorphism(
                    
                    padding: const EdgeInsets.all(20),
                    borderRadius: 26,
                    child: Column(
                      children: [
                        GlassLoginSlider(),
                        const SizedBox(height: 12),
                        
                       Obx(() {
  if (slideController.isEmail.value) {
    return GlassTextField(
      controller: loginController.emailController,
      dark: dark,
      label: 'Email address',
      hint: 'you@example.com',
      icon: Icons.mail_outline_rounded,
    );
  } else {
    return GlassTextField(
      controller: loginController.phoneController,
      dark: dark,
      label: 'Phone Number',
      hint: '+234 806666666666',
      icon: Icons.phone,
    );
  }
}),
                        const SizedBox(height: 12),
                        GlassTextField(
      controller: loginController.passwordController,
      dark: dark,
      label: 'Password',
      hint: '••••••••',
      icon: Icons.lock_outline_rounded,
    ),
                       
                          

                        const SizedBox(height: 4),
                        Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                       children: [
                         Row(
                        children: [
                          Checkbox(
                        value: true,
                        checkColor: TColors.white,
                        onChanged: null,
                        ),
                        const Text(TTexts.rememberMe),
                        ],
                        ),
    
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.red
                  
                ),
                onPressed: (){},
                child: const Text(TTexts.forgetPassword, style: TextStyle(fontSize: TSizes.md -2, fontWeight: FontWeight.w800),),
              ),
            ],
          ),
                        const SizedBox(height: 8),
                        SizedBox(
  width: double.infinity,
  height: 60,
  child: Obx(() => ElevatedButton(
    onPressed: loginController.isLoading.value ? null : loginController.login,
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF2F6BFF),
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 15),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
    ),
    child: loginController.isLoading.value
        ? const SizedBox(
            height: 22, width: 22,
            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Text('Sign', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
              SizedBox(width: 9),
              Icon(Iconsax.verify, size: 20),
            ],
          ),
  )),
),
                        const SizedBox(height: 18),
                        Row(
                          children: [
                            Expanded(
                              child: Divider(
                                color: dark
                                    ? Colors.white.withValues(alpha: 0.15)
                                    : const Color(0xFF5E6784).withValues(alpha: 0.2),
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
                                    : const Color(0xFF5E6784).withValues(alpha: 0.2),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
  onTap: () async {
    try {
      final googleAuth = GoogleAuthService();
      final idToken = await googleAuth.signIn();

      if (idToken == null) return; // user cancelled

      final authController = AuthController();
      final result = await authController.googleSignIn(idToken);

      Get.find<UserController>().setSession(result.user, result.accessToken);
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
  child: SocialGlassButton(
    dark: dark,
    icon: Icons.g_mobiledata_rounded,
  ),
)
,
                            ),
                            const SizedBox(width: 10),
                            Expanded(child: SocialGlassButton(dark: dark, icon: Icons.apple_rounded)),
                            const SizedBox(width: 10),
                            Expanded(child: SocialGlassButton(dark: dark, icon: Icons.facebook_rounded)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                   TQuestionTextButton(question: "Don't have an account?", answer: ' Sign Up', onTap: () => Get.to(() => SignupScreen()),)
                   
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Soft blurred circle used behind the glass card to create the glow.




