#!/usr/bin/env python3
"""Siapkan stempel build untuk aplikasi web.

Yang dilakukan:
1. `web/version.json` diberi/ diperbarui field `buildStamp` (mis.
   `20261122-2330`). Field ini dibaca aplikasi dari server saat start.
2. Salinan `web/version.json` ditulis ke `assets/version.json` -> file ini ikut
   terbawa ke dalam bundle Flutter, jadi representsi bundle yang SEDANG
   BERJALAN.

Dengan begitu aplikasi web bisa mendeteksi sendiri bahwa server sudah punya
build lebih baru: bundle lama dibersihkan dari cache service worker lalu
halaman di-reload. Tanpa ini, browser yang sudah pernah membuka aplikasi
terus menampilkan tampilan lama walaupun file di server sudah diperbarui.

Pakai:
    python -I tool/set_build_stamp.py            # stempel dari waktu sekarang
    python -I tool/set_build_stamp.py 20261122-2330
"""
import datetime
import json
import pathlib
import shutil
import sys

root = pathlib.Path(__file__).resolve().parent.parent
stamp = sys.argv[1] if len(sys.argv) > 1 else datetime.datetime.now().strftime('%Y%m%d-%H%M')

versi = root / 'web' / 'version.json'
data = json.loads(versi.read_text(encoding='utf-8'))
data['buildStamp'] = stamp
versi.write_text(json.dumps(data, ensure_ascii=False, indent=2) + '\n', encoding='utf-8', newline='\n')

tujuan = root / 'assets' / 'version.json'
tujuan.parent.mkdir(parents=True, exist_ok=True)
shutil.copyfile(versi, tujuan)

print('buildStamp =', stamp)
print('ditulis   :', versi, 'dan', tujuan)
