#!/usr/bin/python
# -*- coding: utf-8 -*-
# $File: util.py
# $Date: 2015-03-12 14:42
# $Author: He Zhang <mattzhang9[at]gmail[at]com>


import unittest
from collections import namedtuple
from functools import wraps
from model import *
from faker import Factory
import json
import random

import requests as req

from coffeeconfig import app_config

API_HOST = app_config.HOST
API_PORT = app_config.PORT
PROTOCOL = 'http'

faker = Factory.create('zh-CN')

class APITestCaseBase(unittest.TestCase):

    api_url_prefix = '/api'
    url_base = "{}://{}:{}{}" . format(
        PROTOCOL, API_HOST, API_PORT,
        api_url_prefix)

    def get(self, url, data={}):
        """a GET request to url with data.
        url is a location relative to root, e.g '/sample'
        return: json data"""
        
        headers = {'content-type': 'application/json'}
        response = req.get(self._url(url), params=data, auth = (self.getToken(), ' '), headers=headers)
        return response.json()

    def post(self, url, data={}):
        """a POST request to url with data.(post)
        url is a location relative to root, e.g '/add_tab'
        return: json data
        """
        headers = {'content-type': 'application/json'}
        response = req.post(self._url(url), data=json.dumps(data), auth=(self.getToken(), ' '), headers=headers)

        return response.json()

    def getToken(self):
        headers = {'content-type': 'application/json'}
        resp = req.get(self._url('/user/token'), auth=(self.user.phone, self.user.password_hash), headers=headers)
        return resp.json()['token']
        

    def _url(self, url):
        return self.url_base + url



    def assertSucceed(self, res):
        self.assertEqual(res['success'], '1')

    def assertError(self, res):
        self.assertEqual(res['success'], '0')

    def register(self, user):
        headers = {'content-type': 'application/json'}
        return req.post(self._url('/user/register'), 
                        data=json.dumps({'phone':user.phone,
                                        'pwd':user.password_hash}),
                        headers=headers).json()

    def setUp(self):
        self.user = fake_user()
        self.register(self.user)

    def tearDown(self):
        # Delete the may not be saved user
        udummy=User.get_one(phone=self.user.phone)
        udummy.delete()


def fake_user():
    # It shouldn't be password_hash. It should be password.
    password_hash = '12345'
    user = User(
        username=faker.user_name(),
        password_hash=password_hash,
        sex=Sex.male,
        phone=faker.phone_number(),
        university=faker.company(),
    )
    return user
