# nbconvert config: stores the PNG figures of a notebook as compact 256-color PNGs.
# Dithering keeps gradients smooth, so the figures look the same while notebooks and the
# HTML sheets that embed them get much smaller. Figures with real transparency are kept.
# Run from the chapter folder, when executing a notebook:
#   jupyter nbconvert --to notebook --execute --inplace --config ../_quarto/compact_png.py sol_<stem>_py.ipynb
# or without --execute to compact a notebook that was saved from Jupyter or VS Code.
import base64
import io

from nbconvert.preprocessors import Preprocessor
from PIL import Image


def compact_png(png):
    im = Image.open(io.BytesIO(png))
    if im.mode not in ("RGB", "RGBA") or (im.mode == "RGBA" and im.getextrema()[3][0] < 255):
        return png  # already a palette image, or uses real transparency
    rgb = im.convert("RGB")
    palette = rgb.quantize(256, method=Image.Quantize.FASTOCTREE)
    buf = io.BytesIO()
    # keep the dpi: LaTeX uses it to size the figure in the PDF sheets
    rgb.quantize(palette=palette, dither=Image.Dither.FLOYDSTEINBERG).save(buf, "png", dpi=im.info.get("dpi", (72, 72)))
    return min(buf.getvalue(), png, key=len)


class CompactPNG(Preprocessor):
    def preprocess_cell(self, cell, resources, index):
        for output in cell.get("outputs", []):
            data = output.get("data", {})
            if "image/png" in data:
                png = base64.b64decode(data["image/png"])
                data["image/png"] = base64.b64encode(compact_png(png)).decode()
        return cell, resources


c = get_config()  # noqa: F821
c.Exporter.preprocessors = [CompactPNG]
