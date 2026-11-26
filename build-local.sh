#!/bin/sh
#   ./build-local.sh          # Theme "default"
#
# Ergebnis: build/<theme>/arc42-template.html
set -eu
cd "$(dirname "$0")"

# Was gebaut wird
FORMATS="html"
DOC=docs/arc42-template.adoc

# Befehl im ruby-Container ausführen, mit diesem Ordner als /work
run() {
  docker run --rm -u "$(id -u):$(id -g)" -v "$PWD:/work" -w /work \
    -e HOME=/tmp -e GEM_HOME=/work/.gems -e PATH=/work/.gems/bin:/usr/local/bin:/usr/bin:/bin \
    ruby:4.0.10-alpine3.24 "$@"
}

# Einmalig die komplette Toolchain installieren, damit später nichts mehr geladen werden muss
# (für ein Update: .gems/ löschen)
[ -x .gems/bin/asciidoctor-pdf ] ||
  run gem install --no-document asciidoctor:2.0.26 asciidoctor-pdf:2.3.27

for theme in ${*:-default}; do
  out=build/$theme

  for format in $FORMATS; do
    case $format in
      html)
        # CSS verlinken (nicht einbetten) und docinfo einbinden; CSS und Bilder neben das HTML kopieren
        mkdir -p "$out/css"
        cp html-theme/*.css "$out/css/"
        # Theme-spezifische Dateien (Fonts, Bilder) aus html-theme/<theme>/, falls vorhanden
        for dir in fonts img; do
          [ ! -d "html-theme/$theme/$dir" ] || cp -R "html-theme/$theme/$dir" "$out/css/"
        done
        cp -R docs/images "$out/"
        run asciidoctor -D "$out" \
          -a linkcss -a stylesdir=css -a stylesheet="$theme-theme.css" \
          -a docinfodir="/work/html-theme/$theme" -a docinfo=shared \
          "$DOC" ;;
    esac
  done

  echo "-> $out/"
done
