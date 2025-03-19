#!/usr/bin/env bash

# This script tests NIC performance profiling.
# It runs rocprof-sys-sample to generate a .proto file and then verifies that
# the generated file contains NIC performance tracks.
# In order for it to work, the value in /proc/sys/kernel/perf_event_paranoid
# has to be 1 or 2, and by default it is normally 4.
# Change it manually like this:
#   echo 2 | tee /proc/sys/kernel/perf_event_paranoid

# Set up the environment.
. ./setenv.sh

export PROTO_FILE=perfetto-trace.proto

# Get full path to rocprof-sys-sample from the command line argument.
export ROCPROF_SYS_SAMPLE_PATH=$1

# Create temporary directory where we will write the output of wget.
mkdir -p tmp

# Run the command that generates a .proto file.
$ROCPROF_SYS_SAMPLE_PATH -PTHD -- wget https://github.com/ROCm/rocprofiler-systems/releases/download/rocm-6.3.1/rocprofiler-systems-0.1.0-ubuntu-20.04-ROCm-60200-PAPI-OMPT-Python3.sh \
    -O tmp/somefile.sh

# Copy the .proto file to the current directory.
cp rocprofsys-tests-output/prog/*.proto $PROTO_FILE

# Clean up.
rm -rf tmp/*.sh

# Verify that the .proto file contains NIC tracks.
./verify_proto.py $NIC_NAME $PROTO_FILE
