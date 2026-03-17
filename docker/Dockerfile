FROM ruby:3.3-bookworm

ENV PANDOC_VERSION="3.6.4"

RUN arch=$(dpkg --print-architecture) && \
    wget --output-document="/pandoc-${PANDOC_VERSION}-linux-${arch}.tar.gz" \
      "https://github.com/jgm/pandoc/releases/download/${PANDOC_VERSION}/pandoc-${PANDOC_VERSION}-linux-${arch}.tar.gz" && \
    tar xf "/pandoc-${PANDOC_VERSION}-linux-${arch}.tar.gz" && \
    ln -s "/pandoc-${PANDOC_VERSION}/bin/pandoc" "/usr/local/bin/pandoc"

RUN apt-get update -y && apt-get install -y --no-install-recommends \
    librsvg2-bin \
    lmodern \
    texlive-bibtex-extra \
    texlive-latex-base \
    texlive-latex-extra \
    texlive-fonts-extra \
    texlive-latex-recommended \
    && rm -rf /var/lib/apt/lists/*

ADD ./bin /gen-pdf/bin
ADD ./lib /gen-pdf/lib
ADD ./resources /gen-pdf/resources
ENV PATH="/gen-pdf/bin:$PATH"
WORKDIR /work
ENTRYPOINT ["gen-pdf"]
