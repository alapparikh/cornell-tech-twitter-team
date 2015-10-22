#!/usr/bin/python
# -*- coding: utf-8 -*-
# $File: coffeeutil.py
# $Date: 2015-03-08 22:06
# $Author: He Zhang <mattzhang9[at]gmail[at]com>

"""common utility functions"""

from importlib import import_module
from pkgutil import walk_packages
from functools import wraps

import os
import re
import cgi
import new
import copy
import random
import datetime


from config import TIMEZONE


def get_all_methods(dirname, pkg_name):
    ret = dict()
    for _, module_name, _ in walk_packages([dirname], pkg_name + '.'):
        mod = import_module(module_name)
        for key, val in mod.__dict__.iteritems():
            ret[key] = val
    return ret


def import_all_modules(file_path, pkg_name, import_to_globals=None):
    """import all modules recursively in a package
    :param file_path: just pass __file__
    :param pkg_name: just pass __name__
    :param import_to_globals: a dict of globals()
    """
    for _, module_name, _ in walk_packages(
            [os.path.dirname(file_path)], pkg_name + '.'):
        mod = import_module(module_name)
        if import_to_globals:
            for key, val in mod.__dict__.iteritems():
                # print("{}.{}".format(module_name,key))
                import_to_globals[key] = val


def enum(*sequential, **named):
    """defined a `enum' class similar to that in c++"""

    # string -> int
    enums = dict(zip(sequential, range(len(sequential))), **named)
    # all stored as unicode
    enums = dict(map(lambda x: (unicode(x[0]), x[1]), enums.iteritems()))

    reverse = dict((value, key) for key, value in enums.iteritems())
    cls_dict = copy.deepcopy(enums)
    cls_dict['enums'] = copy.deepcopy(enums)
    cls_dict['reverse_mapping'] = reverse
    cls_dict['values'] = enums.values()
    cls_dict['value_to_names'] = dict((b, a) for a, b in enums.iteritems())

    def __getitem__(self, key):  # number -> number
        return self.values[key]

    def get_name_by_value(self, value):
        return self.value_to_names[value]

    def get_value_by_name(self, key):
        return self.enums[key]

    cls_dict['__getitem__'] = __getitem__
    cls_dict['get_value_by_name'] = get_value_by_name
    cls_dict['get_name_by_value'] = get_name_by_value
    cls = type('Enum', (), cls_dict)

    return cls()


re_string = None


def datetime_now_local(tzinfo=TIMEZONE):
    return datetime.datetime.now(tzinfo)


def str_object_id(obj):
    return str(obj._data['id'])


class abstractclassmethod(classmethod):
    """A decorator indicating abstract classmethods.

    Similar to abstractmethod.

    Usage:

        class C(metaclass=ABCMeta):
            @abstractclassmethod
            def my_abstract_classmethod(cls, ...):
                ...
    """

    __isabstractmethod__ = True

    def __init__(self, callable):
        callable.__isabstractmethod__ = True
        super(abstractclassmethod, self).__init__(callable)


class abstractstaticmethod(staticmethod):
    """A decorator indicating abstract staticmethods.

    Similar to abstractmethod.

    Usage:

        class C(metaclass=ABCMeta):
            @abstractstaticmethod
            def my_abstract_staticmethod(...):
                ...
    """

    __isabstractmethod__ = True

    def __init__(self, callable):
        callable.__isabstractmethod__ = True
        super(abstractstaticmethod, self).__init__(callable)


class abstractproperty(property):
    """A decorator indicating abstract properties."""


def random_date(start, end):
    """
    This function will return a random datetime between two datetime
    objects.
    """
    delta = end - start
    int_delta = (delta.days * 24 * 60 * 60) + delta.seconds
    random_second = random.randrange(int_delta)
    return start + datetime.timedelta(seconds=random_second)


def random_date_between_year(begin, end):
    d1 = datetime.datetime.strptime(
        '1/1/{} 00:00'.format(begin), '%m/%d/%Y %H:%M')
    d2 = datetime.datetime.strptime(
        '1/1/{} 00:00'.format(end), '%m/%d/%Y %H:%M')
    return random_date(d1, d2)


# vim: foldmethod=marker
