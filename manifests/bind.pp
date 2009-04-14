# manifests/bind.pp

class bind::cobbler inherits bind {
    include bind::base::cobbler
}

class bind::base::cobbler inherits bind::base {
    Service['bind']{
        ensure => stopped,
        enable => false,
    }

    File['named.conf', 'named.local']{
        source => undef,
    }
    File['zone_files']{
        ensure => directory,
        source => undef,
        force => false,
        purge => false,
        recurse => false,
    }
}
