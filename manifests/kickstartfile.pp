define cobbler::kickstartfile(){
  case $cobbler_env {
    '': { $cobbler_env = 'cobbler_env_is_not_set' }
  }
  file{"/var/lib/cobbler/kickstarts/${name}":
    source => [ "puppet:///modules/site-cobbler/${fqdn}/kickstarts/${name}",
                "puppet:///modules/site-cobbler/${cobbler_env}/kickstarts/${name}",
                "puppet:///modules/site-cobbler/kickstarts/${name}",
                "puppet:///modules/cobbler/kickstarts/${name}" ],
    require => Package[cobbler],
    notify => [ Service[cobblerd], Exec['cobbler_sync'] ],
    owner => root, group => 0, mode => 0644;
  }
}
