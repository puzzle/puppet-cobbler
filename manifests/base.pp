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
}
