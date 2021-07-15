import os
import sys
sys.path.insert(1, r'.')

import rule

source = r'/mnt/c/Tools/putty/logs/172.24.213.197_0706091828.log'
destination = r'/home/y6wu/172.24.213.197_0706091828.log.py.fetched'

nolights = []

def _getNolightTime(line):
    regex = rule.Regex(r'([0-9]{2}:[0-9]{2}:[0-9]{2}[.][0-9]{6}).*time: ([0-9]+)')
    return f'{regex.searchgroup(line, 1)} -- {regex.searchgroup(line, 2):0>9}'

with open(source, 'r') as sourcefile, open(destination, 'w') as destfile:
    last = None
    for line in sourcefile:
        if 'brugal_get_hal_id' in line:
            last = line.strip()
        elif 'ponfail_nolight_seen' in line:
            nolight = f'{last}--{line}'
            destfile.write(nolight)
            nolights.append(_getNolightTime(nolight))

print('\n'.join(nolights))
print("done!!!")

