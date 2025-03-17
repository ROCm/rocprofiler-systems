#!/usr/bin/env bash

# Get the name of the NIC connected to the default gateway.
# Look the route to the non-existent IP 11.11.11.11.
# (It doesn't matter whether the IP exists or not.)
# Set NIC_NAME environment variable to the primary NIC.
export NIC_NAME=$(ip route get 11.11.11.11 |awk -- '{print $5}')

# Substitute the @NIC@ with $NIC_NAME in prog.cfg.in and
# write the result to prog.cfg.
sed -e "s/@NIC@/$NIC_NAME/g" prog.cfg.in > prog.cfg

export LD_LIBRARY_PATH=/opt/rocprofiler-systems/lib
export ROCPROFSYS_CI=ON
export ROCPROFSYS_OUTPUT_PATH=rocprofsys-tests-output
export ROCPROFSYS_CI_TIMEOUT=120

export OMP_PLACES=threads
export OMP_NUM_THREADS=2
export ROCPROFSYS_CONFIG_FILE=$PWD/prog.cfg
export ROCPROFSYS_DEBUG_SETTINGS=1
