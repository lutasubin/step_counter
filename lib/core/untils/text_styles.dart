import 'package:flutter/material.dart';

/// Helper class để tạo TextStyle với font Montserrat mặc định
class AppTextStyles {
  AppTextStyles._();

  /// Tên font family
  static const String fontFamily = 'Montserrat';

  /// Font weights chuẩn đã khai báo trong pubspec.yaml (Static fonts)
  static const FontWeight thin = FontWeight.w100; // 100 - Thin
  static const FontWeight extraLight = FontWeight.w200; // 200 - ExtraLight
  static const FontWeight light = FontWeight.w300; // 300 - Light
  static const FontWeight normal = FontWeight.w400; // 400 - Regular/Normal
  static const FontWeight medium = FontWeight.w500; // 500 - Medium
  static const FontWeight semiBold = FontWeight.w600; // 600 - SemiBold
  static const FontWeight bold = FontWeight.w700; // 700 - Bold
  static const FontWeight extraBold = FontWeight.w800; // 800 - ExtraBold
  static const FontWeight black = FontWeight.w900; // 900 - Black

  /// Tạo TextStyle với font Montserrat
  /// Nếu không truyền fontFamily, sẽ tự động dùng Montserrat
  static TextStyle montserrat({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? letterSpacing,
    double? height,
    TextDecoration? decoration,
    Color? decorationColor,
    double? decorationThickness,
    FontStyle? fontStyle,
  }) {
    return TextStyle(
      fontFamily: fontFamily,
      fontSize: fontSize,
      fontWeight: fontWeight ?? normal, // Mặc định là normal (w400)
      color: color,
      letterSpacing: letterSpacing,
      height: height,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationThickness: decorationThickness,
      fontStyle: fontStyle,
    );
  }
}
