import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:syathiby/di/providers.dart';
import 'package:syathiby/models/service_injection.dart';
import 'package:syathiby/models/permit/permit.dart';
import 'package:syathiby/models/student/siswa.dart';
import 'package:syathiby/presentation/permit/permit_controller.dart';
import 'package:syathiby/utils/extension/color.dart';
import 'package:syathiby/utils/extension/typography.dart';

class TapIzinBottomSheet extends ConsumerStatefulWidget {
  const TapIzinBottomSheet({super.key});

  @override
  ConsumerState<TapIzinBottomSheet> createState() => _TapIzinBottomSheetState();
}

class _TapIzinBottomSheetState extends ConsumerState<TapIzinBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _detailController = TextEditingController();
  final _searchController = TextEditingController();

  /// Jenis izin dari tabel `permit_type`. Sebelum 7 Sep 2026 form ini hanya
  /// punya field teks bebas, sehingga izin yang dibuat lewat jalur tap tidak
  /// pernah terikat kategori dan batas `max_hari` tidak bisa diberlakukan.
  Permit? _selectedType;

  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now();
  TimeOfDay _jamFrom = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay _jamUntil = const TimeOfDay(hour: 17, minute: 0);
  List<Siswa> _allStudents = [];
  List<Siswa> _selectedStudents = [];
  bool _isLoading = false;
  bool _selectAll = false;
  String? _error;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _loadStudents());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _detailController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<Siswa> get _filteredStudents {
    if (_searchQuery.isEmpty) return _allStudents;
    final q = _searchQuery.toLowerCase();
    return _allStudents.where((s) {
      return (s.namaLengkap?.toLowerCase().contains(q) ?? false) ||
          (s.nis?.toLowerCase().contains(q) ?? false) ||
          (s.kelas?.toLowerCase().contains(q) ?? false);
    }).toList();
  }

  Future<void> _loadStudents() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final currentUser = ref.read(getCurrentUserProvider);
      final key = '${currentUser?.key}';
      final result = await ref.read(studentServiceProvider).getAllSiswa(key);

      if (mounted) {
        setState(() {
          _allStudents = result;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  void _toggleSelectAll() {
    setState(() {
      _selectAll = !_selectAll;
      if (_selectAll) {
        for (final siswa in _filteredStudents) {
          if (!_selectedStudents.any((s) => s.idSiswa == siswa.idSiswa)) {
            _selectedStudents.add(siswa);
          }
        }
      } else {
        _selectedStudents.removeWhere(
          (s) => _filteredStudents.any((fs) => fs.idSiswa == s.idSiswa),
        );
      }
    });
  }

  void _toggleStudent(Siswa siswa) {
    setState(() {
      if (_selectedStudents.any((s) => s.idSiswa == siswa.idSiswa)) {
        _selectedStudents.removeWhere((s) => s.idSiswa == siswa.idSiswa);
      } else {
        _selectedStudents.add(siswa);
      }
      _selectAll = _selectedStudents.length == _allStudents.length;
    });
  }

  bool _isSelected(Siswa siswa) {
    return _selectedStudents.any((s) => s.idSiswa == siswa.idSiswa);
  }

  Future<void> _selectDate(bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate : _endDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          if (_endDate.isBefore(_startDate)) {
            _endDate = _startDate;
          }
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _selectTime(bool isFrom) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isFrom ? _jamFrom : _jamUntil,
    );
    if (picked != null) {
      setState(() {
        if (isFrom) {
          _jamFrom = picked;
        } else {
          _jamUntil = picked;
        }
      });
    }
  }

  String _formatTimeOfDay(TimeOfDay tod) {
    final h = tod.hour.toString().padLeft(2, '0');
    final m = tod.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String _buildJamIzinFrom() {
    return '${_formatDate(_startDate)} ${_formatTimeOfDay(_jamFrom)}:00';
  }

  String _buildJamIzinUntil() {
    return '${_formatDate(_endDate)} ${_formatTimeOfDay(_jamUntil)}:00';
  }

  /// Ambil daftar `permit_type` (type=santri) dan tampilkan sebagai pilihan.
  /// Sumbernya sama dengan yang dipakai layar "Ajukan Izin" sebelum kedua
  /// tombol digabung, jadi daftar kategorinya tetap satu sumber kebenaran.
  Future<void> _pickPermitType() async {
    final currentUser = ref.read(getCurrentUserProvider);
    final key = '${currentUser?.key}';

    List<Permit> items;
    try {
      items = await ref.read(
        fetchPermitTypeProvider(key: key, type: 'santri').future,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat jenis izin: $e')),
      );
      return;
    }
    if (!mounted) return;

    final picked = await showModalBottomSheet<Permit>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (_, scrollController) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Text(
                'Jenis Izin',
                style: Theme.of(sheetContext).textTheme.titleMedium,
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView.separated(
                controller: scrollController,
                itemCount: items.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (_, index) => ListTile(
                  title: Text('${items[index].namePermit}'),
                  onTap: () => Navigator.of(sheetContext).pop(items[index]),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    if (picked != null && mounted) {
      setState(() {
        _selectedType = picked;
        _nameController.text = picked.namePermit ?? '';
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedStudents.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih minimal 1 siswa')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final currentUser = ref.read(getCurrentUserProvider);
      final key = '${currentUser?.key}';
      final studentIds = _selectedStudents.map((s) => s.idSiswa).join(',');

      final result = await ref.read(tapServiceProvider).addTapIzin(
        key,
        _nameController.text,
        _formatDate(_startDate),
        _formatDate(_endDate),
        _buildJamIzinFrom(),
        _buildJamIzinUntil(),
        _detailController.text,
        studentIds,
        idIzin: _selectedType?.idPermit?.toString() ?? '',
      );

      if (mounted) {
        if (result.status == true || result.status == 'true') {
          Navigator.of(context).pop(true);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result.msg)),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result.msg)),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: BoxDecoration(
        color: context.colorSurface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Judul disamakan dengan tombolnya. Sebelum 8 Sep 2026 tertulis
                // "Izin Tap Baru", istilah yang lahir waktu masih ada dua jalur
                // ("Ajukan Izin" vs "Tap Izin"). Sekarang jalurnya cuma satu,
                // jadi kata "Tap" hanya menyisakan kebingungan yang sama.
                Text('Buat Izin Santri', style: context.titleLarge),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  FormField<Permit>(
                    validator: (_) =>
                        _selectedType == null ? 'Wajib dipilih' : null,
                    builder: (field) => InkWell(
                      onTap: _pickPermitType,
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Jenis Izin',
                          errorText: field.errorText,
                          suffixIcon: const Icon(Icons.arrow_drop_down),
                        ),
                        child: Text(
                          _selectedType?.namePermit ?? 'Pilih jenis izin',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () => _selectDate(true),
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'Tanggal Mulai',
                            ),
                            child: Text(_formatDate(_startDate)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: InkWell(
                          onTap: () => _selectDate(false),
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'Tanggal Selesai',
                            ),
                            child: Text(_formatDate(_endDate)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () => _selectTime(true),
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'Jam Mulai',
                            ),
                            child: Text(_formatTimeOfDay(_jamFrom)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: InkWell(
                          onTap: () => _selectTime(false),
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'Jam Batas Kembali',
                            ),
                            child: Text(_formatTimeOfDay(_jamUntil)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _detailController,
                    decoration: const InputDecoration(
                      labelText: 'Detail',
                      hintText: 'Keterangan izin (opsional)',
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 24),
Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Pilih Siswa (${_selectedStudents.length}/${_allStudents.length})',
                            style: context.titleMedium,
                          ),
                          Row(
                            children: [
                              TextButton.icon(
                                onPressed: _toggleSelectAll,
                                icon: Icon(
                                  _selectAll
                                      ? Icons.indeterminate_check_box
                                      : Icons.check_box_outlined,
                                  size: 20,
                                ),
                                label: Text(_selectAll ? 'Deselect All' : 'Select All'),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Cari nama, NIS, atau kelas...',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() => _searchQuery = '');
                                  },
                                )
                              : null,
                        ),
                        onChanged: (v) => setState(() => _searchQuery = v),
                      ),
                  const SizedBox(height: 8),
                  if (_isLoading && _allStudents.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else if (_error != null)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          children: [
                            const Icon(Icons.error_outline, size: 48, color: Colors.red),
                            const SizedBox(height: 8),
                            Text('Error: $_error'),
                            TextButton(
                              onPressed: _loadStudents,
                              child: const Text('Coba Lagi'),
                            ),
                          ],
                        ),
                      ),
                    )
                  else if (_filteredStudents.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Text(
                          _searchQuery.isNotEmpty
                              ? 'Tidak ada siswa yang cocok'
                              : 'Tidak ada data siswa',
                        ),
                      ),
                    )
                  else
                    Container(
                      height: 300,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            color: Colors.grey.shade100,
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 30,
                                  child: Checkbox(
                                    value: _selectAll,
                                    onChanged: (_) => _toggleSelectAll(),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    _searchQuery.isNotEmpty
                                        ? 'Pilih Semua (${_filteredStudents.length} hasil)'
                                        : 'Pilih Semua',
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Divider(height: 1),
                          Expanded(
                            child: ListView.builder(
                              itemCount: _filteredStudents.length,
                              itemBuilder: (context, index) {
                                final siswa = _filteredStudents[index];
                                final isSelected = _isSelected(siswa);
                                return Column(
                                  children: [
                                    CheckboxListTile(
                                      value: isSelected,
                                      onChanged: (_) => _toggleStudent(siswa),
                                      title: Text(siswa.namaLengkap ?? '-'),
                                      subtitle: Text(
                                        '${siswa.kelas ?? '-'} - ${siswa.nis ?? '-'}',
                                      ),
                                      controlAffinity: ListTileControlAffinity.leading,
                                      dense: true,
                                    ),
                                    if (index < _filteredStudents.length - 1)
                                      const Divider(height: 1),
                                  ],
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(
              20,
              12,
              20,
              MediaQuery.of(context).padding.bottom + 12,
            ),
            decoration: BoxDecoration(
              color: context.colorSurface,
              border: Border(top: BorderSide(color: Colors.grey.shade200)),
            ),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _isLoading ? null : _submit,
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text('Simpan (${_selectedStudents.length} siswa)'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
