import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';

class LogoWidget extends StatelessWidget {
  final double size;
  final bool showText;
  final String? subtitle;

  const LogoWidget({
    Key? key,
    this.size = 120,
    this.showText = true,
    this.subtitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.coffee,
            size: 60,
            color: AppColors.textLight,
          ),
        ),
        if (showText) ...[
          const SizedBox(height: 16),
          const Text(
            'BaristaBot',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: AppColors.textLight,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 8),
            Text(
              subtitle!,
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ],
    );
  }
}