local colors = require("colors")

-- Date (top)
local date = sbar.add("item", "date", {
    position = "right",
    icon = { drawing = false },
    label = {
        font = { size = 10 },
        color = colors.white,
        align = "right",
        padding_right = 4,
    },
    y_offset = 8,
    width = 0,
    update_freq = 60,
})

-- Time (bottom)
local clock = sbar.add("item", "clock", {
    position = "right",
    icon = { drawing = false },
    label = {
        font = { size = 14, style = "Bold" },
        color = colors.white,
        align = "right",
        padding_right = 4,
    },
    y_offset = -6,
    update_freq = 10,
})

date:subscribe({"forced", "routine", "system_woke"}, function()
    date:set({ label = os.date("%a, %b %d") })
end)

clock:subscribe({"forced", "routine", "system_woke"}, function()
    clock:set({ label = os.date("%I:%M %p") })
end)

date:subscribe("mouse.clicked", function()
    os.execute("open -a Calendar.app")
end)

clock:subscribe("mouse.clicked", function()
    os.execute("open -a Calendar.app")
end)

sbar.add("bracket", "calendar.bracket", {date.name, clock.name}, {
    background = {
        color = 0xff000000,
        border_color = colors.white,
        border_width = 1,
        corner_radius = 8,
    }
})
-- Add padding item to control right spacing
sbar.add("item", "calendar.padding", {
    position = "right",
    width = 8  -- Set this to 0 or a negative value to move the widget closer to the right edge
})

