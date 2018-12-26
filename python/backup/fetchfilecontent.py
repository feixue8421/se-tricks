import os
import sys
sys.path.insert(1, r'D:\repository\se-tricks\python')

import rule

source = r'D:\SecureCRT\logs\135.251.206.205 VNC.001.log'
destination = source + '.py.fetched'

with open(source, 'r') as sourcefile, open(destination, 'w') as destfile:
    destfile.write(''.join(rule.match([line for line in sourcefile],
            [rule.Regex(r'GLTD_')])))

print("done!!!")
