enum SkinType {
  normal,
  oily,
  dry;

  String get label => switch (this) {
        SkinType.normal => 'Normal',
        SkinType.oily => 'Berminyak',
        SkinType.dry => 'Kering',
      };

  String get description => switch (this) {
        SkinType.normal =>
          'Produksi minyak dan kelembapan relatif seimbang. Fokus pada menjaga keseimbangan dan perlindungan dari matahari.',
        SkinType.oily =>
          'Produksi sebum tinggi sehingga wajah mudah mengilap. Fokus pada kontrol minyak tanpa membuat kulit kehilangan hidrasi.',
        SkinType.dry =>
          'Kulit kurang minyak dan mudah terasa kencang atau bersisik. Fokus pada hidrasi dan penguatan skin barrier.',
      };

  /// Membaca nama kelas dari server (mendukung bahasa Inggris dan Indonesia).
  static SkinType? fromName(String raw) {
    switch (raw.trim().toLowerCase()) {
      case 'normal':
        return SkinType.normal;
      case 'oily':
      case 'berminyak':
        return SkinType.oily;
      case 'dry':
      case 'kering':
        return SkinType.dry;
    }
    return null;
  }
}
