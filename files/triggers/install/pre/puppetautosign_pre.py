#!/usr/bin/python

import sys
from cobbler import api

cobbler_api = api.BootAPI()
box = cobbler_api.systems().find(name=sys.argv[2])
if box!=None:
    f=open('/etc/puppet/autosign.conf', 'a')
    f.write(box.interfaces["eth0"]["dns_name"]+"\n")
    f.close()
