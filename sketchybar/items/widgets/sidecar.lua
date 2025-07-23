local colors = require("colors")
local icons = require("icons")
local settings = require("settings")

local sidecar = sbar.add("item", "widgets.sidecar", {
    position = "right",
    icon = {
        string = "📱",
        font = {
            style = settings.font.style_map["Regular"],
            size = 15.0
        },
        color = 0xffff007c,  -- Red when inactive
        align = "center"
    },
    label = {
        drawing = false
    },
    click_script = "$CONFIG_DIR/scripts/sidecar.sh"
})

-- Check initial Sidecar status
sbar.exec("$CONFIG_DIR/scripts/sidecar.sh status")

sidecar:subscribe("mouse.clicked", function(env)
    sbar.exec("$CONFIG_DIR/scripts/sidecar.sh")
end)

-- Background around the sidecar item
sbar.add("bracket", "widgets.sidecar.bracket", {sidecar.name}, {
    background = {
        color = 0xff000000,
        border_color = colors.rainbow[#colors.rainbow - 2],
        border_width = 1
    }
})

-- Padding to match other widgets
sbar.add("item", "widgets.sidecar.padding", {
    position = "right",
    width = settings.items.gap
}) 