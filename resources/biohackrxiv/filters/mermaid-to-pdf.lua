-- Renders ```mermaid code blocks with the real mermaid.js, without any
-- npm/puppeteer dependency: everything used here comes from Debian
-- stable packages (node-mermaid ships mermaid.js's browser bundle at
-- /usr/share/nodejs/mermaid/dist/mermaid.min.js; chromium provides a
-- --headless mode with built-in --dump-dom and --virtual-time-budget
-- flags that drive and capture JS-rendered DOM content on their own,
-- with no driver library needed).
--
-- For each mermaid block: write a small self-contained HTML page that
-- loads mermaid.js from disk and puts the block's source in a
-- <pre class="mermaid">; run Chromium headless against it with
-- --dump-dom, which waits for the page to load, lets the given amount
-- of (virtual) time pass for mermaid's async rendering to finish, then
-- prints the full resulting DOM as text; extract the <svg>...</svg>
-- mermaid.js rendered into that DOM and write it to a sibling .svg
-- file. htmlLabels is turned off because mermaid.js otherwise renders
-- node text via <foreignObject> (embedded HTML), which the svg-to-pdf
-- filter's rsvg-convert (librsvg) cannot render (it silently drops the
-- text) - plain SVG <text> avoids that entirely.
--
-- The generated .svg is returned as a plain Image, so the svg-to-pdf.lua
-- filter later in the pipeline converts it to PDF exactly like any
-- other SVG figure; this filter must therefore run before svg-to-pdf.lua.
--
-- Only what mermaid.js 9's grammar supports can be rendered this way,
-- which is the great majority of Mermaid diagram types (flowcharts,
-- sequence, class, state, ER, gantt, git, pie, ...). Anything mermaid.js
-- itself fails to parse is left as a plain code block.

local MERMAID_JS = "/usr/share/nodejs/mermaid/dist/mermaid.min.js"

local function shq(s)
  return "'" .. s:gsub("'", "'\\''") .. "'"
end

local function html_escape(s)
  return (s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
end

local function read_file(path)
  local fh = io.open(path, "r")
  if not fh then
    return nil
  end
  local content = fh:read("a")
  fh:close()
  return content
end

local function write_file(path, content)
  local fh = io.open(path, "w")
  fh:write(content)
  fh:close()
end

local diagram_count = 0

function CodeBlock(block)
  if not block.classes:includes("mermaid") then
    return nil
  end
  if not read_file(MERMAID_JS) then
    io.stderr:write("mermaid-to-pdf.lua: " .. MERMAID_JS .. " not found (is node-mermaid installed?), leaving as a code block\n")
    return nil
  end

  diagram_count = diagram_count + 1
  local base = string.format("mermaid-diagram-%d", diagram_count)
  local html_path, dom_path, svg_path = base .. ".html", base .. ".dom.html", base .. ".svg"

  write_file(html_path, string.format([[
<!doctype html>
<html><head><meta charset="utf-8"></head>
<body>
<pre class="mermaid">
%s
</pre>
<script src="file://%s"></script>
<script>
  mermaid.initialize({ startOnLoad: true, flowchart: { htmlLabels: false }, htmlLabels: false });
</script>
</body></html>
]], html_escape(block.text), MERMAID_JS))

  local html_abspath = pandoc.path.join{pandoc.system.get_working_directory(), html_path}
  local ok = os.execute(string.format(
    "chromium --headless --disable-gpu --no-sandbox --virtual-time-budget=5000 --dump-dom %s > %s 2>/dev/null",
    shq("file://" .. html_abspath),
    shq(dom_path)
  ))
  if not ok then
    io.stderr:write("mermaid-to-pdf.lua: chromium failed to render " .. html_path .. ", leaving as a code block\n")
    return nil
  end

  local dom = read_file(dom_path)
  local svg = dom and dom:match("(<svg.-</svg>)")
  if not svg then
    io.stderr:write("mermaid-to-pdf.lua: could not find rendered <svg> for " .. html_path .. " (invalid diagram source?), leaving as a code block\n")
    return nil
  end
  write_file(svg_path, svg)

  os.remove(html_path)
  os.remove(dom_path)

  return pandoc.Para({ pandoc.Image({}, svg_path) })
end
