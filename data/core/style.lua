local config = require "core.config"
local common = require "core.common"


config.dprint("style.lua -> loaded")


local style = {}


style.padding = { x = common.round(14 * SCALE), y = common.round(7 * SCALE) }
style.divider_size = common.round(1 * SCALE)
style.scrollbar_size = common.round(4 * SCALE)
style.caret_width = common.round(2 * SCALE)
style.tab_width = common.round(170 * SCALE)

-- local xft = "/data/fonts/umono-r.ttf"
-- local xftb = "/data/fonts/umono-b.ttf"
-- 
-- style.font = renderer.font.load(EXEDIR .. xft, 14 * SCALE)
-- style.small_font = style.font
-- style.mid_font = renderer.font.load(EXEDIR .. xft, 22 * SCALE)
-- style.big_font = renderer.font.load(EXEDIR .. xft, 34 * SCALE)
-- style.icon_font = renderer.font.load(EXEDIR .. "/data/fonts/icons.ttf", 14 * SCALE)
-- style.code_font = renderer.font.load(EXEDIR .. xftb, 16 * SCALE)

local xft = {}

xft.icon = "/data/fonts/icons.ttf"

xft.condensed = "/data/fonts/ubuntu-condensed.ttf"

xft.regular = "/data/fonts/ubuntu-regular.ttf"
xft.bold = "/data/fonts/ubuntu-bold.ttf"
xft.light = "/data/fonts/ubuntu-light.ttf"

xft.regular_italic = "/data/fonts/ubuntu-regular-italic.ttf"
xft.bold_italic = "/data/fonts/ubuntu-bold-italic.ttf"
xft.light_italic = "/data/fonts/ubuntu-light-italic.ttf"

xft.mono_regular = "/data/fonts/ubuntu-mono-regular.ttf"
xft.mono_bold = "/data/fonts/ubuntu-mono-bold.ttf"
xft.mono_regular_italic = "/data/fonts/ubuntu-mono-regular-italic.ttf"
xft.mono_bold_italic = "/data/fonts/ubuntu-mono-bold-italic.ttf"

style.xft = {}

for family, path in pairs(xft) do
  style.xft[family] = renderer.font.load(EXEDIR .. path, 14 * SCALE)
end

style.xft.logo = renderer.font.load(EXEDIR .. xft.mono_bold, 32 * SCALE)

style.background = { common.color "#2e2e32" }
style.background2 = { common.color "#252529" }
style.background3 = { common.color "#252529" }
style.text = { common.color "#97979c" }
style.caret = { common.color "#FFA94D" }
style.accent = { common.color "#e1e1e6" }
style.accent2 = { common.color "#FFA94D" }
style.dim = { common.color "#757e84" }
-- style.dim = { common.color "#525257" }
style.divider = { common.color "#202024" }
style.selection = { common.color "#48484f" }
style.line_number = { common.color "#525259" }
style.line_number2 = { common.color "#83838f" }
style.line_highlight = { common.color "#343438" }
style.scrollbar = { common.color "#414146" }
style.scrollbar2 = { common.color "#4b4b52" }

style.warn = { common.color "#FF0000" }

style.syntax = {}
style.syntax["tab"] = { common.color "#676b6f" }
style.syntax["space"] = { common.color "#676b6f" }
style.syntax["normal"] = { common.color "#e1e1e6" }
style.syntax["symbol"] = { common.color "#e1e1e6" }
style.syntax["comment"] = { common.color "#676b6f" }
style.syntax["keyword"] = { common.color "#E58AC9" }
style.syntax["keyword2"] = { common.color "#F77483" }
style.syntax["number"] = { common.color "#FFA94D" }
style.syntax["literal"] = { common.color "#FFA94D" }
style.syntax["string"] = { common.color "#f7c95c" }
style.syntax["operator"] = { common.color "#93DDFA" }
style.syntax["function"] = { common.color "#93DDFA" }


style.icons = {
  ["attention"] = "!",
  ["angle-circled-down"] = "\"",
  ["angle-circled-up"] = ",",
  ["angle-circled-left"] = ")",
  ["angle-circled-right"] = "*",
  -- document
  ["doc-text"] = "#",
  ["file-archive"] = "/",
  ["file-image"] = "0",
  ["file-pdf"] = "1",
  ["file-video"] = "J",
  ["file-audio"] = "K",
  ["file-code"] = "f",
  -- align
  ["align-left"] = "5",
  ["align-center"] = "6",
  ["align-right"] = "7",
  -- lock
  ["lock"] = "$",
  ["lock-open-alt"] = "%",
  -- feed back icon
  ["ok"] = "&",
  ["cancel"] = "x",
  ["check-empty"] = "B",
  ["check"] = "C",
  ["sort"] = ";",
  ["sort-down"] = "<",
  ["sort-up"] = "=",
  ["dot"] = ".",
  ["dot-3"] = "I",
  ["unlink"] = "?",
  ["folder-open"] = "D",
  ["folder-close"] = "d",
  ["fold-close"] = "+",
  ["fold-open"] = "-",
  -- button
  ["toggle-on"] = "@",
  ["toggle-off"] = "A",
  -- icon symbol
  ["info-circled"] = "i",
  ["chart-line"] = "g",
  ["chart-bar"] = "G",
  ["book"] = "p",
  ["build"] = "'",
  ["code"] = "3",
  ["menu"] = "4",
  ["git"] = "8",
  ["fork"] = "9",
  ["cube"] = ":",
  ["right-angle"] = ">",
  ["undo"] = "F",
  ["redo"] = "H",
  ["share"] = "L",
  ["terminal"] = "T",
}

return style
