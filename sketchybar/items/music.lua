local music = sbar.add("item", "music", {
    position = "right",
    label = {
        font = { size = 14 },
        max_chars = 24,
        padding_left = 8,
        scroll_duration = 100,
    },
    script = "$CONFIG_DIR/scripts/music_widget.sh",
    click_script = "$CONFIG_DIR/scripts/music_widget.sh mouse.clicked",
    background = {
        color = 0xff000000,
        border_color = 0xffa6da95,
        border_width = 2,
        corner_radius = 8,
        padding_left = 2,
    },
    padding_right = 0,
    update_freq = 10,
})

-- Timer to update every 10 seconds (or adjust as needed)
sbar.add("timer", "music_timer", {
    interval = 10,
    callback = function()
        sbar.exec("$CONFIG_DIR/scripts/music_widget.sh")
    end
}) 