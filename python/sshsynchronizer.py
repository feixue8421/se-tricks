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

"""using python ssh to upload/download files to/from linux server"""

import paramiko
import time
import rule
import queue
import threading
import subprocess
import sys
import os

serverip = "172.24.213.197"
serverport = 22
sshuser = 'yongwu'
sshpassword = 'Bell1908@'
localupload = r'c:\Repository\upload'
localdownload = r'c:\Repository\download'
remoteupload = r'/home/yongwu/upload'
remotedownload = r'/home/yongwu/download'

transport = paramiko.Transport((serverip, serverport))
transport.connect(username = sshuser, password = sshpassword)
time.sleep(1)

sftp = paramiko.SFTPClient.from_transport(transport)

# download from server
sftp.chdir(remotedownload)
list(map(lambda file: (sftp.get(file, os.path.join(localdownload, file)), sftp.remove(file)) , sftp.listdir()))

# upload to server
sftp.chdir(remoteupload)
list(map(lambda file: (sftp.put(os.path.join(localupload, file), file), os.remove(os.path.join(localupload, file))), os.listdir(localupload)))

transport.close()
print('------------------------------------------------------------------------------')
print("-process {} done!!!-".format(__file__))
print('------------------------------------------------------------------------------')
