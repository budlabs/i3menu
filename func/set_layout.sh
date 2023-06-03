#!/bin/bash

set_layout()
{
  declare -a layouts
  declare -A i3list
  # capital W/H because 3menu -h is show help
  local x y W H orientation

  eval "$(i3list)"

  [[ ${_o[layout]} =~ [ABCD] ]] \
    && _o[layout]=$(getvirtualpos "${_o[layout]}")

  mapfile -t layouts <<< "${_o[layout]//,/$'\n'}"
  layouts+=(default)

  [[ ${_o[layout]} ]] && for layout in "${layouts[@]}"; do

    case "$layout" in
      mouse   )
        read -rd '' x y _ < <(xdotool getmouselocation --shell \
                            | sed -r 's/^.+=//g')
        ;;
      A       )
        [[ ${i3list[LVI]} =~ $layout ]] || continue
        W="${i3list[SAB]}"
        H="${i3list[SAC]}"
        orientation=vertical
        ;;
      B       )
        [[ ${i3list[LVI]} =~ $layout ]] || continue
        W="$((i3list[WFW] - i3list[SAB]))"
        H="${i3list[SBD]}"
        x="${i3list[SAB]}"
        orientation=vertical
        ;;
      C       )
        [[ ${i3list[LVI]} =~ $layout ]] || continue
        W="${i3list[SAB]}"
        H="$((i3list[WFH] - i3list[SAC]))"
        y="${i3list[SAC]}"
        orientation=vertical
        ;;
      D       )
        [[ ${i3list[LVI]} =~ $layout ]] || continue
        W="$((i3list[WFW] - i3list[SAB]))"
        H="$((i3list[WFH] - i3list[SBD]))"
        x="${i3list[SAB]}"
        y="${i3list[SBD]}"
        orientation=vertical
        ;;
      AC      )
        [[ ${i3list[LVI]} =~ [${layout}] && ${i3list[SAB]} -gt 0 ]] \
          || continue
        W="${i3list[SAB]}"
        H="${i3list[WFH]}"
        orientation=vertical
        ;;
      BD      )
        [[ ${i3list[LVI]} =~ [${layout}] && ${i3list[SAB]} -gt 0 ]] \
          || continue
        W="$((i3list[WFW] - i3list[SAB]))"
        H="${i3list[WFH]}"
        x="${i3list[SAB]}"
        orientation=vertical
        ;;
      window  )
        [[ ${i3list[TWC]} ]] || continue
        x=$((i3list[TWX]+i3list[WAX]))
        y=$((i3list[TWY]+i3list[WAY]))
        W=${i3list[TWW]}
        H=${i3list[TWH]}
        orientation=vertical
        ;;
      title*   )
        [[ ${i3list[TWC]} ]] || continue
        x=$((i3list[TWX]+i3list[WAX]))
        y=$((i3list[TWY]+i3list[WAY]))
        W=${i3list[TWW]}
        H=${i3list[TWB]}
        orientation=horizontal
        ;;
      tab     )
        [[ ${i3list[TWC]} ]] || continue
        if ((i3list[TTW]==i3list[TWW])); then
          x=$((i3list[TWX]+i3list[WAX]))
          W=${i3list[TWW]}
        else
          x=$((i3list[TTX]+i3list[TWX]))
          W=${i3list[TTW]}
        fi

        y=$((i3list[TWY]+i3list[WAY]))
        H=${i3list[TWB]}
        ;;
      *       )
        H="${i3list[TWB]}"
        orientation=horizontal
        ;;
    esac
    break
  done

  ((_o[width]))   && W=${_o[width]}
  ((_o[height]))  && H=${_o[height]}

  [[ -n ${_o[xpos]} ]] && {
    if ((_o[xpos]<0)) || ((_o[xpos]==-0))
      then x=$((i3list[WAW]-((_o[xpos]*-1)+W)))
      else x=${_o[xpos]}
    fi
  }

  [[ -n ${_o[ypos]} ]] && {
    if ((_o[ypos]<0)) || ((_o[ypos]==-0))
      then y=$((i3list[WAH]-((_o[ypos]*-1)+H)))
      else y=${_o[ypos]}
    fi
  }

  ((_o[xoffset])) && x=$((x + _o[xoffset]))
  ((_o[yoffset])) && y=$((y + _o[yoffset]))

  [[ ${_o[orientation]:-$orientation} = vertical ]] \
    && menu_options+=(-l 9999) \
    || menu_options+=(-l 0)

  for k in x y W H ; do
    # !!!! H 20 doesnt work???
    [[ $k = H && ${!k} -eq 20 ]] && k=21
    [[ ${!k} ]] && menu_options+=("-${k^^}" "${!k}")
  done
}
