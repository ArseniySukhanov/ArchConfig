# Copyright (c) 2010 Aldo Cortesi
# Copyright (c) 2010, 2014 dequis
# Copyright (c) 2012 Randall Ma
# Copyright (c) 2012-2014 Tycho Andersen
# Copyright (c) 2012 Craig Barnes
# Copyright (c) 2013 horsik
# Copyright (c) 2013 Tao Sauvage
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

import os
import subprocess
from time import time
from pathlib import Path
from typing import List  # noqa: F401

from libqtile import bar, layout, widget, hook
from libqtile.config import Click, Drag, Group, Key, Match, Screen
from libqtile.lazy import lazy
from libqtile.utils import guess_terminal
from widgets import batteryNerdIcon, internet, volume


@hook.subscribe.startup
def autostart():
    home = os.path.expanduser('~')
    subprocess.Popen([home + '/.config/qtile/autostart.sh'])


@hook.subscribe.startup_once
def firststart():
    home = os.path.expanduser('~')
    subprocess.Popen([home + '/.config/qtile/firststart.sh'])


BROWSER = 'firefox'


mod = "mod4"
terminal = guess_terminal()

# Widgets


# Screenshot
def screenshot(save=True, copy=False):
    def f(qtile):
        path = Path.home() / 'Pictures/Screenshots'
        path /= f'screenshot_{str(int(time() * 100))}.png'
        shot = subprocess.run(['maim'], stdout=subprocess.PIPE)

        if save:
            with open(path, 'wb') as sc:
                sc.write(shot.stdout)

        if copy:
            subprocess.run(['xclip', '-selection',
                            'clipboard', '-t', 'image/png'], input=shot.stdout)

    return f


def volumechange(action):
    def f(qtile):
        mute = str(subprocess.run(['pamixer', '--get-mute'],
                                  stdout=subprocess.PIPE).stdout)[:-1]
        if "true" in mute:
            subprocess.run(['tvolnoti-show', '-m'])
        else:
            vol = int(
                str(subprocess.run(['pamixer', '--get-volume'],
                                   stdout=subprocess.PIPE).stdout)[2:-3])
            if vol != 0 or action != 'd':
                if (vol > 49 and action == 'i') \
                        or (vol > 39 and action == 'd'):
                    subprocess.run(['pamixer', f'-{action}', '10'])
                    vol = str(subprocess.run(['pamixer', '--get-volume'],
                                                stdout=subprocess.PIPE).stdout)[2:-3]
                else:
                    subprocess.run(['pamixer', f'-{action}', '1'])
                    vol = str(subprocess.run(['pamixer', '--get-volume'],
                                                stdout=subprocess.PIPE).stdout)[2:-3]

            subprocess.run(['tvolnoti-show', f'{vol}'])
    return f


def volumetoogle():
    def f(qtile):
        subprocess.run(['pamixer', '-t'])
        mute = str(subprocess.run(['pamixer', '--get-mute'],
                                  stdout=subprocess.PIPE).stdout)[:-1]
        if "true" in mute:
            subprocess.run(['tvolnoti-show', '-m'])
        else:
            volume = int(
                str(subprocess.run(['pamixer', '--get-volume'],
                                   stdout=subprocess.PIPE).stdout)[2:-3])
            subprocess.run(['tvolnoti-show', f'{volume}'])
    return f


def open_pavu():
    from libqtile import qtile

    qtile.cmd_spawn('pavucontrol')


keys = [
    # Switch between windows
    Key([mod], "h", lazy.layout.left(), desc="Move focus to left"),
    Key([mod], "l", lazy.layout.right(), desc="Move focus to right"),
    Key([mod], "j", lazy.layout.down(), desc="Move focus down"),
    Key([mod], "k", lazy.layout.up(), desc="Move focus up"),
    Key([mod], "space", lazy.layout.next(),
        desc="Move window focus to other window"),

    # Move windows between left/right columns or move up/down in current stack.
    # Moving out of range in Columns layout will create new column.
    Key([mod, "shift"], "h", lazy.layout.shuffle_left(),
        desc="Move window to the left"),
    Key([mod, "shift"], "l", lazy.layout.shuffle_right(),
        desc="Move window to the right"),
    Key([mod, "shift"], "j", lazy.layout.shuffle_down(),
        desc="Move window down"),
    Key([mod, "shift"], "k", lazy.layout.shuffle_up(), desc="Move window up"),

    # Grow windows. If current window is on the edge of screen and direction
    # will be to screen edge - window would shrink.
    Key([mod, "control"], "h",
        lazy.layout.grow_left(),
        lazy.layout.shrink(),
        lazy.layout.decrease_ratio(),
        lazy.layout.add(),
        desc="Grow window to the left"),
    Key([mod, "control"], "l",
        lazy.layout.grow_right(),
        lazy.layout.grow(),
        lazy.layout.increase_ratio(),
        lazy.layout.delete(),
        desc="Grow window to the right"),
    Key([mod, "control"], "j",
        lazy.layout.grow_down(),
        lazy.layout.shrink(),
        lazy.layout.increase_nmaster(),
        desc="Grow window down"),
    Key([mod, "control"], "k",
        lazy.layout.grow_up(),
        lazy.layout.grow(),
        lazy.layout.decrease_nmaster(),
        desc="Grow window up"),
    Key([mod], "n", lazy.layout.normalize(), desc="Reset all window sizes"),

    # Toggle between split and unsplit sides of stack.
    # Split = all windows displayed
    # Unsplit = 1 window displayed, like Max layout, but still with
    # multiple stack panes
    Key([mod, "shift"], "Return", lazy.layout.toggle_split(),
        desc="Toggle between split and unsplit sides of stack"),
    Key([mod], "Return", lazy.spawn(terminal), desc="Launch terminal"),
    Key([mod], "f", lazy.spawn(BROWSER), desc="Launch browser"),
    # Toggle between different layouts as defined below
    Key([mod], "Tab", lazy.next_layout(), desc="Toggle between layouts"),
    Key([mod], "w", lazy.window.kill(), desc="Kill focused window"),

    Key([mod, "control"], "r", lazy.restart(), desc="Restart Qtile"),
    Key([mod, "control"], "q", lazy.shutdown(), desc="Shutdown Qtile"),
    Key([mod], "r", lazy.spawn("rofi -show drun"),
        desc="Spawn rofi"),

    # Volume
    Key([], 'XF86AudioRaiseVolume', lazy.function(volumechange('i'))),
    Key([], 'XF86AudioLowerVolume', lazy.function(volumechange('d'))),
    Key([], 'XF86AudioMute', lazy.function(volumetoogle())),

    # Screenshot
    Key([], 'Print', lazy.function(screenshot())),

]

groups = [Group("1", label=""), Group("2", label=""), Group("3", label=""),
          Group("4", label="")]

for i in groups:
    keys.extend([
        # mod1 + letter of group = switch to group
        Key([mod], i.name, lazy.group[i.name].toscreen(),
            desc="Switch to group {}".format(i.name)),

        # mod1 + shift + letter of group = switch to
        # & move focused window to group
        Key([mod, "shift"], i.name,
            lazy.window.togroup(i.name, switch_group=True),
            desc="Switch to & move focused window to group {}".format(i.name)),
        # Or, use below if you prefer not to switch to that group.
        # # mod1 + shift + letter of group = move focused window to group
        # Key([mod, "shift"], i.name, lazy.window.togroup(i.name),
        #     desc="move focused window to group {}".format(i.name)),
    ])

layouts = [
    layout.MonadTall(margin=5, border_width=0),
    layout.Columns(margin=5, border_width=0),
    layout.Max(margin=5, border_width=0),
    # Try more layouts by unleashing below layouts.
    # layout.Stack(num_stacks=2),
    # layout.Bsp(),
    # layout.Matrix(),
    # layout.MonadWide(),
    # layout.RatioTile(),
    layout.Tile(margin=5, border_width=0),
    # layout.TreeTab(),
    # layout.VerticalTile(),
    # layout.Zoomy(),
]

widget_defaults = dict(
    font='sans',
    fontsize=12,
    padding=3,
    foreground="#abb2bf"
)
extension_defaults = widget_defaults.copy()

screens = [
    Screen(
        top=bar.Bar(
            [
                widget.CurrentLayoutIcon(background="#282c34", scale=0.7),
                widget.GroupBox(margin=3, spacing=0, fontsize=16),
                widget.Chord(
                    chords_colors={
                        'launch': ("#ff0000", "#ffffff"),
                    },
                    name_transform=lambda name: name.upper(),
                ),
                widget.Spacer(),
                widget.Clock(format='%I:%M %p'
                             ),
                widget.Spacer(),
                widget.WidgetBox(widgets=[
                                          widget.Systray(),
                                         ],
                                 fontsize=20,
                                 text_closed='ﰰ ',
                                 text_open='ﰴ '
                                 ),
                volume.Volume(margin=4,
                              mouse_callbacks={'Button1': open_pavu}
                              ),
                internet.Internet(),
                batteryNerdIcon.batteryNerdIcon(spacing=5,
                                                fontsize=14,
                                                font="mono"),
                widget.QuickExit(default_text="襤",
                                 font="FiraCode Nerd Font",
                                 countdown_format='{}',
                                 fontsize=26, padding=6),
            ],
            24,
            margin=[5, 5, 0, 5],
            background="#1f2329"
        ),
        wallpaper='~/.config/qtile/wallpaper/wallpaper_1.jpg'
    ),
]

# Drag floating layouts.
mouse = [
    Drag([mod], "Button1", lazy.window.set_position_floating(),
         start=lazy.window.get_position()),
    Drag([mod], "Button3", lazy.window.set_size_floating(),
         start=lazy.window.get_size()),
    Click([mod], "Button2", lazy.window.bring_to_front())
]

dgroups_key_binder = None
dgroups_app_rules = []  # type: List
main = None  # WARNING: this is deprecated and will be removed soon
follow_mouse_focus = True
bring_front_click = False
cursor_warp = False
floating_layout = layout.Floating(float_rules=[
    # Run the utility of `xprop` to see the wm class and name of an X client.
    *layout.Floating.default_float_rules,
    Match(wm_class='confirmreset'),  # gitk
    Match(wm_class='makebranch'),  # gitk
    Match(wm_class='maketag'),  # gitk
    Match(wm_class='ssh-askpass'),  # ssh-askpass
    Match(wm_class='pavucontrol'),  # sound control panel
    Match(title='branchdialog'),  # gitk
    Match(title='pinentry'),  # GPG key password entry
])
auto_fullscreen = True
focus_on_window_activation = "smart"

# XXX: Gasp! We're lying here. In fact, nobody really uses or cares about this
# string besides java UI toolkits; you can see several discussions on the
# mailing lists, GitHub issues, and other WM documentation that suggest setting
# this string if your java app doesn't work correctly. We may as well just lie
# and say that we're a working one by default.
#
# We choose LG3D to maximize irony: it is a 3D non-reparenting WM written in
# java that happens to be on java's whitelist.
wmname = "LG3D"
