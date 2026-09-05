-- Replaces insert-cito-in-ref.lua for the biblatex-based pipeline. That
-- filter annotated citeproc's pre-rendered bibliography Div text, which
-- only exists when pandoc renders the bibliography itself (--citeproc).
-- With --biblatex, pandoc instead emits plain \cite{key} and defers all
-- bibliography rendering to biblatex/biber at LaTeX-compile time, so the
-- CiTO property has to be handed to LaTeX instead: this filter turns the
-- citation_properties metadata recorded by extract-cito.lua into
-- \citoannotate{key}{property} calls, which latex.template's \finentry
-- hook looks up when biblatex prints each bibliography entry.
function Pandoc(doc)
  local props = doc.meta.citation_properties
  if not props then
    return doc
  end
  local pre = pandoc.List({})
  for key, list in pairs(props) do
    local seen = {}
    for _, prop in ipairs(list) do
      local name = pandoc.utils.stringify(prop)
      if not seen[name] then
        seen[name] = true
        pre:insert(pandoc.RawBlock("tex",
          "\\citoannotate{" .. key .. "}{" .. name .. "}"))
      end
    end
  end
  doc.blocks = pre .. doc.blocks
  return doc
end
