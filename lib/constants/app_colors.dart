import 'package:flutter/material.dart';

class AppColors {
  // Brand colors aligned with study_buddy_final
  static const primary = Color(0xFF4E7FFF);      // Vivid Blue
  static const secondary = Color(0xFF10B981);    // Emerald Green / Success
  static const warning = Color(0xFFF59E0B);       // Warning / Amber
  static const error = Color(0xFFEF4444);        // Red
  static const success = Color(0xFF10B981);      // Emerald Green
  
  // Theme Background & Surfaces (for Dark Console theme)
  static const background = Color(0xFF090A0F);
  static const surface = Color(0xFF0E101A);
  static const card = Color(0xFF131520);
  static const divider = Color(0xFF1C1E30);
  static const border = Color(0xFF23263B);
  
  // Text Colors
  static const textPrimary = Colors.white;
  static const textSecondary = Color(0xFF8C91B2);
  static const textMuted = Color(0xFF555978);
  static const textLight = Color(0xFFC7D2FE);
  
  // Selection/Highlight overlays
  static final primaryHighlight = primary.withOpacity(0.12);
  static final primaryHover = primary.withOpacity(0.15);
  static final secondaryHighlight = secondary.withOpacity(0.12);
}
