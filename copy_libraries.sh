#!/bin/bash

# Path to your mervin binary
MERVIN_BIN="prog/mervin/mervin"
# Root filesystem path
ROOTFS_DIR="rootfs"

# Check if the binary exists
if [ ! -f "$MERVIN_BIN" ]; then
  echo "Error: $MERVIN_BIN not found!"
  exit 1
fi

# Create the necessary directories in rootfs
mkdir -p $ROOTFS_DIR/lib/x86_64-linux-gnu
mkdir -p $ROOTFS_DIR/usr/lib/x86_64-linux-gnu
mkdir -p $ROOTFS_DIR/lib64

# Get the list of shared libraries used by mervin using ldd
LD_LIBS=$(ldd $MERVIN_BIN | grep -oP '=> \K.+' | tr -d ' ' | sed 's/(0x.*)//')

# Copy each library to the root filesystem
for lib in $LD_LIBS; do
  # Ensure the library exists on the host system
  if [ -f "$lib" ]; then
    # Extract the directory path of the library
    lib_dir=$(dirname "$lib")
    
    # Determine the destination directory inside the root filesystem
    if [[ "$lib_dir" == /lib* || "$lib_dir" == /usr/lib* ]]; then
      dest_dir="$ROOTFS_DIR$lib_dir"
    else
      # If the path is non-standard (e.g., relative), we default to /usr/lib/x86_64-linux-gnu
      dest_dir="$ROOTFS_DIR/usr/lib/x86_64-linux-gnu"
    fi

    # Create the destination directory if it doesn't exist
    mkdir -p "$dest_dir"

    # Copy the library to the guest rootfs
    cp "$lib" "$dest_dir"
    echo "Copied: $lib to $dest_dir"
  else
    echo "Warning: Library not found on host: $lib"
  fi
done

# Ensure dynamic linker is copied
cp /lib64/ld-linux-x86-64.so.2 $ROOTFS_DIR/lib64/
echo "Copied dynamic linker: /lib64/ld-linux-x86-64.so.2 to $ROOTFS_DIR/lib64/"

echo "Libraries copied successfully!"
