import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:syathiby/di/providers.dart';
import 'package:syathiby/models/service_injection.dart';
import 'package:syathiby/models/violation/mukholif_santri.dart';
import 'package:syathiby/utils/extension/color.dart';
import 'package:syathiby/utils/extension/typography.dart';

class MukholifDetailScreen extends ConsumerStatefulWidget {
  final int santrialId;
  final String studentName;
  final String? kelas;
  final String? kamar;

  const MukholifDetailScreen({
    super.key,
    required this.santrialId,
    required this.studentName,
    this.kelas,
    this.kamar,
  });

  @override
  ConsumerState<MukholifDetailScreen> createState() =>
      _MukholifDetailScreenState();
}

class _MukholifDetailScreenState extends ConsumerState<MukholifDetailScreen> {
  String _startDate = DateTime.now().year.toString() + '-01-01';
  String _endDate = DateTime.now().toIso8601String().split('T')[0];
  String? _selectedBagian;
  String? _selectedKategori;

  AsyncValue<MukholifDetailResponse>? _detailResult;

  final List<String> _bagianList = [
    'Pengabdian',
    'Kesantrian',
    'DINIYYAH',
    'TAHFIDZ',
    'Bahasa'
  ];
  final List<String> _kategoriList = [
    'Ringan',
    'Sedang',
    'Berat',
    'Sangat Berat'
  ];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    final key = ref.read(getCurrentUserProvider)?.key;
    if (key == null || key.isEmpty) return;

    setState(() {
      _detailResult = const AsyncValue.loading();
    });

    try {
      final result = await ref.read(violationServiceProvider).getMukholifDetail(
            key,
            widget.santrialId,
            _startDate,
            _endDate,
            bagian: _selectedBagian,
            kategori: _selectedKategori,
          );

      setState(() {
        _detailResult = AsyncValue.data(result);
      });
    } catch (e, st) {
      setState(() {
        _detailResult = AsyncValue.error(e, st);
      });
    }
  }

  Color _getKategoriColor(String? kategori) {
    switch (kategori?.toLowerCase()) {
      case 'berat':
        return Colors.red;
      case 'sedang':
        return Colors.orange;
      case 'ringan':
        return Colors.green;
      case 'sangat berat':
        return Colors.deepPurple;
      default:
        return Colors.grey;
    }
  }

  IconData _getKategoriIcon(String? kategori) {
    switch (kategori?.toLowerCase()) {
      case 'berat':
        return Icons.warning;
      case 'sedang':
        return Icons.error_outline;
      case 'ringan':
        return Icons.info_outline;
      case 'sangat berat':
        return Icons.dangerous;
      default:
        return Icons.help_outline;
    }
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '-';
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day} ${_monthName(date.month)} ${date.year}';
    } catch (e) {
      return dateStr;
    }
  }

  String _monthName(int month) {
    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember'
    ];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Pelanggaran'),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: context.colorSurface,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.studentName,
                  style: context.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Kelas ${widget.kelas ?? '-'} • Kamar ${widget.kamar ?? '-'}',
                  style: context.bodyMedium?.copyWith(
                    color: context.colorOnSurface.withOpacity(0.7),
                  ),
                ),
                const Divider(height: 24),
                _detailResult == null || _detailResult!.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _detailResult!.when(
                        data: (response) {
                          final data = response.data;
                          if (data == null) return const SizedBox();
                          return Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: _StatItem(
                                      label: 'Total Pelanggaran',
                                      value:
                                          '${data.summary?.totalPelanggaran ?? 0}',
                                      color: context.colorPrimary,
                                    ),
                                  ),
                                  Expanded(
                                    child: _StatItem(
                                      label: 'Total Poin',
                                      value: '${data.summary?.totalPoin ?? 0}',
                                      color: Colors.orange,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              _StatItem(
                                label: 'Total Poin Aktif',
                                value:
                                    '${data.summary?.totalPoinAktif ?? 0}',
                                color: Colors.red,
                                isLarge: true,
                              ),
                            ],
                          );
                        },
                        error: (e, st) => Text('Error: $e'),
                        loading: () =>
                            const Center(child: CircularProgressIndicator()),
                      ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Filter',
                  style: context.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedBagian,
                        decoration: InputDecoration(
                          labelText: 'Bagian',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        items: [
                          const DropdownMenuItem(
                              value: null, child: Text('Semua')),
                          ..._bagianList.map((b) => DropdownMenuItem(
                                value: b,
                                child: Text(b),
                              )),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedBagian = value;
                          });
                          _fetchData();
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedKategori,
                        decoration: InputDecoration(
                          labelText: 'Kategori',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        items: [
                          const DropdownMenuItem(
                              value: null, child: Text('Semua')),
                          ..._kategoriList.map((k) => DropdownMenuItem(
                                value: k,
                                child: Text(k),
                              )),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedKategori = value;
                          });
                          _fetchData();
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Periode: ${_formatDate(_startDate)} - ${_formatDate(_endDate)}',
                        style: context.bodySmall,
                      ),
                    ),
                    TextButton(
                      onPressed: _fetchData,
                      child: const Text('Refresh'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _detailResult == null
                ? const SizedBox()
                : _detailResult!.when(
                    data: (response) {
                      final pelanggaran =
                          response.data?.pelanggaran ?? [];
                      if (pelanggaran.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.check_circle,
                                size: 64,
                                color: Colors.green
                                    .withOpacity(0.5),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Tidak ada data pelanggaran',
                                style: context.bodyMedium?.copyWith(
                                  color: context.colorOnSurface
                                      .withOpacity(0.5),
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: pelanggaran.length,
                        itemBuilder: (context, index) {
                          final p = pelanggaran[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor:
                                    _getKategoriColor(p.kategori)
                                        .withOpacity(0.1),
                                child: Icon(
                                  _getKategoriIcon(p.kategori),
                                  color: _getKategoriColor(p.kategori),
                                  size: 20,
                                ),
                              ),
                              title: Text(
                                p.namaPelanggaran ?? '-',
                                style: context.bodyMediumBold,
                              ),
                              subtitle: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _formatDate(p.tanggal),
                                    style: context.bodySmall,
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _getKategoriColor(p.kategori)
                                          .withOpacity(0.1),
                                      borderRadius:
                                          BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      p.kategori ?? '-',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: _getKategoriColor(
                                            p.kategori),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              trailing: Text(
                                '${p.poin ?? 0}',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: (p.poin ?? 0) > 0
                                      ? Colors.red
                                      : Colors.green,
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                    error: (e, st) => Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 64,
                            color: context.colorError,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Terjadi kesalahan',
                            style: context.bodyMedium,
                          ),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: _fetchData,
                            child: const Text('Coba Lagi'),
                          ),
                        ],
                      ),
                    ),
                    loading: () => const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final bool isLarge;

  const _StatItem({
    required this.label,
    required this.value,
    required this.color,
    this.isLarge = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: context.colorOnSurface.withOpacity(0.6),
              ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
                fontSize: isLarge ? 32 : 24,
              ),
        ),
      ],
    );
  }
}
