@echo off
rem   .\build-local.bat          # Theme "default"
rem   .\build-local.bat default  # explizites Theme
rem
rem Ergebnis: build\<theme>\arc42-template.html
rem Voraussetzung: Docker Desktop laeuft.
setlocal EnableExtensions
cd /d "%~dp0"

rem Was gebaut wird
set "FORMATS=html pdf"
set "DOC=docs/arc42-template.adoc"
set "IMAGE=ruby:4.0.10-alpine3.24"

rem Einmalig die komplette Toolchain installieren, damit spaeter nichts mehr geladen werden muss
rem (fuer ein Update: .gems\ loeschen)
if not exist ".gems\bin\asciidoctor-pdf" (
  call :run gem install --no-document asciidoctor:2.0.26 asciidoctor-pdf:2.3.27
  if errorlevel 1 exit /b 1
)

set "THEMES=%*"
if "%THEMES%"=="" set "THEMES=ddc"

for %%T in (%THEMES%) do (
  call :build %%T
  if errorlevel 1 exit /b 1
)
exit /b 0

rem ---------------------------------------------------------------
rem Befehl im ruby-Container ausfuehren, mit diesem Ordner als /work
rem ---------------------------------------------------------------
:run
docker run --rm -v "%CD%:/work" -w /work ^
  -e HOME=/tmp -e GEM_HOME=/work/.gems -e PATH=/work/.gems/bin:/usr/local/bin:/usr/bin:/bin ^
  %IMAGE% %*
exit /b %errorlevel%

rem ---------------------------------------------------------------
rem Ein Theme bauen (alle Formate aus FORMATS)
rem ---------------------------------------------------------------
:build
set "theme=%~1"
set "out=build\%theme%"

for %%F in (%FORMATS%) do (
  call :build_%%F
  if errorlevel 1 exit /b 1
)

echo -^> %out%\
exit /b 0

:build_html
rem CSS verlinken (nicht einbetten) und docinfo einbinden; CSS und Bilder neben das HTML kopieren
if not exist "%out%\css" mkdir "%out%\css"
copy /Y "html-theme\*.css" "%out%\css\" >nul
if errorlevel 1 exit /b 1
rem Theme-spezifische Dateien (Fonts, Bilder) aus html-theme\<theme>\, falls vorhanden
for %%D in (fonts img) do (
  if exist "html-theme\%theme%\%%D\" (
    xcopy /E /I /Y /Q "html-theme\%theme%\%%D" "%out%\css\%%D" >nul
    if errorlevel 1 exit /b 1
  )
)
xcopy /E /I /Y /Q "docs\images" "%out%\images" >nul
if errorlevel 1 exit /b 1

call :run asciidoctor -D "build/%theme%" ^
  -a linkcss -a stylesdir=css -a stylesheet="%theme%-theme.css" ^
  -a docinfodir="/work/html-theme/%theme%" -a docinfo=shared ^
  "%DOC%"
exit /b %errorlevel%

:build_pdf
rem Theme-YAML und Fonts per Attribut einbinden; Fonts aus pdf-theme/<theme>/fonts, sonst aus dem Gem
call :run asciidoctor-pdf -D "build/%theme%" ^
  -a pdf-themesdir=/work/pdf-theme/themes -a pdf-theme="%theme%" ^
  -a pdf-fontsdir="/work/pdf-theme/%theme%/fonts;GEM_FONTS_DIR" ^
  "%DOC%"
exit /b %errorlevel%

