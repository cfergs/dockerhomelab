#!/usr/bin/with-contenv bash

URL=/subtitles/
FILE=/config/app/config/config.ini

if [ ! -f "$FILE" ]; then
    echo "no config file exists - you must be doing a fresh install"
    echo "a config file will be created for you by the container. Restart container to update values"
fi

if [ -f "$FILE" ]; then
    if head -n4 $FILE | grep "base_url = /$"; then #checking only 4th line. sed is a pain to do this and all the other stuff im checking
        sed -i '/base_url = \/$/,${4s||base_url = '"$URL"'|;b};$q1' $FILE
        if [ $? -eq 0 ]; then
            echo "updated values in config file"
        fi
    fi
fi