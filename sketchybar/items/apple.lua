local colors = require("colors")
local icons = require("icons")
local settings = require("settings")

local apple = sbar.add("item", {
    icon = {
        font = {
            family = "FiraCode Nerd Font Mono",
            size = 30.0
        },
        string = "",
        color = 0xff00d4ff,
        padding_right = 8,
        padding_left = 8,
        highlight_color = settings.modes.service.color
    },
    label = {
        drawing = false
    },
    background = {
        color = 0xff000000,
        border_color = 0xff00d4ff,
        border_width = 1
    },

    padding_left = 0,
    padding_right = 1,
    click_script = "$CONFIG_DIR/scripts/caffeine.sh",
    script = "$CONFIG_DIR/scripts/caffeine.sh status"
})

-- Check initial caffeine status
sbar.exec("$CONFIG_DIR/scripts/caffeine.sh status")

apple:subscribe("aerospace_enter_service_mode", function(_)
    sbar.animate("tanh", 10, function()
        apple:set({
            background = {
                border_color = settings.modes.service.color,
                border_width = 3
            },
            icon = {
                highlight = true,
                string = settings.modes.service.icon
            }
        })

    end)
end)

apple:subscribe("aerospace_leave_service_mode", function(_)
    sbar.animate("tanh", 10, function()
        apple:set({
            background = {
                border_color = settings.modes.main.color,
                border_width = 1
            },
            icon = {
                highlight = false,
                string = ""
            }
        })
    end)
end)

-- Padding to the right of the main button
sbar.add("item", {
    width = 7
})

