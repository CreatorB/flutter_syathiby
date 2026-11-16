"""Beri nama unik per-konten pada font hasil tree-shaking Flutter web.

Flutter web menulis font ikon hasil `--tree-shake-icons` ke
`assets/fonts/MaterialIcons-Regular.otf` dengan nama yang SELALU sama. Browser
dan Cloudflare menyimpannya berbulan-bulan (max-age 1 tahun), padahal isi font
berubah setiap kali ada ikon baru. Akibatnya ikon baru tampil sebagai lingkaran
kosong: glifnya tidak ada di font lama yang masih dilayani.

Skrip ini mengganti nama file font dengan `<nama>-<md5[:8]>.<ext>` lalu
memperbarui `assets/FontManifest.json` dan kunci RESOURCES di
`flutter_service_worker.js`. Nama berbasis konten: kalau isi font tidak
berubah, nama juga tidak berubah sehingga cache tetap terpakai.

Pakai: python -I versi-font-web.py <folder-build-web>
"""
import hashlib
import json
import re
import sys
from pathlib import Path


def md5(path: Path) -> str:
    return hashlib.md5(path.read_bytes()).hexdigest()


def main() -> int:
    if len(sys.argv) != 2:
        print("Pakai: versi-font-web.py <folder-build-web>")
        return 1
    build = Path(sys.argv[1]).resolve()
    manifest_path = build / 'assets' / 'FontManifest.json'
    sw_path = build / 'flutter_service_worker.js'
    if not manifest_path.is_file():
        print('GAGAL: FontManifest.json tidak ada di ' + str(build))
        return 1

    asset_manifest = (build / 'assets' / 'AssetManifest.bin')
    bin_bytes = asset_manifest.read_bytes() if asset_manifest.is_file() else b''

    manifest = json.loads(manifest_path.read_text(encoding='utf-8'))
    sw = sw_path.read_text(encoding='utf-8') if sw_path.is_file() else ''

    berubah = []
    for entry in manifest:
        for font in entry.get('fonts', []):
            asset = font.get('asset')
            if not asset:
                continue
            file_path = build / 'assets' / asset
            if not file_path.is_file():
                print('LEWAT (tidak ada): ' + asset)
                continue
            # Asset yang ikut AssetManifest.bin tidak boleh diganti namanya;
            # manifest itu biner dan tidak bisa disunting dengan aman.
            if asset.encode('utf-8') in bin_bytes:
                print('LEWAT (terdaftar di AssetManifest.bin): ' + asset)
                continue

            h = md5(file_path)
            baru = '{}-{}{}'.format(file_path.stem, h[:8], file_path.suffix)
            if baru == file_path.name:
                continue

            file_path.rename(file_path.with_name(baru))
            font['asset'] = str(Path(asset).with_name(baru))

            key_lama = 'assets/' + asset
            key_baru = 'assets/' + font['asset']
            sw = re.sub(
                r'"' + re.escape(key_lama) + r'":\s*"([a-f0-9]{32})"',
                lambda m: '"{}": "{}"'.format(key_baru, m.group(1)),
                sw,
            )
            berubah.append('{} -> {}'.format(asset, font['asset']))

    manifest_path.write_text(
        json.dumps(manifest, separators=(',', ':')), encoding='utf-8')
    if sw:
        sw_path.write_text(sw, encoding='utf-8')

    if berubah:
        for b in berubah:
            print('DIGANTI: ' + b)
    else:
        print('Tidak ada font yang perlu diganti namanya.')
    return 0


if __name__ == '__main__':
    sys.exit(main())
