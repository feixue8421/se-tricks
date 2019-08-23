import os
import sys
sys.path.insert(1, r'c:\repository\se-tricks\python')

import rule

source = r'C:\SecureCRT\logs\172.24.213.197_072617.log'
destination = source + '.py.fetched'

with open(source, 'r') as sourcefile, open(destination, 'w') as destfile:
    destfile.write(''.join(rule.filter(rule.match([line for line in sourcefile],
            [rule.Regex(r'  0 \+00000')]),
            [])))

print("done!!!")
