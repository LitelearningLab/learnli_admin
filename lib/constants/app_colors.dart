import 'package:flutter/material.dart';

class AppColors {
  // Brand colors aligned with study_buddy_final
  static const primary = Color(0xFF4E7FFF);
  static const secondary = Color(0xFF10B981);
  static const warning = Color(0xFFF59E0B);
  static const error = Color(0xFFEF4444);
  static const success = Color(0xFF10B981);
  
  // Theme Background & Surfaces (aligned with study_buddy_final)
  static const background = Color(0xFFF9FAFB);
  static const surface = Colors.white;
  static const card = Colors.white;
  static const divider = Color(0xFFE5E7EB);
  static const border = Color(0xFFE5E7EB);
  
  // Text Colors (aligned with study_buddy_final)
  static const textPrimary = Color(0xFF1F1F1F);
  static const textSecondary = Color(0xFF6B7280);
  static const textMuted = Color(0xFF9CA3AF);
  static const textLight = Color(0xFF4B5563);
  
  // Selection/Highlight overlays
  static final primaryHighlight = primary.withOpacity(0.08);
  static final primaryHover = primary.withOpacity(0.12);
  static final secondaryHighlight = secondary.withOpacity(0.08);

  // Subject colors from study_buddy_final
  static const scienceLight = Color(0xFFD1FAE5);
  static const mathLight = Color(0xFFDBEAFE);
  static const englishLight = Color(0xFFFEF3C7);
  static const socialLight = Color(0xFFFCE7F3);
}
