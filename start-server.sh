#!/bin/bash
PORT=8080

export MSYS_NO_PATHCONV=1
docker rm -f llamacpp 2>/dev/null || true

docker run -d --gpus all \
  -v /c/Workspace/data/llama/models:/models \
  -v /c/Workspace/data/llama/cache:/cache \
  -p $PORT:8080 --name llamacpp \
  ghcr.io/ggml-org/llama.cpp:server-cuda \
  -m /models/gemma-4-26B-A4B-it-UD-Q4_K_M.gguf \
  --slot-save-path /cache \
  --ctx-size 65536 --no-mmap --mlock \
  --host 0.0.0.0 --port 8080 --n-gpu-layers 99 \
  --flash-attn on \
  --threads 2 --alias gemma4 \
  -np 1 --cache-type-k q4_0 --cache-type-v q4_0 --keep -1

echo "Waiting for llama.cpp to load model"

sleep 10
# If we 404 here, abort with error
if [ $(curl -s -o /dev/null -w '%{http_code}' "http://localhost:$PORT/health") -eq 404 ]; then
    echo "Error: Health check returned 404. Aborting."
    exit 1
fi
# Loop until the health endpoint returns a 200 OK
until [ $(curl -s -o /dev/null -w '%{http_code}' "http://localhost:$PORT/health") -eq 200 ]; do
    printf '.'
    sleep 2
done

echo -e "\nModel ready!"