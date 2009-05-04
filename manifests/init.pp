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

import 'dhcpd.pp'
import 'bind.pp'

class cobbler {
    # include other modules needed
    include dhcpd::cobbler
    include bind::base::cobbler::managed
    include tftp
    include apache

    include cobbler::base
}

class cobbler::base {
    package{ [ 'cobbler', 'yum-utils', 'python-ldap', 'rhpl', 'genisoimage', 'syslinux' ]:
        ensure => present,
    }
    service{cobblerd:
        ensure => running,
        enable => true,
        hasstatus => true,
        require => Package[cobbler],
    }

    file{'/etc/cron.d/cobbler_reposync':
        source => [ "puppet://$server/files/cobbler/cron/${fqdn}/cobbler_reposync",
                    "puppet://$server/files/cobbler/cron/cobbler_reposync",
                    "puppet://$server/cobbler/cron/cobbler_reposync" ],
        require => Package['yum-utils'],
        owner => root, group => 0, mode => 0744;
    }

    file{'/etc/httpd/conf.d/cobbler.conf':
        source => [ "puppet://$server/files/cobbler/${fqdn}/httpd/cobbler.conf",
                    "puppet://$server/files/cobbler/httpd/cobbler.conf",
                    "puppet://$server/cobbler/httpd/cobbler.conf" ],
        require => Package[apache],
        notify => Service[apache],
        owner => root, group => 0, mode => 0644;
    }
     file{'/etc/httpd/conf.d/cobbler_svc.conf':
        source => [ "puppet://$server/files/cobbler/${fqdn}/httpd/cobbler_svc.conf",
                    "puppet://$server/files/cobbler/httpd/cobbler_svc.conf",
                    "puppet://$server/cobbler/httpd/cobbler_svc.conf" ],
        require => Package[apache],
        notify => Service[apache],
        owner => root, group => 0, mode => 0644;
    }

    case $cobbler_auth_conf_pwd {
        '': { fail("You need to define the cobbler_auth_conf_pwd variable on ${fqdn} to set a password!") }
    }
    file{'/etc/cobbler/auth.conf':
        content => template('cobbler/auth.conf.erb'),
        require => Package[cobbler],
        notify => [ Service[cobblerd], Exec['cobbler_sync'] ],
        owner => root, group => 0, mode => 0644;
    }

    # deploy all config files and ensure that there is no other unmanaged config
    file{ ['/etc/cobbler', '/etc/cobbler/pxe', '/etc/cobbler/power', '/etc/cobbler/reporting' ]:
        ensure => directory,
        source => "puppet://$server/cobbler/empty",
        purge => true,
        recurse => true,
        ignore => '\.ignore',
        notify => Exec['cobbler_sync'],
        owner => root, group => 0, mode => 0755;
    }
    cobbler::etcconfig{  [ 'default.ks', 'dhcp.template', 'dnsmasq.template',
                            'modules.conf', 'named.template', 'tftpd-rules.template',
                            'rsync.exclude', 'settings', 'users.conf', 'users.digest',
                            'webui-cherrypy.cfg', 'zone.template', 'cheetah_macros', 'acls.conf',
                            # pxe/
                            'pxe/pxedefault.template',  'pxe/pxelocal.template',
                            'pxe/pxesystem_ppc.template', 'pxe/pxesystem_s390x.template',
                            'pxe/pxeprofile.template', 'pxe/pxesystem_ia64.template',
                            'pxe/pxesystem.template',
                            # power/
                            'power/power_apc_snmp.template', 'power/power_bladecenter.template',
                            'power/power_bullpap.template', 'power/power_drac.template',
                            'power/power_ether_wake.template', 'power/power_ilo.template',
                            'power/power_ipmilan.template', 'power/power_ipmitool.template',
                            'power/power_lpar.template', 'power/power_rsa.template',
                            'power/power_virsh.template', 'power/power_wti.template',
                            # reporting
                            'reporting/build_report_email.template' ]:
    }

    file{'/var/lib/cobbler/snippets':
        source => [ "puppet://$server/files/cobbler/${fqdn}/snippets",
                    "puppet://$server/files/cobbler/${cobbler_env}/snippets",
                    "puppet://$server/files/cobbler/snippets/default",
                    "puppet://$server/cobbler/snippets" ],
        purge => true,
        recurse => true,
        notify => [ Exec['cobbler_sync'], Service['cobblerd'] ],
        owner => root, group => 0, mode => 0644,
    }

    exec{'cobbler_sync':
        command => 'cobbler sync',
        refreshonly => true,
        require => Package['cobbler', 'genisoimage', 'syslinux'],
    }
}

define cobbler::etcconfig(){
    case $cobbler_env {
        '': { $cobbler_env = 'cobbler_env_is_not_set' }
    }

    file{"/etc/cobbler/${name}":
        source => [ "puppet://$server/files/cobbler/${fqdn}/etc/${name}",
                    "puppet://$server/files/cobbler/${cobbler_env}/etc/${name}",
                    "puppet://$server/files/cobbler/etc/${name}",
                    "puppet://$server/cobbler/etc/${name}" ],
        require => Package[cobbler],
        notify => [ Service[cobblerd], Exec['cobbler_sync'] ],
        owner => root, group => 0, mode => 0644;
    }
}
