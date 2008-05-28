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

class cobbler {

    # include other modules needed
    include dhcpd 
    include tftp
    include apache
    
    include cobbler::base
}

class cobbler::base {
    package{'cobbler':
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

    # deploy all config files
    cobbler::etconfig{  [ "default.ks", "dhcp.template", "dnsmasq.template", "legacy.ks", 
                          "modules.conf", "named.template", "pxedefault.template", 
                          "pxeprofile.template", "pxesystem_ia64.template", 
                          "pxesystem.template", "rsync.exclude", "sample_end.ks", "sample.ks", 
                          "settings", "users.conf", "users.digest", "webui-cherrypy.cfg", 
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
