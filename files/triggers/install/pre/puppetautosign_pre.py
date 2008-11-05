#!/usr/bin/python

import sys
from cobbler import api

cobbler_api = api.BootAPI()
systems = cobbler_api.systems()
box = systems.find(sys.argv[2])
if box!=None:
    f=open('/etc/puppet/autosign.conf', 'a')
    f.write(box.interfaces["intf0"]["hostname"]+"\n")
    f.close()
