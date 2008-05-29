# manifests/dhcpd.pp

class dhcpd::dhcpd inherits dhcpd {
    include dhcpd::base::cobbler
}

class dhcpd::base::cobbler inherits dhcpd::base {
    File['/etc/dhcpd.conf']{
        replace => false,
    }
}
