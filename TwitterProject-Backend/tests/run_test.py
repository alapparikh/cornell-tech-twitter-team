#!../manage/exec-in-virtualenv.sh
# -*- coding: utf-8 -*-
# $File: run_test.py
# $Date: 2015-03-13 10:50
# $Author: He Zhang <mattzhang9[at]gmail[at]com>

from importlib import import_module
from pkgutil import walk_packages
import os
import sys
import unittest

from testcases import *


if __name__ == '__main__':
    unittest.main(verbosity=2, argv=[sys.argv[0]], exit=False)
