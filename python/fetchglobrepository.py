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

"""using python ssh to execute command on linux and retrieve a zip accordingly"""

import paramiko
import time
import rule
import queue
import threading
import subprocess
import sys

serverip = "172.24.213.197"
serverport = 22
sshuser = 'yongwu'
sshpassword = 'Work1903'
archive = '/home/yongwu/project.zip'
fciv = r'c:\Tools\fciv.exe'
targetfolder = r'c:\Repository/'

dummyoutput = '--dummy output, since there is no actual output currently--'

def executecmd(cmd):
    shell.send(cmd + '\n')
    outputs = []
    while True:
        output = results.get()
        if output == dummyoutput:
            results.task_done()
            break

        outputs.append(output)
        results.task_done()

    return outputs

def executeandecho(cmd):
    print('\n'.join(executecmd(cmd)))

def getmd5(message):
    return rule.first(message.split('\n'), [rule.Regex('\w{32}')]).split()[0]

def fetchoutput():
    output = ''
    while not finished:
        while not shell.recv_ready() and not finished:
            time.sleep(1)

        output += shell.recv(9999).decode('utf-8')
        outputs = output.split('\n')
        last = None if output.endswith('\n') else -1
        [results.put(output) for output in outputs[:last]]
        output = '' if not last else outputs[-1]

        if output.endswith('$'):
            results.put(dummyoutput)

finished = False
results = queue.Queue()

ssh = paramiko.SSHClient()
ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
ssh.connect(serverip, serverport, sshuser, sshpassword)
shell = ssh.invoke_shell()
time.sleep(1)

fetcher = threading.Thread(target=fetchoutput)
fetcher.start()

executeandecho('')
executeandecho('/bin/bash')
executeandecho('cdglob')
executeandecho('')
hglogs = executecmd('hg parents')

prefix = 'glob.' \
    + rule.Regex('[0-9.]+').searchgroup(rule.first(hglogs, [rule.Regex('^summary.*isr[0-9.]+')]) or ['isr 00.000']) \
    + '.' \
    + rule.Regex('changeset:[ ]+(\d+)').searchgroup(rule.first(hglogs, [rule.Regex('changeset.*\d+')]), 1)

print(f'ready to archive {prefix} ...')
executeandecho('')
executeandecho(f'hgarchive -p "{prefix}"')
executeandecho('')

archivetarget = targetfolder + f'{prefix}.zip'
md5source = getmd5('\n'.join(executecmd(f'md5sum {archive}')))

sftp = paramiko.SFTPClient.from_transport(shell.get_transport())
sftp.get(archive, archivetarget)

finished = True
ssh.close()
fetcher.join()

md5target = getmd5(subprocess.run([fciv, '-add', archivetarget, '-md5'], stdout=subprocess.PIPE, encoding='utf-8').stdout)
if md5source == md5target:
    print('file retrieved successfully')
else:
    print(f'file retrieved with error: source({md5source}), target({md5target})')

print('------------------------------------------------------------------------------')
print("-process {} done!!!-".format(__file__))
print('------------------------------------------------------------------------------')
