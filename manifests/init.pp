#
# cobbler module
#
# Copyright 2008, Puzzle ITC
# Marcel Härry haerry+puppet(at)puzzle.ch
# Simon Josi josi+puppet(at)puzzle.ch
#
# This program is free software; you can redistribute 
# it and/or modify it under the terms of the GNU 
# General Public License version 3 as published by 
# the Free Software Foundation.
#
#
# Variables to set:
# - $cobbler_auth_conf_pwd => your password to the auth_config

# modules_dir { \"cobbler\": }

import 'dhcpd.pp'

class cobbler {

    # include other modules needed
    include dhcpd::cobbler
    include tftp
    include apache
    
    include cobbler::base
}

class cobbler::base {
    package{ [ 'cobbler', 'yum-utils' ]:
        ensure => present,
    }
    service{cobblerd:
        ensure => running,
        enable => true,
        hasstatus => true,
        require => Package[cobbler],
    }

    file{'/etc/cron.daily/cobbler_reposync':
        source => "puppet://$server/cobbler/cron/cobbler_reposync",
        require => Package['yum-utils'],
        owner => root, group => 0, mode => 0644;
    }

    file{'/etc/httpd/conf.d/cobbler.conf':
        source => [ "puppet://$server/files/cobbler/httpd/${fqdn}/cobbler.conf",
                    "puppet://$server/files/cobbler/httpd/cobbler.conf",
                    "puppet://$server/cobbler/httpd/cobbler.conf" ],
        require => Package[apache],
        notify => Service[apache],
        owner => root, group => 0, mode => 0644;
    }
    
    file{'/etc/httpd/conf.d/cobbler_svc.conf':
        source => [ "puppet://$server/files/cobbler/httpd/${fqdn}/cobbler_svc.conf",
                    "puppet://$server/files/cobbler/httpd/cobbler_svc.conf",
                    "puppet://$server/cobbler/httpd/cobbler_svc.conf" ],
        require => Package[apache],
        notify => Service[apache],
        owner => root, group => 0, mode => 0644;
    }

    case $cobbler_auth_conf_pwd {
        '': { fail("You need to define the cobbler_auth_conf_pwd variable to set a password!") }
    }
    file{'/etc/cobbler/auth.conf':
        content => template("cobbler/auth.conf.erb"),
        require => Package[cobbler],
        notify => Service[cobblerd],
        owner => root, group => 0, mode => 0644;
    }  

    # deploy all config files and ensure that there is no other unmanaged config
    file{'/etc/cobbler':
        source => "puppet://$server/cobbler/empty",
        purge => true,
        recurse => true,
        owner => root, group => 0, mode => 0755;
    }
    cobbler::etcconfig{  [ "default.ks", "dhcp.template", "dnsmasq.template", 
                          "modules.conf", "named.template", "pxedefault.template", 
                          "pxeprofile.template", "pxesystem_ia64.template", 
                          "pxesystem.template", "rsync.exclude", "settings", 
                          "users.conf", "users.digest", "webui-cherrypy.cfg", 
                          "zone.template" ] : 
    } 
}

define cobbler::etcconfig(){
    file{"/etc/cobbler/${name}":
        source => [ "puppet://$server/files/cobbler/etc/${fqdn}/${name}",
                    "puppet://$server/files/cobbler/etc/${name}",
                    "puppet://$server/cobbler/etc/${name}" ],
        require => Package[cobbler],
        notify => Service[cobblerd],
        owner => root, group => 0, mode => 0644;
    }
}
