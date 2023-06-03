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

