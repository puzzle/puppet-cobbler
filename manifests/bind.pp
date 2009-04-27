# manifests/bind.pp

class bind::cobbler::unmanaged inherits bind {
    include bind::base::cobbler::unmanaged
}

class bind::base::cobbler::unmanaged inherits bind::base {
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

