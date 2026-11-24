# BigfootSignature

Email signature maker for Bigfoot Group. Type your name, title, email and phone numbers, then download or copy the finished signature as a PNG. The email disclaimer can be copied from the same page.

## For staff

Open **`release/Bigfoot Signature Maker.html`** by double-clicking it. It opens in your browser (Chrome or Edge) and works offline; nothing is sent anywhere. It is one self-contained file, so it can be shared on the company drive, Teams or by email.

Use a Windows PC: the text uses Segoe UI Bold, which only comes with Windows.

## For maintainers

- `index.html` – the page source
- `background.png` – signature banner (2038 × 772) the text is drawn onto
- `build-standalone.py` – builds the single shareable file

After changing `index.html` or `background.png`, rebuild the shareable file and commit it:

```
python build-standalone.py
```

Text positions are in the `TEXT POSITIONS` block in `index.html`, in the same pixels as the Photoshop file.
