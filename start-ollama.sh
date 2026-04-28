#!/bin/bash
export MSYS_NO_PATHCONV=1
docker rm -f ollama 2>/dev/null || true

docker run -d --gpus=all \
  -e OLLAMA_KEEP_ALIVE=1h\
  -e OLLAMA_NUM_PARALLEL=1 \
  -e OLLAMA_FLASH_ATTENTION=1 \
  -v /c/Workspace/data/ollama:/root/.ollama \
  -p 11434:11434 --name ollama ollama/ollama && sleep 5

echo Pull base models
docker exec ollama ollama pull gemma4:26b-a4b-it-q4_K_M
docker exec ollama ollama pull qwen3-embedding:8b
docker exec ollama ollama pull qwen2.5-coder:1.5b
echo READY