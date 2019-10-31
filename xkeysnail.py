# -*- coding: utf-8 -*-

import re
from xkeysnail.transform import *

# [Global modemap] Change modifier keys as in xmodmap
define_modmap({
    Key.CAPSLOCK: Key.LEFT_CTRL
})

# # [Conditional modmap] Change modifier keys in certain applications
# define_conditional_modmap(re.compile(r'Emacs'), {
#     Key.RIGHT_CTRL: Key.ESC,
# })

# # [Multipurpose modmap] Give a key two meanings. A normal key when pressed and
# # released, and a modifier key when held down with another key. See Xcape,
# # Carabiner and caps2esc for ideas and concept.
# define_multipurpose_modmap(
#     # Enter is enter when pressed and released. Control when held down.
#     {Key.ENTER: [Key.ENTER, Key.RIGHT_CTRL]}

#     # Capslock is escape when pressed and released. Control when held down.
#     # {Key.CAPSLOCK: [Key.ESC, Key.LEFT_CTRL]
#     # To use this example, you can't remap capslock with define_modmap.
# )


# Keybindings for Firefox/Chrome
define_keymap(re.compile("Firefox|Google-chrome"), {
    # M-f
    K("M-y"): K("C-TAB"),
    # M-b
    K("M-n"): K("C-Shift-TAB"),
}, "Firefox and Chrome")

# Emacs-like keybindings in non-Emacs applications
# use `xprop WM_CLASS` to check wm_class
define_keymap(lambda wm_class: wm_class not in ("Emacs", "Remacs", "URxvt", "Gnome-terminal", "Alacritty", "Inkscape", "Blender", "Code"), {
    # Cursor
    # C-b
    K("C-n"): with_mark(K("left")),
    # C-f
    K("C-y"): with_mark(K("right")),
    # C-p
    K("C-r"): with_mark(K("up")),
    # C-n
    K("C-l"): with_mark(K("down")),
    # C-h
    K("C-j"): with_mark(K("backspace")),
    # Forward/Backward word
    # M-b
    K("M-n"): with_mark(K("C-left")),
    # C-f
    K("M-y"): with_mark(K("C-right")),
    # Beginning/End of line
    # C-a
    K("C-a"): with_mark(K("home")),
    # C-e
    K("C-d"): with_mark(K("end")),
    # Page up/down
    # M-v
    K("M-dot"): with_mark(K("page_up")),
    # C-v
    K("C-dot"): with_mark(K("page_down")),
    # Beginning/End of file
    # M-<
    K("M-Shift-w"): with_mark(K("C-home")),
    # M->
    K("M-Shift-e"): with_mark(K("C-end")),
    # Newline
    # C-m
    K("C-m"): K("enter"),
    # C-j
    K("C-c"): K("enter"),
    # C-o
    K("C-s"): [K("enter"), K("left")],
    # Copy
    # C-w
    K("C-comma"): [K("C-b"), set_mark(False)],
    # M-w
    K("M-comma"): [K("C-i"), set_mark(False)],
    # C-y
    K("C-t"): [K("C-dot"), set_mark(False)],
    # Delete
    # C-d
    K("C-h"): [K("delete"), set_mark(False)],
    # C-d
    K("M-h"): [K("C-delete"), set_mark(False)],
    # Kill line
    # C-k
    K("C-v"): [K("Shift-end"), K("C-b"), set_mark(False)],
    # Undo
#    K("C-atmark"): [K("C-z"), set_mark(False)],
    # C-/
    K("C-left_brace"): K("C-slash"),
    # Mark
    # C-SPC
    K("C-space"): set_mark(True),
    # Search
    # C-s
    K("C-semicolon"): K("F3"),
    # C-r
    K("C-o"): K("Shift-F3"),
    # M-%
    K("M-Shift-key_5"): K("C-j"),
    # Cancel
    # C-g
    K("C-u"): [K("esc"), set_mark(False)],
    # C-x YYY
    K("C-b"): {
        # C-x h (select all)
        K("j"): [K("C-home"), K("C-a"), set_mark(True)],
        # C-x C-f (open)
        K("C-y"): K("C-s"),
        # C-x C-s (save)
        K("C-semicolon"): K("C-semicolon"),
        # C-x k (kill tab)
        K("v"): K("C-f4"),
        # C-x C-c (exit)
        K("C-i"): K("C-x"),
        # cancel
        K("C-u"): pass_through_key,
        # C-x u (undo)
        K("f"): [K("C-slash"), set_mark(False)],
    }
}, "Emacs-like keys")
