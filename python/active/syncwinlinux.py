import os
import sys
sys.path.insert(1, r'D:\Repository\se-tricks\python')

import json
import rule

with open('config.json') as configfile:
    config = json.load(configfile)

print(config)

omcilines = []
rawlines = []
requestflag = rule.Regex(r'<OMCI MSG> Tx --> OntId\(')
omcicontent = rule.ForwardRegexGroup(rule.Regex(r'([0-9a-f]{2} ){8}'), 0)
omcidetected = False

source = config['source']
destination = config['destination']
if len(destination) < 1:
    destination = source + '.omci'

with open(source, 'r') as sourcefile, open(destination, 'w') as destfile:
    for line in sourcefile:
        if omcidetected:
            rawlines.append(line)
            if omcicontent.search(line):
                omcilines.append(omcicontent.result().replace(' ', ''))
                if len(omcilines) == 5:
                    omcifound = '//' + '//'.join(rawlines[:-5]) \
                                     + config['prefix'] \
                                     + ''.join(omcilines) \
                                     + '\n\n\n'

                    if any(pattern in omcifound for pattern in config['match']) \
                            and not any(pattern in omcifound for pattern in config['filter']):
                        destfile.write(omcifound)

                    omcidetected = False
                    omcilines = []
                    rawlines = []
        else:
            if requestflag.search(line):
                omcidetected = True
                rawlines.append(line)

print("process {} done!!!".format(__file__))
input()

