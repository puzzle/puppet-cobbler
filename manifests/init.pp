#
# cobbler module
#
# Copyright 2008-2012, Puzzle ITC
# Marcel Härry haerry+puppet(at)puzzle.ch
# Simon Josi josi+puppet(at)puzzle.ch
#
# Update September 2012:
# For Cobbler Version 2.2.3, CentOS 6
# Simplified Definitions
# by Philipp Gassmann gassmann(at)puzzle.ch
#
# This program is free software; you can redistribute
# it and/or modify it under the terms of the GNU
# General Public License version 3 as published by
# the Free Software Foundation.

class cobbler(
  $env = 'cobbler_env_is_not_set'
){
  # include other modules needed
  include cobbler::bind::managed
  include tftp
  include apache
  include dhcpd::noreplace
  include git::base

  package{ [ 'cobbler', 'cobbler-web', 'genisoimage', 'pykickstart']:
    ensure => present,
  }

  service{cobblerd:
    ensure    => running,
    enable    => true,
    hasstatus => true,
    require   => Package[cobbler],
  }

  file{'/etc/httpd/conf.d/cobbler.conf':
    source  => [ "puppet:///modules/site_cobbler/${fqdn}/httpd/cobbler.conf",
                "puppet:///modules/site_cobbler/httpd/cobbler.conf",
                "puppet:///modules/cobbler/httpd/cobbler.conf" ],
    require => Package[apache],
    notify  => Service[apache],
    owner   => root, group => 0, mode => 0644;
  }

  # deploy all config files and ensure that there is no other unmanaged config

  file{ 
    '/etc/cobbler':
      ensure        => directory,
      purge         => true,
      recurse       => true,
      sourceselect  => all,
      source        => [ "puppet:///modules/site_cobbler/${fqdn}/etc",
                         "puppet:///modules/site_cobbler/${cobbler::env}/etc",
                         "puppet:///modules/site_cobbler/etc",
                         "puppet:///modules/cobbler/etc" ],
      notify        => [ Exec['cobbler_sync'], Service['cobblerd'] ],
      owner         => root, group => 0, mode => 0644;

    '/var/lib/cobbler/kickstarts/':
      require       => Package[cobbler],
      ensure        => directory,
      purge         => true,
      recurse       => true,
      sourceselect  => all,
      source        => [ "puppet:///modules/site_cobbler/${fqdn}/kickstarts",
                         "puppet:///modules/site_cobbler/${cobbler::env}/kickstarts",
                         "puppet:///modules/site_cobbler/kickstarts",
                         "puppet:///modules/cobbler/kickstarts" ],
      notify        => [ Exec['cobbler_sync'], Service['cobblerd'] ],
      owner         => root, group => 0, mode => 0644;

    '/var/lib/cobbler/snippets':
      ensure        => directory,
      purge         => true,
      recurse       => true,
      sourceselect  => all,
      source        => [ "puppet:///modules/site_cobbler/${fqdn}/snippets",
                         "puppet:///modules/site_cobbler/${cobbler::env}/snippets",
                         "puppet:///modules/site_cobbler/snippets/default",
                         "puppet:///modules/cobbler/snippets" ],
      notify        => [ Exec['cobbler_sync'], Service['cobblerd'] ],
      owner         => root, group => 0, mode => 0644;
  }

  exec{'cobbler_sync':
    command     => 'cobbler sync',
    refreshonly => true,
    require     => [Service['cobblerd'], Package['genisoimage']];
  }

  exec{'cobbler_get_loaders':
    command     => 'cobbler get-loaders',
    creates     => '/var/lib/cobbler/loaders/pxelinux.0',
    require     => Service['cobblerd'];
  }
}
