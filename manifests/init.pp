#
# cobbler module
#
# Copyright 2008, Puzzle ITC
# Marcel Härry haerry+puppet(at)puzzle.ch
# Simon Josi josi+puppet(at)puzzle.ch
#
# This program is free software; you can redistribute
# it and/or modify it under the terms of the GNU
# General Public License version 3 as published by
# the Free Software Foundation.
#
#
# Variables to set:
# - $cobbler_auth_conf_pwd => your password to the auth_config

class cobbler {
  # include other modules needed
  include cobbler::dhcpd
  include cobbler::bind::managed
  include tftp
  include apache

  include cobbler::base
}

