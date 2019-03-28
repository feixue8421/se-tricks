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

"""counting....."""

import paramiko
import time
import rule
import queue
import threading
import subprocess
import sys
import os

left = """

"""


right = """

"""

content = [item.strip() for item in content.replace('\n', ',').split(',') if item.strip()]
content = dict(zip(content, (content.count(item) for item in content)))
content = sorted(content.items(), key = lambda kv: kv[1], reverse = True)
list(map(lambda item: print(f'ONT {item[0]} == {item[1]}', end = ', '), content))

print('------------------------------------------------------------------------------')
print("-process {} done!!!-".format(__file__))
print('------------------------------------------------------------------------------')
