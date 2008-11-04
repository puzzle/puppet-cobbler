#!/usr/bin/python

import sys
from cobbler import api

cobbler_api = api.BootAPI()
systems = cobbler_api.systems()
boxes = systems.find(netboot_enabled="True",return_list=True)
f=open('/etc/puppet/autosign.conf', 'w')
for box in boxes:
    f.write(box.interfaces["intf0"]["hostname"]+"\n")
f.close()
