--!nonstrict
-- Bar widget: ports BarWidget.qml. screen-share glyph, red tint while a
-- mirror session is active, click opens the panel.

local PANEL_ID = "monkeman/mirror-mirror:mirror"

local function apply(mirroring)
  if mirroring then
    barWidget.setGlyphColor("error")
    barWidget.setTooltip(noctalia.tr("bar.tooltip.active"))
  else
    barWidget.setGlyphColor("on_surface")
    barWidget.setTooltip(noctalia.tr("bar.tooltip.inactive"))
  end
end

-- The initial draw happens in update(); a static widget only needs rare ticks.
function update()
  noctalia.setUpdateInterval(10000)
  barWidget.setGlyph("screen-share")
  apply(noctalia.state.get("mirroring") == true)
end

noctalia.state.watch("mirroring", function(value)
  apply(value == true)
end)

function onClick()
  noctalia.togglePanel(PANEL_ID)
end
