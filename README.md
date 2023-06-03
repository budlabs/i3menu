# i3menu

i3menu is a bashscript that uses [i3ass] to launch a
[fork of dmenu] in cool i3 specific ways. It can
for instance make a menu overlay the current
windows title-bar or the whole window. If the current
workspace is [i3fyra], it can overlay the menu ontop
of a specific i3fyra container (A,B,C,D) or family (AC,BD).

i3menu used to be included in [i3ass] but was made
independent to ease the dependency burden on
i3ass (the [fork of dmenu]). [xdotool] is an optional
dependency for *mouse* support (`--layout mouse`).

## installation

### AUR

Arch Linux users can install the [i3menu AUR package],
which has a hard dependency on [dmenu-bud AUR package], 
meaning it will automatically install the needed [dmenu fork]
and resolve conflicts of other dmenu installations.

### manual installation

Build dependencies: GNU/make , gawk
Runtime dependencies: 
  - [dmenu-bud]
  - [i3ass] ([i3wm])
  - gawk
  - bash
  - xdotool (*optional*)

``` text
$ git clone https://github.com/budlabs/i3menu.git
$ cd i3menu
$ make
# make install
```

> it is possible to change the shbang of the bashscript
> with SHBANG make macro: `make SHBANG='#!/usr/bin/env bash'`


## options

```
-b, --bottom                     | shorthand for dmenu -b 
--dryrun                         | do not execute any i3-msg commands  
-f, --filter         FILTER      | sets initial inputbox text
--height             INT         | overrides the calculated height of the menu.  
-h, --help                       | print help and exit  
-a, --layout         LAYOUT      | mouse, window, titlebar, tab, A, B, C, D  
-d, --list-directory DIRECTORY   | content of DIRECTORY will be list  
-o, --orientation    ORIENTATION | vertical|horizontal  
-p, --prompt         PROMPT      | Sets the prompt of the menu to PROMPT 
--sensitive                      | case sensitivity on  
-t, --theme          THEME       | change appearance of the menu  
--top                TOP         | put TOP at the top of the list  
--verbose                        | print additional information to STDERR 
-v, --version                    | print version info and exit  
-w, --width          INT         | changes the width of the menu  
--xoffset            INT         | offsets the menu on the x axis  
-x, --xpos           INT         | absolute X position of the menu  
--yoffset            INT         | offsets the menu on the y axis   
-y, --ypos           INT         | absolute Y position of the menu  
```  

### -a, --layout         LAYOUT      

This is where **i3menu** differs the most from normal **rofi** behavior and is the only option that truly depends on `i3`, `i3list` (and **i3fyra** if the value is A|B|C|D). If this option is not set, the menu will default to a single line (*dmenu like*) menu at the top of the screen. If however a value to this option is one of the following:  

- mouse       
  At the mouse position (requires `xdotool`)

- window      
  The currently active window.

- titlebar    
  The titlebar of the currently active window.

- tab         
  The tab (or titlebar if it isn't tabbed) of the currently active window.

- A,B,C or D  
  The **i3fyra** container of the same name if it is visible. If target container isn't visible the menu will be displayed at the default location.


titlebar and tab LAYOUT will be displayed as a single line (*dmenu like*) menu, and the other LAYOUTS will be of vertical (*combobox*) layout with the prompt and entrybox above the list.  

The position of the menu can be further manipulated by using `--xpos`,`--ypos`,`--width`,`--height`,`--orientation`,`--include`.  

`$ echo "list" | i3menu --prompt "select: " --layout window --xpos -50 --ypos 30`  
The command above would create a menu with the same size and position as the current window, but place it 50px to the left of the window, and 30px below the *lower* of the window.

### -d, --list-directory DIRECTORY   

This option will list filenames in DIRECORY. The
selected item will be returned with the full path.

### -o, --orientation    ORIENTATION 

This forces the layout of the menu to be either vertical or horizontal. If `--layout` is set to **window**, the layout will always be `vertical`.


### -t, --theme          THEME       

default theme (~/.config/i3menu/default) will be
created and used if not specified.

    foreground = #83e736
    background = #000000
    foreground_selected = #FFFFFF
    background_selected = #0000c6
    font = monospace

### --top                TOP         

If TOP is set, the input stream (LIST) will get matched against TOP.
Lines in LIST with an exact MATCH of those in TOP will get moved to the TOP of LIST before the menu is created.

`$ printf '%s\n' one two three four | i3menu --top "$(printf '%s\n' two four)"`  

will result in a list looking like this:  
`two four one three`

### -w, --width          INT         

If the argument to `--width` ends with a `%`
character the width will be that many percentages
of the screenwidth. Without `%` absolute width in
pixels will be set.

### --xoffset            INT         

If `--layout` is set to `window` and `--xpos`
is set to `-50`, the menu will be placed 50 pixels
to the left of the active window but have the same
dimensions as the window.

