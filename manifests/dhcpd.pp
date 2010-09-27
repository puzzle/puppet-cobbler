# manifests/dhcpd.pp

class cobbler::dhcpd {
  include dhcpd::noreplace

  package{'dhcdbd':
    ensure => installed,
  }
}
