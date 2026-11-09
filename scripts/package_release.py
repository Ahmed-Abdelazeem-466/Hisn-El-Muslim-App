#!/usr/bin/env python3
"""Package verified Hisn APK, public Flutter source, and separate private key backup."""
import argparse
import hashlib
import json
import shutil
import zipfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--destination', type=Path, required=True)
    parser.add_argument('--version', default='1.0.2')
    parser.add_argument('--label', default='Separate-Weather-and-Food')
    args = parser.parse_args()
    dest = args.destination.resolve()
    dest.mkdir(parents=True, exist_ok=True)
    apk = ROOT / 'build/app/outputs/apk/release/app-release.apk'
    assert apk.is_file()
    book = json.loads((ROOT / 'assets/data/hisn-book.json').read_text())
    assert len(book['categories']) == 13
    assert len(book['chapters']) == 135
    assert sum(len(ch['blocks']) for ch in book['chapters']) == 320
    with zipfile.ZipFile(apk) as z:
        assert z.read('assets/flutter_assets/assets/data/hisn-book.json') == (ROOT / 'assets/data/hisn-book.json').read_bytes()
    delivered_apk = dest / f'Hisn-AlMuslim-{args.label}-v{args.version}.apk'
    shutil.copy2(apk, delivered_apk)
    source_zip = dest / f'Hisn-AlMuslim-{args.label}-v{args.version}-Flutter-Source.zip'
    excludes = {'build', '.dart_tool', '.git', '.gradle', '.idea', '.DS_Store', 'signing'}
    with zipfile.ZipFile(source_zip, 'w', zipfile.ZIP_DEFLATED) as z:
        for path in sorted(ROOT.rglob('*')):
            if not path.is_file():
                continue
            rel = path.relative_to(ROOT)
            if any(part in excludes for part in rel.parts):
                continue
            if path.name in {'local.properties', 'key.properties', '.flutter-plugins', '.flutter-plugins-dependencies'}:
                continue
            if path.suffix.lower() in {'.keystore', '.jks', '.p12', '.apk', '.log'}:
                continue
            z.write(path, Path('hisn-almuslim-flutter') / rel)
    private_zip = dest / f'Hisn-AlMuslim-PRIVATE-Signing-Key-Backup-v{args.version}.zip'
    with zipfile.ZipFile(private_zip, 'w', zipfile.ZIP_DEFLATED) as z:
        for rel in ['android/key.properties', 'android/signing/hisn-almuslim-release.p12']:
            assert (ROOT / rel).is_file()
            z.write(ROOT / rel, rel)
        z.writestr('KEEP-PRIVATE.txt', f'Keep this archive private and backed up. Extract into the Flutter project root to restore the release key introduced in v1.0.1 and reused for v{args.version}. Never replace it for future update builds. It cannot sign an update compatible with the old v1.0 APK.\n')
    with zipfile.ZipFile(source_zip) as z:
        assert z.testzip() is None
        assert not any(name.endswith(('key.properties', '.p12', '.keystore', '.jks')) for name in z.namelist())
        assert 'hisn-almuslim-flutter/test/category_split_test.dart' in z.namelist()
    files = [delivered_apk, source_zip, private_zip]
    checksum_lines = [f'{hashlib.sha256(path.read_bytes()).hexdigest()}  {path.name}' for path in files]
    (dest / 'SHA256SUMS.txt').write_text('\n'.join(checksum_lines) + '\n')
    for path in files:
        print(path.resolve())
    print('ZIP integrity, embedded asset and private-key separation verified.')


if __name__ == '__main__':
    main()
