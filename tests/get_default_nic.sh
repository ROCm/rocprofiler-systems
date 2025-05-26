#!/usr/bin/env bash
# This script gets the name of the default NIC and writes it to standard output.

ip r | awk '/default/{print $5}'
