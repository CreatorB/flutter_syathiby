import 'package:flutter/material.dart';

/// Buka satu gambar di layar penuh dengan kemampuan zoom.
///
/// Dipakai untuk bukti transfer: di dalam kartu ukurannya kecil, sehingga
/// nominal atau nomor rekening sulit dibaca. Ketuk gambarnya -> layar penuh,
/// lalu perbesar dengan cubit dua jari, klik ganda, tombol +/- , atau roda
/// mouse (di versi web).
///
/// Pemakaian:
///
/// ```dart
/// GestureDetector(
///   onTap: () => showGambarZoom(context, url: urlBukti),
///   child: Image.network(urlBukti),
/// )
/// ```
Future<void> showGambarZoom(
  BuildContext context, {
  required String url,
  String? judul,
}) {
  // Navigator ROOT: tampilan menutup seluruh aplikasi, termasuk navbar
  // bawah. Kalau pushed ke navigator cabangnya, navbar bawah masih menutupi
  // bagian bawah layar gambar.
  return Navigator.of(context, rootNavigator: true).push<void>(
    MaterialPageRoute<void>(
      fullscreenDialog: true,
      builder: (_) => LayarGambarZoom(url: url, judul: judul),
    ),
  );
}

/// Layar penuh untuk melihat satu gambar: bisa di-zoom dan digeser.
class LayarGambarZoom extends StatefulWidget {
  const LayarGambarZoom({super.key, required this.url, this.judul});

  final String url;
  final String? judul;

  @override
  State<LayarGambarZoom> createState() => _LayarGambarZoomState();
}

class _LayarGambarZoomState extends State<LayarGambarZoom> {
  final TransformationController _kontrol = TransformationController();
  final GlobalKey _kunciTampilan = GlobalKey();

  static const double _skalaMin = 1;
  static const double _skalaMaks = 6;
  static const double _skalaGanda = 2.5;

  /// Titik klik ganda terakhir (ruang gambar).
  Offset? _titikGanda;

  /// Skala terakhir dalam persen, dipakai untuk indikator di layar.
  int _persen = 100;

  @override
  void initState() {
    super.initState();
    _kontrol.addListener(_perbaruiPersen);
  }

  @override
  void dispose() {
    _kontrol.removeListener(_perbaruiPersen);
    _kontrol.dispose();
    super.dispose();
  }

  void _perbaruiPersen() {
    final nilai = (_kontrol.value.getMaxScaleOnAxis() * 100).round();
    if (nilai != _persen) {
      setState(() => _persen = nilai);
    }
  }

  double _skala() => _kontrol.value.getMaxScaleOnAxis();

  /// Ubah skala ke [target], dengan titik [titik] (ruang layar) sebagai titik
  /// tetap: bagian gambar di bawah titik itu tidak bergeser.
  void _zoom(double target, {Offset? titik}) {
    final m = _kontrol.value;
    final lama = m.getMaxScaleOnAxis();
    if (lama <= 0) {
      return;
    }
    final baru = target.clamp(_skalaMin, _skalaMaks).toDouble();
    final rasio = baru / lama;
    if ((rasio - 1).abs() < 0.005) {
      return;
    }

    final pusat = titik ?? _pusatLayar();
    final tx = m.storage[12];
    final ty = m.storage[13];
    // Titik di ruang gambar yang sekarang berada tepat di `pusat`.
    final xGambar = (pusat.dx - tx) / lama;
    final yGambar = (pusat.dy - ty) / lama;

    _kontrol.value = m.clone()
      ..scaleByDouble(rasio, rasio, 1, 1)
      ..setTranslationRaw(
        tx + (lama - baru) * xGambar,
        ty + (lama - baru) * yGambar,
        0,
      );
  }

  Offset _pusatLayar() {
    final kotak = _kunciTampilan.currentContext?.findRenderObject() as RenderBox?;
    if (kotak == null || !kotak.hasSize) {
      final ukuran = MediaQuery.of(context).size;
      return Offset(ukuran.width / 2, ukuran.height / 2);
    }
    return Offset(kotak.size.width / 2, kotak.size.height / 2);
  }

  void _klikGanda() {
    if (_skala() > 1.05) {
      _kontrol.value = Matrix4.identity();
      return;
    }
    _zoom(_skalaGanda, titik: _titikGanda);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: InteractiveViewer(
              key: _kunciTampilan,
              transformationController: _kontrol,
              minScale: _skalaMin,
              maxScale: _skalaMaks,
              // Di web, roda mouse dipakai untuk zoom (bukan menggulir halaman).
              trackpadScrollCausesScale: true,
              child: GestureDetector(
                onDoubleTapDown: (d) => _titikGanda = d.localPosition,
                onDoubleTap: _klikGanda,
                child: SizedBox.expand(
                  child: Image.network(
                    widget.url,
                    fit: BoxFit.contain,
                    loadingBuilder: (ctx, child, progres) => progres == null
                        ? child
                        : const Center(
                            child: CircularProgressIndicator(color: Colors.white),
                          ),
                    errorBuilder: (ctx, e, _) => const Center(
                      child: Text(
                        'Gambar tidak bisa dimuat.',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  children: [
                    _TombolLayar(
                      ikon: Icons.close,
                      tooltip: 'Tutup',
                      onTap: () => Navigator.of(context).pop(),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.judul ?? '',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _TombolLayar(
                      ikon: Icons.remove,
                      tooltip: 'Perkecil',
                      onTap: () => _zoom(_skala() / 1.5),
                    ),
                    const SizedBox(width: 10),
                    Semantics(
                      label: 'Zoom gambar $_persen persen',
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '$_persen%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    _TombolLayar(
                      ikon: Icons.add,
                      tooltip: 'Perbesar',
                      onTap: () => _zoom(_skala() * 1.5),
                    ),
                    const SizedBox(width: 10),
                    _TombolLayar(
                      ikon: Icons.zoom_out_map,
                      tooltip: 'Kembali ke ukuran semula',
                      onTap: () => _kontrol.value = Matrix4.identity(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Tombol bulat semi transparan di atas gambar.
class _TombolLayar extends StatelessWidget {
  const _TombolLayar({
    required this.ikon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData ikon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.white.withValues(alpha: 0.15),
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Icon(ikon, color: Colors.white, size: 22),
          ),
        ),
      ),
    );
  }
}
