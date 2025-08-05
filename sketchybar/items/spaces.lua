local colors = require("colors")
local icons = require("icons")
local settings = require("settings")
local app_icons = require("helpers.app_icons")

local spaces = {}

-- Neon color palette for different monitors (1-4, add more as needed)
local neon_colors = {
    [1] = {
        default = 0xff00d4ff,    -- Neon blue
        active = 0xffb3ecff,     -- Use 0xff66e0ff if you want medium light neon blue
        focused = 0xffb3ecff     -- Even lighter for focused
    },
    [2] = {
        default = 0xffff007c,    -- Neon pink
        active = 0xffff4da6,     -- Lighter neon pink
        focused = 0xffff4da6     -- Use 0xffff99cc for even lighter for focused
    },
    [3] = {
        default = 0xff00ff88,    -- Neon green
        active = 0xff4dffaa,     -- Lighter neon green
        focused = 0xff99ffcc     -- Even lighter for focused
    },
    [4] = {
        default = 0xffbb00ff,    -- Neon purple
        active = 0xffcc4dff,     -- Lighter neon purple
        focused = 0xffdd99ff     -- Even lighter for focused
    }
}

-- Cache for workspace-monitor mapping
local workspace_monitors = {}

-- Function to get monitor for a workspace
local function get_workspace_monitor(workspace)
    if workspace_monitors[workspace] then
        return workspace_monitors[workspace]
    end
    
    sbar.exec("aerospace list-workspaces --all --format '%{workspace} %{monitor-id}'", function(result)
        for line in result:gmatch("[^\r\n]+") do
            local ws, monitor = line:match("(%d+) (%d+)")
            if ws and monitor then
                workspace_monitors[ws] = tonumber(monitor)
            end
        end
    end)
    
    return workspace_monitors[workspace] or 1
end

-- Function to get color for workspace based on monitor and state
local function get_workspace_color(workspace, state, is_visible)
    local monitor = get_workspace_monitor(workspace)
    local color_set = neon_colors[monitor] or neon_colors[1]
    
    if state == "focused" then
        return color_set.focused
    elseif is_visible then
        return color_set.active
    else
        return color_set.default
    end
end

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

-- Initialize workspace-monitor mapping
sbar.exec("aerospace list-workspaces --all --format '%{workspace} %{monitor-id}'", function(result)
    for line in result:gmatch("[^\r\n]+") do
        local ws, monitor = line:match("(%d+) (%d+)")
        if ws and monitor then
            workspace_monitors[ws] = tonumber(monitor)
        end
    end
end)

for i, workspace in ipairs(workspaces) do
    local selected = workspace == current_workspace
    local monitor = get_workspace_monitor(workspace)
    local workspace_color = get_workspace_color(workspace, selected and "focused" or "default", false)
    
    local space = sbar.add("item", "item." .. i, {
        icon = {
            font = {
                family = settings.font.numbers
            },
            string = i,
            padding_left = settings.items.padding.left,
            padding_right = settings.items.padding.left / 2,
            color = workspace_color,
            highlight_color = get_workspace_color(workspace, "focused", false),
            highlight = selected
        },
        label = {
            padding_right = settings.items.padding.right,
            color = workspace_color,
            highlight_color = get_workspace_color(workspace, "focused", false),
            font = settings.icons,
            y_offset = -1,
            highlight = selected
        },
        padding_right = 1,
        padding_left = 1,
        background = {
            color = 0xff000000,
            border_width = selected and 3 or 1,
            height = settings.items.height,
            border_color = selected and get_workspace_color(workspace, "focused", false) or workspace_color
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
        for _, app in ipairs(apps) do
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
        
        -- Update workspace-monitor mapping
        sbar.exec("aerospace list-workspaces --all --format '%{workspace} %{monitor-id} %{workspace-is-visible}'", function(result)
            for line in result:gmatch("[^\r\n]+") do
                local ws, monitor, is_visible = line:match("(%d+) (%d+) (%w+)")
                if ws and monitor then
                    workspace_monitors[ws] = tonumber(monitor)
                    
                    if ws == workspace then
                        local workspace_color = get_workspace_color(workspace, selected and "focused" or "default", is_visible == "true")
                        
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
                                        color = workspace_color,
                                        highlight_color = get_workspace_color(workspace, "focused", false),
                                        highlight = selected
                                    },
                                    label = {
                                        color = workspace_color,
                                        highlight_color = get_workspace_color(workspace, "focused", false),
                                        highlight = selected
                                    },
                                    background = {
                                        border_color = workspace_color,
                                        border_width = selected and 3 or 1
                                    }
                                })
                            else
                                space:set({
                                    drawing = false
                                })
                            end
                        end)
                    end
                end
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
            for _, app in ipairs(apps) do
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
    -- Update workspace-monitor mapping and colors on focus change
    sbar.exec("aerospace list-workspaces --all --format '%{workspace} %{monitor-id} %{workspace-is-visible} %{workspace-is-focused}'", function(result)
        for line in result:gmatch("[^\r\n]+") do
            local ws, monitor, is_visible, is_focused = line:match("(%d+) (%d+) (%w+) (%w+)")
            if ws and monitor then
                workspace_monitors[ws] = tonumber(monitor)
                local workspace_num = tonumber(ws)
                
                if spaces[workspace_num] then
                    local workspace_color = get_workspace_color(ws, is_focused == "true" and "focused" or "default", is_visible == "true")
                    
                    sbar.exec("aerospace list-windows --workspace " .. ws .. " --format '%{app-name}' --json ", function(apps)
                        local icon_line = ""
                        local no_app = true
                        for _, app in ipairs(apps) do
                            no_app = false
                            local app_name = app["app-name"]
                            local lookup = app_icons[app_name]
                            local icon = ((lookup == nil) and app_icons["default"] or lookup)
                            icon_line = icon_line .. " " .. icon
                        end

                        if no_app then
                            icon_line = " —"
                            -- Hide workspace if it's empty and not workspace 1
                            if ws ~= "1" then
                                spaces[workspace_num]:set({
                                    drawing = false
                                })
                            end
                        else
                            -- Show workspace if it has apps and update colors
                            spaces[workspace_num]:set({
                                drawing = true,
                                icon = {
                                    color = workspace_color,
                                    highlight_color = get_workspace_color(ws, "focused", false),
                                    highlight = is_focused == "true"
                                },
                                label = {
                                    color = workspace_color,
                                    highlight_color = get_workspace_color(ws, "focused", false),
                                    highlight = is_focused == "true"
                                },
                                background = {
                                    border_color = workspace_color,
                                    border_width = (is_focused == "true") and 3 or 1
                                }
                            })
                        end

                        sbar.animate("tanh", 10, function()
                            spaces[workspace_num]:set({
                                label = icon_line
                            })
                        end)
                    end)
                end
            end
        end
    end)
end)
