import 'package:flutter/material.dart';

/// Centralized color constants for UGO Drivers app.
/// Use these across the app for consistent theming.
class AppColors {
  AppColors._();

  // ── Brand / Primary ─────────────────────────────────────────────────────
  /// Primary brand orange - main CTA, accents
  static const Color primary = Color(0xFFFF7B10);

  /// Gradient start for brand gradients
  static const Color primaryGradientStart = Color(0xFFFF8E32);

  /// Lighter orange for gradients, highlights
  static const Color primaryLight = Color(0xFFFF9E4D);

  /// Very light orange for backgrounds
  static const Color primaryLightBg = Color(0xFFFFB785);

  // ── Status Colors ───────────────────────────────────────────────────────
  /// Success, completed, positive actions
  static const Color success = Color(0xFF4CAF50);

  /// Alternate green (lime green)
  static const Color successAlt = Color(0xFF00C853);

  /// Error, cancel, destructive actions
  static const Color error = Color(0xFFE53935);

  /// Dark red for critical actions (delete, etc.)
  static const Color errorDark = Color(0xFF8B0000);

  /// Error for dialogs/buttons
  static const Color errorCritical = Color(0xFFB71C1C);

  /// Info, links, secondary accents
  static const Color info = Color(0xFF1976D2);

  /// Dark blue for headers
  static const Color infoDark = Color(0xFF0D47A1);

  // ── Neutral / UI ────────────────────────────────────────────────────────
  static const Color black = Color(0xFF000000);

  /// Primary text color
  static const Color textPrimary = Color(0xFF1D2025);

  /// Secondary dark (slate)
  static const Color textDark = Color(0xFF1E293B);

  static const Color white = Color(0xFFFFFFFF);

  /// Muted grey for secondary text
  static const Color grey = Color(0xFF757575);

  /// Slate grey
  static const Color greySlate = Color(0xFF64748B);

  /// Light grey for borders
  static const Color greyBorder = Color(0xFFE2E8F0);

  /// Divider, subtle borders
  static const Color divider = Color(0xFFEEEEEE);

  /// Light grey for disabled/inactive
  static const Color greyLight = Color(0xFF94A3B8);

  /// Muted text grey
  static const Color textMuted = Color(0xFF7F7B7B);

  /// Card/input borders
  static const Color greyMid = Color(0xFFE8E8E8);

  /// Dark grey for text
  static const Color greyDark = Color(0xFF333333);

  /// Medium grey
  static const Color greyMedium = Color(0xFF666666);

  /// Light grey for backgrounds
  static const Color greyBg = Color(0xFFCCCCCC);

  // ── Backgrounds ─────────────────────────────────────────────────────────
  /// Page background (off-white)
  static const Color background = Color(0xFFF5F5F5);

  /// Alternate background
  static const Color backgroundAlt = Color(0xFFF5F7FA);

  /// Card/input background
  static const Color backgroundCard = Color(0xFFF9F9F9);

  /// Light background for sections
  static const Color backgroundLight = Color(0xFFF8FAFC);

  /// Light grey for containers
  static const Color containerGrey = Color(0xFFF1F1F1);

  // ── Section / Accent Backgrounds ────────────────────────────────────────
  /// Light green for success/positive sections
  static const Color sectionGreen = Color(0xFFE8F5E9);

  /// Light orange for highlight sections
  static const Color sectionOrange = Color(0xFFFFF3E0);

  /// Light orange tint
  static const Color sectionOrangeTint = Color(0xFFFFF7ED);

  /// Light green for approved/success state
  static const Color sectionGreenTint = Color(0xFFF0FDF4);

  // ── Team Earnings / Orders ──────────────────────────────────────────────
  static const Color teamEarningsGreen = Color(0xFF004D40);
  static const Color teamEarningsTextGreen = Color(0xFF00897B);
  static const Color teamEarningsYellow = Color(0xFFFFC107);

  static const Color activeTabBg = Color(0xFFFFF176);

  // ── Theme / Accent Variants ─────────────────────────────────────────────
  static const Color accentIndigo = Color(0xFF6366F1);

  static const Color accentPurple = Color(0xFF8B5CF6);

  static const Color accentPink = Color(0xFFEC4899);

  static const Color accentAmber = Color(0xFFF59E0B);

  static const Color accentEmerald = Color(0xFF10B981);

  /// Google/social red
  static const Color googleRed = Color(0xFFDB4437);

  /// Withdraw accent
  static const Color accentCoral = Color(0xFFFF6B35);

  /// Registration/document flow orange
  static const Color registrationOrange = Color(0xFFFF8C00);

  /// Border/divider light grey
  static const Color greyBorderLight = Color(0xFFE1E1E1);

  /// Silver (vehicle colors)
  static const Color silver = Color(0xFFC0C0C0);

  /// Accent red
  static const Color accentRed = Color(0xFFEF4444);

  /// Accent blue
  static const Color accentBlue = Color(0xFF3B82F6);

  /// Grey for vehicle color
  static const Color greyVehicle = Color(0xFF6B7280);

  /// Success dark green
  static const Color successDark = Color(0xFF2E7D32);

  /// Muted background
  static const Color backgroundMuted = Color(0xFFE9ECEF);

  /// Light orange section background
  static const Color sectionOrangeLight = Color(0xFFFFF4E6);

  /// Very dark text (near black)
  static const Color textNearBlack = Color(0xFF1A1A1A);
}
