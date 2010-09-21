class cobbler::bind::unmanaged::base inherits cobbler::bind::managed::base {
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
