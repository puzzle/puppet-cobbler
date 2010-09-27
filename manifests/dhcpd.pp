# manifests/dhcpd.pp

class cobbler::dhcpd {
  include dhcp::noreplace

  package{'dhcdbd':
    ensure => installed,
  }
}
