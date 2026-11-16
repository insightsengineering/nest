-- Draws the Products page from products/*.yml (see the comment at the top of products/01-public.yml).
-- Every file is a list of sections; sections with the same `category` are merged across files.
local str = pandoc.utils.stringify

local function esc(s)
  return (str(s):gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"):gsub('"', "&quot;"))
end

local function read_sections(path)
  local f = io.open(path, "r")
  if not f then return {} end
  local text = f:read("*a"); f:close()
  -- Wrap the bare list so pandoc's own YAML reader parses it.
  local body = text:gsub("\r", ""):gsub("([^\n]*)\n?", function(line)
    return "  " .. line .. "\n"
  end)
  local doc = pandoc.read("---\nsections:\n" .. body .. "---\n", "markdown")
  return doc.meta.sections or {}
end

local function link(l)
  return string.format('<a href="%s" target="_blank" rel="noopener">%s<span class="pf-arrow" aria-hidden="true">&#8599;</span></a>', esc(l.url), esc(l.text))
end

local function card(fam)
  local icon
  if fam.image then
    icon = string.format('<img class="pf-icon" src="%s" alt="">', esc(fam.image))
  else
    icon = string.format('<span class="pf-icon pf-mono" aria-hidden="true">%s</span>', esc(str(fam.title):sub(1, 1):upper()))
  end
  local links = {}
  for _, l in ipairs(fam.links or {}) do links[#links + 1] = link(l) end
  return string.format(
    '<div class="pf-card"><div class="pf-head">%s<div><h3>%s</h3><p>%s</p></div></div><div class="pf-links">%s</div></div>',
    icon, (esc(fam.title):gsub("%.", ".<wbr>")), esc(fam.description or ""), table.concat(links))
end

function Div(el)
  if el.identifier ~= "product-grid" then return nil end
  local root = (quarto and quarto.project and quarto.project.directory) or "."
  local dir = root .. "/products"
  local names = {}
  for _, n in ipairs(pandoc.system.list_directory(dir)) do
    if n:match("%.ya?ml$") then names[#names + 1] = n end
  end
  table.sort(names)

  local order, byname = {}, {}
  for _, n in ipairs(names) do
    for _, sec in ipairs(read_sections(dir .. "/" .. n)) do
      local key = str(sec.category)
      if not byname[key] then
        byname[key] = { category = key, description = sec.description and str(sec.description) or "", families = {}, links = {} }
        order[#order + 1] = key
      end
      local s = byname[key]
      for _, f in ipairs(sec.families or {}) do
        -- A card with the same title as an earlier one (for example from the internal file) adds its links to it.
        local existing
        for _, e in ipairs(s.families) do
          if str(e.title) == str(f.title) then existing = e break end
        end
        if existing then
          existing.links = existing.links or pandoc.MetaList({})
          for _, l in ipairs(f.links or {}) do existing.links[#existing.links + 1] = l end
        else
          s.families[#s.families + 1] = f
        end
      end
      for _, l in ipairs(sec.links or {}) do s.links[#s.links + 1] = l end
    end
  end

  local out = {}
  for _, key in ipairs(order) do
    local s = byname[key]
    local html = {}
    html[#html + 1] = '<section class="pf-section"><div class="pf-intro"><h2>' .. esc(s.category) .. '</h2><p>' .. esc(s.description) .. '</p></div>'
    if #s.families > 0 then
      html[#html + 1] = '<div class="pf-grid">'
      for _, f in ipairs(s.families) do html[#html + 1] = card(f) end
      html[#html + 1] = '</div>'
    end
    if #s.links > 0 then
      local pills = {}
      for _, l in ipairs(s.links) do pills[#pills + 1] = link(l) end
      html[#html + 1] = '<div class="pf-pills">' .. table.concat(pills) .. '</div>'
    end
    html[#html + 1] = '</section>'
    out[#out + 1] = pandoc.RawBlock("html", table.concat(html))
  end
  return out
end
