# manifests/dhcpd.pp

class dhcpd::cobbler inherits dhcpd {
    include dhcpd::base::cobbler

    package{'dhcdbd':
        ensure => installed,
    }
}

class dhcpd::base::cobbler inherits dhcpd::base {
    File['/etc/dhcpd.conf']{
        replace => false,
    }
}
