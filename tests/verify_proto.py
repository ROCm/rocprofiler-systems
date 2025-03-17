#!/usr/bin/env python3

import sys
from perfetto.trace_processor import TraceProcessor

def Usage(prog):
    print(f"""
{prog}
Check if a .proto file has a track with NIC traffic
Usage: {prog} <NIC-name> <proto-file>
"""
    )

def main():
    argv = sys.argv
    if len(argv) < 3:
        Usage(argv[0])
        sys.exit(0)
    nic = argv[1]
    proto_file = argv[2]
    tp = TraceProcessor(trace=proto_file)
    # Find all records in track table that have the name field that contains the NIC name.
    qr = tp.query(f"SELECT * FROM track WHERE name LIKE '%{nic}%'")
    # Count the rows and check if there is at least one.
    count = 0
    for row in qr:
        count = count + 1
    if count > 0:
        # Found a track.
        sys.exit(0) # Return success.
    # Didn't find a track.
    sys.exit(1) # Return failure.

if __name__ == "__main__":
    main()
