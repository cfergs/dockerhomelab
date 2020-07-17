#!/usr/bin/with-contenv bash

FILE=${CONFIG_FILE}

if [ ! ${BASE_URL} ]; then
  URL=/jackett
else
  URL=${BASE_URL}
fi

if [ ! -f "$FILE" ]; then
    echo "no config file exists - you must be doing a fresh install"
    echo "a config file will be created for you by the container. Restart container to update values"
fi

if [ -f "$FILE" ]; then
  #update urlbase
  sed -i '/"BasePathOverride": null,$/,${s||"BasePathOverride": "'"$URL"'",|;b};$q1' $FILE
  if [ $? -eq 0 ]; then
    echo "updated base url to $URL"
  fi

  if [ ${TORRENT_BLACKHOLE} ]; then
     sed -i '/"BlackholeDir": null,$/,${s||"BlackholeDir": "'"${TORRENT_BLACKHOLE}"'",|;b};$q1' $FILE
    if [ $? -eq 0 ]; then
      echo "updated torrent blackhole to ${TORRENT_BLACKHOLE}"
    fi
  fi

fi