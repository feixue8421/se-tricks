import os
import sys
import unittest

class TestGenerator(object):
    module_template = """
import unittest
import {module} as {alias}

class Test{alias}(unittest.TestCase):

{cases}

"""

    case_template = """
    def test_{case}(self):
{action}

"""

    test_module = {'module': '', 'alias': '', 'cases': ''}

    def retrieve(self, module):
        mods = []
        mod = os.path.dirname(module)

        while os.path.exists(os.path.join(mod, '__init__.py')):
            mods.append(os.path.basename(mod))
            mod = os.path.dirname(mod)

        alias = os.path.basename(module)[:-3]
        mods.reverse()
        mods.append(alias)

        self.test_module['module'] = '.'.join(mods)
        self.test_module['alias'] = alias + '_RAT'

    def trim(self, row):
        if 'print ' in row and ' # ' in row:
            row = row.replace('print ', 'self.assertEqual(').replace(' # ', ', ').rstrip() + ')\n'

        return row

    def write(self, cases):
        self.test_module['cases'] = ''.join(cases)
        with open('test_%s.py' % (self.test_module['alias']), 'w') as dest:
            dest.write(self.module_template.format(**self.test_module))

        self.test_module['cases'] = None

    def caseid(self, caseid, line):
        if line.startswith('class '):
            caseid = line[len('class ') : line.find('(')]

        return caseid

    def generate(self, module):
        self.retrieve(module)
        cases = []
        with open(module, 'r') as source:
            rows = []
            flag = False
            caseid = ''
            for line in source:
                caseid = self.caseid(caseid, line)
                if flag:
                    if '"""' in line:
                        action = ''.join(map(self.trim, rows))
                        case = {'case': caseid, 'action': action.replace(caseid, self.test_module['alias'] + '.' + caseid)}
                        cases.append(self.case_template.format(**case))
                        rows = []
                        flag = False
                        caseid = ''
                    else:
                        rows.append(line)
                else:
                    if 'Sample:' in line:
                        flag = True

        if cases:
            self.write(cases)

    def discover(self, location):
        from utility.common import get_files
        map(self.generate, get_files(location, '.py'))

if __name__ == '__main__':
    sys.path.append("c:\\work\\feixue\\python")
    if 'update' in sys.argv:
        TestGenerator().discover("c:\\work\\feixue\\python\\utility")
    unittest.TextTestRunner(verbosity=2).run(unittest.TestLoader().discover(os.path.dirname(__file__)))
