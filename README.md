# Generate a PDF for BioHackrXiv.org

This CLI tool generates PDF files complying with the specifications for [biohackrxiv.org](https://biohackrxiv.org/).
The PDF is generated using [pandoc](https://pandoc.org/) with LaTeX templates starting from a markdown (MD) file.
The PDF can then be uploaded to [biohackrxiv.org](https://biohackrxiv.org/).

**NOTE:** alternatively you could generate the PDF using the [web-based upload tool](http://preview.biohackrxiv.org/).

# Quick start

BioHackrXiv supports files formatted in [pandoc flavored markdown](https://pandoc.org/MANUAL.html#pandocs-markdown) or text files.
See the following example files:
- [Pandoc flavored MD formatted example](https://github.com/biohackrxiv/bhxiv-gen-pdf/blob/master/example/logic/paper.md)
- [Raw text example](https://raw.githubusercontent.com/biohackrxiv/bhxiv-gen-pdf/master/example/logic/paper.md)

LaTex can also be embedded into the Pandoc flavored MD files.

To start, you could use the [template files in our repository](https://github.com/biohackrxiv/bhxiv-gen-pdf/blob/master/example/logic/)
**IMPORTANT:** Do not modify the file names as they are used to generate the final paper.
We suggest that you copy and edit these files in your own git repository.

Once you are done editing you generate the PDF using [BioHackrXiv's web-based PDF generator](preview.biohackrxiv.org)
You can eaither paste the URL to your repository, or upload an acrhive containing the edited template files.

**IMPORTANT**: If you want to use the URL to your repository, only pasted the base URL. The web-tool will automatically detect the paper.md file.

1. If you want to use the URL to your repository, only paste the base URL.
2. Each repo must contain a single `paper.md` file.
3. For biohackathons you edit our [citation template file](https://github.com/biohackrxiv/publication-template) and add it to your repository

# Deploy the web-tool using docker

There is also a [dockerized version](#run-via-docker).

If you find any bugs, please propose improvements via PRs. Thanks!

## Setup

1. Install the following packages:
  - ruby
  - pandoc
  - pandoc-citeproc
  - pdflatex
  - biblatex
2. Clone this git repository
Confirmed versions of the library can be found in [Dockerfile](https://github.com/biohackrxiv/bhxiv-gen-pdf/blob/master/docker/Dockerfile)

For more information see also the Guix [script](.guix-deploy) for current dependencies.

## Run

Generate the PDF with

    ./bin/gen-pdf [--debug] dir [output.pdf]

where *dir* points to a directory where paper.md and paper.bib reside, and *output.pdf* is optional (defaults to "paper.pdf").
All metadata is now taken directly from the markdown file header and must include:

- `biohackathon_name`: The name of the event (e.g., "NBDC/DBCLS BioHackathon")
- `biohackathon_url`: The URL of the event (e.g., "http://2019.biohackathon.org/")
- `biohackathon_location`: The location of the event (e.g., "Fukuoka, Japan, 2019")
- `git_url`: The URL of the git repository containing the paper

For example from the repository try

    ./bin/gen-pdf example/logic/

which will generate the paper as *paper.pdf* by default, or:

    ./bin/gen-pdf example/logic/ my_paper.pdf

to specify a custom output filename.

# Run via Docker

Build docker container and run

    docker build -t biohackrxiv/gen-pdf:local -f docker/Dockerfile .
    docker run --rm -it -v $(pwd):/work -w /work biohackrxiv/gen-pdf:local gen-pdf /work/example/logic

Note that the current working directory of host machine is mounted on `/work` inside the container

# Run via GNU Guix

The [guix-deploy](./.guix-deploy) script starts a Guix container which allows running
the generator and tests. The instructions are in the header of that script.

# Bibliography hints

pandoc generates the bibliography (not biber or bibtex!).
You can inspect the intermediate .tex format (see below).

Importantly:

* Don't put references in literal markdown, such as surrounded by `backticks`!
* Don't use a colon in the reference ID because that has a special meaning in CITO

# Trouble shooting

If you are not using Docker or Guix you may need to explicitely add ruby

    ruby bin/gen-pdf [dir]

## First, run tests

    ruby -I lib test/test_generator.rb

## Next generate default example

    ruby ./bin/gen-pdf --debug ./example/logic Japan2019
    ls -l example/logic/paper.pdf

and for debugging tex output:

    ruby ./bin/gen-pdf --debug ./example/logic Japan2019 output.tex
    ls -l example/logic/output.tex
    cd example/logic
    lualatex output.tex
    biber output.tex

Note that the svg figure may complain. Just hit enter.

    ruby ./bin/gen-pdf ./example/logic
    ls -l example/logic/paper.pdf

and for debugging tex output:

    ruby ./bin/gen-pdf --debug ./example/logic output.tex
    ls -l example/logic/output.tex
    cd example/logic
    lualatex output.tex
    biber output.tex

Note that the svg figure may complain. Just hit enter.

## Next try generating your document using path

Clone your repo in to a visible path and

    git clone my-repo.git
    ruby ./bin/gen-pdf --debug my-repo-path/paper Japan2019

If you get pandoc errors, such as `Unknown option --citeproc` you'll need a plugin.
Try the Guix container described above.

That should generate a PDF. To generate the latex file add it to the command and try

    ruby ./bin/gen-pdf --debug my-repo-path/paper output.tex

and now you can also debug the generated latex:

    cd example/logic
    lualatex output.tex
    biber output.tex # note that biber or bibtex won't work!

we find

    INFO - Found 0 citekeys in bib section 0

this is because the references are generated directly inline by pandoc. To test the bib file you can try

    pandoc-citeproc --bib2json paper.bib

and you can check the JSON records.
