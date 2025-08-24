#!/bin/sh

# ==============================================================================
# CREATED BY:  Tyler Heck
# CREATED ON:  2019-11-10
#
# EDITED BY:   Tyler Heck
# EDITED ON:   2025-08-23
#
# CHANGELOG:   2019-11-10 (1.0.0)   Initial version.
#              2019-11-13 (1.1.0)   Add font option.
#              2022-11-15 (1.2.0)   Add mode option.
#              2024-04-13 (1.2.1)   Add text quotes.
#              2025-08-23 (1.2.2)   Add parentheses.
#
# DESCRIPTION: Create a single image with a user-specified array of screenshots.
# ==============================================================================

COLOR_3="#333"
COLOR_E="#eee"
FONT="Roboto.ttf"
USAGE="USAGE: $0 -f [font(optional)] -l [width:height] -m [mode(optional)]  -o [output] -s [screenshot1] -s [screenshot2] -t [text1] -t [text2]"

if [ $# -eq 0 ]
then
    echo "ERROR: Invalid number of input arguments."
    echo "$USAGE"
    exit 1
else
    while getopts ":f:l:m:o:s:t:" opt
    do
        case $opt in
            f)  font="$OPTARG"
                ;;
            l)  layout="$OPTARG"
                ;;
            m)  mode="$OPTARG"
                ;;
            o)  output="$OPTARG"
                ;;
            s)  screenshot+=("$OPTARG")
                ;;
            t)  text+=("$OPTARG")
                ;;
            \?) echo "ERROR: Invalid option -$OPTARG." >&2
                echo "$USAGE"
                exit 1
                ;;
            :)  echo "ERROR: -$OPTARG requires an argument." >&2
                echo "$USAGE"
                exit 1
                ;;
        esac
    done

    # SET COLORS FROM MODE ARGUMENT

    if [ -z "$mode" ]
    then
        background=$COLOR_E
        foreground=$COLOR_3
    else
        case $mode in
            d|dark|D|Dark)
                background=$COLOR_3
                foreground=$COLOR_E
                ;;
            l|light|L|Light)
                background=$COLOR_E
                foreground=$COLOR_3
                ;;
            \?) echo "ERROR: Mode must be Dark(D) or Light(L)."
                echo "$USAGE"
                exit 1
        esac
    fi

    # GET DIMENSIONS FROM LAYOUT ARGUMENT

    IFS=':'
    read -ra dimensions <<< "$layout"

    if [ ${#dimensions[@]} -eq 2 ]
    then
        width=${dimensions[0]}
        height=${dimensions[1]}
        IFS=' '
    else
        echo "ERROR: Invalid number of layout dimensions."
        echo "$USAGE"
        exit 1
    fi

    # VERIFY SCREENSHOTS FIT LAYOUT

    if [ $(( width * height )) -ne ${#screenshot[@]} ]
    then
        echo "ERROR: Invalid number of screenshots for layout."
        echo "layout size: "$(( width * height ))
        echo "screenshots: "${#screenshot[@]}
        exit 1
    fi

    # VERIFY TEXT LABELS FIT LAYOUT

    if [ $(( width )) -ne ${#text[@]} ]
    then
        echo "ERROR: Invalid number of text labels for layout."
        echo "layout size: "$(( width ))
        echo "text labels: "${#text[@]}
        exit 1
    fi

    # VERIFY OUTPUT ARGUMENT EXISTS

    if [ -z "$output" ]
    then
        echo "ERROR: Must specify output file."
        echo "$USAGE"
        exit 1
    fi

    # VERIFY FONT TYPEFACE EXISTS

    if [ -z "$font" ]
    then
        font=$FONT
    fi

    if [ -z "$(magick identify -list font | grep "$font" | tr -d \'\"\')" ] && [ ! -f "$font" ]
    then
        if [ "$font" = $FONT ]
        then
            echo "ERROR: $font font doesn't exist.  Choose a font with -f or add $font."
        else
            echo "ERROR: $font font doesn't exist.  Check fonts with \"magick identify -list font\" command."
        fi

        echo "$USAGE"
        exit 1
    fi

    # CREATE COMMAND AND CONSTANTS

    ((spacing=40))
    ((x=spacing))
    ((x_screenshot=$(magick identify -format \"%w\" "${screenshot[0]}" | tr -d \'\"\')))
    ((x_offset=spacing+x_screenshot))
    ((x_text=x_screenshot))
    ((y=spacing+100))
    ((y_screenshot=$(magick identify -format \"%h\" "${screenshot[0]}" | tr -d \'\"\')))
    ((y_offset=spacing+y_screenshot))
    ((y_text=70))

    size="$x_text"x"$y_text"
    label="-background \"$background\" -fill \"$foreground\" -font \"$font\" -gravity center -pointsize 64 -size $size label:"

    command="magick "

    # CREATE COMMAND FOR BACKGROUND WITH DIMENSIONS

    ((background_width=x))
    ((background_height=y))

    for (( column=0; column<width; column++ ))
    do
        ((background_width+=x_offset))
    done

    for (( row=0; row<height; row++ ))
    do
        ((background_height+=y_offset))
    done

    size="$background_width"x"$background_height"
    command+="-size $size xc:\"$background\" "

    # CREATE COMMAND FOR LABELS WITH DIMENSIONS

    ((text_offset=spacing))

    for (( i=0; i<${#text[@]}; i++ ))
    do
        command+="\( -page +$text_offset+$x $label${text[$i]// /\\ } \) "
        ((text_offset+=x_offset))
    done

    # CREATE COMMAND FOR SCREENSHOTS WITH DIMENSIONS

    ((index=0))

    for (( column=0; column<width; column++ ))
    do
        for (( row=0; row<height; row++ ))
        do
            x_position=$((x+x_offset*column))
            y_position=$((y+y_offset*row))
            command+="\( -page +$x_position+$y_position ${screenshot[$index]} \) "
            ((index++))
        done
    done

    command+=" -flatten $output"
    eval "$command"

    # APPEND COMMAND TO FILE FOR DEBUGGING

    # echo "$command" >> screenshot.sh
fi

# EXAMPLES
# 2019-11-10 (ImageMagick 7.0.9-2)
# magick convert -size 2280x4060 xc:#eee -page +40+40 -background #eee -fill #333 -gravity center -pointsize 64 -size 1080x70 label:Screenshot1 -page +1160+40 -background #eee -fill #333 -gravity center -pointsize 64 -size 1080x70 label:Screenshot2 -page +40+140 screenshot1.png -page +1160+140 screenshot2.png -flatten output.png
# 2019-11-13 (ImageMagick 7.0.9-2)
# magick convert -size 2280x4060 xc:#eee -page +40+40 -background #eee -fill #333 -font Roboto.ttf -gravity center -pointsize 64 -size 1080x70 label:Screenshot1 -page +1160+40 -background #eee -fill #333 -font Roboto.ttf -gravity center -pointsize 64 -size 1080x70 label:Screenshot2 -page +40+140 screenshot1.png -page +1160+140 screenshot2.png -flatten output.png
# 2022-11-15 (ImageMagick 7.0.9-2)
# magick convert -size 2280x4060 xc:#333 -page +40+40 -background #333 -fill #eee -font Roboto.ttf -gravity center -pointsize 64 -size 1080x70 label:Screenshot1 -page +1160+40 -background #333 -fill #eee -font Roboto.ttf -gravity center -pointsize 64 -size 1080x70 label:Screenshot2 -page +40+140 screenshot1.png -page +1160+140 screenshot2.png -flatten output.png
# 2025-04-13 (ImageMagick 7.1.1-47)
# magick convert -quiet -size 2280x4060 xc:"#333" -page +40+40 -background "#333" -fill "#eee" -font Roboto.ttf -gravity center -pointsize 64 -size 1080x70 label:Screenshot\ 1 -page +1160+40 -background "#333" -fill "#eee" -font Roboto.ttf -gravity center -pointsize 64 -size 1080x70 label:Screenshot\ 2 -page +40+140 screenshot1.png -page +1160+140 screenshot2.png -flatten output.png
# 2025-08-23 (ImageMagick 7.1.1-47)
# magick -size 2280x9996 xc:"#333" \( -page +40+40 -background "#333" -fill "#eee" -font Roboto.ttf -gravity center -pointsize 64 -size 1080x70 label:Screenshot\ 1 \) \( -page +1160+40 -background "#333" -fill "#eee" -font Roboto.ttf -gravity center -pointsize 64 -size 1080x70 label:Screenshot\ 2 \) \( -page +40+140 screenshot1.png \) \( -page +1160+140 screenshot2.png \) -flatten output.png
