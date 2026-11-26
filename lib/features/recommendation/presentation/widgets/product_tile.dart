import 'package:flutter/material.dart';
import 'package:skinsense/core/theme/app_theme.dart';
import 'package:skinsense/core/utils/formatters.dart';
import 'package:skinsense/features/recommendation/domain/entities/recommendation.dart';

class ProductTile extends StatelessWidget {
  const ProductTile({super.key, required this.item});

  final RankedProduct item;

  @override
  Widget build(BuildContext context) {
    final p = item.product;
    final changed = item.fixedRank != null && item.fixedRank != item.rank;
    final isTop = item.rank == 1;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isTop ? AppTheme.navy : AppTheme.border,
          width: isTop ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.navy.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: isTop ? AppTheme.navy : AppTheme.ice,
              borderRadius: BorderRadius.circular(11),
            ),
            alignment: Alignment.center,
            child: Text(
              '#${item.rank}',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 13,
                color: isTop ? Colors.white : AppTheme.navy,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      p.brand.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.4,
                        color: AppTheme.slate,
                      ),
                    ),
                    if (isTop) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.coralSoft,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'Terbaik',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.coral,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  p.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 14.5,
                    color: AppTheme.navy,
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    Text(
                      Formatters.rupiah(p.price),
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.navy,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.star_rounded,
                        size: 15, color: AppTheme.gold),
                    const SizedBox(width: 2),
                    Text(
                      '${p.rating}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.slate,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Kandungan: ${p.ingredients.take(3).join(', ')}',
                  style: const TextStyle(
                    fontSize: 11.5,
                    height: 1.35,
                    color: AppTheme.slate,
                  ),
                ),
                if (changed) ...[
                  const SizedBox(height: 6),
                  Text(
                    'SAW bobot tetap: peringkat #${item.fixedRank}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.coral,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: isTop ? AppTheme.coralSoft : AppTheme.ice,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text(
                  Formatters.percent(item.score),
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: isTop ? AppTheme.coral : AppTheme.navy,
                  ),
                ),
                const Text(
                  'cocok',
                  style: TextStyle(fontSize: 10.5, color: AppTheme.slate),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
