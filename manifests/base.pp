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

  file{'/etc/httpd/conf.d/cobbler.conf':
    source => [ "puppet:///modules/site-cobbler/${fqdn}/httpd/cobbler.conf",
                "puppet:///modules/site-cobbler/httpd/cobbler.conf",
                "puppet:///modules/cobbler/httpd/cobbler.conf" ],
    require => Package[apache],
    notify => Service[apache],
    owner => root, group => 0, mode => 0644;
  }
   file{'/etc/httpd/conf.d/cobbler_svc.conf':
    source => [ "puppet:///modules/site-cobbler/${fqdn}/httpd/cobbler_svc.conf",
                "puppet:///modules/site-cobbler/httpd/cobbler_svc.conf",
                "puppet:///modules/cobbler/httpd/cobbler_svc.conf" ],
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
  file{ ['/etc/cobbler', '/etc/cobbler/pxe', '/etc/cobbler/power', '/etc/cobbler/reporting',
      '/etc/cobbler/zone_templates', '/var/lib/cobbler/kickstarts' ]:
    ensure => directory,
    source => "puppet:///modules/common/empty",
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
 
  cobbler::kickstartfile{ ['default.ks', 'legacy.ks', 'pxerescue.ks', 'sample_end.ks',
                           'sample.ks', 'sample.seed' ]:
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
