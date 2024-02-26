FROM ruby:3.0.2

ENV PANDOC_VERSION="2.16.1"

RUN wget --output-document="/pandoc-${PANDOC_VERSION}-linux-amd64.tar.gz" "https://github.com/jgm/pandoc/releases/download/${PANDOC_VERSION}/pandoc-${PANDOC_VERSION}-linux-amd64.tar.gz" && \
    tar xf "pandoc-${PANDOC_VERSION}-linux-amd64.tar.gz" && \
    ln -s "/pandoc-${PANDOC_VERSION}/bin/pandoc" "/usr/local/bin"

RUN apt update -y && apt install -y \
    librsvg2-bin=2.50.3+dfsg-1 \
    texlive-bibtex-extra=2020.20210202-3 \
    texlive-latex-base=2020.20210202-3 \
    texlive-latex-extra=2020.20210202-3 \
    texlive-luatex=2020.20210202-3 \
    texlive-lang-japanese=2020.20210202-2

ADD ./bin /gen-pdf/bin
ADD ./lib /gen-pdf/lib
ADD ./resources /gen-pdf/resources
ENV PATH /gen-pdf/bin:$PATH
CMD ["bash"]
