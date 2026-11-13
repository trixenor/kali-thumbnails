#!/usr/bin/env bash
# kali-miniatures-complet.sh
# Miniatures dans Thunar (XFCE) sur Kali Linux : PSD, Illustrator, ZIP, vidéos, images spéciales, Office, polices.
# Un seul fichier, une seule commande :  bash kali-miniatures-complet.sh

set -u

DIR="$HOME/.local/share/thumbnailers"
BINDIR="$HOME/.local/bin"
ZIPTHUMB="$BINDIR/zip-thumb"
FONTTHUMB="$BINDIR/font-thumb"

DO_PSD=0; DO_AI=0; DO_ZIP=0; DO_VIDEO=0; DO_IMAGES=0; DO_OFFICE=0; DO_FONTS=0
UNINSTALL=0

usage() {
  cat << 'HELP'
kali-miniatures-complet.sh : miniatures dans Thunar sur Kali Linux

Utilisation :
  bash kali-miniatures-complet.sh               installe TOUT (par défaut)
  bash kali-miniatures-complet.sh --psd         Photoshop (.psd)
  bash kali-miniatures-complet.sh --ai          Illustrator (.ai) et EPS
  bash kali-miniatures-complet.sh --zip         ZIP : première image de l'archive (aussi .cbz, .ora, .kra)
  bash kali-miniatures-complet.sh --video       vidéos (mp4, mkv, avi, webm...)
  bash kali-miniatures-complet.sh --images      WebP, SVG, HEIC, AVIF, XCF (GIMP)
  bash kali-miniatures-complet.sh --office      Word, Excel, PowerPoint (si l'aperçu est dans le fichier)
  bash kali-miniatures-complet.sh --fonts       polices .ttf/.otf et ZIP de polices (aperçu « Aa Abc 123 »)
  bash kali-miniatures-complet.sh --uninstall   supprime les générateurs ajoutés (combinable avec les options ci-dessus)
  bash kali-miniatures-complet.sh --help        affiche cette aide

Les options se combinent : bash kali-miniatures-complet.sh --psd --ai --zip
Les PDF et les polices sont déjà gérés par tumbler-plugins-extra.
HELP
  exit 0
}

for arg in "$@"; do
  case "$arg" in
    --psd) DO_PSD=1 ;;
    --ai) DO_AI=1 ;;
    --zip) DO_ZIP=1 ;;
    --video) DO_VIDEO=1 ;;
    --images) DO_IMAGES=1 ;;
    --office) DO_OFFICE=1 ;;
    --fonts) DO_FONTS=1 ;;
    --all) DO_PSD=1; DO_AI=1; DO_ZIP=1; DO_VIDEO=1; DO_IMAGES=1; DO_OFFICE=1; DO_FONTS=1 ;;
    --uninstall) UNINSTALL=1 ;;
    -h|--help) usage ;;
    *) echo "Option inconnue : $arg"; echo "Essaie : bash $0 --help"; exit 1 ;;
  esac
done

# Sans option de format : tout
if [ $((DO_PSD + DO_AI + DO_ZIP + DO_VIDEO + DO_IMAGES + DO_OFFICE + DO_FONTS)) -eq 0 ]; then
  DO_PSD=1; DO_AI=1; DO_ZIP=1; DO_VIDEO=1; DO_IMAGES=1; DO_OFFICE=1; DO_FONTS=1
fi

restart_thumbnails() {
  echo "==> Redémarrage de tumbler et de Thunar, cache vidé"
  pkill tumblerd 2>/dev/null
  rm -rf "$HOME/.cache/thumbnails"
  if command -v thunar >/dev/null 2>&1; then
    thunar -q 2>/dev/null
    sleep 1
    (thunar >/dev/null 2>&1 &)
  fi
}

# Installe chaque paquet s'il existe dans les dépôts (sans planter sinon)
apt_try() {
  for p in "$@"; do
    if apt-cache show "$p" >/dev/null 2>&1; then
      sudo apt install -y "$p" || echo "Échec d'installation : $p (ignoré)"
    else
      echo "Paquet absent des dépôts (ignoré) : $p"
    fi
  done
}

# ====================== DÉSINSTALLATION ======================
if [ "$UNINSTALL" -eq 1 ]; then
  echo "==> Suppression des générateurs"
  [ "$DO_PSD" -eq 1 ] && rm -f "$DIR/psd.thumbnailer"
  [ "$DO_AI" -eq 1 ] && rm -f "$DIR/ai.thumbnailer"
  [ "$DO_ZIP" -eq 1 ] && rm -f "$DIR/zip.thumbnailer"
  [ "$DO_IMAGES" -eq 1 ] && rm -f "$DIR/images-extra.thumbnailer"
  [ "$DO_OFFICE" -eq 1 ] && rm -f "$DIR/office.thumbnailer"
  [ "$DO_FONTS" -eq 1 ] && rm -f "$DIR/fonts.thumbnailer" "$FONTTHUMB"
  # L'assistant zip-thumb n'est supprimé que s'il n'est plus utilisé
  if [ ! -f "$DIR/zip.thumbnailer" ] && [ ! -f "$DIR/office.thumbnailer" ]; then
    rm -f "$ZIPTHUMB"
  fi
  restart_thumbnails
  echo "Terminé."
  exit 0
fi

# Les polices zippées passent par l'assistant zip
[ "$DO_FONTS" -eq 1 ] && DO_ZIP=1

# ====================== PAQUETS ======================
echo "==> Mise à jour des paquets"
sudo apt update

echo "==> Base : tumbler (moteur de miniatures)"
apt_try tumbler tumbler-plugins-extra

NEED_IM=0
[ "$DO_PSD" -eq 1 ] && NEED_IM=1
[ "$DO_IMAGES" -eq 1 ] && NEED_IM=1
[ "$DO_ZIP" -eq 1 ] && NEED_IM=1
[ "$DO_OFFICE" -eq 1 ] && NEED_IM=1
[ "$DO_FONTS" -eq 1 ] && NEED_IM=1

[ "$NEED_IM" -eq 1 ] && apt_try imagemagick
[ "$DO_AI" -eq 1 ] && apt_try ghostscript
{ [ "$DO_ZIP" -eq 1 ] || [ "$DO_OFFICE" -eq 1 ]; } && apt_try unzip
[ "$DO_VIDEO" -eq 1 ] && apt_try ffmpegthumbnailer
[ "$DO_IMAGES" -eq 1 ] && apt_try webp-pixbuf-loader librsvg2-common heif-gdk-pixbuf libheif-gdk-pixbuf

mkdir -p "$DIR" "$BINDIR"

# ====================== LIMITES IMAGEMAGICK ======================
if [ "$DO_PSD" -eq 1 ] || [ "$DO_IMAGES" -eq 1 ]; then
  echo "==> Limites ImageMagick relevées (gros fichiers)"
  for p in /etc/ImageMagick-6/policy.xml /etc/ImageMagick-7/policy.xml; do
    [ -f "$p" ] && sudo sed -i -E \
      -e 's/(name="memory" value=")[^"]*"/\14GiB"/' \
      -e 's/(name="map" value=")[^"]*"/\14GiB"/' \
      -e 's/(name="area" value=")[^"]*"/\12GP"/' \
      -e 's/(name="disk" value=")[^"]*"/\18GiB"/' "$p"
  done
fi

CONVERT=$(command -v convert || command -v magick || true)

# ====================== PSD ======================
if [ "$DO_PSD" -eq 1 ]; then
  if [ -z "$CONVERT" ]; then
    echo "Erreur : ImageMagick introuvable, PSD ignoré."
  else
    echo "==> Générateur PSD"
    cat > "$DIR/psd.thumbnailer" << EOF
[Thumbnailer Entry]
TryExec=$CONVERT
Exec=$CONVERT %i[0] -thumbnail %sx%s png:%o
MimeType=image/vnd.adobe.photoshop;image/x-psd;application/x-photoshop;application/photoshop;
EOF
  fi
fi

# ====================== ILLUSTRATOR / EPS ======================
if [ "$DO_AI" -eq 1 ]; then
  GS=$(command -v gs || true)
  if [ -z "$GS" ]; then
    echo "Erreur : Ghostscript introuvable, AI ignoré."
  else
    echo "==> Générateur AI et EPS"
    # Les .ai récents sont des PDF : rendu avec Ghostscript
    # (la politique ImageMagick de Kali bloque le format PDF)
    cat > "$DIR/ai.thumbnailer" << EOF
[Thumbnailer Entry]
TryExec=$GS
Exec=$GS -dNOPAUSE -dBATCH -dSAFER -dQUIET -sDEVICE=png16m -dTextAlphaBits=4 -dGraphicsAlphaBits=4 -dUseCropBox -dFirstPage=1 -dLastPage=1 -dPDFFitPage -dDEVICEWIDTHPOINTS=%s -dDEVICEHEIGHTPOINTS=%s -sOutputFile=%o %i
MimeType=application/illustrator;application/vnd.adobe.illustrator;application/postscript;image/x-eps;image/eps;application/eps;
EOF
  fi
fi

# ====================== ASSISTANT POLICES ======================
if [ "$DO_FONTS" -eq 1 ]; then
  if [ -z "$CONVERT" ]; then
    echo "Erreur : ImageMagick introuvable, polices ignorées."
    DO_FONTS=0
  else
    echo "==> Assistant font-thumb"
    cat > "$FONTTHUMB" << 'EOF'
#!/usr/bin/env bash
# font-thumb police.ttf taille sortie.png : dessine « Aa » et « Abc 123 » avec la police
f="$1"; size="$2"; out="$3"
CONVERT="@CONVERT@"
p1=$((size / 3)); p2=$((size / 10)); off=$((size / 8)); off2=$((size / 4))
"$CONVERT" -size "${size}x${size}" xc:white -fill '#111111' -font "$f" -gravity center \
  -pointsize "$p1" -annotate "+0-${off}" 'Aa' \
  -pointsize "$p2" -annotate "+0+${off2}" 'Abc 123' "png:$out"
EOF
    sed -i "s|@CONVERT@|$CONVERT|" "$FONTTHUMB"
    chmod +x "$FONTTHUMB"
  fi
fi

# ====================== ASSISTANT ZIP (ZIP + OFFICE + POLICES) ======================
if [ "$DO_ZIP" -eq 1 ] || [ "$DO_OFFICE" -eq 1 ]; then
  if [ -z "$CONVERT" ]; then
    echo "Erreur : ImageMagick introuvable, ZIP et Office ignorés."
    DO_ZIP=0; DO_OFFICE=0
  else
    echo "==> Assistant zip-thumb"
    cat > "$ZIPTHUMB" << 'EOF'
#!/usr/bin/env bash
# zip-thumb archive taille sortie.png [strict]
# Cherche une image d'aperçu dans une archive zip et la convertit en miniature.
# Mode "strict" : n'accepte que les aperçus intégrés (documents Office), pas la première image venue.
zip="$1"; size="$2"; out="$3"; mode="${4:-any}"
CONVERT="@CONVERT@"
FONTTHUMB="@FONTTHUMB@"

list=$(unzip -Z1 "$zip" 2>/dev/null) || exit 1

name=""
for cand in "mergedimage.png" "Thumbnails/thumbnail.png" "docProps/thumbnail.jpeg" \
            "docProps/thumbnail.jpg" "docProps/thumbnail.png" "preview.png" "Preview.png"; do
  if printf '%s\n' "$list" | grep -qxF "$cand"; then name="$cand"; break; fi
done

# Polices : aperçu de la première police (de préférence "Regular") si l'assistant font-thumb existe
if [ -z "$name" ] && [ "$mode" != "strict" ] && [ -x "$FONTTHUMB" ]; then
  fl=$(printf '%s\n' "$list" | grep -v '^__MACOSX/' | grep -v '/\._' | grep -iE '\.(ttf|otf)$')
  font=$(printf '%s\n' "$fl" | grep -i 'regular' | head -n1)
  [ -z "$font" ] && font=$(printf '%s\n' "$fl" | head -n1)
  if [ -n "$font" ]; then
    tmp=$(mktemp -d)
    ext=$(printf '%s' "${font##*.}" | tr 'A-Z' 'a-z')
    fesc=$(printf '%s' "$font" | sed 's/[][*?\\]/\\&/g')
    unzip -p "$zip" "$fesc" > "$tmp/f.$ext"
    "$FONTTHUMB" "$tmp/f.$ext" "$size" "$out"
    rc=$?
    rm -rf "$tmp"
    exit $rc
  fi
fi

if [ -z "$name" ] && [ "$mode" != "strict" ]; then
  name=$(printf '%s\n' "$list" \
    | grep -v '^__MACOSX/' | grep -v '/\._' | grep -v '/$' \
    | grep -iE '\.(png|jpe?g|gif|webp)$' | head -n1)
fi

[ -z "$name" ] && exit 1

# unzip traite les noms comme des motifs : échapper [ ] * ? \
esc=$(printf '%s' "$name" | sed 's/[][*?\\]/\\&/g')
unzip -p "$zip" "$esc" | "$CONVERT" '-[0]' -thumbnail "${size}x${size}" "png:$out"
EOF
    sed -i "s|@CONVERT@|$CONVERT|; s|@FONTTHUMB@|$FONTTHUMB|" "$ZIPTHUMB"
    chmod +x "$ZIPTHUMB"
  fi
fi

# ====================== ZIP ======================
if [ "$DO_ZIP" -eq 1 ]; then
  echo "==> Générateur ZIP (aussi .cbz, .ora, .kra)"
  cat > "$DIR/zip.thumbnailer" << EOF
[Thumbnailer Entry]
TryExec=$ZIPTHUMB
Exec=$ZIPTHUMB %i %s %o
MimeType=application/zip;application/x-zip-compressed;application/x-cbz;application/vnd.comicbook+zip;image/openraster;application/x-krita;
EOF
fi

# ====================== OFFICE ======================
if [ "$DO_OFFICE" -eq 1 ]; then
  echo "==> Générateur Office (docx, xlsx, pptx : aperçu intégré au fichier)"
  cat > "$DIR/office.thumbnailer" << EOF
[Thumbnailer Entry]
TryExec=$ZIPTHUMB
Exec=$ZIPTHUMB %i %s %o strict
MimeType=application/vnd.openxmlformats-officedocument.wordprocessingml.document;application/vnd.openxmlformats-officedocument.spreadsheetml.sheet;application/vnd.openxmlformats-officedocument.presentationml.presentation;
EOF
fi

# ====================== POLICES ======================
if [ "$DO_FONTS" -eq 1 ]; then
  echo "==> Générateur polices (.ttf, .otf)"
  cat > "$DIR/fonts.thumbnailer" << EOF
[Thumbnailer Entry]
TryExec=$FONTTHUMB
Exec=$FONTTHUMB %i %s %o
MimeType=font/ttf;font/otf;font/sfnt;application/x-font-ttf;application/x-font-otf;application/x-font-opentype;application/font-sfnt;application/vnd.ms-opentype;
EOF
fi

# ====================== IMAGES SPÉCIALES ======================
if [ "$DO_IMAGES" -eq 1 ]; then
  if [ -z "$CONVERT" ]; then
    echo "Erreur : ImageMagick introuvable, XCF/HEIC/AVIF ignorés."
  else
    echo "==> Générateur XCF, HEIC, AVIF (WebP et SVG passent par gdk-pixbuf)"
    cat > "$DIR/images-extra.thumbnailer" << EOF
[Thumbnailer Entry]
TryExec=$CONVERT
Exec=$CONVERT %i[0] -thumbnail %sx%s png:%o
MimeType=image/x-xcf;image/heic;image/heif;image/avif;
EOF
  fi
fi

# ====================== THUNAR ======================
if command -v xfconf-query >/dev/null 2>&1; then
  echo "==> Thunar : miniatures toujours actives, limite de taille à 10 Go"
  xfconf-query -c thunar -p /misc-thumbnail-mode --create -t string -s THUNAR_THUMBNAIL_MODE_ALWAYS
  xfconf-query -c thunar -p /misc-thumbnail-max-file-size --create -t uint64 -s 10737418240
else
  echo "xfconf-query absent : active les miniatures à la main dans Thunar (Édition > Préférences > Affichage)."
fi

restart_thumbnails

echo
echo "==> Générateurs installés :"
ls -1 "$DIR"
echo
echo "Terminé. Ouvre ton dossier en vue icônes (Ctrl+1) et attends quelques secondes."
echo "Si une miniature reste générique, vérifie son type : xdg-mime query filetype fichier"
