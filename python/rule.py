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

"""Rule for text format and is used in "parser" module."""

import sys
import re
from datetime import datetime

class Param(object):
    """
    This class is used for parsing parameters in fixed format.
    Sample:
        params = Param.parse("name=hello index=3")

        print Param.get(params, "name", "default") # "hello"
        print Param.get(params, "index", 0) # 3
        print Param.get(params, "hello", 0) # 0
    """
    @staticmethod
    def parse(param):
        return dict(part.partition('=')[::2] for part in param.split())

    @staticmethod
    def get(params, param, value):
        if params.has_key(param):
            temp = params[param]
            if isinstance(value, int):
                value = int(temp)
            elif isinstance(value, str):
                value = str(temp)
            else:
                value = temp

        return value

class Rule(object):
    """
    Abstract class for rules. Used for parsing formatted text.
    """
    def __init__(self, rule):
        self._rule = rule
        self._result = None

    def search(self, content):
        return False

    def result(self):
        return self._result

    @staticmethod
    def match(content, rules):
        return any(rule.search(content) for rule in rules)

def match(contents, rules):
    return [content for content in contents if Rule.match(content, rules)]

def filter(contents, filters):
    return [content for content in contents if not filters or not Rule.match(content, filters)]

def analyze(files, rules, filters):
    result = []
    for file in files:
        with open(file, "r") as contents:
            result.extend(filter(match(contents, rules), filters))

    return result

class Regex(Rule):
    """
    Retrieve text using regual expression.
    Sample:
        rule = Regex(r"((<<<)|(>>>))")

        print rule.search(r"echo <<< hello world") # True
        print rule.result(0) # "<<<"
    """
    def __init__(self, rule):
        super(self.__class__, self).__init__(rule)
        self._rule = re.compile(self._rule)

    def search(self, content):
        self._result = self._rule.search(content)
        return True if self._result else False

class Fixed(Rule):
    """
    Retrive text using fixed position(index).
    Sample:
        rule = Fixed(r"start=3 count=2")

        rule.search(r"hello")
        print rule.result() # "lo"
    """
    def __init__(self, rule):
        super(self.__class__, self).__init__(rule)
        self._rule = Param.parse(self._rule)

    def search(self, content):
        start = Param.get(self._rule, 'start', 0)
        end = Param.get(self._rule, 'end', None)
        count = Param.get(self._rule, 'count', 0)
        if count > 0: end = start + count
        # return False if the "start" is not valid
        if start >= len(content): return False

        self._result = content[start : end]
        return True if len(self._result) > 0 else False

class Forward:
    def __init__(self, rule):
        self._rule = rule

    def search(self, content):
        return self._rule.search(content)

    def result(self):
        return self._rule.result()

class ForwardRegexGroup(Forward):
    def __init__(self, rule, idx):
        super(self.__class__, self).__init__(rule)
        self._idx = idx

    def result(self):
        return self._rule.result().group(self._idx)

"""
class RuleChain:
    def __init__(self):
        self._rules = []

    def push(self, rule, forward):
        self.rules.append((rule, forward))

    def pop(self):
        return self._rules.pop() if len(self._rules) > 0 else None

    def process(self, content):
        latestrule = None
        latestforward = None
        for rule, foward in self._rules:
            if latestrule != None:
                content = latestforward.forward()
            if rule.search()


        return None
"""


