import os
import sys
sys.path.insert(1, r'D:\github\se-tricks\python')

import rule

source = r'D:\working\JiraIssues\M01-62\supportfile_00000411_20170928171849\EVENTS.LOG'
destination = source + '.py.filtered'

# filter events from event text provider
# rule.Regex(r'[|]01[|]01[:]')

with open(source, 'r') as sourcefile, open(destination, 'w') as destfile:
    destfile.write(''.join(rule.filter([line for line in sourcefile],
            [rule.Regex(r'客户取钞成功'),
            rule.Regex(r'No successful witdrawal')])))


print("done!!!")
