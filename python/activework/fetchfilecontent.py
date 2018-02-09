import os
import sys
sys.path.insert(1, r'D:\github\se-tricks\python')

import rule

source = r'D:\working\JiraIssues\M01-45\conndetailhist_00001208.txt'
destination = source + '.py.fetched'

with open(source, 'r') as sourcefile, open(destination, 'w') as destfile:
    destfile.write(''.join(rule.match([line for line in sourcefile],
            [rule.Regex(r'18988 10')])))

print("done!!!")
