#!/bin/sh

# ==============================================================================
# CREATED BY:  Tyler Heck
# CREATED ON:  2019-11-10
#
# EDITED BY:   Tyler Heck
# EDITED ON:   2019-11-10
#
# CHANGELOG:   2019-11-10 (1.0.0)   Initial version.
#
# DESCRIPTION: Create a single image with a user-specified array of screenshots.
# ==============================================================================

USAGE="USAGE: $0 -l [width:height] -o [output] -s [screenshot1] -s [screenshot2] -t [text1] -t [text2]"

if [ $# -eq 0 ]
then
    echo "ERROR: Invalid number of input arguments."
    echo "$USAGE"
    exit 1
else
    while getopts ":l:o:s:t:" opt
    do
        case $opt in
            l)  layout="$OPTARG"
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
    label="-background #eee -fill #333 -gravity center -pointsize 64 -size $size label:"

    command="magick convert "

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
    command+="-size $size xc:#eee"

    # CREATE COMMAND FOR LABELS WITH DIMENSIONS

    ((text_offset=spacing))

    for (( i=0; i<${#text[@]}; i++ ))
    do
        command+=" -page +$text_offset+$x $label${text[$i]}"
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
            command+=" -page +$x_position+$y_position ${screenshot[$index]}"
            ((index++))
        done
    done

    command+=" -flatten $output"
    eval "$command"

    # APPEND COMMAND TO FILE FOR DEBUGGING

    # echo "$command" >> screenshot.sh
fi

# EXAMPLE
# magick convert -size 2280x4060 xc:#eee -page +40+40 -background #eee -fill #333 -gravity center -pointsize 64 -size 1080x70 label:Screenshot1 -page +1160+40 -background #eee -fill #333 -gravity center -pointsize 64 -size 1080x70 label:Screenshot2 -page +40+140 screenshot1.png -page +1160+140 screenshot2.png -flatten output.png
