#!/usr/bin/env python3

# This script verifies that a .proto file contains one or more tracks
# that match (contain) a given NIC name.
# For example, if the NIC name on the system is enp7s0, and we
# want to verify that the file perfetto-trace.proto contains one or more
# tracks that contain "enp7s0" in their name, then we can run
#   python3 verify_proto.py enp7s0 ./perfetto-trace.proto
# and the return code of that command will be 0 (success) or
# 1 (failure).
# In this example, if we are measuring the given NIC's byte and packet
# transfer, we would get four tracks:
#   - net:::enp7s0:rx:byte    - received bytes
#   - net:::enp7s0:rx:packet  - received packets
#   - net:::enp7s0:tx:byte    - sent bytes
#   - net:::enp7s0:tx:packet  - sent packets


import sys
from perfetto.trace_processor import TraceProcessor


def Usage(prog):
    print(
        f"""
{prog}
Check if a .proto file has a track with NIC traffic
Usage: {prog} <NIC-name> <proto-file>
"""
    )


def main():
    # Read NIC name and .proto file from the command line.
    argv = sys.argv
    if len(argv) < 3:
        Usage(argv[0])
        sys.exit(1)
    nic = argv[1]
    proto_file = argv[2]

    # Instantiate a trace processor.
    try:
        tp = TraceProcessor(trace=proto_file)
    except Exception as ex:
        print(f"Reading {proto_file} failed: {ex}")
        sys.exit(1)

    # Find all records in track table that have the name field that contains the NIC name.
    try:
        qr = tp.query(f"SELECT * FROM track WHERE name LIKE '%{nic}%'")
    except Exception as ex:
        print(f"Query failed: {ex}")
        sys.exit(1)

    # Count the rows and check if there is at least one.
    count = 0
    for row in qr:
        count = count + 1
    if count > 0:
        # Found a track.
        sys.exit(0)  # Return success.

    # Didn't find a track.
    sys.exit(1)  # Return failure.


if __name__ == "__main__":
    main()
