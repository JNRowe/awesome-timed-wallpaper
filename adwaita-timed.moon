---------------------------------------------------------------------------
-- @author James Rowe &lt;jnrowe@gmail.com&gt;
-- @copyright 2016 James Rowe
-- @licence LGPL-2.1
---------------------------------------------------------------------------
-- This is based around the data from adwaita-timed.xml file in
-- gnome-themes-standard, which was (according to the git history) created by
-- Jakub Steiner <jimmac@gmail.com>.  The licence is LGPL-2.1 to reflect that
-- origin.

gfs = require "gears.filesystem"
naughty = require "naughty"

-- Default to resolution of first screen
size =
    width: screen[1].geometry.x,
    height: screen[1].geometry.y,

-- Prefix for external commands.  Fex “gm “ if your installation provides only
-- GraphicsMagick, or “/some/crazy/path/” if you’ve used a weird prefix for
-- ImageMagick installation
command_prefix = ""

cache_path = gfs.get_xdg_cache_home!

adwaita_path = "/usr/share/themes/Adwaita/backgrounds"
resized_path = "#{cache_path}/resized"
gfs.make_directories resized_path
generated_path = "#{cache_path}/generated"
gfs.make_directories generated_path

---
-- Find path to background file
-- @param name Filename to mangle
-- @return Location of cached, and possibly resized, copy of the given file
bg_file = (name) ->
    input = "#{adwaita_path}/#{name}.jpg"
    resized = "#{resized_path}/#{name}.jpg"

    unless gfs.file_readable resized
        ret = os.execute "#{command_prefix}convert #{input} -resize #{size.width}x#{size.height} #{resized}"
        if ret != 0
            naughty.notify
                preset: naughty.config.presets.critical,
                title: "Oops, wallpaper resize went wrong"
    return resized

local PCNT
---
-- Find path to blended image, generating it if necessary
-- @param from_ Base image name
-- @param to Overlay image name
-- @param ratio Image blending ratio
-- @return Location of blended image, generating image if necessary
gen_bg_file = (from_, to, ratio) ->
    pcnt = "%02d"\format ratio * 100
    if pcnt == PCNT
        return nil
    else
        PCNT = pcnt
    wallpaper = "#{generated_path}/#{from_}-#{to}-#{pcnt}.jpg"
    unless gfs.file_readable wallpaper
        from_ = bg_file from_
        to = bg_file to
        ret = os.execute "#{command_prefix}composite -blend #{pcnt}x#{100 - pcnt} #{to} #{from_} #{wallpaper}"
        if ret != 0
            naughty.notify
                preset: naughty.config.presets.critical,
                title: "Oops, wallpaper blend went wrong"
            return from_
    return wallpaper

local _STATIC
local _LAST
---
-- Return location of time-dependent wallpaper image
-- @return Time-dependent wallpaper image, or nil if no change required
background = ->
    now = os.date("*t")
    hours = now.hour + now.min/60

    file = switch now.hour
        when 7
            -- We start with sunrise at 7 AM. It will remain up for 1 hour.
            _STATIC = true
            bg_file "morning"
        when 8, 9, 10, 11, 12
            -- Sunrise starts to transition to day at 8 AM. The transition lasts
            -- for 5 hours, ending at 1 PM.
            _STATIC = false
            gen_bg_file "morning", "bright-day", (hours - 8) / 5
        when 13, 14, 15, 16, 17
            -- It’s 1 PM, we’re showing the day image in full force now, for 5
            -- hours ending at 6 PM.
            _STATIC = true
            bg_file "bright-day"
        when 18, 19, 20, 21, 22, 23
            -- It’s 8 PM and it’s going to start to get darker. This will
            -- transition for 6 hours up until midnight.
            _STATIC = false
            gen_bg_file "bright-day", "good-night", (hours - 18) / 6
        when 0, 1, 2, 3, 4
            -- It’s midnight. It’ll stay dark for 5 hours up until 5 AM.
            _STATIC = true
            bg_file "good-night"
        when 5, 6
            -- It’s 5 AM. We’ll start transitioning to sunrise for 2 hours up
            -- until 7 AM.
            _STATIC = false
            gen_bg_file "good-night", "morning", (hours - 5) / 2
    if _STATIC
        if _LAST == file
            return nil
        else
            _LAST = file
    return file

return background
