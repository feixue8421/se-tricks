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

"""glob traces sorting according occured timestamp and trace index"""



import os
import sys
sys.path.insert(1, r'c:\repository\se-tricks\python')

import rule

source = r'C:\SecureCRT\logs\172.24.213.197_072617.log'
destination = source + '.py.fetched'


occured = rule.Regex(r'\+\d{5}:\d{2}:\d{2}:\d{2}:\d{3}:\d{3}')
index = rule.Regex(r'H[1-4]:[0-9a-f]{4}')


with open(source, 'r') as sourcefile, open(destination, 'w') as destfile:
    destfile.write(''.join(rule.filter(rule.match([line for line in sourcefile],
            [rule.Regex(r'  0 \+00000')]),
            [])))


print('------------------------------------------------------------------------------')
print("-process {} done!!!-".format(__file__))
print('------------------------------------------------------------------------------')
