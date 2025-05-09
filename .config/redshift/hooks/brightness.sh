#!/bin/sh
# Set brightness via light when redshift status changes

# Set brightness values for each status.
brightness_day=100
brightness_transition=75
brightness_night=1

# Adjust this grep to filter only the backlights you want to adjust
backlights=($(light -L | grep intel_backlight))

set_brightness() {
    for backlight in "${backlights[@]}"
    do
        light -s "$backlight" -S $1 &
    done
}

if [ "$1" = period-changed ]
then
    case $3 in
        night)
            set_brightness $brightness_night
            ;;
        transition)
            set_brightness $brightness_transition
            ;;
        daytime)
            set_brightness $brightness_day
            ;;
    esac
fi
