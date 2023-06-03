#!/bin/bash

set_theme()
{
  local theme_file="$I3_MENU_CONF_DIR/${_o[theme]:-default}"
  local qc QC re key val short_option

  # default theme, it really whips the i3ass
  [[ -f $theme_file ]] || {
    mkdir -p "$I3_MENU_CONF_DIR"
    > "$theme_file" printf '%s\n'     \
      "foreground = #83e736"          \
      "background = #000000"          \
      "foreground_selected = #FFFFFF" \
      "background_selected = #0000c6"
  }

  qc="['\"]" QC="[^'\"]"
  re="^(((foreground|background)(_selected)?)|font)\s*=\s*${qc}?(${QC}+)${qc}?\$"

  while read -r ; do
    [[ $REPLY =~ $re ]] || continue
    key="${BASH_REMATCH[1]}"
    val="${BASH_REMATCH[-1]}"
    case "$key" in
      foreground_selected ) short_option=-sf ;;
      foreground          ) short_option=-nf ;;
      background_selected ) short_option=-sb ;;
      background          ) short_option=-nb ;;
      font                ) short_option=-fn ;;
    esac

    menu_options+=("$short_option" "$val")
  done < "$theme_file"
}
