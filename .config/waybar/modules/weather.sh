#!/bin/bash

location=$1

cache_dir=~/.cache/custom_waybar_weather
cache_file=${0##*/}-$location
cache_path=$cache_dir/$cache_file

if [ -n "${2+true}" ]
then
    max_cache_age=0
else
    max_cache_age=1740
fi

[ $DEBUG ] && echo "Cache path: $cache_path, lifetime: $max_cache_age"

[ ! -d $cache_dir ] && mkdir -p $cache_dir

# Save current IFS
SAVEIFS=$IFS
IFS=$'\n'

cache_age=$(($(date +%s) - $(stat -c '%Y' "$cache_path")))
if [ $cache_age -gt $max_cache_age ] || [ ! -s $cache_path ]; then
    curl -s "https://en.wttr.in/${location}?format=%l;%C;%t" | tr ";" "\n" > $cache_path
fi

weather=($(cat $cache_path))
[ $DEBUG ] && echo "Got weather ${weather[@]}"

# Restore IFS
IFS=$SAVEIFS

temperature=$(echo ${weather[2]} | sed -E 's/([[:digit:]])+\.\./\1 to /g')
[ $DEBUG ] && echo "Got temperature $temperature"

declare -A conditions

# in Emacs C-x 8 [Enter] to insert unicode

# F0590 weather-cloudy
# F0F2F weather-cloudy-alert
# F0E6E weather-cloudy-arrow-right
# F18F6 weather-cloudy-clock
# F0591 weather-fog
# F0592 weather-hail
# F0F30 weather-hazy
# F0898 weather-hurricane
# F0593 weather-lightning
# F067E weather-lightning-rainy
# F0594 weather-night
# F0F31 weather-night-partly-cloudy
# F0595 weather-partly-cloudy
# F0F32 weather-partly-lightning
# F0F33 weather-partly-rainy
# F0F34 weather-partly-snowy
# F0F35 weather-partly-snowy-rainy
# F0596 weather-pouring
# F0597 weather-rainy
# F0598 weather-snowy
# F0F36 weather-snowy-heavy
# F067F weather-snowy-rainy
# F0599 weather-sunny
# F0F37 weather-sunny-alert
# F14E4 weather-sunny-off
# F059A weather-sunset
# F059B weather-sunset-down
# F059C weather-sunset-up
# F0F38 weather-tornado
# F059D weather-windy
# F059E weather-windy-variant

# conditions taken from
# https://github.com/chubin/wttr.in/blob/575908ae51010b2d71c0b1d4bf4def997bea0fa3/share/translations/en.txt
#
# Icons from Material Design
# file://~/src/sources/MaterialDesign-Font/cheatsheet.html

# conditions["Clear"]=""
conditions["Sunny"]="󰖙" # weather-sunny
conditions["Partly cloudy"]="󰖕" # weather-partly-cloudy
conditions["Cloudy"]="󰖐" # weather-cloudy
conditions["Overcast"]="󱓤" # weather-sunny-off
conditions["Mist"]="󰖑" # weather-fog
conditions["Patchy rain possible"]="󰼳" # weather-partly-rainy
conditions["Patchy snow possible"]="󰼴" # weather-partly-snowy
# conditions["Patchy sleet possible"]=""
# conditions["Patchy freezing drizzle possible"]=""
# conditions["Thundery outbreaks possible"]=""
# conditions["Blowing snow"]=""
# conditions["Blizzard"]=""
conditions["Fog"]="󰖑" # weather-fog
conditions["Freezing fog"]="󰖑" # weather-fog
# conditions["Patchy light drizzle"]=""
# conditions["Light drizzle"]=""
# conditions["Freezing drizzle"]=""
# conditions["Heavy freezing drizzle"]=""
conditions["Patchy light rain"]="󰼳" # weather-partly-rainy
# conditions["Light rain"]=""
# conditions["Moderate rain at times"]=""
# conditions["Moderate rain"]=""
# conditions["Heavy rain at times"]=""
# conditions["Heavy rain"]=""
# conditions["Light freezing rain"]=""
# conditions["Moderate or heavy freezing rain"]=""
# conditions["Light sleet"]=""
# conditions["Moderate or heavy sleet"]=""
# conditions["Patchy light snow"]=""
# conditions["Light snow"]=""
# conditions["Patchy moderate snow"]=""
# conditions["Moderate snow"]=""
# conditions["Patchy heavy snow"]=""
conditions["Heavy snow"]="󰼶" # weather-snowy-heavy
# conditions["Ice pellets"]=""
conditions["Light rain shower"]="󰖗" # weather-rainy
conditions["Moderate or heavy rain shower"]="󰖖" # weather-pouring
# conditions["Torrential rain shower"]=""
# conditions["Light sleet showers"]=""
# conditions["Moderate or heavy sleet showers"]=""
# conditions["Light snow showers"]=""
# conditions["Moderate or heavy snow showers"]=""
conditions["Patchy light rain with thunder"]="󰼲" # weather-partly-lightning
conditions["Moderate or heavy rain with thunder"]="󰼱" # weather-lightning-rainy
# conditions["Patchy light snow with thunder"]=""
# conditions["Moderate or heavy snow with thunder"]=""

cond=$(echo ${weather[1]##*,})
[ $DEBUG ] && echo "Condition $cond ${conditions[$cond]+exist}"

if [ -n "${conditions[$cond]+exist}" ]
then
    condition="${conditions[$cond]}"
else
    condition="$cond"
fi

echo -e "{\"text\":\""$temperature $condition"\", \"alt\":\""${weather[0]}"\", \"tooltip\":\""${weather[0]}: $temperature ${weather[1]}"\"}"
