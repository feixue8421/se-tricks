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

"""configures shared among python modules"""

import sys
import re
from datetime import datetime

content = """
    { DEVICE_LIU + 10, "sfp0_tx_fault_ch1", 14 },
    { DEVICE_LIU + 11, "sfp0_tx_fault_ch2", 15 },
    { DEVICE_LIU + 12, "sfp1_tx_fault_ch1", 12 },
    { DEVICE_LIU + 13, "sfp1_tx_fault_ch2", 13 },
    { DEVICE_LIU + 14, "sfp2_tx_fault_ch1", 10 },
    { DEVICE_LIU + 15, "sfp2_tx_fault_ch2", 11 },
    { DEVICE_LIU + 16, "sfp3_tx_fault_ch1", 8 },
    { DEVICE_LIU + 17, "sfp3_tx_fault_ch2", 9 },
    { DEVICE_LIU + 18, "sfp4_tx_fault_ch1", 6 },
    { DEVICE_LIU + 19, "sfp4_tx_fault_ch2", 7 },
    { DEVICE_LIU + 20, "sfp5_tx_fault_ch1", 4 },
    { DEVICE_LIU + 21, "sfp5_tx_fault_ch2", 5 },
    { DEVICE_LIU + 22, "sfp6_tx_fault_ch1", 2 },
    { DEVICE_LIU + 23, "sfp6_tx_fault_ch2", 3 },
    { DEVICE_LIU + 24, "sfp7_tx_fault_ch1", 0 },
    { DEVICE_LIU + 25, "sfp7_tx_fault_ch2", 1 },
    { DEVICE_LIU + 26, "sfp8_tx_fault_ch1", 30 },
    { DEVICE_LIU + 27, "sfp8_tx_fault_ch2", 31 },
    { DEVICE_LIU + 28, "sfp9_tx_fault_ch1", 28 },
    { DEVICE_LIU + 29, "sfp9_tx_fault_ch2", 29 },
    { DEVICE_LIU + 30, "sfp10_tx_fault_ch1", 26 },
    { DEVICE_LIU + 31, "sfp10_tx_fault_ch2", 27 },
    { DEVICE_LIU + 32, "sfp11_tx_fault_ch1", 24 },
    { DEVICE_LIU + 33, "sfp11_tx_fault_ch2", 25 },
    { DEVICE_LIU + 34, "sfp12_tx_fault_ch1", 22 },
    { DEVICE_LIU + 35, "sfp12_tx_fault_ch2", 23 },
    { DEVICE_LIU + 36, "sfp13_tx_fault_ch1", 20 },
    { DEVICE_LIU + 37, "sfp13_tx_fault_ch2", 21 },
    { DEVICE_LIU + 38, "sfp14_tx_fault_ch1", 18 },
    { DEVICE_LIU + 39, "sfp14_tx_fault_ch2", 19 },
    { DEVICE_LIU + 40, "sfp15_tx_fault_ch1", 16 },
    { DEVICE_LIU + 41, "sfp15_tx_fault_ch2", 17 }
"""

for line in content.splitlines():
    if not line: continue
    print(f"""{line[0:line.index('D')]}{line[line.index('"') + 1:line.rindex('"')].upper()}{line[line.index(','):]}""")
