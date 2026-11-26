// Helpers for make-grid-assets.ps1: fast pixel access for measuring and
// recolouring the banner (PowerShell's GetPixel is too slow for this).
using System;
using System.Drawing;
using System.Drawing.Imaging;
using System.Runtime.InteropServices;

public static class GridTools
{
    static byte[] Read(Bitmap b, out BitmapData d)
    {
        d = b.LockBits(new Rectangle(0, 0, b.Width, b.Height), ImageLockMode.ReadWrite, PixelFormat.Format32bppArgb);
        var px = new byte[d.Stride * b.Height];
        Marshal.Copy(d.Scan0, px, 0, px.Length);
        return px;
    }

    static void Write(Bitmap b, BitmapData d, byte[] px)
    {
        Marshal.Copy(px, 0, d.Scan0, px.Length);
        b.UnlockBits(d);
    }

    // Rightmost x (< maxX) in each row y0..y1 whose pixel is clearly blue-tinted (the diagonal).
    public static string BlueExtent(Bitmap b, int y0, int y1, int maxX, int step)
    {
        BitmapData d; var px = Read(b, out d);
        var sb = new System.Text.StringBuilder();
        for (int y = y0; y < y1; y += step)
        {
            int right = -1;
            for (int x = 0; x < maxX; x++)
            {
                int i = y * d.Stride + x * 4;
                int B = px[i], G = px[i + 1], R = px[i + 2];
                if (B - R > 25 && B > 120) right = x;
            }
            sb.AppendFormat("{0}:{1} ", y, right);
        }
        b.UnlockBits(d);
        return sb.ToString();
    }

    // x positions in row y where the pixel is a mid grey (the divider lines), with their colour.
    public static string Greys(Bitmap b, int y)
    {
        BitmapData d; var px = Read(b, out d);
        var sb = new System.Text.StringBuilder();
        for (int x = 0; x < b.Width; x++)
        {
            int i = y * d.Stride + x * 4;
            int B = px[i], G = px[i + 1], R = px[i + 2];
            if (R < 200 && Math.Abs(R - G) < 18 && Math.Abs(G - B) < 18) sb.AppendFormat("{0}({1},{2},{3}) ", x, R, G, B);
        }
        b.UnlockBits(d);
        return sb.ToString();
    }

    // Make the red and navy parts of the contact bar one flat colour each,
    // so they meet solid-colour text cells without a visible seam.
    public static void FlattenBar(Bitmap b, int y0, int y1, int redMaxX, Color red, Color navy)
    {
        BitmapData d; var px = Read(b, out d);
        for (int y = y0; y < y1; y++)
            for (int x = 0; x < b.Width; x++)
            {
                int i = y * d.Stride + x * 4;
                int B = px[i], G = px[i + 1], R = px[i + 2];
                bool isRed = x < redMaxX && R > 110 && G < 70 && B < 70 && R > 3 * Math.Max(G, B);
                bool isNavy = R < 45 && G < 65 && B > 55 && B < 125 && B > R + 35 && B > G + 20;
                if (isRed) { px[i] = red.B; px[i + 1] = red.G; px[i + 2] = red.R; }
                else if (isNavy) { px[i] = navy.B; px[i + 1] = navy.G; px[i + 2] = navy.R; }
            }
        Write(b, d, px);
    }

    public static string Pixel(Bitmap b, int x, int y)
    {
        var c = b.GetPixel(x, y);
        return string.Format("({0},{1},{2})", c.R, c.G, c.B);
    }
}
