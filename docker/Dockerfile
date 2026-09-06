FROM ruby:3.3-bookworm

ENV PANDOC_VERSION="3.6.4"

RUN arch=$(dpkg --print-architecture) && \
    wget --output-document="/pandoc-${PANDOC_VERSION}-linux-${arch}.tar.gz" \
      "https://github.com/jgm/pandoc/releases/download/${PANDOC_VERSION}/pandoc-${PANDOC_VERSION}-linux-${arch}.tar.gz" && \
    tar xf "/pandoc-${PANDOC_VERSION}-linux-${arch}.tar.gz" && \
    ln -s "/pandoc-${PANDOC_VERSION}/bin/pandoc" "/usr/local/bin/pandoc"

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
    && rm -rf /var/lib/apt/lists/*

ENV MERMAID_VERSION="9.2.2+~2.0.0-2"

# mermaid.js's browser bundle (loaded by
# resources/biohackrxiv/filters/mermaid-to-pdf.lua to render ```mermaid
# code blocks via headless Chromium) is shipped by Debian's node-mermaid
# package, which isn't in stable yet - only in testing - and pulls in a
# sprawling, version-pinned web of node-*/libjs-* dependencies (plus
# oddly-named ones like mocha) that aren't all satisfiable from stable
# either. None of that dependency graph is actually needed at runtime
# though: the one file we want is a self-contained, pre-bundled browser
# script with everything already inlined, loaded via a plain
# <script src> - so `apt-get download` fetches just the .deb (no
# dependency resolution at all, unaffected by any of that) and dpkg -x
# extracts the one file we need from it, entirely bypassing that
# dependency graph. Testing is enabled only long enough for this and
# removed again immediately after, so it can never affect anything else
# in this image.
RUN echo "deb http://deb.debian.org/debian testing main" > /etc/apt/sources.list.d/testing.list && \
    apt-get update -y && \
    cd /tmp && apt-get download "node-mermaid=${MERMAID_VERSION}" && \
    dpkg -x node-mermaid_*.deb /tmp/node-mermaid-extracted && \
    install -D /tmp/node-mermaid-extracted/usr/share/nodejs/mermaid/dist/mermaid.min.js \
      /usr/share/nodejs/mermaid/dist/mermaid.min.js && \
    rm -rf /tmp/node-mermaid_*.deb /tmp/node-mermaid-extracted \
      /etc/apt/sources.list.d/testing.list && \
    apt-get update -y && \
    rm -rf /var/lib/apt/lists/*

ADD ./bin /gen-pdf/bin
ADD ./lib /gen-pdf/lib
ADD ./resources /gen-pdf/resources
ENV PATH="/gen-pdf/bin:$PATH"
WORKDIR /work
ENTRYPOINT ["gen-pdf"]
