i3menu is a bashscript that enhances and launches a
[fork of dmenu] in cool i3 specific ways. It can
for instance make a menu overlay the current
windows title-bar or the whole window. If the current
workspace is [i3fyra], it can overlay the menu ontop
of a specific i3fyra container (A,B,C,D) or family (AC,BD).

i3menu used to be included in [i3ass] but was made
independent to ease the dependency burden on
i3ass (the [fork of dmenu]). [xdotool] is an optional
dependency for *mouse* support (`--layout mouse`).
