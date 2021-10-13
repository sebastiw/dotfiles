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

conditions["clear"]=""
conditions["sunny"]=""

conditions["partly cloudy"]=""

conditions["cloudy"]=""
conditions["overcast"]=""

conditions["mist"]=""
conditions["fog"]=""
conditions["freezing fog"]=""

conditions["patchy rain possible"]=""
conditions["patchy light drizzle"]=""
conditions["light drizzle"]=""
conditions["patchy light rain"]=""
conditions["light rain"]=""
conditions["light rain shower"]=""
conditions["rain"]=""

conditions["moderate rain at times"]=""
conditions["moderate rain"]=""
conditions["heavy rain at times"]=""
conditions["heavy rain"]=""
conditions["moderate or heavy rain shower"]=""
conditions["torrential rain shower"]=""
conditions["rain shower"]=""

conditions["patchy snow possible"]=""
conditions["patchy sleet possible"]=""
conditions["patchy freezing drizzle possible"]=""
conditions["freezing drizzle"]=""
conditions["heavy freezing drizzle"]=""
conditions["light freezing rain"]=""
conditions["moderate or heavy freezing rain"]=""
conditions["light sleet"]=""
conditions["ice pellets"]=""
conditions["light sleet showers"]=""
conditions["moderate or heavy sleet showers"]=""

conditions["blowing snow"]=""
conditions["moderate or heavy sleet"]=""
conditions["patchy light snow"]=""
conditions["light snow"]=""
conditions["light snow showers"]=""

conditions["blizzard"]="ｓ"
conditions["patchy moderate snow"]="ｓ"
conditions["moderate snow"]="ｓ"
conditions["patchy heavy snow"]="ｓ"
conditions["heavy snow"]="ｓ"
conditions["moderate or heavy snow with thunder"]="ｓ"
conditions["moderate or heavy snow showers"]="ｓ"

conditions["thundery outbreaks possible"]=""
conditions["patchy light rain with thunder"]=""
conditions["moderate or heavy rain with thunder"]=""
conditions["patchy light snow with thunder"]=""

cond=$(echo ${weather[1]##*,} | tr '[:upper:]' '[:lower:]')
[ $DEBUG ] && echo "Condition $cond ${conditions[$cond]+exist}"

if [ -n "${conditions[$cond]+exist}" ]
then
    condition="${conditions[$cond]}"
else
    condition=""
fi

echo -e "{\"text\":\""$temperature $condition"\", \"alt\":\""${weather[0]}"\", \"tooltip\":\""${weather[0]}: $temperature ${weather[1]}"\"}"
