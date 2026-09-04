import 'package:flutter/material.dart';

/// Trip history card (map preview + trip summary + actions).
///
/// The map itself is left as an empty placeholder `Container` — swap
/// it for a real static map image/widget (Google Maps snapshot,
/// cached network image, etc.) when that's wired up.
class TripHistoryCard extends StatelessWidget {
  const TripHistoryCard({
    super.key,
    required this.destination,
    required this.dateTime,
    required this.price,
    this.originalPrice,
    this.stops = 0,
    this.mapChild,
    this.onRate,
    this.onRebook,
  });

  final String destination;
  final String dateTime;
  final String price;
  final String? originalPrice;
  final int stops;
  final Widget? mapChild;
  final VoidCallback? onRate;
  final VoidCallback? onRebook;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEDEDED)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Map placeholder ---
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              color: const Color(0xFFF0F0F0),
              alignment: Alignment.center,
              child: mapChild ??
                  const Icon(
                    Icons.map_outlined,
                    size: 32,
                    color: Colors.black26,
                  ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  destination,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  dateTime,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    if (originalPrice != null) ...[
                      Text(
                        originalPrice!,
                        style: const TextStyle(
                          fontSize: 15,
                          color: Colors.black54,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                      const SizedBox(width: 6),
                    ] else
                      Text(
                        price,
                        style: const TextStyle(
                          fontSize: 15,
                          color: Colors.black54,
                        ),
                      ),
                    if (originalPrice != null)
                      Text(
                        ' • $stops stop${stops == 1 ? '' : 's'}',
                        style: const TextStyle(
                          fontSize: 15,
                          color: Colors.black54,
                        ),
                      )
                    else
                      Text(
                        ' • $stops stop${stops == 1 ? '' : 's'}',
                        style: const TextStyle(
                          fontSize: 15,
                          color: Colors.black54,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    _PillButton(
                      icon: Icons.star_border_rounded,
                      label: 'Rate',
                      onTap: onRate,
                    ),
                    const SizedBox(width: 10),
                    _PillButton(
                      icon: Icons.refresh_rounded,
                      label: 'Rebook',
                      onTap: onRebook,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PillButton extends StatelessWidget {
  const _PillButton({
    required this.icon,
    required this.label,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF4F4F4),
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 19, color: Colors.black87),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
