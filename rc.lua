--[[

    Min Awesome Config-fil

--]]

--{{{ Required libraries
local gears     = require("gears")
local awful     = require("awful")
awful.rules     = require("awful.rules")
require("awful.autofocus")
local wibox     = require("wibox")
local beautiful = require("beautiful")
local naughty   = require("naughty")
--local drop      = require("scratchdrop")
local lain      = require("lain")

local debianmenu = require("debian.menu")
--}}}

--{{{ Error handling
if awesome.startup_errors then
  naughty.notify({ preset = naughty.config.presets.critical,
                   title  = "Oops, there were errors during startup!",
                   text   = awesome.startup_errors })
end

do
  local in_error = false
  awesome.connect_signal("debug::error", function (err)
    if in_error then return end
    in_error = true

    naughty.notify({ preset = naughty.config.presets.critical,
                     title  = "Oops, an error happened!",
                     text   = err })

    in_error = false
  end)
end
--}}}

--{{{ Autostart applications
--}}}

--{{{ Variable definitions
-- localization
os.setlocale(os.getenv("LANG"))

-- beautiful init
beautiful.init(os.getenv("HOME") .. "/.config/awesome/themes/multicolor/theme.lua")

-- common
modkey     = "Mod4"
altkey     = "Mod1"
terminal   = "x-terminal-emulator" or "terminator"
editor     = os.getenv("EDITOR") or "vim"
editor_cmd = terminal .. " -e " .. editor

-- user defined

local layouts =
{
    awful.layout.suit.floating,
    awful.layout.suit.tile,
    awful.layout.suit.tile.left,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.tile.top,
    awful.layout.suit.fair,
    awful.layout.suit.fair.horizontal,
    awful.layout.suit.spiral,
    awful.layout.suit.spiral.dwindle,
    awful.layout.suit.max,
    awful.layout.suit.max.fullscreen,
    awful.layout.suit.magnifier
}
--}}}

-- {{{ Tags
tags = {
  names   = { "web", "dev", "docs", "media", "other" },
  layouts = { layouts[3], layouts[3], layouts[3], layouts[3], layouts[3] }
}

for s = 1, screen.count() do
    tags[s] = awful.tag(tags.names, s, tags.layouts)
end
-- }}}

-- {{{ Wallpaper
if beautiful.wallpaper then
  for s = 1, screen.count() do
    gears.wallpaper.maximized(beautiful.wallpaper, s, true)
  end
end
-- }}}

-- {{{ Menu
myawesomemenu = {
   { "manual",      terminal .. " -e man awesome" },
   { "edit config", editor_cmd .. " " .. awesome.conffile },
   { "restart",     awesome.restart },
   { "quit",        awesome.quit }
}

mymainmenu = awful.menu({ items = { --{ "awesome", myawesomemenu, beautiful.awesome_icon },
                                    { "logout",   terminal .. " -e gnome-session-quit" },
                                    { "terminal", terminal },
                                    { "chromium", terminal .. " -e chromium-browser" },
                                    { "more...",  debianmenu.Debian_menu.Debian }
                                  }
                        })

--mylauncher = awful.widget.launcher({ menu = mymainmenu })
-- }}}

-- {{{ Wibox
markup = lain.util.markup

-- Textclock
clockicon = wibox.widget.imagebox(beautiful.widget_clock)
mytextclock = awful.widget.textclock(markup("#7788af", "%d %B") .. markup("#343639", ">") .. markup("#de5e1e", " %H:%M "))

-- Calendar
--lain.widgets.calendar:attach(mytextclock, { font_size = 10 })

-- / fs
fsicon = wibox.widget.imagebox(beautiful.widget_fs)
fswidget = lain.widgets.fs({
  settings = function()
    widget:set_markup(markup("#80d9d8", fs_now.used .. "% "))
  end
})

-- Net
netdownicon = wibox.widget.imagebox(beautiful.widget_netdown)
netdowninfo = wibox.widget.textbox()
netupicon = wibox.widget.imagebox(beautiful.widget_netup)
netupinfo = lain.widgets.net({
  settings = function()
    widget:set_markup(markup("#e54c62", net_now.sent .. " "))
    netdowninfo:set_markup(markup("#87af5f", net_now.received .. " "))
  end
})

-- MEM
memicon = wibox.widget.imagebox(beautiful.widget_mem)
memwidget = lain.widgets.mem({
  settings = function()
    widget:set_markup(markup("#e0da37", mem_now.used .. "M "))
  end
})

-- ALSA volume
volicon = wibox.widget.imagebox(beautiful.widget_vol)
volumewidget = lain.widgets.alsa({
  settings = function()
    if volume_now.status == "off" then
        volume_now.level = volume_now.level .. "M"
    end
    widget:set_markup(markup("#7493d2", volume_now.level .. "% "))
  end
})

-- CPU
cpuicon = wibox.widget.imagebox()
cpuicon:set_image(beautiful.widget_cpu)
cpuwidget = lain.widgets.cpu({
  settings = function()
    widget:set_markup(markup("#e33a6e", cpu_now.usage .. "% "))
  end
})

-- Coretemp
tempicon = wibox.widget.imagebox(beautiful.widget_temp)
tempwidget = lain.widgets.temp({
  settings = function()
    widget:set_markup(markup("#f1af5f", coretemp_now .. "°C "))
  end
})
-- }}}

-- {{{ Spacer
spacer = wibox.widget.textbox(" ")
-- }}}

-- {{{ Layout
mywibox       = {}
mybuttomwibox = {}
mypromptbox   = {}
mylayoutbox   = {}
mytaglist     = {}
mytaglist.buttons = awful.util.table.join(
                    awful.button({ }, 1, awful.tag.viewonly),
                    awful.button({ modkey }, 1, awful.client.movetotag),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, awful.client.toggletag),
                    awful.button({ }, 4, function(t) awful.tag.viewnext(awful.tag.getscreen(t)) end),
                    awful.button({ }, 5, function(t) awful.tag.viewprev(awful.tag.getscreen(t)) end)
                    )

mytasklist = {}
mytasklist.buttons = awful.util.table.join(
                     awful.button({ }, 1, function (c)
                                              if c == client.focus then
                                                  c.minimized = true
                                              else
                                                  -- Without this, the following
                                                  -- :isvisible() makes no sense
                                                  c.minimized = false
                                                  if not c:isvisible() then
                                                      awful.tag.viewonly(c:tags()[1])
                                                  end
                                                  -- This will also un-minimize
                                                  -- the client, if needed
                                                  client.focus = c
                                                  c:raise()
                                                end
                                            end),
                     awful.button({ }, 3, function ()
                                              if instance then
                                                  instance:hide()
                                                  instance = nil
                                              else
                                                  instance = awful.menu.clients({ width=250 })
                                              end
                                          end),
                     awful.button({ }, 4, function ()
                                              awful.client.focus.byidx(1)
                                              if client.focus then client.focus:raise() end
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.client.focus.byidx(-1)
                                              if client.focus then client.focus:raise() end
                                          end))

for s = 1, screen.count() do
  -- Create a promptbox for each screen
  mypromptbox[s] = awful.widget.prompt()

  -- We need one layoutbox per screen
  mylayoutbox[s] = awful.widget.layoutbox(s)
  mylayoutbox[s]:buttons(awful.util.table.join(
                          awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
                          awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
                          awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
                          awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)))

  -- Create a taglist widget
  mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.filter.all, mytaglist.buttons)

  -- Create a tasklist widget
  mytasklist[s] = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, mytasklist.buttons)

  -- Create a upper wibox
  mywibox[s] = awful.wibox({ position = "top", screen = s, height = 20 })

  -- Widgets that are aligned to the upper left
  local left_layout = wibox.layout.fixed.horizontal()
  left_layout:add(mytaglist[s])
  left_layout:add(mypromptbox[s])
  --left_layout:add(mpdicon)
  --left_layout:add(mpdwidget)

  -- Widgets that are aligned to the upper right
  local right_layout = wibox.layout.fixed.horizontal()
  --right_layout:add(mailicon)
  --right_layout:add(mailwidget)
  right_layout:add(netdownicon)
  right_layout:add(netdowninfo)
  right_layout:add(netupicon)
  right_layout:add(netupinfo)
  right_layout:add(volicon)
  right_layout:add(volumewidget)
  right_layout:add(memicon)
  right_layout:add(memwidget)
  right_layout:add(cpuicon)
  right_layout:add(cpuwidget)
  right_layout:add(fsicon)
  right_layout:add(fswidget)
  --right_layout:add(weathericon)
  --right_layout:add(yawn.widget)
  right_layout:add(tempicon)
  right_layout:add(tempwidget)
  --right_layout:add(baticon)
  --right_layout:add(batwidget)
  right_layout:add(clockicon)
  right_layout:add(mytextclock)
  if s == 1 then right_layout:add(wibox.widget.systray()) end

  -- Now bring it all together (with the tasklist in the middle)
  local layout = wibox.layout.align.horizontal()
  layout:set_left(left_layout)
  --layout:set_middle(mytasklist[s])
  layout:set_right(right_layout)

  mywibox[s]:set_widget(layout)

  -- Create the bottom wibox
  --mybottomwibox[s] = awful.wibox({ position = "bottom", screen = s, border_width = 0, height = 20 })
  --mybottomwibox[s].visible = false

  -- Widgets that are aligned to the bottom left
  bottom_left_layout = wibox.layout.fixed.horizontal()

  -- Widgets that are aligned to the bottom right
  bottom_right_layout = wibox.layout.fixed.horizontal()
  bottom_right_layout:add(mylayoutbox[s])

  -- Now bring it all together (with the tasklist in the middle)
  bottom_layout = wibox.layout.align.horizontal()
  bottom_layout:set_left(bottom_left_layout)
  bottom_layout:set_middle(mytasklist[s])
  bottom_layout:set_right(bottom_right_layout)
  --mybottomwibox[s]:set_widget(bottom_layout)
end
-- }}}

-- {{{ Mouse Bindings
root.buttons(awful.util.table.join(
  awful.button({ }, 3, function () mymainmenu:toggle() end),
  awful.button({ }, 4, awful.tag.viewnext),
  awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings
globalkeys = awful.util.table.join(
    awful.key({ modkey,           }, "Left",   awful.tag.viewprev       ),
    awful.key({ modkey,           }, "Right",  awful.tag.viewnext       ),
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore),

    awful.key({ modkey,           }, "j",
        function ()
            awful.client.focus.byidx( 1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "k",
        function ()
            awful.client.focus.byidx(-1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "w", function () mymainmenu:show({keygrabber=true}) end),

    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end),
    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end),
    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto),
    awful.key({ modkey,           }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end),

    -- Standard program
    awful.key({ modkey,           }, "Return", function () awful.util.spawn(terminal) end),
    awful.key({ modkey, "Control" }, "r", awesome.restart),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit),

    awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)    end),
    awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)    end),
    awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1)      end),
    awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1)      end),
    awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1)         end),
    awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1)         end),
    awful.key({ modkey,           }, "space", function () awful.layout.inc(layouts,  1) end),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(layouts, -1) end),

    awful.key({ modkey, "Control" }, "n", awful.client.restore),

    -- Prompt
    awful.key({ modkey },            "r",     function () mypromptbox[mouse.screen]:run() end),

    awful.key({ modkey }, "x",
              function ()
                  awful.prompt.run({ prompt = "Run Lua code: " },
                  mypromptbox[mouse.screen].widget,
                  awful.util.eval, nil,
                  awful.util.getdir("cache") .. "/history_eval")
              end)
)

clientkeys = awful.util.table.join(
    awful.key({ modkey,           }, "f",      function (c) c.fullscreen = not c.fullscreen  end),
    awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end),
    awful.key({ modkey,           }, "o",      awful.client.movetoscreen                        ),
    awful.key({ modkey, "Shift"   }, "r",      function (c) c:redraw()                       end),
    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end),
    awful.key({ modkey,           }, "n",
        function (c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end),
    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c.maximized_vertical   = not c.maximized_vertical
        end)
)

-- Compute the maximum number of digit we need, limited to 9
keynumber = 0
for s = 1, screen.count() do
   keynumber = math.min(9, math.max(#tags[s], keynumber));
end

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, keynumber do
    globalkeys = awful.util.table.join(globalkeys,
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = mouse.screen
                        if tags[screen][i] then
                            awful.tag.viewonly(tags[screen][i])
                        end
                  end),
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = mouse.screen
                      if tags[screen][i] then
                          awful.tag.viewtoggle(tags[screen][i])
                      end
                  end),
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus and tags[client.focus.screen][i] then
                          awful.client.movetotag(tags[client.focus.screen][i])
                      end
                  end),
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus and tags[client.focus.screen][i] then
                          awful.client.toggletag(tags[client.focus.screen][i])
                      end
                  end))
end

clientbuttons = awful.util.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize))

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
awful.rules.rules = {
  -- All clients will match this rule.
  { rule = { },
    properties = { border_width     = beautiful.border_width,
                   border_color     = beautiful.border_normal,
                   focus            = awful.client.focus.filter,
                   keys             = clientkeys,
                   buttons          = clientbuttons,
                   size_hints_honor = false } }
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c, startup)
    -- Enable sloppy focus
    c:connect_signal("mouse::enter", function(c)
        if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
            and awful.client.focus.filter(c) then
            client.focus = c
        end
    end)

    if not startup and not c.size_hints.user_position
       and not c.size_hints.program_position then
        awful.placement.no_overlap(c)
        awful.placement.no_offscreen(c)
    end
end)

-- No border for maximized clients
client.connect_signal("focus",
    function(c)
      if c.maximized_horizontal == true and c.maximized_vertical == true then
          c.border_width = 0
          c.border_color = beautiful.border_normal
      else
          c.border_width = beautiful.border_width
          c.border_color = beautiful.border_focus
      end
    end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}

-- {{{ Arrange signal handler
for s = 1, screen.count() do screen[s]:connect_signal("arrange", function ()
        local clients = awful.client.visible(s)
        local layout  = awful.layout.getname(awful.layout.get(s))

        if #clients > 0 then -- Fine grained borders and floaters control
          for _, c in pairs(clients) do -- Floaters always have borders
            -- No borders with only one humanly visible client
            if layout == "max" then
              c.border_width = 0
            elseif awful.client.floating.get(c) or layout == "floating" then
              c.border_width = beautiful.border_width
            elseif #clients == 1 then 
              clients[1].border_width = 0
              if layout ~= "max" then
                awful.client.moveresize(0, 0, 2, 0, clients[1])
              end
            else
              c.border_width = beautiful.border_width
            end
          end
        end
      end)
end
-- }}}
