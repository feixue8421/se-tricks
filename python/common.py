#!/usr/bin/env python3
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

"""This module provides common functions."""

import os

# functions for files

def make_writeable(file):
    """description: make file writeable.
    input:
        file: a full path to be operated with.
    ouput: None.
    exception:
        file not exist exception.
    """
    if not file or not os.path.exists(file):
        raise Exception('make_writeable: invalid file name or file does not exist, file <%s>' % file if file else "")
    os.chmod(file, stat.S_IWRITE)

def get_files(folder, extension = None, sensitive = False, recursive = False):
    """description: get files in the specified folder.
    input:
        folder: a full path to be operated with.
        extension: the returned file shall have the specified extension.
        sensitive: specifies whether the extension check is case-sensitive.
        recursive: specifies whether the search is recursive.
    ouput: list of files with full path.
    exception: None.
    """
    if recursive:
        return _get_files_recursive(folder, extension, sensitive)

    return [os.path.join(folder, file) for file in os.listdir(folder) if not os.path.isdir(os.path.join(folder, file)) and _chk_file_ext(file, extension, sensitive)]

def _chk_file_ext(file, extension, sensitive):
    return file if not extension or (file.endswith(extension) if sensitive else file.upper().endswith(extension.upper())) else None

def _get_files_recursive(folder, extension, sensitive):
    abs_files = []

    # to support folders with symbolic links, the "followlinks" of "os.walk" shall be set to "True"
    for dir, folders, files in os.walk(folder):
        abs_files.extend(os.path.join(dir, file) for file in files if _chk_file_ext(file, extension, sensitive))

    return abs_files
