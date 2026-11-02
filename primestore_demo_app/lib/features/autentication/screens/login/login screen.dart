import 'package:demo_project/common/widgets/textfield/textfield_rounded.dart';
import 'package:demo_project/data/repositories/auth_repository.dart';
import 'package:demo_project/data/services/google_auth_service.dart';
import 'package:demo_project/features/autentication/controllers/login_controller.dart';
import 'package:demo_project/features/autentication/controllers/user_controller.dart';
import 'package:demo_project/features/autentication/screens/signup.dart/signup%20screen.dart';
import 'package:demo_project/navigation/navigation%20menu.dart';
import 'package:demo_project/utils/constants/colors.dart';
import 'package:demo_project/utils/helpers/helper_functions.dart';
import 'package:demo_project/utils/local_storage/secure_storage_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  static const _backgroundImage = 'assets/images/IMG_1656.JPG';
  static const _blue = Color(0xFF1769E8);

  @override
  Widget build(BuildContext context) {
    Get.put(LoginController());
    final controller = Get.find<LoginController>();
    final formKey = GlobalKey<FormState>();
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;

    return Scaffold(
      backgroundColor: _blue,
      resizeToAvoidBottomInset: false,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            _backgroundImage,
            fit: BoxFit.cover,
            alignment: Alignment.topCenter,
          ),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.center,
                colors: [Color(0x55000000), Colors.transparent],
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(top: 22),
                child: Text(
                  '',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Colors.white,
                    letterSpacing: 3,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: _LoginSheet(
              controller: controller,
              bottomInset: bottomInset,
              onGoogleTap: () => _signInWithGoogle(context),
              formKey: formKey,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _signInWithGoogle(BuildContext context) async {
    try {
      final idToken = await GoogleAuthService().signIn();
      if (idToken == null) return;
      final result = await AuthController().googleSignIn(idToken);
      Get.find<UserController>().setSession(result.user, result.accessToken);
      await SecureStorageService.saveTokens(
        accessToken: result.accessToken,
        refreshToken: result.refreshToken,
      );
      Get.offAll(() => NavigationMenu());
    } catch (error) {
      Get.snackbar('Sign-in failed', _cleanError(error));
    }
  }

  String _cleanError(Object error) =>
      error.toString().replaceFirst('Exception: ', '');
}

class _LoginSheet extends StatelessWidget {
  const _LoginSheet({
    required this.controller,
    required this.bottomInset,
    required this.onGoogleTap,
    required this.formKey,
  });

  final LoginController controller;
  final double bottomInset;
  final VoidCallback onGoogleTap;
  final GlobalKey<FormState> formKey;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenHeight = MediaQuery.sizeOf(context).height;
    final dark = THelperFunctions.isDarkMode(context);

    return Container(
      constraints: BoxConstraints(
        maxHeight: screenHeight * 0.62,
        minHeight: 390,
      ),
      width: double.infinity,
      decoration: BoxDecoration(
        color: dark ? TColors.black : TColors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(34)),
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(24, 26, 24, 18 + bottomInset),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE1E5EC),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 22),
              Text(
                'Welcome back',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                'Sign in and pick up where you left off.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF8A93A5),
                ),
              ),
              const SizedBox(height: 20),
              TTextFieldRounded(
                controller: controller.emailController,
                hintText: 'Email or phone',
                icon: Icons.mail_outline_rounded,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                validator: _validateEmail,
              ),
              const SizedBox(height: 12),
              TTextFieldRounded(
                controller: controller.passwordController,
                hintText: 'Password',
                icon: Icons.lock_outline_rounded,
                obscureText: true,
                textInputAction: TextInputAction.done,
                validator: _validatePassword,
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    foregroundColor: Color.fromARGB(255, 151, 12, 2),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  child: Text(
                    'Forgot password?',
                    style: theme.textTheme.titleMedium?.apply(
                      color: const Color(0xFFEA6A37),
                      fontSizeDelta: -2,
                      fontWeightDelta: 25,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 2),
              Obx(
                () => SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: controller.isLoading.value
                        ? null
                        : () {
                            if (formKey.currentState?.validate() ?? false) {
                              FocusManager.instance.primaryFocus?.unfocus();
                              controller.login();
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: TColors.primary,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: const Color(0xFFF2A98D),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                      elevation: 0,
                    ),
                    child: controller.isLoading.value
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            'Log in',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  const Expanded(child: Divider(color: Color(0xFFE7E9EE))),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      'or continue with',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: const Color(0xFFA0A7B5),
                      ),
                    ),
                  ),
                  const Expanded(child: Divider(color: Color(0xFFE7E9EE))),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _SocialButton(
                      icon: Icons.g_mobiledata_rounded,
                      label: 'Google',
                      onTap: onGoogleTap,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _SocialButton(
                      icon: Icons.apple_rounded,
                      label: 'Apple',
                      onTap: () {},
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Center(
                child: Wrap(
                  children: [
                    Text(
                      "Don't have an account? ",
                      style: theme.textTheme.bodySmall?.copyWith(),
                    ),
                    GestureDetector(
                      onTap: () => Get.to(() => SignupScreen()),
                      child: Text(
                        'Sign up',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return 'Enter your email address.';
    final emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailPattern.hasMatch(email)) return 'Enter a valid email address.';
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Enter your password.';
    if (value.length < 6) return 'Password must be at least 6 characters.';
    return null;
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);
    final theme = Theme.of(context);
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, color: dark ? TColors.white : TColors.dark, size: 22),
      label: Text(
        label,
        style: theme.textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(44),
        side: const BorderSide(color: Color(0xFFE2E5EB)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
      ),
    );
  }
}
