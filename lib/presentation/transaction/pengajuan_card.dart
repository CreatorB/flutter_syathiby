import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syathiby/models/transaction/transaction.dart';
import 'package:syathiby/utils/alur_kegiatan.dart';
import 'package:syathiby/utils/extension/color.dart';
import 'package:syathiby/utils/extension/typography.dart';

/// Satu kartu pengajuan: status, progres alur, dan tim yang ditugaskan.
class PengajuanCard extends StatelessWidget {
  const PengajuanCard({super.key, required this.history, required this.onTap});

  final Transaction? history;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final jenis = history?.jenisKegiatan ?? '';
    final status = history?.status ?? '';
    final tanpaNominal = jenisTanpaNominal(jenis);
    final progress = progressAlur(jenis, status);
    final total = history?.totalPrice ?? 0;
    final totalFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(total);
    final tim = history?.namaTim?.trim() ?? '';

    return Card(
      margin: const EdgeInsets.fromLTRB(12, 4, 12, 4),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: context.colorPrimary,
                    child: Icon(
                      tanpaNominal ? Icons.build : Icons.inventory_2,
                      color: context.colorOnPrimary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          history?.noInvoice ?? '-',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.titleMediumBold,
                        ),
                        Text(
                          (history?.nameKegiatan ?? '').trim().isEmpty
                              ? (jenis.isEmpty ? 'Pengajuan' : jenis)
                              : '${history?.nameKegiatan}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  if (!tanpaNominal && total > 0)
                    Text(totalFormat, style: context.bodyMediumBold),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  if (jenis.isNotEmpty)
                    TagLabel(
                      teks: jenis,
                      warna: context.colorPrimary,
                      foreground: context.colorOnPrimary,
                    ),
                  TagLabel(
                    teks: labelStatus(status),
                    warna: progress.ditolak
                        ? context.colorError
                        : progress.selesai
                            ? context.colorPrimary
                            : context.colorSurfaceVariant,
                    foreground: progress.ditolak
                        ? context.colorOnError
                        : progress.selesai
                            ? context.colorOnPrimary
                            : context.colorOnSurfaceVariant,
                  ),
                  if (tim.isNotEmpty)
                    TagLabel(
                      teks:
                          '${namaTimUntukJenis(jenis)}: $tim',
                      warna: context.colorSurfaceVariant,
                      foreground: context.colorOnSurfaceVariant,
                    ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress.nilai,
                  minHeight: 6,
                  backgroundColor: context.colorSurfaceVariant,
                  color: progress.ditolak
                      ? context.colorError
                      : context.colorPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                progress.ditolak
                    ? 'Ditolak'
                    : '${progress.ringkas} • ${progress.label}',
                style: context.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Label kecil untuk jenis/status/tim.
class TagLabel extends StatelessWidget {
  const TagLabel({super.key, required this.teks, required this.warna, required this.foreground});

  final String teks;
  final Color warna;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: warna,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        teks,
        style: context.bodySmall?.copyWith(color: foreground),
      ),
    );
  }
}
