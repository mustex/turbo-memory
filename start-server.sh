#!/bin/bash

# Script to start a llama.cpp server inside a Docker container with NVIDIA GPU support.
# It uses models and cache stored in the LLAMA_HOME directory.

# The port on the host machine to map to the container's port 8080
PORT=8080
CONTAINER_NAME="llamacpp"

if [ "$#" -ne 2 ]; then
    echo "Error: Missing arguments. Usage: ./start-server.sh <MODEL_NAME> <MODEL_ALIAS>"
    exit 1
fi

MODEL_NAME="$1"
MODEL_ALIAS="$2"

CTX_SIZE=262144
CACHE_TYPE_K="f16"
CACHE_TYPE_V="f16"

# Resolve the Windows path to a Unix-style path for Docker compatibility
HOME_PATH=`cygpath -u $LLAMA_HOME`

# Prevent MSYS from converting paths in Docker commands
export MSYS_NO_PATHCONV=1

# Remove any existing container to avoid conflicts
docker rm -f $CONTAINER_NAME 2>/dev/null || true

# Start the llama.cpp server container
# --gpus all: Enables NVIDIA GPU acceleration
# -v: Mounts local models and cache directories into the container
# -p: Maps the host PORT to the container's port 8080
docker run -d --gpus all \
  -v $HOME_PATH/models:/models \
  -v $HOME_PATH/cache:/cache \
  -p $PORT:8080 --name $CONTAINER_NAME \
  ghcr.io/ggml-org/llama.cpp:server-cuda \
  -m /models/$MODEL_NAME \
  --slot-save-path /cache \
  --ctx-size $CTX_SIZE --no-mmap --mlock \
  --host 0.0.0.0 --port 8080 --n-gpu-layers 999 \
  --flash-attn "on" \
  --threads 2 --alias $MODEL_ALIAS \
  -np 1 --cache-type-k $CACHE_TYPE_K --cache-type-v $CACHE_TYPE_V --keep -1

echo "Waiting for llama.cpp to load model"
sleep 10

# Check if the health endpoint is responding at all
# If it returns an error code (like 000), abort the script
if [ $(curl -s -o /dev/null -w '%{http_code}' "http://localhost:$PORT/health") -eq 000 ]; then
    echo "Error: Health check returned error. Aborting."
    exit 1
fi

# Loop and print dots until the health endpoint returns a 200 OK status
until [ $(curl -s -o /dev/null -w '%{http_code}' "http://localhost:$PORT/health") -eq 200 ]; do
    printf '.'
    sleep 2
done

echo -e "\nModel ready!"