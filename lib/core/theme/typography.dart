import 'package:flutter/material.dart';
import 'colors.dart';

/// Typography system using Roboto font
class AppTypography {
  // Headings
  static const TextStyle h1 = TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    fontFamily: 'Roboto',
  );

  static const TextStyle h2 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
    fontFamily: 'Roboto',
  );

  // Body text
  static const TextStyle body = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    fontFamily: 'Roboto',
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
    fontFamily: 'Roboto',
  );

  // Button text
  static const TextStyle button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    fontFamily: 'Roboto',
  );

  // Labels
  static const TextStyle label = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    fontFamily: 'Roboto',
  );

  static const TextStyle labelCaps = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.2,
    color: AppColors.neon,
    fontFamily: 'Roboto',
  );

  // Input text
  static const TextStyle input = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    fontFamily: 'Roboto',
  );

  // Secure input (password/keys)
  static const TextStyle secureInput = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 2,
    color: AppColors.textPrimary,
    fontFamily: 'Roboto',
  );

  // Metadata
  static const TextStyle metadata = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    fontFamily: 'Roboto',
  );
}
