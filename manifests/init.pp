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

# modules_dir { \"cobbler\": }

class cobbler {

    # include other modules needed
    include dhcpd 
    include tftp
    include apache
    
    include cobbler::base
}

class cobbler::base {
    package{'cobbler':
        ensure => present,
    }
    service{cobblerd:
        ensure => running,
        enable => true,
        hasstatus => true,
        require => Package[cobbler],
    }

    file{'/etc/cron.daily/cobbler_reposync':
        source => "puppet://$server/cobbler/cron/cobbler_reposync",
        owner => root, group => 0, mode => 0644;
    }
}
