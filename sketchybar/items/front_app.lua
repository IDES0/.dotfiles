local colors = require("colors")
local settings = require("settings")
local app_icons = require("helpers.app_icons")

-- Separator between workspaces and active window
local separator = sbar.add("item", "front_app.separator", {
    display = "active",
    icon = {
        drawing = false
    },
    label = {
        string = ">",
        color = colors.white,
        font = {
            style = settings.font.style_map["Bold"],
            size = 22.0
        }
    }
})

local front_app_icon = sbar.add("item", "front_app.icon", {
    display = "active",
    icon = {
        drawing = false
    },
    label = {
        font = settings.icons,
        padding_right = 4
    },
    updates = true
})

local front_app_label = sbar.add("item", "front_app.label", {
    display = "active",
    icon = {
        drawing = false
    },
    label = {
        font = {
            style = settings.font.style_map["Bold"],
            size = 14.0
        }
    },
    updates = true
})

front_app_icon:subscribe("front_app_switched", function(env)
    local app_name = env.INFO
    
    -- Use the exact same logic as spaces.lua
    local lookup = app_icons[app_name]
    local icon = ((lookup == nil) and app_icons["default"] or lookup)
    
    front_app_icon:set({
        label = {
            string = icon
        }
    })
end)

front_app_label:subscribe("front_app_switched", function(env)
    local app_name = env.INFO
    
    front_app_label:set({
        label = {
            string = app_name
        }
    })
end)
