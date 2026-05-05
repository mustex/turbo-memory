#!/bin/bash

# Script to start the Gemma 4 model

./start-server.sh --port 8080 --model gemma-4-26B-A4B-it-UD-Q4_K_XL.gguf --alias gemma4 --ctx-size 262144 --cache-type-k q4_0 --cache-type-v q4_0
