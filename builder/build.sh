#!/bin/sh
# Stage 2: läuft im Image. Gleicher Ablauf wie build-local.sh, nur liegen
# Toolchain und Themes jetzt im Image unter /themes.
#   build-docs <dokument.adoc> [theme ...]
# Ergebnis: build/<theme>/<dokument>.pdf und .html
set -eu
DOC=$1; shift
for theme in ${*:-default ddc}; do
  out=build/$theme
  asciidoctor-pdf -D "$out" \
    -a pdf-themesdir=/themes/pdf-theme/themes -a pdf-theme="$theme" \
    -a pdf-fontsdir="/themes/pdf-theme/$theme/fonts;GEM_FONTS_DIR" "$DOC"
  mkdir -p "$out/css"
  cp /themes/html-theme/*.css "$out/css/"
  # Theme-spezifische Dateien (Fonts, Bilder) aus html-theme/<theme>/, falls vorhanden
  for dir in fonts img; do
    [ ! -d "/themes/html-theme/$theme/$dir" ] || cp -R "/themes/html-theme/$theme/$dir" "$out/css/"
  done
  cp -R "$(dirname "$DOC")/images" "$out/"
  asciidoctor -D "$out" \
    -a linkcss -a stylesdir=css -a stylesheet="$theme-theme.css" \
    -a docinfodir="/themes/html-theme/$theme" -a docinfo=shared "$DOC"
  echo "-> $out/"
done
