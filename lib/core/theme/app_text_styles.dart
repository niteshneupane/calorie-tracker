import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTextStyles {
  static const title = TextStyle(
    fontSize: 30,
    fontWeight: FontWeight.w800,
    fontFamily: 'Manrope',
    color: AppColors.text,
  );
  static const heading = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w800,
    fontFamily: 'Manrope',
    color: AppColors.text,
  );
  static const cardTitle = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w700,
    fontFamily: 'Plus Jakarta Sans',
    color: AppColors.text,
  );
  static const body = TextStyle(
    fontSize: 15,
    height: 1.35,
    fontFamily: 'Plus Jakarta Sans',
    color: AppColors.text,
  );
  static const muted = TextStyle(
    fontSize: 13,
    height: 1.3,
    fontFamily: 'Plus Jakarta Sans',
    color: AppColors.muted,
  );
}
