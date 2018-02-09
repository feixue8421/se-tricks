import os
import sys
sys.path.insert(1, r'D:\github\se-tricks\python')

source = r'D:\working\JiraIssues\M01-45\conndetailhist_00001208.txt.py.fetched'
destination = source + '.py.del.duplicate'

result = None

with open(source, 'r') as sourcefile, open(destination, 'w') as destfile:
    destfile.write('\n'.join(set([line.strip() for line in sourcefile])))

print("done!!!")
