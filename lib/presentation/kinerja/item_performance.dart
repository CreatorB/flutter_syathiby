import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syathiby/models/staff/kinerja.dart';
import 'package:syathiby/utils/extension/color.dart';

class ItemPerformanceWidget extends StatelessWidget {
  final Kinerja performance;

  const ItemPerformanceWidget({super.key, required this.performance});

  @override
  Widget build(BuildContext context) {
    final formattedDate = _formatDate(
      performance.date,
      fromFormat: 'yyyy-MM-dd',
      toFormat: 'EEEE, dd MMMM yyyy',
    );
    final isGoodPerformance = performance.status == 'plus';
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 2),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${performance.namaKinerja}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16.0,
                        ),
                      ),
                      const SizedBox(height: 4.0),
                      Visibility(
                        visible: formattedDate != null,
                        child: Text(
                          '$formattedDate ${performance.hour}',
                          style: TextStyle(
                            color: context.colorOnSurface.withOpacity(0.6),
                            fontSize: 14.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: isGoodPerformance
                        ? context.colorPrimary
                        : context.colorError,
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                  child: Text(
                    '${performance.bobot}',
                    style: TextStyle(
                      color: isGoodPerformance
                          ? context.colorOnPrimary
                          : context.colorOnError,
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16.0),
          Container(
            height: 1.0,
            color: context.colorOnSurface.withOpacity(0.3),
          ),
        ],
      ),
    );
  }

  String? _formatDate(
    String? date, {
    String? fromFormat,
    String? toFormat,
  }) {
    if (date == null || date.isEmpty) return null;
    final parseDate = DateFormat(fromFormat).tryParse(date);
    if (parseDate == null) return null;
    final formattedDate = DateFormat(toFormat).format(parseDate);
    return formattedDate;
  }
}
