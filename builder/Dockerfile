# Bauen aus dem Repo-Root, weil die Themes in den Nachbarordnern liegen:
#   docker build -f builder/Dockerfile -t docs-builder .
FROM ruby:4.0.10-alpine3.24

# Toolchain: feste Versionen, damit alle Teams denselben Stand haben
RUN gem install --no-document asciidoctor:2.0.26 asciidoctor-pdf:2.3.27

# Themes: Corporate Design zentral im Image
COPY pdf-theme  /themes/pdf-theme
COPY html-theme /themes/html-theme

COPY builder/build.sh /usr/local/bin/build-docs

# Läuft mit der UID der Aufrufenden (docker run -u), die kein Home im Image hat
ENV HOME=/tmp
WORKDIR /work
ENTRYPOINT ["build-docs"]
