local colors = require("colors")
local icons = require("icons")
local settings = require("settings")

local popup_width = 250

local volume = sbar.add("item", "widgets.volume", {
    position = "right",
    icon = {
        string = icons.volume._100,
        align = "left",
        color = colors.white,
        font = {
            style = settings.font.style_map["Regular"],
            size = 15.0
        },
        min_width = 24
    },
    label = {
        string = "??%",
        font = {
            family = settings.font.numbers,
            size = 15.0
        }
    },
    background = {
        color = 0xff000000,
        border_color = colors.rainbow[#colors.rainbow - 3],
        border_width = 1
    }
})

sbar.add("item", "widgets.volume.padding", {
    position = "right",
    width = settings.items.gap
})

local volume_slider = sbar.add("slider", popup_width, {
    position = "popup.widgets.volume",
    slider = {
        highlight_color = colors.blue,
        background = {
            height = 6,
            corner_radius = 3,
            color = colors.bg2
        },
        knob = {
            string = "􀀁",
            drawing = true
        }
    },
    background = {
        color = 0xff000000,
        height = 2,
        y_offset = -20
    },
    click_script = 'osascript -e "set volume output volume $PERCENTAGE"'
})

volume:subscribe("volume_change", function(env)
    local volume_val = tonumber(env.INFO)
    local icon = icons.volume._0
    if volume_val > 60 then
        icon = icons.volume._100
    elseif volume_val > 30 then
        icon = icons.volume._66
    elseif volume_val > 10 then
        icon = icons.volume._33
    elseif volume_val > 0 then
        icon = icons.volume._10
    end

    local lead = ""
    if volume_val < 10 then
        lead = "0"
    end

    volume:set({
        icon = {
            string = icon
        },
        label = lead .. volume_val .. "%"
    })
    volume_slider:set({
        slider = {
            percentage = volume_val
        }
    })
end)

local function volume_collapse_details()
    local drawing = volume:query().popup.drawing == "on"
    if not drawing then
        return
    end
    volume:set({
        popup = {
            drawing = false
        }
    })
    sbar.remove('/volume.device\\.*/')
end

local current_audio_device = "None"
local function volume_toggle_details(env)
    if env.BUTTON == "right" then
        sbar.exec("open /System/Library/PreferencePanes/Sound.prefpane")
        return
    end

    local should_draw = volume:query().popup.drawing == "off"
    if should_draw then
        volume:set({
            popup = {
                drawing = true
            }
        })
        sbar.exec("SwitchAudioSource -t output -c", function(result)
            current_audio_device = result:sub(1, -2)
            sbar.exec("SwitchAudioSource -a -t output", function(available)
                current = current_audio_device
                local color = colors.white
                local counter = 0

                for device in string.gmatch(available, '[^\r\n]+') do
                    local color = colors.white
                    if current == device then
                        color = colors.white
                    end
                    sbar.add("item", "volume.device." .. counter, {
                        position = "popup.widgets.volume",
                        width = popup_width,
                        align = "center",
                        label = {
                            string = device,
                            color = color
                        },
                        click_script = 'SwitchAudioSource -s "' .. device .. '" && sketchybar --set /volume.device\\.*/ label.color=' .. colors.white .. ' --set $NAME label.color=' .. colors.white

                    })
                    counter = counter + 1
                end
            end)
        end)
    else
        volume_collapse_details()
    end
end

local function volume_scroll(env)
    local delta = env.SCROLL_DELTA
    sbar.exec('osascript -e "set volume output volume (output volume of (get volume settings) + ' .. delta .. ')"')
end

volume:subscribe("mouse.clicked", volume_toggle_details)
volume:subscribe("mouse.scrolled", volume_scroll)
volume:subscribe("mouse.exited.global", volume_collapse_details)

