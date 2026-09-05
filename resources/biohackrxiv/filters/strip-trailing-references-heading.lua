-- BioHackrXiv papers conventionally end their markdown with a manual
-- "## References" heading, written as a placeholder for where citeproc
-- used to insert the rendered bibliography right after it. Now that
-- --biblatex prints the bibliography via \printbibliography (which
-- supplies its own heading through latex.template's \defbibheading),
-- that trailing heading is left dangling with nothing under it and only
-- duplicates \defbibheading's own "References" title, so drop it here.
function Pandoc(doc)
  local blocks = doc.blocks
  local last = blocks[#blocks]
  if last and last.t == "Header" and
     pandoc.utils.stringify(last.content):lower() == "references" then
    blocks:remove(#blocks)
  end
  doc.blocks = blocks
  return doc
end
