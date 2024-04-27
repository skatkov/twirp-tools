#!/bin/bash

# Set the target platforms
platforms=("darwin/amd64" "linux/amd64" "windows/amd64")

# Set the output directory
output_dir="$HOME/bin"

# Create the output directory if it doesn't exist
mkdir -p "$output_dir"

# Compile and install the plugin for each platform
for platform in "${platforms[@]}"; do
    IFS='/' read -ra parts <<< "$platform"
    os="${parts[0]}"
    arch="${parts[1]}"

    echo "Compiling protoc-gen-twirp_ruby for $os/$arch..."

    # Set the appropriate environment variables for cross-compilation
    export GOOS="$os"
    export GOARCH="$arch"

    # Compile the plugin
    go build -o "$output_dir/protoc-gen-twirp_ruby-$os-$arch" github.com/arthurnn/twirp-ruby/protoc-gen-twirp_ruby

    echo "Compiled protoc-gen-twirp_ruby for $os/$arch and placed it in $output_dir"
done

echo "All protoc-gen-twirp_ruby binaries have been compiled and placed in $output_dir"
echo "Make sure to add $output_dir to your PATH environment variable."
