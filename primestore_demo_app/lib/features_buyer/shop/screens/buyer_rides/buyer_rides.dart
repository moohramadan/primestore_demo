import 'package:demo_project/features_buyer/shop/screens/buyer_rides/widgets/rides_box.dart';
import 'package:demo_project/features_buyer/shop/screens/buyer_rides/widgets/trip%20history%20card.dart';
import 'package:demo_project/utils/constants/sizes.dart';
import 'package:flutter/material.dart';

class BuyerRidesScreen extends StatelessWidget {
  const BuyerRidesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(TSizes.defaultSpace),
              child: Column(
                children: [
                  Center(
                    child: Text(
                      'Rides',
                      style: Theme.of(context).textTheme.headlineLarge,
                      
                    ),
                  ),
                  SizedBox(height: TSizes.spaceBtwItems *2), 
                  TripHistoryCard(destination: 'mami', dateTime: 'Jul 12, 2023  10:00 AM', price: '\$50.00'),
                  const SizedBox(height: TSizes.spaceBtwItems),
                  TRidesBox(
                    icon: Icons.directions_car,
                    text: 'Ride to Downtown Mall',
                    dateTitle: 'Jul 12, 2023  10:00 AM',
                    priceTitle: '\$50.00',
                    onTap: () {},
                  ),
                  const SizedBox(height: TSizes.spaceBtwItems),
                  TRidesBox(
                    icon: Icons.local_taxi,
                    text: 'Airport Pickup',
                    dateTitle: 'Jul 14, 2023  6:30 AM',
                    priceTitle: '\$75.00',
                    onTap: () {},
                  ),
                  const SizedBox(height: TSizes.spaceBtwItems),
                  TRidesBox(
                    icon: Icons.directions_car,
                    text: 'Ride to Office',
                    dateTitle: 'Jul 15, 2023  8:15 AM',
                    priceTitle: '\$22.00',
                    onTap: () {},
                  ),
                  const SizedBox(height: TSizes.spaceBtwItems),
                  TRidesBox(
                    icon: Icons.electric_car,
                    text: 'Ride to Grand Central Station',
                    dateTitle: 'Jul 18, 2023  4:45 PM',
                    priceTitle: '\$33.50',
                    onTap: () {},
                  ),
                  const SizedBox(height: TSizes.spaceBtwItems),
                  TRidesBox(
                    icon: Icons.directions_car,
                    text: 'Ride Home',
                    dateTitle: 'Jul 20, 2023  9:00 PM',
                    priceTitle: '\$18.75',
                    onTap: () {},
                  ),
                  TRidesBox(
                    icon: Icons.directions_car,
                    text: 'Ride to Office',
                    dateTitle: 'Jul 15, 2023  8:15 AM',
                    priceTitle: '\$22.00',
                    onTap: () {},
                  ),
                  const SizedBox(height: TSizes.spaceBtwItems),
                  TRidesBox(
                    icon: Icons.electric_car,
                    text: 'Ride to Grand Central Station',
                    dateTitle: 'Jul 18, 2023  4:45 PM',
                    priceTitle: '\$33.50',
                    onTap: () {},
                  ),
                  const SizedBox(height: TSizes.spaceBtwItems),
                  TRidesBox(
                    icon: Icons.directions_car,
                    text: 'Ride Home',
                    dateTitle: 'Jul 20, 2023  9:00 PM',
                    priceTitle: '\$18.75',
                    onTap: () {},
                  ),
                ],
              ),
              
            ),
          ],
        ),
      ),
    );
  }
}