#!/bin/bash

# Script to start the Qwen 3 embeddings model.

./start-server.sh --port 8081 --model Qwen3-Embedding-4B-q4_k_m.gguf --alias qwen3-embeddings --ctx-size 32768 --cache-type-k q4_0 --cache-type-v q4_0 --embedding
