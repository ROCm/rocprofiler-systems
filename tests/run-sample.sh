#!/usr/bin/env bash

# Set up the environment.
. ./setenv.sh

export PROTO_FILE=perfetto-trace.proto

# Create tmp directory.
mkdir -p tmp

# Run the command that generates a .proto file.
rocprof-sys-sample -PTHD -- wget https://github.com/ROCm/rocprofiler-systems/releases/download/rocm-6.3.1/rocprofiler-systems-0.1.0-ubuntu-20.04-ROCm-60200-PAPI-OMPT-Python3.sh \
    -O tmp/somefile.sh

# Copy the .prot file to current directory.
cp rocprofsys-tests-output/prog/*.proto $PROTO_FILE

# Remove unneeded file(s).
rm -rf tmp/*.sh

./verify_proto.py $NIC_NAME $PROTO_FILE
