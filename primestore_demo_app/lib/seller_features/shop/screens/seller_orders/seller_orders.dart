import 'package:demo_project/common/widgets/boxes/search_box.dart';
import 'package:demo_project/common/widgets/custom_shapes/containers/indicator_container.dart';
import 'package:demo_project/common/widgets/custom_shapes/containers/rounded_container.dart';
import 'package:demo_project/common/widgets/texts/rounded_text.dart';
import 'package:demo_project/common/widgets/texts/section_heading.dart';
import 'package:demo_project/utils/constants/colors.dart';
import 'package:demo_project/utils/constants/sizes.dart';
import 'package:demo_project/utils/helpers/helper_functions.dart';
import 'package:flutter/material.dart';

class SellerOrdersScreen extends StatelessWidget {
  const SellerOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);

    final sections = [
      _OrderSection(
        title: 'Today',
        orders: [
          _OrderItem(name: 'Amelia Hart', orderNumber: '#1048 • 23:42 • Online', amount: 320.00, status: TIndicatorStatus.unfilled, color: const Color(0xFFD9D1C7)),
          _OrderItem(name: 'Henri Dubois', orderNumber: '#1047 • 23:09 • Online', amount: 765.00, status: TIndicatorStatus.unfilled, color: const Color(0xFF2F3F4E)),
          _OrderItem(name: 'Maya Chen', orderNumber: '#1046 • 21:56 • Instagram', amount: 415.00, status: TIndicatorStatus.unfilled, color: const Color(0xFF4A4A4A)),
          _OrderItem(name: 'Aiko Tanaka', orderNumber: '#1045 • 19:56 • Online', amount: 410.00, status: TIndicatorStatus.filled, color: const Color(0xFF8E684E)),
          _OrderItem(name: 'Jonas Berg', orderNumber: '#1044 • 17:56 • Online', amount: 440.00, status: TIndicatorStatus.filled, color: const Color(0xFFDCD7CF)),
          _OrderItem(name: 'Sofia Alvarez', orderNumber: '#1043 • 14:56 • POS', amount: 380.00, status: TIndicatorStatus.filled, color: const Color(0xFF2C3946)),
        ],
      ),
      _OrderSection(
        title: 'Yesterday',
        orders: [
          _OrderItem(name: 'Noah Klein', orderNumber: '#1042 • Yesterday • Online', amount: 430.00, status: TIndicatorStatus.unfilled, color: const Color(0xFF2F2F30)),
          _OrderItem(name: 'Luca Moretti', orderNumber: '#1041 • Yesterday • Online', amount: 290.00, status: TIndicatorStatus.filled, color: const Color(0xFF9CA3A5)),
        ],
      ),
      _OrderSection(
        title: 'Thursday 17 Sep',
        orders: [
          _OrderItem(name: 'Ines Costa', orderNumber: '#1040 • 17 Sep • Online', amount: 160.00, status: TIndicatorStatus.filled, color: const Color(0xFFB8C2AE)),
          _OrderItem(name: 'Eva Lindgren', orderNumber: '#1039 • 17 Sep • Instagram', amount: 280.00, status: TIndicatorStatus.filled, color: const Color(0xFFD5C5AF)),
        ],
      ),
      _OrderSection(
        title: 'Wednesday 16 Sep',
        orders: [
          _OrderItem(name: 'Henri Dubois', orderNumber: '#1038 • 16 Sep • Online', amount: 480.00, status: TIndicatorStatus.filled, color: const Color(0xFF2D2D30)),
        ],
      ),
      _OrderSection(
        title: 'Tuesday 15 Sep',
        orders: [
          _OrderItem(name: 'Amelia Hart', orderNumber: '#1037 • 15 Sep • Online', amount: 620.00, status: TIndicatorStatus.cancelled, color: const Color(0xFF374754)),
        ],
      ),
    ];

    return Scaffold(
     
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: TSizes.defaultSpace),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Atelier North',
                        style: Theme.of(context).textTheme.headlineSmall!.apply(fontWeightDelta: 2),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Seller • Vela Plus',
                        style: Theme.of(context).textTheme.bodyMedium!.apply(),
                      ),
                    ],
                  ),
                  Container(
                    width: 54,
                    height: 54,
                    decoration: const BoxDecoration(
                      color: TColors.black,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        'AN',
                        style: Theme.of(context).textTheme.titleLarge!.apply(color: TColors.white),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              TSectionHeading(
                title: 'Orders',
                showActionButton: false,
                fontsize: 2,
                fontWeightDelta: 3,
              ),
              const SizedBox(height: 8),
              Text(
                '14 in the last week',
                style: Theme.of(context).textTheme.titleMedium!.apply(),
              ),
              const SizedBox(height: 22),
              TSearchBox(),
              const SizedBox(height: 18),
              Row(
    children: [
      TRoundedText(text: 'All', darkBackgroundColor: TColors.dark,),
      SizedBox(width: TSizes.sm, ),
      TRoundedText(text: 'Filled', backgroundColor: TColors.grey, darkBackgroundColor: TColors.darkerGrey, lightTextColor: TColors.black,),
      SizedBox(width: TSizes.sm,),
      TRoundedText(text: 'Unfilled', backgroundColor: TColors.grey, darkBackgroundColor: TColors.darkerGrey, lightTextColor: TColors.black,),
    ],
    ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: sections.map((section) => _SectionCard(section: section)).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.section});

  final _OrderSection section;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(
              section.title,
              style: Theme.of(context).textTheme.headlineSmall!.apply(fontSizeDelta: -2, fontWeightDelta: 1),
            ),
          ),
          TRoundedContainer(
            width: double.infinity,
            backgroundColor: darkModeColor(context),
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              children: section.orders
                  .map((order) => _OrderRow(order: order))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Color darkModeColor(BuildContext context) {
    return THelperFunctions.isDarkMode(context) ? TColors.darkerGrey : TColors.grey;
  }
}

class _OrderRow extends StatelessWidget {
  const _OrderRow({required this.order});

  final _OrderItem order;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: order.color,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order.name,
                  style: Theme.of(context).textTheme.titleLarge!.apply(fontWeightDelta: 1),
                ),
                const SizedBox(height: 2),
                Text(
                  order.orderNumber,
                  style: Theme.of(context).textTheme.bodyMedium!.apply(color: Colors.black54),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\$${order.amount.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.titleLarge!.apply(fontWeightDelta: 1),
              ),
              const SizedBox(height: 8),
              TIndicator(
                status: order.status,
                width: 70,
                height: 28,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OrderSection {
  const _OrderSection({required this.title, required this.orders});

  final String title;
  final List<_OrderItem> orders;
}

class _OrderItem {
  const _OrderItem({
    required this.name,
    required this.orderNumber,
    required this.amount,
    required this.status,
    required this.color,
  });

  final String name;
  final String orderNumber;
  final double amount;
  final TIndicatorStatus status;
  final Color color;
}
