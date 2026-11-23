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
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: item.rank == 1 ? AppTheme.teal : const Color(0xFFDCE7E4),
          width: item.rank == 1 ? 1.6 : 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: item.rank == 1 ? AppTheme.teal : AppTheme.mist,
            child: Text('${item.rank}',
                style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: item.rank == 1 ? Colors.white : AppTheme.ink)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(p.brand, style: const TextStyle(fontSize: 12, color: Colors.black54)),
                Text(p.name,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                const SizedBox(height: 4),
                Text('${Formatters.rupiah(p.price)}  |  rating ${p.rating}',
                    style: const TextStyle(fontSize: 12.5)),
                const SizedBox(height: 6),
                Text('Bahan utama: ${p.ingredients.take(3).join(', ')}',
                    style: const TextStyle(fontSize: 12.5, height: 1.35)),
                if (changed) ...[
                  const SizedBox(height: 6),
                  Text(
                    'Pada SAW bobot tetap produk ini peringkat ${item.fixedRank}',
                    style: const TextStyle(fontSize: 11.5, color: AppTheme.coral),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            children: [
              Text(Formatters.percent(item.score),
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.teal)),
              const Text('cocok', style: TextStyle(fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }
}
