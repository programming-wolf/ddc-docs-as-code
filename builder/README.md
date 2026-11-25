# Builder (Stage 2)

Zentrales Docker-Image mit Toolchain (Ruby, asciidoctor, asciidoctor-pdf) und Themes.

```sh
# aus dem Repo-Root bauen, weil die Themes in den Nachbarordnern liegen
docker build -f builder/Dockerfile -t docs-builder .

# Doku damit bauen (Wrapper ../build.sh im Repo-Root)
./build.sh            # Themes "default" und "ddc"
./build.sh ddc        # nur DDC

# Override: lokales Theme statt dem aus dem Image
PDF_THEME_DIR=pdf-theme HTML_THEME_DIR=html-theme ./build.sh ddc
```

| Datei        | Zweck                                                                    |
|--------------|--------------------------------------------------------------------------|
| `Dockerfile` | `ruby`-Image, feste Gem-Versionen, `COPY` der Themes nach `/themes`      |
| `build.sh`   | läuft im Image als `build-docs`, gleicher Ablauf wie `../build-local.sh` |

Ausgabe: `build/<theme>/`.
