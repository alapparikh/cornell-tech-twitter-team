#!/usr/bin/python2
# -*- coding: utf-8 -*-
# $File: __init__.py
# $Date: Sat Jan 3 16:18:47 2015 +0800
# $Author: He Zhang <mattzhang9[at]gmail[dot]com>

from coffeeutil import import_all_modules

import_all_modules(__file__, __name__, locals())

from coffee import get_db, get_app
from faker import Factory
from flask import request, jsonify
import json

faker = Factory.create('zh_CN')
faker_eng = Factory.create()

app = get_app()
mongo = get_db()

@app.route('/Test/Drop_DB', methods = ['POST'])
def drop():
    mongo.db.UserInfo.drop()
    return jsonify(status = 200)

@app.route('/Test/Fake_User', methods = ['POST'])
def fake_users():
    d = request.json
    users = []
    for i in xrange(d['nr_user']):
        user = {'uid': str(i),
                'pwd': str(i),
                'name': faker.name(),
                'title': faker.job(),
                'age': 21,
                'firstDegreeFriends': [],
                'secondDegreeFriends': [],
        'myPublishedMeetings': [], 'myParticipatedMeetings': [], 'firstDegreeMeetings': [], 'secondDegreeMeetings': []
                }
        users.append(user)
    mongo.db.UserInfo.insert(users)
    return jsonify(status = 200)

def main():
    drop_db()
    fake_users(5)

if __name__ == '__main__':
    main()
