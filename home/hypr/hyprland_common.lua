hl.layer_rule({
    match = { namespace = "match:namespace notification" },
    no_anim =true,
})

-- Some default env vars.
hl.env("XCURSOR_SIZE", 24)
hl.env("WLR_NO_HARDWARE_CURSORS", 1)

-- For all categories, see https://wiki.hyprland.org/Configuring/Variables/

hl.config({
    input = {
        kb_layout = "us",
        follow_mouse = 1,
        touchpad = {
            natural_scroll = true,
        },
        sensitivity = 0,
        -- -1.0 - 1.0, 0 means no modification.
        numlock_by_default = true,
    },
})

hl.config({
    general = {
        -- See https://wiki.hyprland.org/Configuring/Variables/ for more
        gaps_in = 5,
        gaps_out = 20,
        border_size = 2,
        layout = "dwindle",
        -- Please see https://wiki.hyprland.org/Configuring/Tearing/ before you turn this on
        allow_tearing = false,
        col = {
            active_border = { colors = { "rgba(33ccffee)", "rgba(00ff99ee)" }, angle = 45 },
            inactive_border = "rgba(595959aa)",
        },
    },
})

hl.config({
    decoration = {
        -- See https://wiki.hyprland.org/Configuring/Variables/ for more
        rounding = 10,
        blur = {
            enabled = true,
            new_optimizations = false,
            -- breaks transparency with hyprwinwrap live wallpaper
            size = 3,
            passes = 1,
        },
        shadow = {
            enabled = true,
            range = 4,
            render_power = 3,
            color = "rgba(1a1a1aee)",
        },
    },
})

-- Animations

hl.config({ animations = { enabled = true } })

hl.curve("wind", { type = "bezier", points = { {0.33, 0.89}, {0.36, 1} } })
hl.curve("liner", { type = "bezier", points = { {1, 1}, {1, 1} } })
hl.curve("md3_decel", { type = "bezier", points = { {0.05, 0.80}, {0.10, 0.97} } })
hl.curve("menu_decel", { type = "bezier", points = { {0.05, 0.82}, {0, 1} } })
hl.curve("menu_accel", { type = "bezier", points = { {0.20, 0}, {0.82, 0.10} } })
hl.curve("easeInOutCirc", { type = "bezier", points = { {0.75, 0}, {0.15, 1} } })
hl.curve("OutBack", { type = "bezier", points = { {0.28, 1.40}, {0.58, 1} } })
hl.curve("easeInOutCirc", { type = "bezier", points = { {0.78, 0}, {0.15, 1} } })

hl.animation({ leaf = "border", enabled = true, speed = 1.6, bezier = "liner" })
hl.animation({ leaf = "borderangle", enabled = true, speed = 82, bezier = "liner", style = "once" })
hl.animation({ leaf = "windowsIn", enabled = true, speed = 3.2, bezier = "wind", style = "popin 80%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 2.8, bezier = "wind", style = "popin 80%" })
hl.animation({ leaf = "windowsMove", enabled = true, speed = 3.0, bezier = "wind", style = "popin 80%" })
hl.animation({ leaf = "fade", enabled = true, speed = 1.8, bezier = "md3_decel" })
hl.animation({ leaf = "layersIn", enabled = true, speed = 1.8, bezier = "menu_decel", style = "popin 80%" })
hl.animation({ leaf = "layersOut", enabled = true, speed = 1.5, bezier = "menu_accel" })
hl.animation({ leaf = "fadeLayersIn", enabled = true, speed = 1.6, bezier = "menu_decel" })
hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 1.8, bezier = "menu_accel" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 4.0, bezier = "menu_decel", style = "fade" })
hl.animation({ leaf = "specialWorkspace", enabled = true, speed = 2.3, bezier = "md3_decel", style = "slidefadevert 15%" })

hl.config({
    dwindle = {
        -- master switch for pseudotiling. Enabling is bound to mainMod + P in the keybinds section below
        preserve_split = true,
        -- you probably want this
        smart_split = true,
        -- Allow splitting horizontally based on cursor position
    },
})

hl.workspace_rule({
    workspace = "w[t1]",
    gaps_out = 0,
    gaps_in = 0,
})

hl.workspace_rule({
    workspace = "w[tg1]",
    gaps_out = 0,
    gaps_in = 0,
})

hl.window_rule({
    name  = "border_size_0",
    match = { workspace = "w[t1]" },
    border_size = 0,
})

hl.window_rule({
    name  = "rounding_0",
    match = { workspace = "w[t1]" },
    rounding = 0,
})

hl.config({
    misc = {
        -- See https://wiki.hyprland.org/Configuring/Variables/ for more
        force_default_wallpaper = -1,
        -- Set to 0 to disable the anime mascot wallpapers
        focus_on_activate = true,
        vrr = 2,
        -- enabled when fullscreen
    },
})

-- Special cases
hl.window_rule({
    name  = "idle_inhibit_fullscr",
    match = { class = "(Slay the Spire)( 2)?" },
})
hl.window_rule({
    name  = "idle_inhibit_fullscr",
    match = { class = "(Hollow Knight Silksong)" },
})

-- Chrome profile picker should float
hl.window_rule({
    name  = "tile_on",
    match = { class = "^google-chrome$" },
})
hl.window_rule({
    name  = "float_on",
    match = { title = "^Google Chrome$" },
})

-- Zoom should keep monitors on
hl.window_rule({
    name  = "idle_inhibit_always",
    match = { class = "^zoom$" },
})

-- See https://wiki.hyprland.org/Configuring/Keywords/ for more

local mainMod = "SUPER"

hl.bind(mainMod .. " + Q", hl.dsp.exec_cmd("kitty"))
hl.bind(mainMod .. " + C", hl.dsp.window.close())
hl.bind(mainMod .. " + CTRL + ALT + SHIFT + M", hl.dsp.exit())
hl.bind(mainMod .. " + CTRL + ALT + SHIFT + P", hl.dsp.exec_cmd("sudo shutdown now"))
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd("dolphin"))
hl.bind(mainMod .. " + V", hl.dsp.window.float())
hl.bind(mainMod .. " + R", hl.dsp.exec_cmd("wofi --show drun -i --allow-images -D key_expand=Ctrl-Tab"))
hl.bind(mainMod .. " + P", hl.dsp.window.pseudo())

-- dwindle

--bind = $mainMod, J, togglesplit, # dwindle
hl.bind(mainMod .. " + U", hl.dsp.window.pseudo())
hl.bind(mainMod .. " + CTRL + U", hl.dsp.window.pseudo())
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd("google-chrome-stable"))
hl.bind(mainMod .. " + CTRL + ALT + SHIFT + L", hl.dsp.exec_cmd("hyprlock"))

-- Move focus with mainMod + arrow keys
hl.bind(mainMod .. " + H", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + L", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + K", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + J", hl.dsp.focus({ direction = "down" }))

-- Move active window within workspace
hl.bind(mainMod .. " + CTRL + H", hl.dsp.window.move({ direction = "l", group_aware = true }))
hl.bind(mainMod .. " + CTRL + J", hl.dsp.window.move({ direction = "d", group_aware = true }))
hl.bind(mainMod .. " + CTRL + K", hl.dsp.window.move({ direction = "u", group_aware = true }))
hl.bind(mainMod .. " + CTRL + L", hl.dsp.window.move({ direction = "r", group_aware = true }))

-- Switch workspaces
hl.bind(mainMod .. " + SHIFT + L", hl.dsp.focus({ workspace = "+1" }))
hl.bind(mainMod .. " + SHIFT + H", hl.dsp.focus({ workspace = "-1" }))

-- Move window between workspaces
hl.bind(mainMod .. " + CTRL + SHIFT + L", hl.dsp.window.move({ workspace = "+1" }))
hl.bind(mainMod .. " + CTRL + SHIFT + H", hl.dsp.window.move({ workspace = "-1" }))

-- Switch workspaces with mainMod + [0-9]
hl.bind(mainMod .. " + 1", hl.dsp.focus({ workspace = 1 }))
hl.bind(mainMod .. " + 2", hl.dsp.focus({ workspace = 2 }))
hl.bind(mainMod .. " + 3", hl.dsp.focus({ workspace = 3 }))
hl.bind(mainMod .. " + 4", hl.dsp.focus({ workspace = 4 }))
hl.bind(mainMod .. " + 5", hl.dsp.focus({ workspace = 5 }))
hl.bind(mainMod .. " + 6", hl.dsp.focus({ workspace = 6 }))
hl.bind(mainMod .. " + 7", hl.dsp.focus({ workspace = 7 }))
hl.bind(mainMod .. " + 8", hl.dsp.focus({ workspace = 8 }))
hl.bind(mainMod .. " + 9", hl.dsp.focus({ workspace = 9 }))
hl.bind(mainMod .. " + 0", hl.dsp.focus({ workspace = 10 }))

-- Move active window to a workspace with mainMod + CTRL + [0-9]
hl.bind(mainMod .. " + CTRL + 1", hl.dsp.window.move({ workspace = 1 }))
hl.bind(mainMod .. " + CTRL + 2", hl.dsp.window.move({ workspace = 2 }))
hl.bind(mainMod .. " + CTRL + 3", hl.dsp.window.move({ workspace = 3 }))
hl.bind(mainMod .. " + CTRL + 4", hl.dsp.window.move({ workspace = 4 }))
hl.bind(mainMod .. " + CTRL + 5", hl.dsp.window.move({ workspace = 5 }))
hl.bind(mainMod .. " + CTRL + 6", hl.dsp.window.move({ workspace = 6 }))
hl.bind(mainMod .. " + CTRL + 7", hl.dsp.window.move({ workspace = 7 }))
hl.bind(mainMod .. " + CTRL + 8", hl.dsp.window.move({ workspace = 8 }))
hl.bind(mainMod .. " + CTRL + 9", hl.dsp.window.move({ workspace = 9 }))
hl.bind(mainMod .. " + CTRL + 0", hl.dsp.window.move({ workspace = 10 }))

-- Switch monitors
hl.bind(mainMod .. " + ALT + h", hl.dsp.focus({ monitor = "l" }))
hl.bind(mainMod .. " + ALT + j", hl.dsp.focus({ monitor = "u" }))
hl.bind(mainMod .. " + ALT + k", hl.dsp.focus({ monitor = "d" }))
hl.bind(mainMod .. " + ALT + l", hl.dsp.focus({ monitor = "r" }))

-- Move active workspace to other monitor
hl.bind(mainMod .. " + CTRL + ALT + h", hl.dsp.workspace.move({ monitor = "l" }))
hl.bind(mainMod .. " + CTRL + ALT + j", hl.dsp.workspace.move({ monitor = "u" }))
hl.bind(mainMod .. " + CTRL + ALT + k", hl.dsp.workspace.move({ monitor = "d" }))
hl.bind(mainMod .. " + CTRL + ALT + l", hl.dsp.workspace.move({ monitor = "r" }))

-- Example special workspace (scratchpad)
hl.bind(mainMod .. " + S", hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

-- Scroll through existing workspaces with mainMod + scroll
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e-1" }))
hl.bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "e+1" }))

-- Move/resize windows with mainMod + LMB/RMB and dragging
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Take screenshots
hl.bind("print", hl.dsp.exec_cmd("grimblast --freeze --notify copy area"))
hl.bind("CTRL + print", hl.dsp.exec_cmd("grimblast --freeze --notify save area local_var_HOME/Pictures/Screenshots/ $(date +'%F %T.png')"))
hl.bind("ALT + print", hl.dsp.exec_cmd("grimblast -c --notify copy screen"))
hl.bind("CTRL + ALT + print", hl.dsp.exec_cmd("grimblast -c --notify save screen local_var_HOME/Pictures/Screenshots/ $(date +'%F %T.png')"))

-- Volume keys

-- With Pulse
-- hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("pactl set-sink-volume @DEFAULT_SINK@ +5%"))
-- hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("pactl set-sink-volume @DEFAULT_SINK@ -5%"))

-- With PipeWire
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("pamixer -i 5"))
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("pamixer -d 5"))
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("pamixer -t"))

-- hl.plugin("touch_gestures", function()
--     sensitivity = 4.0,
--     edge_margin = 20,
--     long_press_delay = 100,
--     -- ms
-- end)

require('hyprland_host')
require('hyprland_extraMonitors')

-- Autostart
hl.on("hyprland.start", function()
    -- Turn off monitor after 5 minute timeout and lock the session after 15 minute timeout
    hl.exec_cmd("swayidle timeout 300 echo idle && hyprctl dispatch dpms off resume echo resume && hyprctl dispatch dpms on timeout 900 echo away && hyprlock-if-not-locked resume echo back")

    -- Notification daemon
    hl.exec_cmd("dunst")

    -- Wallpaper
    hl.exec_cmd("hyprpaper")

    -- Cursors
    hl.exec_cmd("hyprctl setcursor graphite-dark 24")

    -- Waybar
    hl.exec_cmd("waybar")
end)
