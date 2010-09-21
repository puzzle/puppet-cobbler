define cobbler::etcconfig(){
  case $cobbler_env {
    '': { $cobbler_env = 'cobbler_env_is_not_set' }
  }

  file{"/etc/cobbler/${name}":
    source => [ "puppet:///modules/site-cobbler/${fqdn}/etc/${name}",
                "puppet:///modules/site-cobbler/${cobbler_env}/etc/${name}",
                "puppet:///modules/site-cobbler/etc/${name}",
                "puppet:///modules/cobbler/etc/${name}" ],
    require => Package[cobbler],
    notify => [ Service[cobblerd], Exec['cobbler_sync'] ],
    owner => root, group => 0, mode => 0644;
  }
}


