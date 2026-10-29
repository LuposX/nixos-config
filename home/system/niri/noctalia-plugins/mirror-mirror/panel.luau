--!nonstrict
-- Panel entry: ports Panel.qml. Output pickers (source/destination), start
-- and stop buttons, validation and error text. Monitor selection syncs from
-- noctalia.outputs() on every render, like Quickshell.screens did in v4.

local selectedSource = nil
local selectedDestination = nil
local cmdSeq = 0

local function outputNames()
  local outs = noctalia.outputs() or {}
  local names = {}
  for _, o in ipairs(outs) do
    table.insert(names, o.name)
  end
  return names
end

local function contains(list, value)
  for _, v in ipairs(list) do
    if v == value then
      return true
    end
  end
  return false
end

local function firstAlternate(names, excluded)
  for _, name in ipairs(names) do
    if name ~= excluded then
      return name
    end
  end
  return names[1]
end

-- ui.select's onChange passes an index; handle both 0-based and 1-based
-- delivery by checking which candidate differs from the current selection.
local function indexToName(names, index, current)
  local i = tonumber(index)
  if i == nil then
    return current
  end
  local atI = names[i]
  local atNext = names[i + 1]
  if atI ~= nil and atI ~= current then
    return atI
  end
  if atNext ~= nil and atNext ~= current then
    return atNext
  end
  return atI or atNext or current
end

local function sendCmd(action)
  cmdSeq = cmdSeq + 1
  noctalia.state.set("cmd", {
    seq = cmdSeq,
    action = action,
    source = selectedSource or "",
    destination = selectedDestination or "",
  })
  render()
end

function render()
  local names = outputNames()
  local mirroring = noctalia.state.get("mirroring") == true
  local lastError = tostring(noctalia.state.get("error") or "")
  local hasEnough = #names >= 2

  -- Sync selections: keep valid ones, default the rest (syncSelections in v4).
  if not contains(names, selectedSource) then
    selectedSource = names[1]
  end
  if not hasEnough then
    selectedDestination = names[1]
  elseif not contains(names, selectedDestination) or selectedDestination == selectedSource then
    selectedDestination = firstAlternate(names, selectedSource)
  end

  local srcIdx = 1
  local dstIdx = 1
  for i, name in ipairs(names) do
    if name == selectedSource then
      srcIdx = i
    end
    if name == selectedDestination then
      dstIdx = i
    end
  end

  local sameSelection = selectedSource ~= nil
    and selectedDestination ~= nil
    and selectedSource == selectedDestination
  local canStart = not mirroring
    and hasEnough
    and selectedSource ~= nil
    and selectedDestination ~= nil
    and not sameSelection

  local rows = {
    ui.label({
      text = noctalia.tr("panel.title"),
      fontSize = 16,
      fontWeight = "bold",
      color = "on_surface",
    }),
    ui.label({
      text = noctalia.tr("panel.subtitle"),
      fontSize = 12,
      color = "on_surface_variant",
    }),
    ui.select({
      key = "source",
      options = names,
      selectedIndex = srcIdx,
      enabled = not mirroring and hasEnough,
      onChange = function(index)
        selectedSource = indexToName(names, index, selectedSource)
        render()
      end,
    }),
    ui.select({
      key = "destination",
      options = names,
      selectedIndex = dstIdx,
      enabled = not mirroring and hasEnough,
      onChange = function(index)
        selectedDestination = indexToName(names, index, selectedDestination)
        render()
      end,
    }),
  }

  if sameSelection then
    table.insert(rows, ui.label({
      text = noctalia.tr("panel.validation.sameSelection"),
      fontSize = 12,
      color = "error",
    }))
  end
  if not hasEnough then
    table.insert(rows, ui.label({
      text = noctalia.tr("panel.validation.needTwoMonitors"),
      fontSize = 12,
      color = "error",
    }))
  end
  if lastError ~= "" then
    table.insert(rows, ui.label({
      text = lastError,
      fontSize = 12,
      color = "error",
    }))
  end

  if mirroring then
    table.insert(rows, ui.button({
      text = noctalia.tr("panel.actions.stop"),
      glyph = "stop",
      variant = "destructive",
      onClick = function()
        sendCmd("stop")
      end,
    }))
  else
    table.insert(rows, ui.button({
      text = noctalia.tr("panel.actions.start"),
      glyph = "media-play",
      variant = "primary",
      enabled = canStart,
      onClick = function()
        sendCmd("start")
      end,
    }))
  end

  panel.render(
    ui.column({ gap = 12, padding = 14, flexGrow = 1 }, rows)
  )
end

function onOpen(_context)
  render()
end
