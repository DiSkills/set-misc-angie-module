# Image for CI pipeline

# Local image of Angie WASM SDK
FROM angie-wasm-sdk AS builder

USER root

# Set environment variables for Rust
ENV PATH="/root/.cargo/bin:${PATH}"
ENV RUSTUP_HOME=/root/.rustup
ENV CARGO_HOME=/root/.cargo

# Set environment variables for building and testing
ENV ANGIE_WASM_SDK=/angie-wasm-sdk
ENV WASI_SDK=/sdk-build/wasi-sdk
ENV ANGIE_MODULES=/etc/angie/modules
ENV ANGIE_TESTS=/build/angie/tests
ENV TEST_ANGIE_BINARY=/sbin/angie

# Install Rust
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
# Install nightly toolchain and wasm32-wasip1 target
RUN rustup toolchain install nightly && \
    rustup default nightly && \
    rustup target add wasm32-wasip1
# Install bindgen
RUN apt install -y libclang-dev && \
    cargo install bindgen-cli@0.68.1
WORKDIR /module

ENTRYPOINT [ "/bin/sh" ]
