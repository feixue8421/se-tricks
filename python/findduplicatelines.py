#!/usr/bin/env python
#
# Copyright 2019 feixue
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may
# not use this file except in compliance with the License. You may obtain
# a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations
# under the License.

"""find duplicated lines"""

import os
import sys
sys.path.insert(1, r'c:\repository\se-tricks\python')

source = r'C:\ThgRepository\sw\files.log'
destination = source + '.py.fetched'

upperlines = []

with open(source) as srcfile, open(destination, 'w') as dstfile:
    for line in srcfile:
        if line.upper() in upperlines:
            dstfile.write(line)
        else:
            upperlines.append(line.upper())

print('------------------------------------------------------------------------------')
print("-process {} done!!!-".format(__file__))
print('------------------------------------------------------------------------------')
