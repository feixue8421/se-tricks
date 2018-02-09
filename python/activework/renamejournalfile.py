import os
import sys
sys.path.insert(1, r'D:\github\se-tricks\python')

import rule
import common

jrnfolder = r'D:\working\JiangXi\江西农信20170811数据\00002597'

jrndate = rule.Regex(r'2017-[0-9]{2}-[0-9]{2}')

for jrn in common.get_files(jrnfolder, '.jrn'):
    jrnwithdate = jrn
    with open(jrn) as jrnfile:
        for line in jrnfile:
            if jrndate.search(line):
                jrnwithdate = jrndate.result(0) + '.jrn'
                break
    os.rename(jrn, os.path.join(jrnfolder, jrnwithdate))

print("done!!!")
