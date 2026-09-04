import 'package:demo_project/features_buyer/shop/screens/buyer_route/widgets/location_box.dart';
import 'package:demo_project/utils/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class TDummyLocations extends StatelessWidget {
  const TDummyLocations({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TLocationBox(icon: Iconsax.clock, text: 'IGS Innovative Global Solutions', subText: 'off Adekokunbo Ademola Crescent, Wuse 2, Abuja, Nigeria'),
        SizedBox(height: TSizes.sm,),
        TLocationBox(icon: Iconsax.clock, text: 'Abuja Nmandi Azikwe Airport(ABV)', subText: 'Domestic Flight Terminal D'),
        SizedBox(height: TSizes.sm,),
        TLocationBox(
          icon: Iconsax.clock,
          text: 'Abuja-Keffi Expressway',
          subText: 'Abuja',
        ),
        SizedBox(height: TSizes.sm,),
        TLocationBox(
          icon: Iconsax.bag_2,
          text: 'Banex Plaza',
          subText: '741 Aminu Kano Crescent, Abuja',
        ),
        SizedBox(height: TSizes.sm,),
        TLocationBox(
          icon: Iconsax.bus,
          text: 'Aya Bus Stop',
          subText: 'Abuja',
        ),
        SizedBox(height: TSizes.sm,),
        TLocationBox(
          icon: Iconsax.bag_2,
          text: 'Wuse Market',
          subText: '14 Kashim Ibrahim Street, Abuja',
        ),
        SizedBox(height: TSizes.sm,),
        TLocationBox(
          icon: Iconsax.location,
          text: 'Transcorp Hilton Abuja',
          subText: '1 Aguiyi Ironsi Street, Abuja',
        ),
        SizedBox(height: TSizes.sm,),
        TLocationBox(
          icon: Iconsax.bus,
          text: 'Jabi Motor Park',
          subText: '92 Bimbo Akintola Way, Abuja',
        ),
        SizedBox(height: TSizes.sm,),
        TLocationBox(
          icon: Iconsax.reserve,
          text: 'Farm City Abuja',
          subText: 'Kashim Ibrahim Way, Abuja',
        ),
        SizedBox(height: TSizes.sm,),
        TLocationBox(
          icon: Iconsax.location,
          text: 'Nyanya bus station',
          subText: 'Abuja',),
          SizedBox(height: TSizes.sm,),
          
      ],
    );
  }
}