#!/bin/bash

# Script to download and refresh specific GGUF models from Hugging Face
# into the local LLAMA_HOME/models directory.

# Ensure LLAMA_HOME is set; it defines the base directory for models
if [ "$LLAMA_HOME" == "" ]; then
    echo "LLAMA_HOME is not set"
    exit -1
fi

# Convert Windows path to Unix-style using cygpath and define the models directory
MODEL_PATH=`cygpath -u $LLAMA_HOME`/models

# Install necessary packages for Hugging Face downloads
# hf_transfer is used for significantly faster download speeds
pip install -q huggingface_hub hf_transfer

# Enable the high-speed transfer optimization
export HF_HUB_ENABLE_HF_TRANSFER=1

# Download specific quantized models from the Unsloth/Mungert repositories

# Chat - MOE
hf download unsloth/gemma-4-26B-A4B-it-GGUF gemma-4-26B-A4B-it-UD-Q4_K_XL.gguf --local-dir $MODEL_PATH
hf download unsloth/Qwen3.6-27B-GGUF Qwen3.6-27B-UD-Q4_K_XL.gguf --local-dir $MODEL_PATH
# Chat - Dense
hf download unsloth/gemma-4-31B-it-GGUF gemma-4-31B-it-UD-Q4_K_XL.gguf --local-dir $MODEL_PATH
hf download unsloth/Qwen3.6-35B-A3B-GGUF Qwen3.6-35B-A3B-UD-Q4_K_XL.gguf --local-dir $MODEL_PATH
# Autocomplete
hf download unsloth/Qwen3-Coder-30B-A3B-Instruct-GGUF Qwen3-Coder-30B-A3B-Instruct-UD-Q4_K_XL.gguf --local-dir $MODEL_PATH
# Embeddings
hf download Mungert/Qwen3-Embedding-4B-GGUF Qwen3-Embedding-4B-q4_k_m.gguf --local-dir $MODEL_PATH
# Rerank
hf download Mungert/Qwen3-Reranker-4B-GGUF Qwen3-Reranker-4B-q4_k_m.gguf --local-dir $MODEL_PATH