#!/usr/bin/python

import sys
from cobbler import api

cobbler_api = api.BootAPI()
box = cobbler_api.systems().find(name=sys.argv[2])
if box!=None:
    f=open('/etc/puppet/autosign.conf', 'r')
    boxes=f.readlines()
    f.close
    f=open('/puppet/autosign.conf', 'w')
    for oldbox in boxes:
        if box.interfaces["eth0"]["dns_name"]!=oldbox.rstrip('\n'):
            f.write(oldbox)
    f.close()
