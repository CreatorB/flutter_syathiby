/// Versi non-web: tidak ada service worker, jadi tidak ada yang perlu
/// disegarkan.[PENTING] Jangan isi apa-apa di sini -- file ini dipakai juga
/// oleh test runner (VM) dan harus tetap bisa dikompilasi di semua platform.
class WebBundleRefresh {
  /// Tidak melakukan apa-apa di platform selain web.
  static Future<void> ensureFreshBundle() async {}
}
