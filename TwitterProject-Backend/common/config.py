
#!/usr/bin/python2
# -*- coding: utf-8 -*-
# $File: config.py
# $Date: Sun May 31 22:13:31 2015 +0800
# $Author: He Zhang <mattzhang9[at]gmail[dot]com>


from pytz import timezone


#Variables that contains the user credentials to access Twitter API 
Taccess_token = "553946988-eHSrOa4LjhkYtzf1YZI8quJ8TUGcYMonwLk46dcl"
Taccess_token_secret = "Dx4hbdGULvF5BCbCauvS5qUdc2DZb8w5fYsWM6CMHOnjv"
Tconsumer_key = "iTu865KvVPOMVrpuIAKupH78k"
Tconsumer_secret = "jvQXjdWUvIUuoZJLzoGgWQe7sK6NaWS4XIGVWdAUdumuqPNghj"


TIMEZONE = timezone('US/Eastern')

USERNAME_LEN_MIN = 1
USERNAME_LEN_MAX = 23

PASSWORD_LEN_MIN = 1
PASSWORD_LEN_MAX = 23

UNIVERSITY_LEN_MAX = 23
MAJOR_LEN_MAX = 10
TITLE_LEN_MAX = 10
AGE_LEN_MAX = 10
NOTE_LEN_MAX = 20
PLACE_LEN_MAX = 20
MEETING_TITLE_LEN_MAX = 20

COMPANY_LEN_MAX = 12
POSITION_LEN_MAX = 6


QINIU_ACCESS_KEY = 'uIE-mqGE4wKE8Jjaq4tNL3mjuDlCrMYM-UmbLamx'
QINIU_SECRET_KEY = 'urdL-PfXqdHIULLdQsj6zhlNGT5MIf3AWpPW1RPo'
QINIU_AVATAR_BUCKET = 'sixdegreecoffeeavatartest'
QINIU_AVATAR_SIZE_LIMIT = 10000000
QINIU_AVATAR_MIME_LIMIT = 'image/*'
QINIU_AVATAR_TIMEOUT = 600
QINIU_AVATAR_URL = 'http://7xj1fj.com1.z0.glb.clouddn.com/{}'


USER_INFO_UPDATE_WHITE_LIST = ("sex username major university title age note location")

class _DefaultConfig(object):
    HOST = '0.0.0.0'
    PORT = 54321

    OPTIONS = {'debug': True}

    MONGODB_SETTINGS = {
        'DB': 'tw',
        'HOST': 'localhost',
        'PORT': 27017,
    }

app_config = _DefaultConfig()
