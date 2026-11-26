"""Build the one-file signature maker with all three versions as tabs.

Every banner marked EMBED in combined.html is replaced by that file as a data URL,
so the result opens by double-clicking and works offline (the Text Details tab
still loads its banner from GitHub Pages, as the signature itself does).

Usage:  python build-combined.py
Output: release/Bigfoot Signature Maker - All Versions.html
"""
from pathlib import Path
import base64
import re

root = Path(__file__).parent
page = (root / 'combined.html').read_text(encoding='utf-8')
types = {'.png': 'image/png', '.webp': 'image/webp', '.jpg': 'image/jpeg'}


def embed(m):
    f = root / m.group(1)
    data = base64.b64encode(f.read_bytes()).decode('ascii')
    return "'data:%s;base64,%s'" % (types[f.suffix.lower()], data)


page, n = re.subn(r"/\*EMBED\*/'([^']+)'", embed, page)
assert n == 4, 'Expected 4 banners to embed, found %d' % n

out = root / 'release' / 'Bigfoot Signature Maker - All Versions.html'
out.parent.mkdir(exist_ok=True)
out.write_text(page, encoding='utf-8', newline='\n')
print('Built', out, '(%.1f MB)' % (out.stat().st_size / 1e6))
