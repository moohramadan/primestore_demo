import 'package:demo_project/utils/constants/colors.dart';
import 'package:flutter/material.dart';

class TTopProductTile extends StatelessWidget {
	const TTopProductTile({
		super.key,
		required this.number,
		required this.productName,
		this.onTap,
    this.contentPadding,
    this.numberColor = TColors.primary,
	});

	final int number;
	final String productName;
  final EdgeInsetsGeometry? contentPadding;
	final VoidCallback? onTap;
	final Color numberColor;

	@override
	Widget build(BuildContext context) {
		return ListTile(
      contentPadding: contentPadding,
			leading: CircleAvatar(
				radius: 18,
				backgroundColor: numberColor.withValues(alpha: 0.12),
				child: Text(
					'$number',
					style: Theme.of(context).textTheme.titleSmall?.copyWith(
						color: numberColor,
						fontWeight: FontWeight.w700,
					),
				),
			),
			title: Text(
				productName,
				maxLines: 1,
				overflow: TextOverflow.ellipsis,
				style: Theme.of(context).textTheme.titleMedium,
			),
			trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
			onTap: onTap,
		);
	}
}
