-- Draws the Products page (#product-grid) and the landing-page cards (#featured-products) from products/*.yml
-- (see the comment at the top of products/01-public.yml).
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

local LOCK = '<svg class="pf-lock" viewBox="0 0 24 24" aria-hidden="true"><path d="M7.5 11V7.5a4.5 4.5 0 0 1 9 0V11" fill="none" stroke="currentColor" stroke-width="2.6" stroke-linecap="round"/><rect x="4" y="10.5" width="16" height="11.5" rx="2.5" fill="currentColor"/><circle cx="12" cy="15.4" r="1.8" fill="#fff"/><rect x="11.1" y="15.8" width="1.8" height="3.4" rx=".9" fill="#fff"/></svg>'

local function link(l)
  local lock, title = "", ""
  if l.internal then
    lock = LOCK
    title = ' title="Roche only"'
  end
  return string.format('<a href="%s" target="_blank" rel="noopener"%s>%s%s<span class="pf-arrow" aria-hidden="true">&#8599;</span></a>', esc(l.url), title, lock, esc(l.text))
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

-- One card of the landing-page carousel: a family marked `featured: true`, linking to its first public link.
local function featured_card(category, fam)
  local href
  for _, l in ipairs(fam.links or {}) do
    if not l.internal then href = str(l.url) break end
  end
  local img = ""
  if fam.image then
    img = string.format('<img src="%s" alt="%s hex sticker">', esc(fam.image), esc(fam.title))
  end
  local go = ""
  if href then
    go = string.format('<a class="go" href="%s" target="_blank" rel="noopener">Explore %s &#8599;</a>', esc(href), esc(fam.title))
  end
  return string.format(
    '<div class="card-tool"><div class="head">%s<div><div class="name">%s</div><div class="kind">%s</div></div></div><div class="desc">%s</div>%s</div>',
    img, esc(fam.title), esc(category), esc(fam.description or ""), go)
end

-- Reads every products/*.yml and merges them: sections by `category`, cards by `title`.
local function load_sections()
  local root = (quarto and quarto.project and quarto.project.directory) or "."
  local dir = root .. "/products"
  local names = {}
  for _, n in ipairs(pandoc.system.list_directory(dir)) do
    if n:match("%.ya?ml$") then names[#names + 1] = n end
  end
  table.sort(names)

  local order, byname = {}, {}
  local any_internal = false
  for _, n in ipairs(names) do
    local from_internal = n:lower():find("internal", 1, true) ~= nil
    for _, sec in ipairs(read_sections(dir .. "/" .. n)) do
      -- Every link in a file with "internal" in its name is marked Roche only.
      if from_internal then
        for _, fam in ipairs(sec.families or {}) do
          for _, l in ipairs(fam.links or {}) do l.internal = true; any_internal = true end
        end
        for _, l in ipairs(sec.links or {}) do l.internal = true; any_internal = true end
      end
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
  return order, byname, any_internal
end

function Div(el)
  if el.identifier == "featured-products" then
    local order, byname = load_sections()
    local html = {}
    for _, key in ipairs(order) do
      for _, f in ipairs(byname[key].families) do
        if f.featured == true then html[#html + 1] = featured_card(key, f) end
      end
    end
    return pandoc.RawBlock("html", table.concat(html, "\n"))
  end
  if el.identifier ~= "product-grid" then return nil end
  local order, byname, any_internal = load_sections()

  local out = {}
  if any_internal then
    out[#out + 1] = pandoc.RawBlock("html", '<p class="pf-legend">' .. LOCK .. 'Roche only: not part of the open-source release.</p>')
  end
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
