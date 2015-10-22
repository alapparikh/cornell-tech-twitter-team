#!/usr/bin/python
# -*- coding: utf-8 -*-
# $File: tweets.py
# $Date: 2015-10-22 16:58
# $Author: Matt Zhang <mattzhang9[at]gmail[dot]com>

import model
from flask import request, jsonify, g
from tw import get_app

app = get_app()

@app.route('/hellos')
def hsd():
    return jsonify(hello=1)
