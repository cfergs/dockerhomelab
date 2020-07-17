#!/usr/bin/with-contenv bash

FILE=${CONFIG_FILE}

if [ ! ${BASE_URL} ]; then
  URL=/bazarr
else
  URL=${BASE_URL}
fi

if [ ! -f "$FILE" ]; then
    echo "no config file exists - you must be doing a fresh install"
    echo "a config file will be created for you by the container. Restart container to update values"
fi

if [ -f "$FILE" ]; then
    if head -n4 $FILE | grep "base_url = /$"; then #checking only 4th line. sed is a pain to do this and all the other stuff im checking
        sed -i '/base_url = \/$/,${4s||base_url = '"$URL"'|;b};$q1' $FILE
        if [ $? -eq 0 ]; then
            echo "updated baseurl to $URL"
        fi
    fi
fi