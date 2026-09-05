FROM ruby:3.3-bookworm

ENV PANDOC_VERSION="3.6.4"

RUN arch=$(dpkg --print-architecture) && \
    wget --output-document="/pandoc-${PANDOC_VERSION}-linux-${arch}.tar.gz" \
      "https://github.com/jgm/pandoc/releases/download/${PANDOC_VERSION}/pandoc-${PANDOC_VERSION}-linux-${arch}.tar.gz" && \
    tar xf "/pandoc-${PANDOC_VERSION}-linux-${arch}.tar.gz" && \
    ln -s "/pandoc-${PANDOC_VERSION}/bin/pandoc" "/usr/local/bin/pandoc"

# node-mermaid (mermaid.js's browser bundle, loaded by
# resources/biohackrxiv/filters/mermaid-to-pdf.lua to render ```mermaid
# code blocks via headless Chromium) is not yet in Debian stable, only
# in testing. Pin testing to a low priority so only an explicit
# `-t testing` install below pulls from it - every other package here
# still comes from the stable release.
RUN echo "deb http://deb.debian.org/debian testing main" > /etc/apt/sources.list.d/testing.list && \
    printf 'Package: *\nPin: release a=testing\nPin-Priority: 100\n' > /etc/apt/preferences.d/testing-pin

RUN apt-get update -y && apt-get install -y --no-install-recommends \
    biber \
    chromium \
    librsvg2-bin \
    lmodern \
    texlive-bibtex-extra \
    texlive-latex-base \
    texlive-latex-extra \
    texlive-fonts-extra \
    texlive-latex-recommended \
    texlive-luatex \
    fonts-noto-cjk \
    && apt-get install -y --no-install-recommends -t testing node-mermaid \
    && rm -rf /var/lib/apt/lists/*

ADD ./bin /gen-pdf/bin
ADD ./lib /gen-pdf/lib
ADD ./resources /gen-pdf/resources
ENV PATH="/gen-pdf/bin:$PATH"
WORKDIR /work
ENTRYPOINT ["gen-pdf"]
