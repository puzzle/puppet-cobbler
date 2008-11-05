#!/usr/bin/python

import sys
from cobbler import api

cobbler_api = api.BootAPI()
systems = cobbler_api.systems()
box = systems.find(sys.argv[2])
if box!=None:
    f=open('/etc/puppet/autosign.conf', 'r')
    boxes=f.readlines()
    f.close
    f=open('/etc/puppet/autosign.conf', 'w')
    for oldbox in boxes:
        if box.interfaces["intf0"]["hostname"]!=oldbox.rstrip('\n'):
            f.write(oldbox)
    f.close()
