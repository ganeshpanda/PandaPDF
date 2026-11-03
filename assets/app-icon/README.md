# PandaPDF app icon

<img src="hicolor/128x128/apps/ai.storyteller.pdfcraft.png" alt="PandaPDF app icon: a panda holding a PDF document, in a dark ring" width="128">

**Artwork:** the PandaPDF logo, a panda holding a red-tabbed PDF document inside a dark ring. The
full logo with the "PandaPDF" wordmark is [`../brand/pandapdf-logo.png`](../brand/pandapdf-logo.png).

**Provenance:** supplied by the PandaPDF owner as a raster image. The icon is the ring cropped from
it (everything outside the ring transparent), squared and scaled to each size. It replaces the lion
icon of PdfCraft, the project PandaPDF is based on.
Licence: [LICENSE.txt](LICENSE.txt) (`MIT OR Apache-2.0`, like the repo).

## Files

The file names are PdfCraft's, so the build and packaging scripts find them unchanged.

| File | What it is |
|---|---|
| `pdfcraft.svg` | the 1024 px icon wrapped in SVG (the artwork is raster) |
| `pdfcraft-small.svg` | the 128 px icon wrapped in SVG |
| `pdfcraft-1024.png` | 1024 px; also the runtime Dock icon on macOS |
| `pdfcraft.icns` | macOS icon (16–1024 px) |
| `pdfcraft.ico` | Windows icon (16–256 px), embedded in `pdfcraft.exe` by `apps/pdfcraft/build.rs` |
| `pdfcraft-document.svg` | Windows PDF file icon master: a Lucide document outline, red badge and outlined PDF lettering; no font dependency |
| `pdfcraft-document.ico` | Windows PDF file icon (16–256 px), embedded as resource 2 in `pdfcraft.exe` |
| `hicolor/<n>x<n>/apps/ai.storyteller.pdfcraft.png` | Linux hicolor theme, 16–512 px; the 256 px one is the runtime icon on Windows and Linux, and the About dialog and home screen show it |
| `hicolor/scalable/apps/ai.storyteller.pdfcraft.svg` | Linux scalable icon (the 512 px icon wrapped in SVG) |

Where it shows: `apps/pdfcraft/src/main.rs` sets the window icon (Dock, taskbar, Alt-Tab, launcher) and the
Wayland app id `ai.storyteller.pdfcraft`; `packaging/linux/ai.storyteller.pdfcraft.desktop` names the
hicolor icon.

Windows PDF files use resource 2 (`"pdfcraft.exe",-2`) when PandaPDF is chosen as the default
reader; the app keeps resource 1. The document outline is adapted from Lucide `file-text`
1.49.0 (ISC); its badge and outlined lettering are original (`MIT OR Apache-2.0`), covered by
[LICENSE-document.txt](LICENSE-document.txt).

## Regenerate

`packaging/icons.sh` renders PdfCraft's vector master and no longer applies. To change the icon, render
each PNG size from the new artwork, rebuild the `.ico` and `.icns` from them, then:

```sh
cargo xtask assets        # update the sha256 values in ATTRIBUTION.toml, then run with --write
```
