#!/bin/bash

# Script to start the Qwen 3 reranker model.

./start-server.sh --port 8082 --model Qwen3-Reranker-4B-q4_k_m.gguf --alias qwen3-reranker --ctx-size 32768 --cache-type-k q4_0 --cache-type-v q4_0 --rerank
