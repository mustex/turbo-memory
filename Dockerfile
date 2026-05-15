# Use official NVIDIA CUDA development image for compilation
FROM nvidia/cuda:12.8.2-devel-ubuntu22.04 AS builder

# Install system dependencies required for building llama.cpp
RUN apt-get update && apt-get install -y \
    git \
    cmake \
    build-essential \
    libcurl4-openssl-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /build

RUN git clone --single-branch --branch feature/turboquant-kv-cache https://github.com/TheTom/llama-cpp-turboquant.git .

ENV LD_LIBRARY_PATH=/usr/local/cuda/lib64/stubs:$LD_LIBRARY_PATH
RUN ln -s /usr/local/cuda/lib64/stubs/libcuda.so /usr/local/cuda/lib64/stubs/libcuda.so.1
# Configure with full CUDA support: RTX 3090/4090/5090/Pro 6000
RUN mkdir build && cd build && \
    cmake .. \
    -DGGML_CUDA=ON \
    -DGGML_NATIVE=OFF \
    -DCMAKE_CUDA_ARCHITECTURES="86-real;89-real;120a-real" \
    -DCMAKE_EXE_LINKER_FLAGS="-Wl,-rpath-link,/usr/local/cuda/lib64/stubs -L/usr/local/cuda/lib64/stubs"

# Run the actual compilation pass
RUN cd build && cmake --build . --config Release --target llama-server -j$(nproc)

# Switch to a slim runtime image to keep the container footprint low
FROM nvidia/cuda:12.8.2-runtime-ubuntu22.04

RUN apt-get update && apt-get install -y \
    libcurl4 \
    libomp5 \
    libgomp1 \
    && rm -rf /var/lib/apt/lists/*

# Copy the compiled executable from the builder stage
COPY --from=builder /build/build/bin/llama-server /usr/local/bin/llama-server
COPY --from=builder /build/build/bin/*.so* /usr/local/lib/

ENV LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH
ENV GGML_CUDA_NO_PINNED=1

WORKDIR /models
EXPOSE 8000

ENTRYPOINT ["llama-server"]
