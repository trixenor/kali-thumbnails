# kali-thumbnails

**One-command file thumbnails for Thunar on Kali Linux (XFCE).**
PSD, Illustrator (AI/EPS), ZIP archives, fonts (even zipped), videos, WebP, SVG, HEIC, AVIF, XCF and Office documents get a real preview instead of a generic icon.

*Miniatures (aperçus) pour Thunar sur Kali Linux : PSD, Illustrator, ZIP, polices, vidéos, images spéciales et Office, avec un seul script.*

## Features

| Option | Formats |
|---|---|
| `--psd` | Photoshop (`.psd`) |
| `--ai` | Illustrator (`.ai`) and EPS |
| `--zip` | ZIP: first image inside the archive (also `.cbz`, `.ora`, `.kra`) |
| `--video` | mp4, mkv, avi, webm... |
| `--images` | WebP, SVG, HEIC, AVIF, XCF (GIMP) |
| `--office` | Word, Excel, PowerPoint (when the file embeds a preview) |
| `--fonts` | `.ttf` / `.otf` fonts and ZIPs of fonts (preview "Aa Abc 123") |
| `--uninstall` | Remove the thumbnailers added by the script |

PDF files are already handled by `tumbler-plugins-extra`, which the script installs.

## Quick start

```bash
git clone https://github.com/trixenor/kali-thumbnails.git
cd kali-thumbnails
bash kali-miniatures-complet.sh
```

Without options, everything is installed. Options can be combined:

```bash
bash kali-miniatures-complet.sh --psd --ai --zip
```

Then open a folder in Thunar, switch to icon view (`Ctrl+1`) and wait a few seconds: large files are slow the first time.

## How it works

Thunar delegates previews to `tumbler`. The script installs the needed tools (ImageMagick, Ghostscript, ffmpegthumbnailer...), drops `.thumbnailer` files in `~/.local/share/thumbnailers/`, adds two small helpers (`zip-thumb`, `font-thumb`) in `~/.local/bin/`, enables thumbnails in Thunar and restarts `tumblerd`. It is safe to run again.

## Known limits

- **ZIP**: a thumbnail appears only if the archive contains an image (PNG, JPG, GIF, WebP) or, with `--fonts`, a `.ttf`/`.otf` font.
- **Office**: the document must embed a preview, which many do not.
- **AI**: very old Illustrator files (before CS) are not PDF-based and may never get a thumbnail. Non-square artboards can show white margins.
- **Fonts**: `.woff` and `.woff2` are not supported.

## Troubleshooting

```bash
xdg-mime query filetype "my file.psd"      # check the detected MIME type
pkill tumblerd; rm -rf ~/.cache/thumbnails # restart thumbnails
```

If the MIME type is missing from the `MimeType=` line of the matching file in `~/.local/share/thumbnailers/`, add it. In Thunar, check *Edit > Preferences > Display > Thumbnails* (always on, highest file size limit). More details in [`docs/MODE-EMPLOI.txt`](docs/MODE-EMPLOI.txt).

---

# Français

## À quoi ça sert

Afficher des miniatures dans **Thunar**, le gestionnaire de fichiers de Kali, pour des fichiers qui n'en ont pas par défaut : fichiers Photoshop, Illustrator, ZIP, polices (même zippées), vidéos, etc.

## Installation en 3 étapes

1. Télécharge le dépôt : `git clone https://github.com/trixenor/kali-thumbnails.git` puis `cd kali-thumbnails`.
2. Lance le script : `bash kali-miniatures-complet.sh`
3. Entre ton mot de passe quand `sudo` le demande (rien ne s'affiche, c'est normal) et attends le message « Terminé ». Thunar redémarre tout seul.

## Voir les miniatures

Ouvre un dossier contenant tes fichiers, passe en vue icônes (`Ctrl+1`) et attends quelques secondes.

## Choisir les formats

Sans option, tout est installé. Pour choisir : `--psd`, `--ai`, `--zip`, `--video`, `--images`, `--office`, `--fonts`. Les options se combinent. Pour tout supprimer : `bash kali-miniatures-complet.sh --uninstall`.

## Si une miniature ne s'affiche pas

Vérifie le type du fichier avec `xdg-mime query filetype "mon fichier.psd"`. S'il n'est pas dans la ligne `MimeType=` du bon fichier de `~/.local/share/thumbnailers/`, ajoute-le, puis lance `pkill tumblerd; rm -rf ~/.cache/thumbnails` et rouvre Thunar. Le mode d'emploi complet est dans [`docs/MODE-EMPLOI.txt`](docs/MODE-EMPLOI.txt).

## License / Licence

MIT License, see [`LICENSE`](LICENSE). / Licence MIT, voir [`LICENSE`](LICENSE).

## Contributing / Contribuer

Issues and pull requests are welcome, see [`CONTRIBUTING.md`](CONTRIBUTING.md). / Les suggestions et corrections sont les bienvenues.

---

*Keywords: Kali Linux, Thunar, XFCE, thumbnails, thumbnailer, tumbler, PSD preview, Photoshop, Illustrator, AI, EPS, ZIP preview, font preview, TTF, OTF, miniatures, aperçu, polices.*
