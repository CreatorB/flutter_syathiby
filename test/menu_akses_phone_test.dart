import 'package:flutter_test/flutter_test.dart';
import 'package:syathiby/models/store/store.dart';
import 'package:syathiby/presentation/setting/change_phone_screen.dart';

void main() {
  test('Store membaca flag menu akses dari server', () {
    final s = Store.fromJson({
      'admin_utama': 1,
      'menu_pengadaan': 1,
      'menu_perbaikan': 0,
      'menu_kantin': 1,
    });
    expect(s.adminUtama, 1);
    expect(s.menuPengadaan, 1);
    expect(s.menuPerbaikan, 0);
    expect(s.menuKantin, 1);
    expect(Store.fromJson({}).menuKantin, isNull);
  });

  test('Store membaca tanpa_absen; null dianggap wajib absen', () {
    expect(Store.fromJson({'tanpa_absen': 1}).tanpaAbsen, 1);
    expect(Store.fromJson({'tanpa_absen': 0}).tanpaAbsen, 0);
    expect(Store.fromJson({}).tanpaAbsen, isNull);
  });

  test('normalizePhone menerima +62/62 dan menolak format salah', () {
    expect(normalizePhone('0812-3456 7890'), '081234567890');
    expect(normalizePhone('+6281234567890'), '081234567890');
    expect(normalizePhone('6281234567890'), '081234567890');
    expect(normalizePhone('12345'), isNull);
    expect(normalizePhone('08abc12345678'), isNull);
  });
}
