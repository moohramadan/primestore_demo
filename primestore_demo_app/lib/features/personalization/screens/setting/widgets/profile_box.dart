import 'package:demo_project/common/widgets/glass_morphism/glass_morphism_container.dart';
import 'package:demo_project/utils/constants/colors.dart';
import 'package:demo_project/utils/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

/// Profile header card — same footprint/role as the green header in the
/// reference design, but built with TGlassMorphism instead of a solid
/// color fill, so it stays consistent with the rest of the app's UI.
class TProfileHeader extends StatelessWidget {
  const TProfileHeader({
    super.key,
    required this.name,
    required this.username,
    this.avatarUrl,
    this.onEditProfile,
  });

  final String name;
  final String username;
  final String? avatarUrl;
  final VoidCallback? onEditProfile;

  @override
  Widget build(BuildContext context) {
    return Container(
      
      // NOTE: adjust these named params to whatever your
      // TGlassMorphism constructor actually exposes (padding,
      // borderRadius, blur, opacity, etc.) — kept generic here.
      padding: const EdgeInsets.all(TSizes.md),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar + Name + Username
          Row(
            children: [
              CircleAvatar(
                radius: 32,
                backgroundColor: TColors.primary.withValues(alpha:  0.15),
                backgroundImage:
                    avatarUrl != null ? NetworkImage(avatarUrl!) : null,
                child: avatarUrl == null
                    ? const Icon(Iconsax.user, color: TColors.primary)
                    : null,
              ),
              const SizedBox(width: TSizes.spaceBtwItems),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: Theme.of(context).textTheme.headlineSmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '@$username',
                      style: Theme.of(context).textTheme.bodySmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: TSizes.spaceBtwItems),

          // Edit Profile button — a slimmer glass pill instead of the
          // reference's solid button, so it reads as "inside" the card
          // rather than a separate block.
          SizedBox(
            width: double.infinity,
            child: TGlassMorphism(
              padding: const EdgeInsets.symmetric(vertical: TSizes.sm),
              borderRadius: TSizes.lg,
              child: InkWell(
                onTap: onEditProfile,
                borderRadius: BorderRadius.circular(TSizes.cardRadiusLg),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Iconsax.edit_2, size: 16, color: TColors.primary),
                    SizedBox(width: TSizes.sm),
                    Text('Edit Profile'),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}