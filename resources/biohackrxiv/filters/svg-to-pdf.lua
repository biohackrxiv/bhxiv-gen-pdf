-- Converts each .svg image referenced in the document to a sibling .pdf
-- via rsvg-convert (Debian's librsvg2-bin), then rewrites the Image src
-- to point at that .pdf so the LaTeX writer emits a plain
-- \includegraphics instead of \includesvg.
--
-- This replaces the Inkscape-based \includesvg approach (resources/
-- biohackrxiv/latex.template's "svg" package, and -shell-escape on the
-- lualatex invocation in bin/gen-pdf): rsvg-convert is invoked here, in
-- the pandoc/Lua process, which needs no LaTeX shell-escape at all.
local function shq(s)
  return "'" .. s:gsub("'", "'\\''") .. "'"
end

function Image(img)
  if img.src:match("%.svg$") then
    local pdf_out = img.src:gsub("%.svg$", ".pdf")
    -- Skip the (re)conversion when an up-to-date .pdf already exists.
    local cmd = string.format(
      "test %s -nt %s || rsvg-convert -f pdf -o %s %s",
      shq(pdf_out), shq(img.src), shq(pdf_out), shq(img.src)
    )
    local ok = os.execute(cmd)
    if not ok then
      io.stderr:write("svg-to-pdf.lua: rsvg-convert failed for " .. img.src .. "\n")
      return img
    end
    img.src = pdf_out
  end
  return img
end
