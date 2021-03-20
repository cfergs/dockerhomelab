#!/usr/bin/with-contenv bash

# fix for error when updating settings in web interface
#if [ ! -d ${CONFIG_DIR}/app/.ComicTagger ]; then
#  mkdir ${CONFIG_DIR}/app/.ComicTagger
#  chown hotio:hotio "${CONFIG_DIR}/app/.ComicTagger"
#  echo "creating missing .ComicTagger folder"
#fi

echo "installing sed"
apk add --no-cache sed

FILE=${CONFIG_FILE}

if [ ! ${BASE_URL} ]; then
  URL=/comics
else
  URL=${BASE_URL}
fi

if [ ! -f "$FILE" ]; then
    echo "no config file exists - you must be doing a fresh install"
    echo "a config file will be created for you by the container. Restart container to update values"
fi

if [ -f "$FILE" ]; then
  sed -i '/http_root = \/$/,${s||http_root = '"$URL"'|;b};$q1' $FILE
    if [ $? -eq 0 ]; then
      echo "updated baseurl to $URL"
    fi
  
  if [ ${COMICVINE_API_KEY_FILE} ]; then
    COMICVINE_APIKEY=$(cat $COMICVINE_API_KEY_FILE)
    sed -i '/comicvine_api = None$/,${s||comicvine_api = '"${COMICVINE_APIKEY}"'|;b};$q1' $FILE
    if [ $? -eq 0 ]; then
      echo "updated comicvine api key"
    fi
  fi

  if [ ${COMIC_DIR} ]; then
    sed -i '/destination_dir = None$/,${s||comic_dir = '"${COMIC_DIR}"'|;b};$q1' $FILE
    if [ $? -eq 0 ]; then
      echo "updated destination_dir to ${COMIC_DIR}"
    fi
  fi

fi