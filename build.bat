@echo off
rem Stage 2: Doku mit dem zentralen Image bauen. Braucht nur Docker und das Image.
rem   .\build.bat                                   # Themes "default" und "ddc"
rem   .\build.bat ddc                               # nur das DDC-Theme
rem   set PDF_THEME_DIR=pdf-theme  & .\build.bat ddc   # lokales Theme statt dem aus dem Image
rem   set HTML_THEME_DIR=html-theme & .\build.bat ddc
rem Ergebnis: build\<theme>\arc42-template.pdf und .html
setlocal EnableExtensions
cd /d "%~dp0"

if "%IMAGE%"=="" set "IMAGE=docs-builder"

set "MOUNTS="
rem Override: lokaler Ordner ueberdeckt das Theme im Image
if not "%PDF_THEME_DIR%"=="" (
  if not exist "%PDF_THEME_DIR%\" (
    echo PDF_THEME_DIR nicht gefunden: %PDF_THEME_DIR% 1>&2
    exit /b 1
  )
  for %%I in ("%PDF_THEME_DIR%") do set "MOUNTS=%MOUNTS% -v "%%~fI:/themes/pdf-theme:ro""
)
if not "%HTML_THEME_DIR%"=="" (
  if not exist "%HTML_THEME_DIR%\" (
    echo HTML_THEME_DIR nicht gefunden: %HTML_THEME_DIR% 1>&2
    exit /b 1
  )
  for %%I in ("%HTML_THEME_DIR%") do set "MOUNTS=%MOUNTS% -v "%%~fI:/themes/html-theme:ro""
)

docker run --rm -v "%CD%:/work"%MOUNTS% "%IMAGE%" docs/arc42-template.adoc %*
exit /b %errorlevel%
