import os
import sys
sys.path.insert(1, r'C:\repository\se-tricks\python')

import rule

source = r'C:\FR\ALU02574866\FailureLog_ALU02574866\SLS_LT15.txt'
destination = source + '.py.filtered'

# filter events from event text provider
# rule.Regex(r'[|]01[|]01[:]')

with open(source, 'r') as sourcefile, open(destination, 'w') as destfile:
    destfile.write(''.join(rule.filter([line for line in sourcefile],
            [rule.Regex(r'\(PRNT\)'),
                rule.Regex(r'###########')])))


print("done!!!")
