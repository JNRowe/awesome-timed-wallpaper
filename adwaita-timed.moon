---------------------------------------------------------------------------
-- @author James Rowe &lt;jnrowe@gmail.com&gt;
-- @copyright 2016 James Rowe
-- @licence LGPL-2.1
---------------------------------------------------------------------------
-- This is based around the data from adwaita-timed.xml file in
-- gnome-themes-standard, which was (according to the git history) created by
-- Jakub Steiner <jimmac@gmail.com>.  The licence is LGPL-2.1 to reflect that
-- origin.

awful = require "awful"
naughty = require "naughty"

size =
    width: 1920,
    height: 1080,

cache_path = awful.util.getdir 'cache'
awful.util.mkdir cache_path

adwaita_path = "/usr/share/themes/Adwaita/backgrounds"
resized_path = "#{cache_path}/resized"
awful.util.mkdir resized_path
generated_path = "#{cache_path}/generated"
awful.util.mkdir generated_path

---
-- Find path to background file
-- @param name Filename to mangle
-- @return Location of cached, and possibly resized, copy of the given file
bg_file = (name) ->
    input = "#{adwaita_path}/#{name}.jpg"
    resized = "#{resized_path}/#{name}.jpg"

    unless awful.util.file_readable resized
        ret = os.execute "convert #{input} -resize #{size.width}x#{size.height} #{resized}"
        if ret != 0
            naughty.notify
                preset: naughty.config.presets.critical,
                title: "Oops, wallpaper resize went wrong"
    return resized

---
-- Find path to blended image, generating it if necessary
-- @param from_ Base image name
-- @param to Overlay image name
-- @param ratio Image blending ratio
-- @return Location of blended image, generating image if necessary
gen_bg_file = (from_, to, ratio) ->
    pcnt = "%02d"\format ratio * 100
    wallpaper = "#{generated_path}/#{from_}-#{to}-#{pcnt}.jpg"
    unless awful.util.file_readable wallpaper
        from_ = bg_file from_
        to = bg_file to
        ret = os.execute "composite -blend #{pcnt}x#{100 - pcnt} #{to} #{from_} #{wallpaper}"
        if ret != 0
            naughty.notify
                preset: naughty.config.presets.critical,
                title: "Oops, wallpaper blend went wrong"
            return from_
    return wallpaper

---
-- Return location of time-dependent wallpaper image
-- @return Time-dependent wallpaper image
background = ->
    now = os.date("*t")
    hours = now.hour + now.min/60

    switch now.hour
        when 7
            -- We start with sunrise at 7 AM. It will remain up for 1 hour.
            bg_file "morning"
        when 8, 9, 10, 11, 12
            -- Sunrise starts to transition to day at 8 AM. The transition lasts
            -- for 5 hours, ending at 1 PM.
            gen_bg_file "morning", "bright-day", (hours - 8) / 5
        when 13, 14, 15, 16, 17
            -- It's 1 PM, we're showing the day image in full force now, for 5
            -- hours ending at 6 PM.
            bg_file "bright-day"
        when 18, 19, 20, 21, 22, 23
            -- It's 8 PM and it's going to start to get darker. This will
            -- transition for 6 hours up until midnight.
            gen_bg_file "bright-day", "good-night", (hours - 18) / 6
        when 0, 1, 2, 3, 4
            -- It's midnight. It'll stay dark for 5 hours up until 5 AM.
            bg_file "good-night"
        when 5, 6
            -- It's 5 AM. We'll start transitioning to sunrise for 2 hours up
            -- until 7 AM.
            gen_bg_file "good-night", "morning", (hours - 5) / 2

return background
