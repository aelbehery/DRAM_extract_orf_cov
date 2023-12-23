#!/usr/bin/env ython3
import sys
with open(sys.argv[1]) as table:
    for line in table:
        x = 0
        line = line.rstrip()
        line = line.split("\t")
        if line[2] == "E":
            continue
        for i in (3,6,12,16):
            if line[i] != "":
                x += 1
        if x >= 2:
            print("\t".join(line))
