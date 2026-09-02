import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:syathiby/di/providers.dart';
import 'package:syathiby/models/service_injection.dart';
import 'package:syathiby/models/violation/mukholif_santri.dart';
import 'package:syathiby/routing/app_router.dart';
import 'package:syathiby/utils/extension/color.dart';
import 'package:syathiby/utils/extension/typography.dart';
import 'package:syathiby/utils/rest_exception.dart';

class MukholifSearchScreen extends ConsumerStatefulWidget {
  const MukholifSearchScreen({super.key});

  @override
  ConsumerState<MukholifSearchScreen> createState() =>
      _MukholifSearchScreenState();
}

class _MukholifSearchScreenState extends ConsumerState<MukholifSearchScreen> {
  final _searchController = TextEditingController();
  List<MukholifSantri> _santriList = [];
  List<MukholifSantri> _filteredSantri = [];
  String? _warningMessage;
  bool _isLoading = false;
  bool _hasSearched = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterSantri(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredSantri = _santriList;
      });
      return;
    }

    final lowercaseQuery = query.toLowerCase();
    setState(() {
      _filteredSantri = (_santriList)
              .where((santri) =>
              santri.nama?.toLowerCase().contains(lowercaseQuery) == true)
          .toList();
    });
  }

  Future<void> _manualSearch() async {
    final currentUser = ref.read(getCurrentUserProvider);
    final key = currentUser?.key;
    if (key == null || key.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Session expired, please login again')),
      );
      return;
    }

    final query = _searchController.text.trim();
    if (query.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama minimal 3 karakter')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _hasSearched = true;
    });

    try {
      final result = await ref
          .read(violationServiceProvider)
          .searchMukholifSantri(key, query);

      setState(() {
        _santriList = result.data ?? [];
        _filteredSantri = result.data ?? [];
        _warningMessage = result.warningMessage;
        _isLoading = false;
      });
    } catch (e, st) {
      debugPrint('[_manualSearch] CAUGHT EXCEPTION: $e');
      debugPrint('[_manualSearch] Stack trace: $st');
      String errorMessage = 'Terjadi kesalahan';
      if (e is DioException) {
        if (e.error is RestException) {
          errorMessage = (e.error as RestException).message;
        } else if (e.message != null) {
          errorMessage = e.message!;
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );

      setState(() {
        _santriList = [];
        _filteredSantri = [];
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cari Santri'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Ketik nama santri...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    textInputAction: TextInputAction.search,
                    onChanged: _filterSantri,
                    onSubmitted: (_) => _manualSearch(),
                  ),
                ),
                const SizedBox(width: 12),
                FilledButton(
                  onPressed: _isLoading ? null : _manualSearch,
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Cari'),
                ),
              ],
            ),
          ),
          if (_warningMessage != null)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber, color: Colors.orange.shade700),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _warningMessage!,
                      style: TextStyle(color: Colors.orange.shade700),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 8),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : _filteredSantri.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _hasSearched
                                  ? Icons.search_off
                                  : Icons.person_search,
                              size: 64,
                              color: context.colorOnSurface.withOpacity(0.3),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _hasSearched
                                  ? 'Tidak ada hasil untuk "${_searchController.text}"'
                                  : 'Ketik nama untuk mencari santri',
                              style: context.bodyMedium?.copyWith(
                                color: context.colorOnSurface.withOpacity(0.5),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _filteredSantri.length,
                        itemBuilder: (context, index) {
                          final santris = _filteredSantri[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              leading: CircleAvatar(
                                backgroundColor:
                                    context.colorPrimary.withOpacity(0.1),
                                child: Text(
                                  santris.nama?.substring(0, 1).toUpperCase() ??
                                      '?',
                                  style: TextStyle(
                                    color: context.colorPrimary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              title: Text(
                                santris.nama ?? 'Unknown',
                                style: context.bodyMediumBold,
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (santris.nis != null && santris.nis!.isNotEmpty)
                                    Text(
                                      'NIS: ${santris.nis}',
                                      style: context.bodySmall?.copyWith(
                                        color: context.colorOnSurface.withOpacity(0.7),
                                      ),
                                    ),
                                  if (santris.kelas != null || santris.kamar != null)
                                    Text(
                                      'Kelas ${santris.kelas ?? '-'} • Kamar ${santris.kamar ?? '-'}',
                                      style: context.bodySmall,
                                    ),
                                  Text(
                                    'Poin Aktif: ${santris.poinAktif ?? 0}',
                                    style: context.bodySmall?.copyWith(
                                      color: (santris.poinAktif ?? 0) > 0
                                          ? Colors.red
                                          : Colors.green,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () {
                                context.goNamed(
                                  AppRoute.mukholifDetail.name,
                                  extra: {
                                    'santri_id': santris.santrialId,
                                    'nama': santris.nama,
                                    'kelas': santris.kelas,
                                    'kamar': santris.kamar,
                                  },
                                );
                              },
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
