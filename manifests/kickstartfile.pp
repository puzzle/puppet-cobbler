define cobbler::kickstartfile(){
  case $cobbler_env {
    '': { $cobbler_env = 'cobbler_env_is_not_set' }
  }
  file{"/var/lib/cobbler/kickstarts/${name}":
    source => [ "puppet://$server/files/cobbler/${fqdn}/kickstarts/${name}",
          "puppet://$server/files/cobbler/${cobbler_env}/kickstarts/${name}",
          "puppet://$server/files/cobbler/kickstarts/${name}",
          "puppet://$server/cobbler/kickstarts/${name}" ],
    require => Package[cobbler],
    notify => [ Service[cobblerd], Exec['cobbler_sync'] ],
    owner => root, group => 0, mode => 0644;
  }
}
