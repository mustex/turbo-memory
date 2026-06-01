#!/bin/bash

# 1. Extract the UUID for the RTX 5090
export RTX_5090_UUID=$(nvidia-smi --query-gpu=uuid,name --format=csv,noheader | \
    awk -F', ' '/RTX 5090/ {print $1}')

# 2. Extract the UUID for the RTX 4090
export RTX_4090_UUID=$(nvidia-smi --query-gpu=uuid,name --format=csv,noheader | \
    awk -F', ' '/RTX 4090/ {print $1}')

# 3. Print verification to console
echo "Found RTX 5090 UUID: ${RTX_5090_UUID:-NOT FOUND}"
echo "Found RTX 4090 UUID: ${RTX_4090_UUID:-NOT FOUND}"

HOME_PATH=`cygpath -u $LLAMA_HOME` docker compose up -d --force-recreate --remove-orphans
#HOME_PATH=`cygpath -u $LLAMA_HOME` docker compose exec api-gateway nginx -s reload

echo "Waiting for llama.cpp to load model"
sleep 10

# Check if the health endpoint is responding at all
# If it returns an error code (like 000), abort the script
if [ $(curl -s -o /dev/null -w '%{http_code}' "http://localhost:8080/health") -eq 000 ]; then
    echo "Error: Health check returned error. Aborting."
    exit 1
fi

# Loop and print dots until the health endpoint returns a 200 OK status
until [ $(curl -s -o /dev/null -w '%{http_code}' "http://localhost:8080/health") -eq 200 ]; do
    printf '.'
    sleep 2
done

echo -e "\nModel ready!"