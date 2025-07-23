local colors = require("colors")
local icons = require("icons")
local settings = require("settings")
local app_icons = require("helpers.app_icons")

local spaces = {}

local workspaces = get_workspaces()
local current_workspace = get_current_workspace()
local function split(str, sep)
    local result = {}
    local regex = ("([^%s]+)"):format(sep)
    for each in str:gmatch(regex) do
        table.insert(result, each)
    end
    return result
end

for i, workspace in ipairs(workspaces) do
    local selected = workspace == current_workspace
    local space = sbar.add("item", "item." .. i, {
        icon = {
            font = {
                family = settings.font.numbers
            },
            string = i,
            padding_left = settings.items.padding.left,
            padding_right = settings.items.padding.left / 2,
            color = settings.items.default_color(i),
            highlight_color = settings.items.highlight_color(i),
            highlight = selected
        },
        label = {
            padding_right = settings.items.padding.right,
            color = settings.items.default_color(i),
            highlight_color = settings.items.highlight_color(i),
            font = settings.icons,
            y_offset = -1,
            highlight = selected
        },
        padding_right = 1,
        padding_left = 1,
        background = {
            color = 0xff000000,
            border_width = 1,
            height = settings.items.height,
            border_color = selected and settings.items.highlight_color(i) or settings.items.default_color(i)
        },
        popup = {
            background = {
                border_width = 5,
                border_color = colors.black
            }
        }
    })

    spaces[i] = space

    -- Define the icons for open apps on each space initially
    sbar.exec("aerospace list-windows --workspace " .. i .. " --format '%{app-name}' --json ", function(apps)
        local icon_line = ""
        local no_app = true
        for i, app in ipairs(apps) do
            no_app = false
            local app_name = app["app-name"]
            local lookup = app_icons[app_name]
            local icon = ((lookup == nil) and app_icons["default"] or lookup)
            icon_line = icon_line .. " " .. icon
        end

        if no_app then
            icon_line = " —"
            -- Hide workspace if it's empty and not workspace 1 (always keep workspace 1 visible)
            if workspace ~= "1" then
                space:set({
                    drawing = false
                })
            end
        else
            -- Show workspace if it has apps
            space:set({
                drawing = true
            })
        end

        sbar.animate("tanh", 10, function()
            space:set({
                label = icon_line
            })
        end)
    end)

    -- Padding space between each item
    sbar.add("item", "item." .. i .. "padding", {
        script = "",
        width = settings.items.gap
    })

    -- Item popup
    local space_popup = sbar.add("item", {
        position = "popup." .. space.name,
        padding_left = 5,
        padding_right = 0,
        background = {
            drawing = true,
            image = {
                corner_radius = 9,
                scale = 0.2
            }
        }
    })

    space:subscribe("aerospace_workspace_change", function(env)
        local selected = env.FOCUSED_WORKSPACE == workspace
        
        -- Check if workspace has windows before showing it
        sbar.exec("aerospace list-windows --workspace " .. workspace .. " --format '%{app-name}' --json ", function(apps)
            local has_windows = false
            for _, app in ipairs(apps) do
                has_windows = true
                break
            end
            
            -- Only show workspace if it has windows or is workspace 1
            if has_windows or workspace == "1" then
                space:set({
                    drawing = true,
                    icon = {
                        highlight = selected
                    },
                    label = {
                        highlight = selected
                    },
                    background = {
                        border_color = selected and settings.items.highlight_color(i) or settings.items.default_color(i)
                    }
                })
            else
                space:set({
                    drawing = false
                })
            end
        end)
    end)

    space:subscribe("mouse.clicked", function(env)
        local SID = split(env.NAME, ".")[2]
        if env.BUTTON == "other" then
            space_popup:set({
                background = {
                    image = "item." .. SID
                }
            })
            space:set({
                popup = {
                    drawing = "toggle"
                }
            })
        else
            sbar.exec("aerospace workspace " .. SID)
        end
    end)

    space:subscribe("mouse.exited", function(_)
        space:set({
            popup = {
                drawing = false
            }
        })
    end)
end

local space_window_observer = sbar.add("item", {
    drawing = false,
    updates = true
})

-- Event handles
space_window_observer:subscribe("space_windows_change", function(env)
    for i, workspace in ipairs(workspaces) do
        sbar.exec("aerospace list-windows --workspace " .. i .. " --format '%{app-name}' --json ", function(apps)
            local icon_line = ""
            local no_app = true
            for i, app in ipairs(apps) do
                no_app = false
                local app_name = app["app-name"]
                local lookup = app_icons[app_name]
                local icon = ((lookup == nil) and app_icons["default"] or lookup)
                icon_line = icon_line .. " " .. icon
            end

            if no_app then
                icon_line = " —"
                -- Hide workspace if it's empty and not workspace 1
                if workspace ~= "1" then
                    spaces[i]:set({
                        drawing = false
                    })
                end
            else
                -- Show workspace if it has apps
                spaces[i]:set({
                    drawing = true
                })
            end

            sbar.animate("tanh", 10, function()
                spaces[i]:set({
                    label = icon_line
                })
            end)
        end)
    end
end)

space_window_observer:subscribe("aerospace_focus_change", function(env)
    for i, workspace in ipairs(workspaces) do
        sbar.exec("aerospace list-windows --workspace " .. i .. " --format '%{app-name}' --json ", function(apps)
            local icon_line = ""
            local no_app = true
            for i, app in ipairs(apps) do
                no_app = false
                local app_name = app["app-name"]
                local lookup = app_icons[app_name]
                local icon = ((lookup == nil) and app_icons["default"] or lookup)
                icon_line = icon_line .. " " .. icon
            end

            if no_app then
                icon_line = " —"
                -- Hide workspace if it's empty and not workspace 1
                if workspace ~= "1" then
                    spaces[i]:set({
                        drawing = false
                    })
                end
            else
                -- Show workspace if it has apps
                spaces[i]:set({
                    drawing = true
                })
            end

            sbar.animate("tanh", 10, function()
                spaces[i]:set({
                    label = icon_line
                })
            end)
        end)
    end
end)
