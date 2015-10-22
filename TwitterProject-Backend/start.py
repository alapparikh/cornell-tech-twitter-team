#!manage/exec-in-virtualenv.sh
# -*- coding: utf-8 -*-
# $File: start.py
# $Date: Thu May 28 18:02:14 2015 +0800
# $Author: He Zhang <mattzhang9[at]gmail[dot]com>

from tw import get_app
import api
#import test

app = get_app()

@app.route('/')
def hello():
    return 'hello'

def main():
    app.run(app.config['HOST'], app.config['PORT'], debug = True)


if __name__ == '__main__':
    main()
