import os
import sys
sys.path.insert(1, r'D:\github\se-tricks\python')

import rule

source = r'D:\working\JiraIssues\M01-45\conndetailhist_00001208.txt'

result = {}

with open(source, 'r') as sourcefile:
    for line in sourcefile:
        line = line.strip()
        if len(line) < 1:
            continue

        if line in result:
            result[line] = result[line] + 1
        else:
            result[line] = 0

    destfile.write(''.join(rule.match([line for line in sourcefile],
            [rule.Regex(r'18988 10')])))

print("done!!!")
