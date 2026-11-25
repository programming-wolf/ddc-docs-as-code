# Workshop: Docs-as-Code mit Asciidoctor (DDC Köln)

Material für den 4-Stunden-Workshop: eine Architekturdokumentation (arc42) in AsciiDoc, zwei Themes
für HTML und PDF und ein zentrales Docker-Image, das alles zusammen baut.

## Voraussetzungen

- **Docker** (Docker Desktop, OrbStack, Colima o. Ä.)
- **POSIX-Shell**: macOS oder Linux. Windows nur mit **WSL2**; das Repo dann im WSL-Dateisystem
  klonen (z. B. `~/`), nicht unter `/mnt/c/…`
- Git

Ruby und Asciidoctor müssen nicht installiert sein. Der erste Build lädt das `ruby`-Image und die
Gems, braucht also Internet; danach geht alles offline.

```sh
git clone <repo-url>
cd <repo>
./build-local.sh
```

## Struktur

| Pfad             | Inhalt                                                                                  |
|------------------|-----------------------------------------------------------------------------------------|
| `build-local.sh` | Stage 1: Doku lokal bauen, Themes direkt aus den Nachbarordnern                         |
| `build.sh`       | Stage 2: Doku mit dem zentralen Image bauen                                             |
| `docs/`          | AsciiDoc-Quellen: arc42-Template (DE plain), Einstieg `arc42-template.adoc`             |
| `html-theme/`    | `default-theme.css` (Asciidoctor-Standard, unverändert), `ddc-theme.css`, `fonts/`, `img/` (Logo), `ddc/` (docinfo) |
| `pdf-theme/`     | `themes/default-theme.yml` (asciidoctor-pdf-Standard, unverändert), `themes/ddc-theme.yml`, `fonts/` |
| `builder/`       | Stage 2: `Dockerfile` und das Build-Skript im Image, siehe [builder/README.md](builder/README.md) |

Die beiden Standard-Themes sind unveränderte Kopien und dienen als Nachschlagewerk. Eigene Themes
bauen darauf auf (`@import` im CSS, `extends` im YAML) und überschreiben nur, was anders ist.

## Stage 1: lokal bauen

```sh
./build-local.sh               # Theme "default"
./build-local.sh ddc           # DDC-Theme
./build-local.sh default ddc   # beide, zum Vergleich nebeneinander
```

Ausgabe: `build/<theme>/arc42-template.html`, im Browser öffnen (macOS: `open build/ddc/arc42-template.html`).

Welche Formate gebaut werden, steht oben in `build-local.sh`:

```sh
FORMATS="html pdf"
```

Die Gems liegen nach dem ersten Lauf in `.gems/`. Für ein Update der Toolchain `.gems/` löschen.

## Stage 2: zentrales Image

Toolchain und Themes stecken in einem Image. Das Doku-Repo braucht dann nur noch `build.sh`.

```sh
# aus dem Repo-Root bauen, weil das Dockerfile pdf-theme/ und html-theme/ kopiert
docker build -f builder/Dockerfile -t docs-builder .

./build.sh                # Themes "default" und "ddc", jeweils HTML und PDF
./build.sh ddc            # nur DDC
```

Ausgabe: `build/<theme>/`, wie in Stage 1.

Die Themes sind im Image eingefroren: Nach einer Theme-Änderung das Image neu bauen. Zum
Ausprobieren ohne neues Image lassen sich lokale Theme-Ordner über die im Image legen:

```sh
HTML_THEME_DIR=html-theme ./build.sh ddc
PDF_THEME_DIR=pdf-theme ./build.sh ddc
```

## Lizenzen

- **arc42-Template** (`docs/`): [arc42.org](https://arc42.org), Creative Commons Attribution-ShareAlike 4.0 International (CC BY-SA 4.0)
- **Poppins** und **Orbitron**: SIL Open Font License 1.1, Lizenztexte in `pdf-theme/fonts/OFL-*.txt` bzw.
  `html-theme/fonts/OFL-*.txt`. „Orbitron“ ist ein Reserved Font Name: die Schriftdateien nicht verändern.
- **Asciidoctor-Standard-Themes** (`default-theme.css`, `default-theme.yml`): MIT-Lizenz, Asciidoctor-Projekt
