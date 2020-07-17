#!/usr/bin/with-contenv bash

FILE=${CONFIG_FILE}

if [ ! ${BASE_URL} ]; then
  URL=/sonarr
else
  URL=${BASE_URL}
fi

if [ ! -f "$FILE" ]; then
    echo "no config file exists - you must be doing a fresh install"
    echo "a config file will be created for you by the container. Restart container to update values"
fi

if [ -f "$FILE" ]; then
    sed -i '/<UrlBase><\/UrlBase>/,${s||<UrlBase>'"$URL"'<\/UrlBase>|;b};$q1' $FILE
    if [ $? -eq 0 ]; then
        echo "updated baseurl to $URL"
    fi
fi