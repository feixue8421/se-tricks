#!/usr/bin/env python
#
# Copyright 2021 feixue
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

"""show fpga register"""

from itertools import groupby

register = 0x007010c
value = 0x114

registers = {
    "ICB_PONFAIL_EVENT_LTOBC" : (0x0070104, ['8ponfail_tx_fail_ltobc:\t0', '7ponfail_light_seen_ltobc:\t0', '6ponfail_send_fail_ltobc:\t0', '5ponfail_kill_laser_ltobc:\t0', '4ponfail_nios_timeout_ltobc:\t0', '3ponfail_los_hold_ltobc:\t0', '2ponfail_los_ltobc:\t0', '1ponfail_los_fe_ltobc:\t0', '0ponfail_los_re_ltobc:\t0']),
    "ICB_PONFAIL_ENABLE_LTOBC": (0x007010C, ['8ponfail_tx_fail_ltobcM:\t0', '7ponfail_light_seen_ltobcM:\t0', '6ponfail_send_fail_ltobcM:\t0', '5ponfail_kill_laser_ltobcM:\t0', '4ponfail_nios_timeout_ltobcM:\t0', '3ponfail_los_hold_ltobcM:\t0', '2ponfail_los_ltobcM:\t0', '1ponfail_los_fe_ltobcM:\t0', '0ponfail_los_re_ltobcM:\t0'])
}

if register not in registers:
    for name, offset in registers.items():
        if register == offset[0]:
            register = name

mask = registers[register][1]
print(f'register: \t{register}')
print(f'offset: \t0x{registers[register][0]:x}')

print(f'value: \t\t0x{value:x}')
value = f'{value:0>32b}'
print(f'binary: \tB{value}')
print(f'field:')
for item in mask:
    fields = [''.join(list(g)) for _, g in groupby(item, key = lambda x: x.isdigit())]
    print(f'\t{value[::-1][int(fields[0])]}\t{fields[1].strip().ljust(30)}[default: {fields[2]}]')

print('------------------------------------------------------------------------------')
print("-process {} done!!!-".format(__file__))
print('------------------------------------------------------------------------------')
