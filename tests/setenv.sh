#!/usr/bin/env bash

# Use lo as the NIC name, because every Linux system should have it.
export NIC_NAME=lo

# Substitute the @NIC@ with $NIC_NAME in prog.cfg.in and
# write the result to prog.cfg.
sed -e "s/@NIC@/$NIC_NAME/g" prog.cfg.in > prog.cfg

# Set up the environment.
export LD_LIBRARY_PATH=/opt/rocprofiler-systems/lib
export ROCPROFSYS_CI=ON
export ROCPROFSYS_OUTPUT_PATH=rocprofsys-tests-output
export ROCPROFSYS_CI_TIMEOUT=120

export OMP_PLACES=threads
export OMP_NUM_THREADS=2
export ROCPROFSYS_CONFIG_FILE=$PWD/prog.cfg
export ROCPROFSYS_DEBUG_SETTINGS=1
