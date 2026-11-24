"""Build a single offline HTML file that staff can open by double-clicking.

The banner is embedded in the page, so there are no other files to keep
alongside it, and the browser lets the page export the finished PNG even
when it is opened straight from disk.

Usage:  python build-standalone.py
Output: release/Bigfoot Signature Maker.html
"""
from pathlib import Path
import base64

root = Path(__file__).parent
page = (root / 'index.html').read_text(encoding='utf-8')
banner = base64.b64encode((root / 'background.png').read_bytes()).decode('ascii')

marker = "bg.src = 'background.png';"
assert page.count(marker) == 1, 'Could not find where the page loads background.png'
page = page.replace(marker, "bg.src = 'data:image/png;base64," + banner + "';")

out = root / 'release' / 'Bigfoot Signature Maker.html'
out.parent.mkdir(exist_ok=True)
out.write_text(page, encoding='utf-8', newline='\n')
print('Built', out, '(%.1f MB)' % (out.stat().st_size / 1e6))
