import os
import sys
sys.path.insert(1, r'D:\Repository\se-tricks\python')

import rule

source = r'D:\working\OMCI\omci_dual_stack\LT.TRACE.session_1017.log'
destination = source + '.py.fetched'

idxstart = 262807 # start line index in python format
idxend = -1 # end line index in python format
idxposition = 0

with open(source, 'r') as sourcefile, open(destination, 'w') as destfile:
    for line in sourcefile:
        if (idxposition >= idxstart and (idxend == -1 or idxposition < idxend)):
            destfile.write(line)

        idxposition = idxposition + 1

print("process {} done!!!".format(__file__))

