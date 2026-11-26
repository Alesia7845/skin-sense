import 'package:flutter/material.dart';
import 'package:skinsense/shared/models/skin_type.dart';

extension SkinTypeStyle on SkinType {
  Color get color => switch (this) {
        SkinType.normal => const Color(0xFF1F9D74),
        SkinType.oily => const Color(0xFFF66B85),
        SkinType.dry => const Color(0xFF5B6FD1),
      };

  Color get softColor => switch (this) {
        SkinType.normal => const Color(0xFFE7F7F1),
        SkinType.oily => const Color(0xFFFFEEF1),
        SkinType.dry => const Color(0xFFEDF0FC),
      };

  IconData get icon => switch (this) {
        SkinType.normal => Icons.spa_outlined,
        SkinType.oily => Icons.water_drop_outlined,
        SkinType.dry => Icons.air_outlined,
      };
}
