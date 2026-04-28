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
  --ctx-size 131072 --no-mmap \
  --host 0.0.0.0 --port 8080 --n-gpu-layers 999 \
  --flash-attn on \
  -np 1

echo "Waiting for llama.cpp to load model"

# Loop until the health endpoint returns a 200 OK
until [ $(curl -s -o /dev/null -w '%{http_code}' "http://localhost:$PORT/health") -eq 200 ]; do
    printf '.'
    sleep 2
done

echo -e "\nModel ready!"