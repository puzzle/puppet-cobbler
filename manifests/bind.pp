# manifests/bind.pp

class bind::cobbler inherits bind {
    include bind::base::cobbler
}

class bind::base::cobbler inherits bind::base {
    Service['bind']{
        ensure => stopped,
        enable => false,
    }
}
