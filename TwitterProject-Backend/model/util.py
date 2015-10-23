#!/usr/bin/python
# -*- coding: utf-8 -*-
# $File: util.py
# $Date: Sat Jul 04 14:42:03 2015 +0800
# $Author: He Zhang <mattzhang9[at]gmail[at]com>


from tm import get_db
from config import *
from util import *

from flask import request
from functools import wraps

from flask_wtf import Form
from wtforms.fields import *
from wtforms.validators import *
from wtforms.validators import ValidationError

import pytz

from mongoengine import signals, Q
import mongoengine

db = get_db()


@classmethod
def _get_one(cls, *args, **kwargs):
    try:
        # print args, kwargs
        objs = cls.objects(*args, **kwargs)
        # print objs
        if len(objs) == 0:
            return None
        if len(objs) > 1:
            raise RuntimeError((
                "{}.get_one failed: more than one object with" +
                "  query:\n" +
                "    {}\n" +
                "    {}\n").format(cls.__name__, args, kwargs))
        return objs[0]
    except mongoengine.errors.ValidationError:
        return None
    except RuntimeError:
        return None


setattr(db.Document, 'get_one', _get_one)


def _save_update_timestamp(self, *args, **kwargs):
    if not self.creation_time:
        self.creation_time = datetime_now_local()
    self.modification_time = datetime_now_local()

    self.save(*args, **kwargs)

setattr(db.Document, 'save_update_timestamp', _save_update_timestamp)


@classmethod
def _increase(cls, id, name, delta=1, save=True):
    if isinstance(id, basestring):
        entity = cls.get_one(id=id)
    else:
        entity = id
    orig = getattr(entity, name)
    setattr(entity, name, orig + delta)
    if save:
        entity.save()
    return entity


def _instance_increase(self, name, delta=1):
    orig = getattr(self, name)
    setattr(self, name, orig + delta)
    return self


setattr(db.Document, 'increase', _increase)
setattr(db.Document, 'instance_increase', _instance_increase)


def create_bulk_signal_handler(func):
    """
    Create bulk handler for function
    """
    @wraps(func)
    def handler(sender, documents, **kwargs):
        for document in documents:
            func(sender, document, **kwargs)

    func.__dict__['bulk'] = handler

    return func


@create_bulk_signal_handler
def update_timestamp(sender, document, **kwargs):
    """
    Update the time when create or modify.
    """
    if not document.creation_time:
        document.creation_time = datetime_now_local()
    document.modification_time = datetime_now_local()
