import os
import sys
sys.path.insert(1, r'C:\repository\se-tricks\python')

import rule

source = r'C:\SecureCRT\logs\135.251.206.205 VNC 4_060310.log'
destination = source + '.py.filtered'

# filter events from event text provider
# rule.Regex(r'[|]01[|]01[:]')

with open(source, 'r') as sourcefile, open(destination, 'w') as destfile:
    destfile.write(''.join(rule.filter([line for line in sourcefile],
            [rule.Regex(r' 7 \+000'), rule.Regex(r' 6 \+000'), rule.Regex(r' 5 \+000'), rule.Regex(r' 3 \+000'), rule.Regex(r' 2 \+000'), rule.Regex(r' 1 \+000'), rule.Regex(r' 0 \+000')])))


print("done!!!")
