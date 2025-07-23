local colors = require("colors")
local icons = require("icons")

return {
    paddings = 6,
    group_paddings = 12,
    modes = {
        main = {
            icon = icons.rebel,
            color = colors.rainbow[1]
        },
        service = {
            icon = icons.nuke,
            color = 0xffff9e64
        }
    },
    bar = {
        height = 42,
        padding = {
            x = 4,
            y = 0
        },
        background = colors.bar.bg
    },
    items = {
        height = 32,
        gap = 8,
        padding = {
            right = 18,
            left = 14,
            top = 2,
            bottom = 2
        },
        default_color = function(workspace)
            return colors.rainbow[workspace + 1]
        end,
        highlight_color = function(workspace)
            return colors.yellow
        end,
        colors = {
            background = colors.bg1
        },
        corner_radius = 8
    },

    icons = "sketchybar-app-font:Regular:18.0", -- slightly smaller icon font

    font = {
        text = "FiraCode Nerd Font Mono", -- Used for text
        numbers = "FiraCode Nerd Font Mono", -- Used for numbers
        style_map = {
            ["Regular"] = "Regular",
            ["Semibold"] = "Medium",
            ["Bold"] = "SemiBold",
            ["Heavy"] = "Bold",
            ["Black"] = "ExtraBold"
        }
    }
}
