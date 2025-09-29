# save as make_pdf_ocr_harder.py
import fitz                  # PyMuPDF
from PIL import Image, ImageFilter, ImageDraw, ImageFont
import numpy as np
import io
import math
import sys

def perlin_noise(width, height, scale=8.0, octaves=3, persistence=0.5, lacunarity=2.0, seed=None):
    # Simple fractal noise using summed Gaussian-smoothed random layers (not full Perlin)
    if seed is not None:
        np.random.seed(seed)
    noise = np.zeros((height, width), dtype=np.float32)
    frequency = scale
    amplitude = 1.0
    for _ in range(octaves):
        layer = np.random.randn(height, width).astype(np.float32)
        # gaussian blur via FFT-friendly smoothing; using simple resizing for speed
        layer = Image.fromarray(((layer - layer.min()) / (layer.max() - layer.min() + 1e-9) * 255).astype('uint8'))
        layer = layer.resize((max(1, int(width/frequency)), max(1, int(height/frequency))), resample=Image.BILINEAR)
        layer = layer.resize((width, height), resample=Image.BILINEAR)
        layer = np.asarray(layer).astype(np.float32)/255.0
        noise += layer * amplitude
        amplitude *= persistence
        frequency *= lacunarity
    # normalize
    noise = (noise - noise.min()) / (noise.max() - noise.min() + 1e-9)
    return noise

def add_noise_and_artifacts(pil_img, noise_strength=0.12, grain_scale=6.0, lines=3, seed=None):
    w, h = pil_img.size
    arr = np.asarray(pil_img).astype(np.float32) / 255.0

    # grayscale luminance for noise blending if image RGB
    if arr.ndim == 3:
        base = arr.copy()
    else:
        base = np.stack([arr]*3, axis=2)

    # Perlin-esque fractal noise (low frequency)
    smooth_noise = perlin_noise(w, h, scale=grain_scale, octaves=4, seed=seed)

    # high-frequency speckle noise
    speckle = np.random.RandomState(seed).randn(h, w) * noise_strength

    # combine noises
    combined = (smooth_noise * 0.6 + (speckle - speckle.min())/(speckle.max()-speckle.min()+1e-9)*0.4)
    combined = (combined - combined.min()) / (combined.max() - combined.min() + 1e-9)
    # convert to 3-channel subtle overlay (tint to paper color if desired)
    overlay = np.stack([combined]*3, axis=2)

    # blend overlay onto base with low alpha
    alpha = 0.18  # controls visibility of noise
    noisy = np.clip(base*(1.0 - alpha) + overlay*alpha, 0, 1.0)

    # convert back to PIL image
    noisy_img = Image.fromarray((noisy*255).astype('uint8'))

    draw = ImageDraw.Draw(noisy_img)
    # add faint thin curved lines to break baselines
    rng = np.random.RandomState(seed)
    for i in range(lines):
        y = rng.randint(int(0.1*h), int(0.9*h))
        amplitude = rng.randint(int(0.005*h), int(0.03*h))
        frequency = rng.uniform(0.0005, 0.002) # controls horizontal frequency
        path = []
        for x in range(0, w, 6):
            yy = int(y + amplitude * math.sin(2*math.pi*frequency*x + rng.uniform(0, 2*math.pi)))
            path.append((x, yy))
        # draw a faint curve
        draw.line(path, fill=(0,0,0, int(18)), width=1)
    # slight blur to mimic scanning artifacts
    noisy_img = noisy_img.filter(ImageFilter.GaussianBlur(radius=0.6))

    return noisy_img

def process_pdf(input_pdf, output_pdf, dpi=300, noise_strength=0.12, seed=42):
    doc = fitz.open(input_pdf)
    out_images = []
    for page_num in range(len(doc)):
        page = doc.load_page(page_num)
        mat = fitz.Matrix(dpi/72, dpi/72)  # scale to DPI
        pix = page.get_pixmap(matrix=mat, alpha=False)
        img = Image.frombytes("RGB", [pix.width, pix.height], pix.samples)
        noisy = add_noise_and_artifacts(img, noise_strength=noise_strength, grain_scale=6.0, lines=2, seed=seed+page_num)
        out_images.append(noisy.convert('RGB'))

    # Save images back to PDF (preserves page size roughly)
    out_images[0].save(output_pdf, save_all=True, append_images=out_images[1:], resolution=dpi)
    doc.close()

if __name__ == "__main__":
    if len(sys.argv) < 3:
        print("Usage: python make_pdf_ocr_harder.py input.pdf output.pdf")
        sys.exit(1)
    process_pdf(sys.argv[1], sys.argv[2], dpi=300, noise_strength=0.10, seed=12345)

