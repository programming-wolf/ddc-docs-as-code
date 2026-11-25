#!/bin/sh
# Stage 2: Doku mit dem zentralen Image bauen. Braucht nur Docker und das Image.
#   ./build.sh                                  # Themes "default" und "ddc"
#   ./build.sh ddc                              # nur das DDC-Theme
#   PDF_THEME_DIR=pdf-theme ./build.sh ddc      # lokales Theme statt dem aus dem Image
#   HTML_THEME_DIR=html-theme ./build.sh ddc
# Ergebnis: build/<theme>/arc42-template.pdf und .html
set -eu
cd "$(dirname "$0")"
IMAGE=${IMAGE:-docs-builder}
themes=$*

set -- docker run --rm -u "$(id -u):$(id -g)" -v "$PWD:/work"
# Override: lokaler Ordner überdeckt das Theme im Image
[ -z "${PDF_THEME_DIR:-}" ]  || set -- "$@" -v "$(cd "$PDF_THEME_DIR" && pwd):/themes/pdf-theme:ro"
[ -z "${HTML_THEME_DIR:-}" ] || set -- "$@" -v "$(cd "$HTML_THEME_DIR" && pwd):/themes/html-theme:ro"

"$@" "$IMAGE" docs/arc42-template.adoc $themes
