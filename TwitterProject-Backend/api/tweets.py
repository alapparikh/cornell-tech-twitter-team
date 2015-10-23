#!/usr/bin/python
# -*- coding: utf-8 -*-
# $File: tweets.py
# $Date: 2015-10-22 16:58
# $Author: Matt Zhang <mattzhang9[at]gmail[dot]com>

import model
from flask import request, jsonify, g
from tw import get_app
from TwitterSearch import *
from common import *
app = get_app()

@app.route('/search/<name>')
def hsd(name):
    #req = request.json
    #name = req['name']
    try:
        tso = TwitterSearchOrder() # create a TwitterSearchOrder object
        tso.set_language('en')
        tso.set_keywords([name]) # let's define all words we would like to have a look for
        tso.set_include_entities(False) # and don't give us all those entity information

        # it's about time to create a TwitterSearch object with our secret tokens
        ts = TwitterSearch(
            consumer_key = Tconsumer_key,
            consumer_secret = Tconsumer_secret,
            access_token = Taccess_token,
            access_token_secret = Taccess_token_secret
         )

         # this is where the fun actually starts :)
        ts.search_tweets(tso)
        r = ts.get_tweets()['statuses'][0:10]
        return jsonify(tweets=r)
    except TwitterSearchException as e: # take care of all those ugly errors if there are some
        print(e)
    return jsonify(error=1)
