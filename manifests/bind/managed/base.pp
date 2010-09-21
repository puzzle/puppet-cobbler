class cobbler::bind::managed::base inherits bind::base {
  File['named.conf']{
    source => undef,
  }
}
