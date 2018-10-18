#!/usr/bin/env python
#
# Copyright 2016 feixue
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

"""using pyinstaller to make "py" to windows image"""

import sys
import subprocess

pymodule = r'D:\Repository\se-tricks\python\active\collectomci.py'
pyinstaller = r'C:\Users\yongwu\AppData\Local\Programs\Python\Python37-32\Scripts\pyinstaller.exe'
addbinarry = r'D:\Repository\se-tricks\python'

subprocess.run([pyinstaller, '-F', pymodule, '-p', addbinarry], stdout=sys.stdout)

print("process {} done!!!".format(__file__))
