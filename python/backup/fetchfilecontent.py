import os
import sys
sys.path.insert(1, r'c:\repository\se-tricks\python')

import rule

source = r'C:\FR\ALU02572051\SLS_CLI.txt'
destination = source + '.py.fetched'

with open(source, 'r') as sourcefile, open(destination, 'w') as destfile:
    destfile.write(''.join(rule.filter(rule.match([line for line in sourcefile],
            [rule.Regex(r'service affecting')]), [rule.Regex(r'1/1/8'), rule.Regex(r'1/1/1/')])))

print("done!!!")
