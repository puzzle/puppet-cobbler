# manifests/dhcpd.pp

class cobbler::dhcpd inherits dhcpd {
  include cobbler::dhcpd::base

  package{'dhcdbd':
    ensure => installed,
  }
}
