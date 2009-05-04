# manifests/bind.pp

class bind::cobbler::managed inherits bind {
    include bind::base::cobbler::managed
}

class bind::cobbler::unmanaged inherits bind::cobbler::managed {
    include bind::base::cobbler::unmanaged
}

class bind::base::cobbler::managed inherits bind::base {
    File['named.conf']{
        source => undef,
    }
}

class bind::base::cobbler::unmanaged inherits bind::base::cobbler::managed {
    Service['bind']{
        ensure => stopped,
        enable => false,
    }
    File['zone_files']{
        ensure => directory,
        source => undef,
        force => false,
        purge => false,
        recurse => false,
    }
}
