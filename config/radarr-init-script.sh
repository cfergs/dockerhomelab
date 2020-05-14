#!/usr/bin/with-contenv bash

URL=/radarr
FILE=/config/app/config.xml

if [ ! -f "$FILE" ]; then
    echo "no config file exists - you must be doing a fresh install"
    echo "a config file will be created for you by the container. Restart container to update values"
fi

if [ -f "$FILE" ]; then
    sed -i '/<UrlBase><\/UrlBase>/,${s||<UrlBase>'"$URL"'<\/UrlBase>|;b};$q1' $FILE
    if [ $? -eq 0 ]; then
        echo "updated values in config file"
    fi
fi