import 'package:demo_project/features/personalization/screens/user_profile/widgets/edit_email.dart';
import 'package:demo_project/features/personalization/screens/user_profile/widgets/edit_name.dart';
import 'package:demo_project/features/personalization/controllers/profile_controller.dart';
import 'package:demo_project/utils/constants/colors.dart';
import 'package:demo_project/utils/helpers/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';

class PersonalInfoScreen extends StatelessWidget {
  const PersonalInfoScreen({super.key});

  static const Color accentGreen = Color(0xFF06C167);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProfileController());
    final dark = THelperFunctions.isDarkMode(context);
    return Scaffold(
      
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _TopBar(),
            const Divider(height: 1, thickness: 1, color: Color(0xFFF2F2F2)),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                final user = controller.user.value;
                if (user == null) {
                  return const Center(child: Text('Could not load profile'));
                }

                return ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  children: [
                    const SizedBox(height: 24),
                    const Text(
                      'Personal info',
                      style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 24),
                    _Avatar(),
                    const SizedBox(height: 24),
                    _InfoRow(
                      label: 'Name',
                      value: user.name,
                      onTap: () => Get.to(() => const EditNameScreen()),
                    ),
                    _InfoRow(
                      label: 'User ID',
                      value: user.id.toString(),
                      onTap: null,
                    ),
                    _InfoRow(
                      label: 'Email',
                      value: user.email,
                      verified: true,
                      onTap: () => Get.to(() => const EditEmailScreen()),
                    ),
                    _InfoRow(
                      label: 'Phone number',
                      value: user.phone,
                      verified: true,
                      onTap: () {},
                      isLast: true,
                    ),
                    const SizedBox(height: 24),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.close, size: 26),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          const Expanded(
            child: Text(
              'Account',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);
    return Stack(
      children: [
        CircleAvatar(
          radius: 44,
          backgroundColor: const Color(0xFFEDEDED),
          child: const Icon(Icons.person, size: 48, color: Colors.black38),
        ),
        Positioned(
          left: 60,
          bottom: 0,
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
            ),
            child:  Icon(Icons.edit, size: 16, color: dark? TColors.black: TColors.black,),
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    this.onTap,
    this.verified = false,
    this.isLast = false,
  });

  final String label;
  final String value;
  final VoidCallback? onTap;
  final bool verified;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          border: isLast
              ? null
              : const Border(bottom: BorderSide(color: Color(0xFFF2F2F2))),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Flexible(
                        child: Text(value, style: Theme.of(context).textTheme.titleSmall),
                      ),
                      if (verified) ...[
                        const SizedBox(width: 6),
                        const Icon(Icons.check_circle, size: 16, color: PersonalInfoScreen.accentGreen),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            if (onTap != null) const Icon(Icons.chevron_right, color: Colors.black38),
          ],
        ),
      ),
    );
  }
}
