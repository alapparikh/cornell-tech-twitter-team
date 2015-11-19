#!/usr/bin/python
# -*- coding: utf-8 -*-
# $File: tweets.py
# $Date: 2015-11-19 18:03
# $Author: Matt Zhang <mattzhang9[at]gmail[dot]com>

from util import *
from tw import *

app = get_app()
db = get_db()

class Tweets(db.Document):
    keyword = db.StringField(required=True)
    tw = db.ListField()

    def __init__(self, *args, **kwargs):
        super(Tweets, self).__init__(*args, **kwargs)
