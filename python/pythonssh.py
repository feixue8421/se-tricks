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

"""using pyinstaller to make "py" to windows image"""

import paramiko
import time
import rule

ssh = paramiko.SSHClient()
ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
ssh.connect("135.251.206.205", 22, 'yongwu', 'Work201809')
shell = ssh.invoke_shell()

def getoutput(cmd):
    shell.send(cmd + '\n')

    result = ''
    while True:
        while not shell.recv_ready():
            time.sleep(1)

        result += shell.recv(9999).decode('utf-8')
        if result.endswith('$'):
            break

    return result.split('\n')

getoutput('/bin/bash')
getoutput('cdglob')
hglogs = getoutput('hg log -l 10 -b .')

prefix = 'glob.' \
    + rule.Regex('[0-9.]+').searchgroup(rule.first(hglogs, [rule.Regex('^summary.*isr[0-9.]+')])) \
    + '.' \
    + rule.Regex('\d{4}').searchgroup(rule.first(hglogs, [rule.Regex('changeset.*\d{4}')]))

print(f'ready to archive {prefix} ...')
getoutput(f'hgarchive -p "{prefix}"')

sftp = paramiko.SFTPClient.from_transport(shell.get_transport())
sftp.get('/home/yongwu/project.zip', f'{prefix}.zip')

ssh.close()

print('------------------------------------------------------------------------------')
print("-process {} done!!!-".format(__file__))
print('------------------------------------------------------------------------------')
