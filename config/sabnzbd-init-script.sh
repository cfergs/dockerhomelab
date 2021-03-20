#!/usr/bin/with-contenv bash

echo "installing sed"
apk add --no-cache sed

FILE=${CONFIG_FILE}

if [ ! -f "$FILE" ]; then
  echo "no config file exists - you must be doing a fresh install"
  echo "a config file will be created for you by the container. Restart container to update values"
fi

if [ -f "$FILE" ]; then
  echo "file found"
  if [ ${DOMAIN_WHITELIST} ]; then
    sed -i 's/host_whitelist =.*/host_whitelist = '"${DOMAIN_WHITELIST}"',/g' $FILE
    if [ $? -eq 0 ]; then
      echo "updated host_whitelist"
    fi
  fi

  if [ ${PARENT_DOWNLOAD_PATH} ]; then
    sed -i '/download_dir = Downloads\/incomplete$/,${s||download_dir = '"${PARENT_DOWNLOAD_PATH}"'\/incomplete|;b};$q1' $FILE
    if [ $? -eq 0 ]; then
      echo "updated incomplete download_dir"
    fi
    sed -i '/complete_dir = Downloads\/complete$/,${s||complete_dir = '"${PARENT_DOWNLOAD_PATH}"'\/complete|;b};$q1' $FILE
    if [ $? -eq 0 ]; then
      echo "updated complete_dir"
    fi
  fi

fi
