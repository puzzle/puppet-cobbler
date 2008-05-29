# manifests/dhcpd.pp

class cobbler::dhcpd inherits dhcpd {
    include cobbler::dhcpd::base
}

class cobbler::dhcpd::base inherits dhcpd::base {
    File['/etc/dhcpd.conf']{
        replace => false,
    }
}
