import 'package:flutter/material.dart';
import 'package:skinsense/shared/models/skin_type.dart';

extension SkinTypeStyle on SkinType {
  Color get color => switch (this) {
        SkinType.normal => const Color(0xFF1F7A74),
        SkinType.oily => const Color(0xFFD98E1F),
        SkinType.dry => const Color(0xFF5B6FD1),
      };

  IconData get icon => switch (this) {
        SkinType.normal => Icons.spa_outlined,
        SkinType.oily => Icons.water_drop_outlined,
        SkinType.dry => Icons.air_outlined,
      };
}
