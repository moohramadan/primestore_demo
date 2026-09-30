import 'package:demo_project/utils/constants/colors.dart';
import 'package:flutter/material.dart';

enum TIndicatorStatus { active, draft, notActive, filled, unfilled, cancelled }

class TIndicator extends StatelessWidget {
  const TIndicator({
    super.key,
    this.status = TIndicatorStatus.draft,
    this.width = 70,
    this.height = 25,
  });

  final TIndicatorStatus status;
  final double width;
  final double height;

  String get _label {
    switch (status) {
      case TIndicatorStatus.active:
        return 'Active';
      case TIndicatorStatus.draft:
        return 'Draft';
      case TIndicatorStatus.notActive:
        return 'Not Active';
      case TIndicatorStatus.filled:
        return 'Filled';
      case TIndicatorStatus.unfilled:
        return 'Unfilled';
      case TIndicatorStatus.cancelled:
        return 'Cancelled';
    }
  }

  Color get _textColor {
    switch (status) {
      case TIndicatorStatus.active:
        return TColors.success;
      case TIndicatorStatus.draft:
        return TColors.info;
      case TIndicatorStatus.notActive:
        return TColors.error;
      case TIndicatorStatus.filled:
        return Colors.green;
      case TIndicatorStatus.unfilled:
        return Colors.brown;
      case TIndicatorStatus.cancelled:
        return Colors.black;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding: const EdgeInsets.all(0),
      decoration: BoxDecoration(
        color: _textColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Center(
        child: Text(
          _label,
          style: TextStyle(
            color: _textColor,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}