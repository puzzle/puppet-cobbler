class cobbler::dhcpd::base inherits dhcpd::base {
  File['/etc/dhcpd.conf']{
    replace => false,
  }
}
