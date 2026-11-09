import 'package:flutter_test/flutter_test.dart';
import 'package:syathiby/utils/alur_kegiatan.dart';

void main() {
  group('isAlurTim', () {
    test('perbaikan dan jasa memakai alur tim', () {
      expect(isAlurTim('Perbaikan'), isTrue);
      expect(isAlurTim('Jasa'), isTrue);
      expect(isAlurTim('jasa'), isTrue);
      expect(isAlurTim(' Perbaikan '), isTrue);
    });

    test('jenis lain tidak memakai alur tim', () {
      expect(isAlurTim('Pengadaan Barang'), isFalse);
      expect(isAlurTim(''), isFalse);
      expect(isAlurTim(null), isFalse);
    });
  });

  group('isJenisPerbaikan', () {
    test('hanya perbaikan', () {
      expect(isJenisPerbaikan('Perbaikan'), isTrue);
      expect(isJenisPerbaikan('perbaikan'), isTrue);
      expect(isJenisPerbaikan('Jasa'), isFalse);
      expect(isJenisPerbaikan(null), isFalse);
    });
  });
}
