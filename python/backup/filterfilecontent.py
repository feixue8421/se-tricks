import os
import sys
sys.path.insert(1, r'D:\repository\se-tricks\python')

import rule

source = r'C:\Users\yongwu\Desktop\createdeleteont-G240WG_MXXT-20181203\CLI_log.txt.py.fetched'
destination = source + '.py.filtered'

# filter events from event text provider
# rule.Regex(r'[|]01[|]01[:]')

with open(source, 'r') as sourcefile, open(destination, 'w') as destfile:
    destfile.write(''.join(rule.filter([line for line in sourcefile],
            [rule.Regex(r'Received optical signal too low')
            ,rule.Regex(r'SERNUM =')
            ,rule.Regex(r'ONT SWDL In Progress')
            ,rule.Regex(r'Planned software version does not')])))


print("done!!!")
